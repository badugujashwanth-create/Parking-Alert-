# Recording guide

## Preparation

1. Install dependencies using docs/DEVELOPMENT.md.
2. Copy example environment files and use only local or synthetic values.
3. Start the demo with scripts/run-demo.ps1 or the component-specific command.
4. Confirm the complete workflow manually before recording.
5. Close notifications, unrelated applications, password managers, and personal browser profiles.

## Record

For a web-capable build, run `scripts/record-demo.ps1` with the healthy local `BaseUrl`. The Playwright specification waits for Flutter's rendered canvas, enables accessibility semantics, captures the overview and thumbnail, and records the scripted workflow at 1280×720.

## Post-production

Do not splice in fake success states. Mux the narration into MP4 and WebM, keep `demo-captions.vtt` beside both formats, and verify duration, codecs, dimensions, audio level, representative frames, and SHA-256 checksums. Commit only the final deliverables; discard the raw WAV and Playwright capture.

