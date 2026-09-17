# Maintenance architecture

The editable entry point is `source/HamamatsuImagingApp.m`. `build_mlapp.m`
generates `HamamatsuImagingApp.mlapp`; the package directory `+zoulab` remains a
runtime dependency. Edit source files, run the relevant offline tests, rebuild,
then launch the generated app in a fresh MATLAB process in Simulation Mode.

## Where to make a change

| Responsibility | Location | Boundary |
| --- | --- | --- |
| User settings MAT file, legacy timing/light migration, shared parsing | `+zoulab/UserSettings.m` | Plain values, folder and profile inputs; no UI or hardware ownership |
| User identity and preset selection | `+zoulab/VisualPresetManager.m` | Existing public settings methods delegate to `UserSettings`; active-user guard remains here |
| Module methods and rig wiring | `+zoulab/ModuleMethodManager.m`, `+zoulab/RigWiringConfig.m` | Existing schemas and authoritative wiring remain unchanged |
| Capture/conversion/close lifecycle and acquisition control availability | `+zoulab/AcquisitionState.m` | One shared handle instance per App; no mirrored lifecycle flags in the App |
| Start/stop, cycle scheduling, task cleanup and acquisition manifest | `+zoulab/AcquisitionCoordinator.m` | State, logger, session/camera/DAQ services and explicitly named callback operations |
| Panel construction and event binding | `+zoulab/+ui/*.m` | Parent graphics container, necessary initial display values and explicit callbacks |
| UI-to-experiment adaptation, plan preparation, per-cycle capture backends | `source/HamamatsuImagingApp.m` | Coordinates existing services and presents feedback; these are still areas for later incremental extraction |
| Camera ownership, preview mailbox, BIN writing, TIFF conversion, alignment | Existing `CameraService*`, `PreviewSharedBuffer`, `BufferedBinRecorder`, `ParallelTiffConverter`, `VisualFrameAlignment`, etc. | Hardware/process ownership and numerical/timing algorithms unchanged |

## State and operation order

Capture normally reports `PREPARING`, then `RUNNING`, optionally `WAITING` between cycles and
`FLUSHING` while draining, then a result (`COMPLETED`, `COMPLETED_WITH_WARNINGS`,
`STOPPED`, or `ERROR`). A stop request sets the shared stop flag and reports
`STOPPING`; the existing acquisition path preserves data and finishes cleanup.
Subsequent result/status updates retain the pre-refactor ordering.

Conversion is independent of capture ownership: it can be submitted while
capture cleanup is still running. `finishCapture` therefore does not clear
`ConversionRunning`. Conversion blocks a new acquisition while allowing the
existing preview/setup workflow. Terminal status can be reported before final
resource cleanup, so `Status` alone must never be used to infer that resources
are free. `beginCapture` resets stop requests and cycle history at the original
post-preflight boundary, preserving the frozen plan.

Start guards remain in `AcquisitionCoordinator.startAcquisition`: reject an
already-running capture, an active TIFF conversion or standalone visual
playback before preparing a new experiment. No additional transition rejection
rules or automatic retries were introduced. The state class centralizes writes
and the existing control policy; it does not silently redefine valid workflows.

For Record, `PREPARING` allocates every Cycle folder and reserves all planned
segments as `Rec_###.bin.part`, then asks the persistent camera service to start
its per-camera writer tasks. Only after those steps succeed does the coordinator
start the Cycle scheduling clock. A finished writer truncates and verifies the
current segment before publishing it as `Rec_###.bin`; untouched future `.part`
files are removed on stop/failure. All Cycles reuse the one frozen DAQ matrix and
the same writer tasks. Never move allocation, DAQ compilation or writer creation
back into the timed Cycle body.

Post-processing runs in a background batch job. Visual BIN crop work is parallel
by Cycle so the two cameras in one Cycle retain their transactional all-or-none
commit. TIFF work is parallel by Cycle-camera output. Both paths are limited by
the configured eight-worker and memory budget, and a running post-processing job
continues to block a new Record.

