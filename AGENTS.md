# Project guide

- This is a SwiftUI iOS app generated with Tuist. Edit `Project.swift` and source files; do not hand-edit generated Xcode project files.
- Keep screen code under `Scratch Card/Features/<Feature>`, shared UI and app infrastructure in their existing shared folders, and card state or behavior in the card model/repository.
- Use `Scratch Card/Core` for app-wide infrastructure that multiple features depend on, such as dependency injection protocols, shared composition, factories, and SwiftUI environment access. Keep feature-specific modules, models, repositories, and UI in that feature's folder; add a Core abstraction only when it is genuinely shared.
- Keep user-visible text in `Scratch Card/Resources/Localizable.xcstrings`.
- Name tests `GIVEN <precondition> WHEN <action> THEN <outcome>`. Omit a section when it is trivial, but always state the `THEN` outcome. See `Scratch CardTests/ActivationScreenTests.swift`.
- Use the pinned Tuist version from `.mise.toml`. Generate with `tuist generate`; run tests with `xcodebuild test -project 'Scratch Card.xcodeproj' -scheme 'Scratch Card' -destination 'platform=iOS Simulator,name=iPhone 17'`.
