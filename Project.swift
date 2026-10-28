import ProjectDescription

private let appName = "Scratch Card"
private let deploymentTargets: DeploymentTargets = .iOS("26.5")

private let commonSettings: SettingsDictionary = [
    "CODE_SIGN_STYLE": "Automatic",
    "CURRENT_PROJECT_VERSION": "1",
    "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
    "GENERATE_INFOPLIST_FILE": "YES",
    "MARKETING_VERSION": "1.0",
    "GCC_TREAT_WARNINGS_AS_ERRORS": "YES",
    "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
    "SWIFT_APPROACHABLE_CONCURRENCY": "YES",
    "SWIFT_TREAT_WARNINGS_AS_ERRORS": "YES",
    "SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY": "YES",
    "SWIFT_VERSION": "5.0",
    "TARGETED_DEVICE_FAMILY": "1,2",
]

private let buildConfigurations: [Configuration] = [
    .debug(name: "Debug"),
    .debug(
        name: "Coverage",
        settings: [
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) CODE_COVERAGE UI_TESTING",
        ]
    ),
    .release(name: "Release"),
]

private func targetSettings(_ overrides: SettingsDictionary) -> Settings {
    .settings(
        base: commonSettings.merging(overrides) { _, new in new },
        configurations: buildConfigurations
    )
}

let project = Project(
    name: appName,
    options: .options(
        automaticSchemesOptions: .disabled,
        disableBundleAccessors: true,
        disableSynthesizedResourceAccessors: true
    ),
    packages: [
        .remote(
            url: "https://github.com/nalexn/ViewInspector",
            requirement: .upToNextMajor(from: "0.10.5")
        ),
        .remote(
            url: "https://github.com/SimplyDanny/SwiftLintPlugins",
            requirement: .upToNextMajor(from: "0.65.1")
        ),
        .remote(
            url: "https://github.com/pointfreeco/swift-clocks",
            requirement: .upToNextMajor(from: "0.4.0")
        ),
    ],
    settings: .settings(
        base: [
            "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "YES",
            "LOCALIZATION_PREFERS_STRING_CATALOGS": "YES",
            "STRING_CATALOG_GENERATE_SYMBOLS": "YES",
        ],
        configurations: buildConfigurations
    ),
    targets: [
        .target(
            name: appName,
            destinations: .iOS,
            product: .app,
            productName: "Scratch_Card",
            bundleId: "com.lukas.vyletel.Scratch-Card",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            buildableFolders: ["Scratch Card"],
            dependencies: [
                .package(product: "Clocks", type: .runtime),
                .package(product: "SwiftLintBuildToolPlugin", type: .plugin),
            ],
            settings: targetSettings([
                "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
                "ENABLE_PREVIEWS": "YES",
                "INFOPLIST_KEY_UIApplicationSceneManifest_Generation": "YES",
                "INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents": "YES",
                "INFOPLIST_KEY_UILaunchScreen_Generation": "YES",
                "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad": "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight",
                "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone": "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight",
                "SWIFT_EMIT_LOC_STRINGS": "YES",
            ])
        ),
        .target(
            name: "Scratch CardTests",
            destinations: .iOS,
            product: .unitTests,
            productName: "Scratch_CardTests",
            bundleId: "com.lukas.vyletel.Scratch-CardTests",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            buildableFolders: [
                .folder("Scratch Card", exceptions: [.exception(excluded: ["Scratch_CardApp.swift"])]),
                "Scratch CardTests",
            ],
            dependencies: [
                .package(product: "Clocks", type: .runtime),
                .package(product: "ViewInspector", type: .runtime),
            ],
            settings: targetSettings([
                "SWIFT_EMIT_LOC_STRINGS": "NO",
            ])
        ),
        .target(
            name: "Scratch CardUITests",
            destinations: .iOS,
            product: .uiTests,
            productName: "Scratch_CardUITests",
            bundleId: "com.lukas.vyletel.Scratch-CardUITests",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            buildableFolders: ["Scratch CardUITests"],
            dependencies: [.target(name: appName)],
            settings: targetSettings([
                "SWIFT_EMIT_LOC_STRINGS": "NO",
                "TEST_TARGET_NAME": .string(appName),
            ])
        ),
    ],
    schemes: [
        .scheme(
            name: appName,
            buildAction: .buildAction(targets: ["Scratch Card", "Scratch CardTests", "Scratch CardUITests"]),
            testAction: .targets(
                ["Scratch CardTests", "Scratch CardUITests"],
                configuration: "Coverage",
                options: .options(coverage: true)
            ),
            runAction: .runAction(executable: .executable(.target(appName))),
            archiveAction: .archiveAction(configuration: .release)
        ),
    ],
    additionalFiles: [
        "README.md",
        "AGENTS.md",
        ".github/dependabot.yml",
        ".github/workflows/dependabot-auto-merge.yml",
        ".github/workflows/tests.yml",
        .folderReference(path: "scripts"),
    ]
)