Safe Exit retains its existing confirmation and stop/cleanup/close sequence.
The window X retains its existing immediate force-close path. These two paths
remain distinct. A future change to this behavior requires its own review.

## Callback boundary

The coordinator receives individually named operations such as
`freezeAcquisitionPlan`, `runRecordCycle`, `setAcquisitionState` and
`writeCycleManifest`. This allows tests to supply a failing recorder or a stop
request without creating UI controls or using real devices. Do not replace this
interface with an entire App reference or a generic method-name dispatcher.

Panel classes hold their own graphics handles and construct their event
bindings. The App retains aliases to those same graphics handles so existing
callbacks continue to work; there is no second copy of control values. Panel
construction is followed by the existing initialization/refresh calls after
the App has received the handles. Panel constructors do not connect hardware.
Business operations invoked by those callbacks remain in the App or existing
controllers; this refactor does not claim to have extracted every callback.

## Compatibility constraints

- Keep existing MAT fields, schema versions, unknown settings fields, active-user
  attribution, deferred-save conditions and save filenames.
- Keep signed timing-field precedence, legacy lead conversion and old fallback
  values. Keep light-table matching by hardware ID, old mW-to-percent conversion,
  clamping and forced-OFF restoration. Do not infer new physical wiring.
- Preserve exposure/ROI/binning semantics, trigger command order, cycle interval
  semantics, alignment/cropping rules, raw uint16 orientation, BIN/TIFF policies,
  file naming and manifest/log event contents.
- Preserve labels, tags, grid layout, numeric limits and initial values when
  moving panel code. Layout redesign is separate work.

## Verification

New focused tests: `TestUserSettings`, `TestAcquisitionState`, and
`TestAcquisitionCoordinator`. Existing `TestHamamatsuImagingApp` tests exercise
the same UI callback paths after extraction. The full `tests` suite includes
offline/simulated camera-service, recorder and processing tests.

Results and the pre-refactor backup are in
`reports/maintenance_refactor_20260907/`. No real-hardware timing validation is
implied by passing offline tests. On the rig, validate a short record and stop
path before a long experiment.

## R2024b preview update (2026-09-14)

The production camera client selects this rig's tested adaptor at
`%APPDATA%/MathWorks/MATLAB Add-Ons/Toolboxes/Hamamatsu Image Acquisition/hamamatsu.dll`
(validated file version `2.3.2300.15`). Only the camera-owning child loads IAT;
the App constructor selects the path without connecting hardware. The child
removes conflicting same-name registrations before loading the selected DLL.
A missing selected DLL is an explicit error, not an automatic switch to another
installed version. This is a rig-specific selection, not a claim that newer
adaptors are incompatible with R2024b on all machines.

The remote preview timer uses `fixedSpacing` with a 1 ms yield after each
completed callback, rather than adding 17 ms after rendering. The existing
60 Hz display cap remains. Both cameras' CData updates share one
`drawnow nocallbacks`; transport remains a latest-frame memory map containing
full-resolution uint16 pixels. The camera child still limits publication to
30 Hz for full-sensor images and 60 Hz for smaller images. Per-frame timestamp
formatting is unchanged; the diagnostic timestamp shortcut is not enabled in
the App. Recording frames, triggers, and saved pixel data are unchanged.

中文说明：这次修改仅减少预览回调结束后的等待，不承诺每一时刻均达到
30 Hz，也不把诊断程序的帧率当作正式 APP 的实测帧率。R2024b 的既有诊断
没有复现持续的大幅内存增长，但短时测试不能证明无限期运行没有泄漏。
本次交付仅运行模拟预览检查与离线构建，未连接相机或其他硬件。
构建日志和更新前的 MLAPP 备份保存在
`reports/preview_offline_update_20260914/`。
