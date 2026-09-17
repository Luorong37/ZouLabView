# ZouLabView

ZouLabView is a MATLAB App Designer application for laboratory imaging with
Hamamatsu cameras, NI-DAQ timing, illumination, visual stimulation, DMD
control, and reproducible binary acquisition storage.

The repository intentionally contains **source code and a generic wiring
template only**. It does not contain any laboratory's device identities,
ports, network addresses, users, logs, recordings, tests, or diagnostic data.

## First-time setup

1. Install MATLAB and the required Image Acquisition, Data Acquisition, and
   Psychtoolbox dependencies for your instrument.
2. Copy `config/rig_wiring.example.json` to `config/rig_wiring.json`.
3. Edit only the new `rig_wiring.json` with your verified camera identities,
   DAQ lines, serial ports, and DMD network endpoints. This file is ignored by
   Git and remains local to the workstation.
4. In MATLAB, open the repository root and run:

   ```matlab
   addpath(pwd)
   addpath(fullfile(pwd, 'source'), '-begin')
   app = HamamatsuImagingApp;
   ```

5. To generate an App Designer file locally, run `build_mlapp`. The generated
   `HamamatsuImagingApp.mlapp` is intentionally not versioned; the reviewed
   source in `source/HamamatsuImagingApp.m` is canonical.

## Repository structure

- `source/` — main App Designer source.
- `+zoulab/` — camera, DAQ, light, DMD, preview, recording, and persistence
  components.
- `config/rig_wiring.example.json` — safe configuration template.
- `assets/`, `vendor/`, `tools/` — required DMD assets and vendor integration.
- `docs/` — bilingual user/developer manual and architecture notes.

Read [the bilingual manual](docs/HAMAMATSU_IMAGING_APP_MANUAL_BILINGUAL.md)
before connecting real hardware.
