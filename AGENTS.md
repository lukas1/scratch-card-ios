# Project guide

- This is a SwiftUI iOS app generated with Tuist. Edit `Project.swift` and source files; do not hand-edit generated Xcode project files.
- Keep screen code under `Scratch Card/Features/<Feature>`, shared UI and app infrastructure in their existing shared folders, and card state or behavior in the card model/repository.
- Use `Scratch Card/Core` for app-wide infrastructure that multiple features depend on, such as dependency injection protocols, shared composition, factories, and SwiftUI environment access. Keep feature-specific modules, models, repositories, and UI in that feature's folder; add a Core abstraction only when it is genuinely shared.
- Keep user-visible text in `Scratch Card/Resources/Localizable.xcstrings`.
- Name tests `GIVEN <precondition> WHEN <action> THEN <outcome>`. Omit a section when it is trivial, but always state the `THEN` outcome. See `Scratch CardTests/Features/Activation/View/ActivationSheetTests.swift`.
- Use the pinned Tuist version from `.mise.toml` and generate with `tuist generate`.
- After changing application code, run `./scripts/test-with-coverage.sh`. It runs unit and UI tests with the `Coverage` configuration and fails if app code coverage is below 99%; SwiftUI previews are excluded from that build by `#if !CODE_COVERAGE`.
- Direct `xcodebuild test` runs the tests but does not enforce the coverage threshold.
