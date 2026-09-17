# Persistent camera service

The real-hardware app lazily starts one hidden child MATLAB after an
identity-confirmed camera action. That child owns both Hamamatsu
`videoinput` objects until Safe Exit. Preview, Snap, Time Lapse, Record and
visual-stimulus Record reuse that service; camera ownership is not handed
back to the UI MATLAB between operations.

```text
Main MATLAB / App UI
  - operator actions and UI rendering
  - PTB visual stimulus and DAQ timestamps
  - DAQ, light source and DMD coordination
          |
          | localhost TCP: small JSON commands and status only
          v
Persistent child MATLAB
  - both videoinput objects and IAT buffers
  - latest-preview publication
  - 64-frame IAT drains and per-camera BIN writer workers
          |
          +-- memory-mapped two-slot mailbox: full uint16 preview pixels
          +-- BIN + info JSON: record data
```

## Preview contract

- Pixel arrays do not travel over TCP. A two-slot memory-mapped mailbox holds
  only the newest complete `uint16` frame, so a delayed UI cannot build a
  preview queue. The global header, two fixed-size slot headers and two
  fixed-shape `[height,width] uint16` frame regions are mapped separately;
  publishing no longer creates a flattened byte-index vector proportional to
  the full frame size.
- The service publishes at no more than 60 FPS. If either ROI dimension is
  2304 pixels, it publishes at no more than 30 FPS.
- Frames are not spatially downsampled. Camera 1 display transpose remains a
  UI-only operation; raw preview and saved arrays retain camera orientation.
- `Stream` FPS uses the camera `FramesAcquired` counter carried with the
  latest preview frame. `View` FPS is the rate actually received by the UI.
- A blocking callback in the main MATLAB can temporarily pause screen
  repainting, but camera acquisition continues in the child and the UI
  resumes from the newest frame rather than replaying a backlog.
- If the child exits unexpectedly, the client closes stale preview mappings,
  clears camera connection state and logs the exit. The next explicit Preview
  action launches a fresh child and reconnects; there is no automatic hardware
  reconnect without a user action.

## Record and PTB contract

- The child continuously drains IAT to bounded per-camera writer queues.
- During a PTB flip loop, the main process performs no TCP polling and no
  writer polling. The flip callback only writes the required DAQ visual-frame
  stamp. Camera draining and BIN writing continue in the child process.
- Record is saved as headerless uint16 BIN with an info JSON per segment.
  Optional TIFF conversion does not run between cycles: it begins only after
  every Record cycle has finished capturing. A background batch coordinator
  uses a process pool and converts independent cycle-camera units in parallel;
  each worker exclusively owns one output TIFF. The worker count is capped at
  eight and further limited by core count, unit count, and available physical
  memory. The UI polls small progress JSON files, so TIFF work and ETA updates
  do not block the app event loop. After one unit's TIFF frame count and files
  verify, only that unit's source BIN segments are deleted. Disk preflight uses
  all BIN bytes plus the sum of up to N simultaneously active TIFF units, where
  N is the estimated worker count, followed by a 10% safety margin. Snap and
  Time Lapse points remain direct TIFF captures.
- Each worker reads BIN in bounded `fread` chunks (256 MiB target). A local
  four-repeat 512x512x256 benchmark measured 396.0 MiB/s for `fread` and
  160.4 MiB/s for `memmapfile`, so memory mapping is retained only as a
  diagnostic option and is not the app default.
- Visual Record keeps the full camera window during acquisition, then applies
  DAQ-counter alignment and physically crops the BIN head/tail after writers
  close. Invalid alignment preserves the original BIN and records an error.
- An open-ended visual Record is not unlimited. `MARK_RECORD_STARTED` resets
  an independent child-process clock; at the frozen camera-window duration
  plus a one-second guard, the child stops `videoinput` while preserving IAT
  frames for later drain. This deadline still works while the main MATLAB is
  blocked reading DAQ data or flushing UI events.
- Imaging-light tail timing completes and owned illumination is switched OFF
  before DAQ bulk read, IAT drain, BIN close, alignment, or TIFF conversion.
- A writer error aborts the drain immediately, stops both cameras and resets
  the service Record state. It cannot leave a 300-second queue wait behind.

## Cycle and segment storage contract

Each acquisition Cycle owns an independent namespace. Camera data are stored
as follows:

```text
Record/
  Cycle1/
    Cam1_<label>/Rec_001.bin
                 Rec_001.info.json
                 Rec_002.bin          # only if Cycle1 exceeds one segment
                 Rec_002.info.json
    Cam2_<label>/Rec_001.bin
                 Rec_001.info.json
  Cycle2/
    Cam1_<label>/Rec_001.bin           # numbering restarts for Cycle2
                 Rec_001.info.json
```

- A new Cycle always restarts segment numbering at `Rec_001` inside that
  Cycle's camera folder. BIN files from different Cycles are never appended
  to, converted as, or described as one movie.
- The app verifies that every camera folder is a child of the current
  `CycleN` folder. The writer separately refuses to start if that folder
  already contains any `Rec_*.bin` or `Rec_*.info.json`; this fail-closed
  check prevents stale files or a path bug from mixing experiments.
- Planned segments are preallocated before capture. If actual acquisition
  exceeds the planned count, the next file is created in the same Cycle and
  grows by sequential `fwrite`; it is not extended with `fseek` beyond EOF.
- Every BIN segment has exactly one same-basename info JSON. Its `storage`
  object records Cycle index/folder, camera folder, and BIN filename, while
  its frame range remains local to the current Cycle's acquisition.

At visual-synchronization finish, the main log times DAQ `stop`, bulk `read`,
and counter-alignment separately. This distinguishes a driver/session stop
delay from data transfer or MATLAB alignment work without adding work inside
the PTB flip loop.

## Control and shutdown

`127.0.0.1` is the loopback interface of the same computer; this service does
not use the laboratory LAN. TCP carries commands such as Connect, Apply ROI,
Preview, Snap, Record and Safe Exit, plus compact status replies.

The red **Safe Exit** button is the normal, data-preserving shutdown path and
requires confirmation. An active acquisition receives a stop/preserve
request; outputs are made safe, writers close, cameras are released, and the
child confirms shutdown before the UI closes.

The window's upper-right **X** is deliberately a separate emergency path. It
does not show a confirmation dialog. It first commands DAQ, Spectra X and
connected Coherent sources to OFF, signals the child through an out-of-band
shutdown file, and closes the exact child process after a two-second grace
period if it does not acknowledge. Emergency closure prioritizes hardware
safety over completion of the current BIN; partial data may require recovery.
The child also detects loss of its parent MATLAB and performs safe cleanup.

The main log records every user request and service response. The child log,
console log and control artifacts live in the `tmp/camera_service_*` folder;
that exact folder is written to the main `CAMERA_SERVICE_STARTED` log entry.
