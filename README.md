# Scratch Card iOS

The Xcode project is generated from [Project.swift](Project.swift) with Tuist. Commit changes to the manifest and source files; generated `.xcodeproj` and `.xcworkspace` files are ignored.

## Generate and open the project

Install [mise](https://mise.jdx.dev/), then run:

```sh
mise install
tuist generate
```

Open `Scratch Card.xcodeproj` in Xcode. The Tuist version is pinned in `.mise.toml` so everyone generates the project with the same version.

SwiftLint is integrated through Swift Package Manager for the **Scratch Card** app target. Xcode downloads the SwiftLint binary during package resolution, and the app build runs it automatically; no separate SwiftLint installation is needed. The first package resolution requires network access. The lint scope is the app source folder, configured in `.swiftlint.yml`.

To edit `Project.swift` or `Tuist.swift` in Xcode with code completion, run `tuist edit`. Run `tuist generate` again after changing a manifest.

To run both unit and UI tests with the 99% app coverage gate, run:

```sh
./scripts/test-with-coverage.sh
```

The scheme's Test action uses the `Coverage` build configuration, which compiles out SwiftUI previews marked with `#if !CODE_COVERAGE`. The Swift script counts distinct executable app source lines in the coverage archive and exits unsuccessfully if coverage is below 99%. Running tests directly in Xcode or with `xcodebuild test` does not enforce the threshold.

# Original Assignment

Create an iOS application in Swift (minimum iOS version is at your discretion, libraries are allowed, framework choices - if any - are 
up to you as well). The application should model a scratch card and its usage. The scratch card is initially unscratched, then gets 
scratched (revealing the code), and subsequently needs to be activated (i.e. 3 states).

## The UI should be as follows:

On the main screen, always display
1. the current state of the scratch card,
2. a button that navigates to the scratch screen,
3. a button that navigates to the activation screen.

On the scratch screen, there should be a button whose click changes the state of the card to scratched. Scratching off the card means to 
reveal a code (just generate a random UUID). Let's pretend this is a heavy operation and takes 2 seconds. The operation should be 
cancelled if the user closes the screen (back button) and the operation has not yet successfully completed. On the activation screen, 
there should be a button whose click activates the scratch card. Activation means sending the revealed code to an API.

## Definition of the service:
```
url "https://api.o2.sk/version",

parameter "code",

method "GET",

no authentication,

example response: { "ios": "6.24" }
```

If the value of "ios" is greater than `6.1`, then the card in the app changes to an activated state, otherwise, an error modal should be 
displayed. If the user closes the screen during this operation, the operation should not be cancelled. Critical parts of the application 
should be covered by unit tests.

Publish the source code on github.com or a similar service, and send us the URL to the repository.

## Solution notes

The project does not aim at 100% line code coverage, only 99%. There are some scenarios, that while could be tested, are too contrived to justify
test complexity created just to artificially claim 100% line code coverage. 99% is still extremely high number.
