# Repository Guidelines

## Project Structure & Module Organization

This repository is a HarmonyOS / ArkTS Sokoban game. The `entry` module holds the app code and resources:

- `entry/src/main/ets/pages/Index.ets`: main UI, game flow, audio, and save handling.
- `entry/src/main/ets/data/SnailLevels.ets`: level metadata and maps.
- `entry/src/main/ets/utils/`: game logic and keyboard mapping helpers.
- `entry/src/main/ets/theme/VisualTheme.ets`: shared visual constants.
- `entry/src/main/resources/base/media/`: image assets used by the app.
- `entry/src/main/resources/rawfile/`: music and sound effects.
- `entry/src/test/`: local Hypium unit tests.
- `entry/src/ohosTest/`: device or ability tests.
- `doc/screenshots/`: README and release screenshots.

Avoid editing generated output in `build/`, `entry/build/`, `node_modules/`, and `oh_modules/`.

## Build, Test, and Development Commands

- Open the repository root in DevEco Studio, select `entry`, then run on a simulator or device.
- `hvigor assembleApp`: build/package the full app from the command line when the HarmonyOS SDK and hvigor CLI are configured.
- Use DevEco Studio's test runner for `entry/src/test` local tests and `entry/src/ohosTest` device tests.
- `python3 scripts/md_to_docx.py`: convert markdown documents when updating presentation or report material.

## Coding Style & Naming Conventions

Use existing ArkTS conventions: two-space indentation, typed interfaces, `PascalCase` for classes/interfaces/components, `camelCase` for functions and variables, and uppercase constants only for stable keys such as `SAVE_KEY`. Keep UI styling centralized in `VisualTheme.ets` instead of scattering colors and sizes through pages. Follow `code-linter.json5`, which applies recommended performance and TypeScript rules to `*.ets` files.

## Testing Guidelines

Tests use `@ohos/hypium`. Add local unit tests under `entry/src/test`, with files named `*.test.ets`, and keep game-rule coverage close to `SokobanLogic` and `KeyboardMapping`. Update tests when changing level parsing, movement rules, keyboard controls, save behavior, or level data. Use device tests for ability or runtime behavior.

## Commit & Pull Request Guidelines

Recent history mixes English conventional-style commits, such as `docs: document responsive layout and game cache`, with short Chinese summaries. Prefer `type: short summary` (`fix:`, `docs:`, `chore:`, `feat:`), and keep the subject specific. Pull requests should include a description, test/build results, linked issues when applicable, and screenshots for UI or asset changes.

## Agent-Specific Instructions

Do not overwrite user assets or screenshots without confirming intent. When editing UI, check responsive behavior for compact and wide layouts, and keep the README screenshots and asset documentation in sync when visible behavior changes.
