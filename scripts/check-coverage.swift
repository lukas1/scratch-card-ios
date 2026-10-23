#!/usr/bin/env swift

import Darwin
import Foundation

func fail(_ message: String) -> Never {
    fputs("\(message)\n", stderr)
    exit(EXIT_FAILURE)
}

guard CommandLine.arguments.count == 2 else {
    fail("Usage: check-coverage.swift <test-results.xcresult>")
}

let resultBundle = CommandLine.arguments[1]
func xccovJSON(_ view: String) -> [String: Any] {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
    process.arguments = ["xccov", "view", view, "--json", resultBundle]

    let output = Pipe()
    process.standardOutput = output
    process.standardError = FileHandle.standardError

    do {
        try process.run()
    } catch {
        fail("Could not run xccov: \(error.localizedDescription)")
    }

    let data = output.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()

    guard process.terminationStatus == 0 else {
        fail("xccov \(view) failed with exit code \(process.terminationStatus).")
    }

    do {
        guard let decoded = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            fail("Coverage \(view) has an unexpected format.")
        }
        return decoded
    } catch {
        fail("Could not decode coverage \(view): \(error.localizedDescription)")
    }
}

let report = xccovJSON("--report")
guard
    let targets = report["targets"] as? [[String: Any]],
    let appTarget = targets.first(where: { $0["name"] as? String == "Scratch_Card.app" }),
    let unitTestTarget = targets.first(where: { $0["name"] as? String == "Scratch_CardTests.xctest" }),
    let appTargetFiles = appTarget["files"] as? [[String: Any]],
    let unitTestTargetFiles = unitTestTarget["files"] as? [[String: Any]]
else {
    fail("Could not find Scratch_Card.app and Scratch_CardTests.xctest coverage in the report.")
}

let repoRoot = URL(fileURLWithPath: CommandLine.arguments[0])
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .standardizedFileURL
let appSourceDirectory = repoRoot.appendingPathComponent("Scratch Card", isDirectory: true)
let appSourcePrefix = appSourceDirectory.path + "/"
let appEntryPoint = appSourceDirectory.appendingPathComponent("Scratch_CardApp.swift").path

func appSourceFiles(from targetFiles: [[String: Any]]) -> Set<String> {
    var paths = Set<String>()
    for file in targetFiles {
        guard
            let path = file["path"] as? String,
            path.hasPrefix(appSourcePrefix),
            path.hasSuffix(".swift")
        else {
            continue
        }
        guard paths.insert(path).inserted else {
            fail("Duplicate app source in coverage report: \(path)")
        }
    }
    return paths
}

let appFiles = appSourceFiles(from: appTargetFiles)
let unitFiles = appSourceFiles(from: unitTestTargetFiles)
guard appFiles.contains(appEntryPoint) else {
    fail("Could not find Scratch_CardApp.swift coverage in Scratch_Card.app.")
}
let expectedUnitFiles = appFiles.subtracting([appEntryPoint])
guard unitFiles == expectedUnitFiles else {
    let missing = expectedUnitFiles.subtracting(unitFiles).sorted()
    let unexpected = unitFiles.subtracting(expectedUnitFiles).sorted()
    fail("Hostless unit-test coverage does not match app sources. Missing: \(missing); unexpected: \(unexpected)")
}

let archive = xccovJSON("--archive")
var coveredLines = 0
var executableLines = 0
var uncoveredFiles: [(path: String, covered: Int, executable: Int)] = []

for path in appFiles.sorted() {
    guard let lines = archive[path] as? [[String: Any]] else {
        fail("Could not find app source in coverage archive: \(path)")
    }

    // The archive is indexed by source path. Count each executable source line once,
    // including lines compiled into both the app and the hostless unit-test target.
    var executionsByLine: [Int: Bool] = [:]
    for line in lines {
        guard let number = line["line"] as? Int, number > 0,
              let isExecutable = line["isExecutable"] as? Bool else {
            fail("Invalid line coverage in \(path): \(line)")
        }
        guard isExecutable else { continue }
        guard let count = line["executionCount"] as? Int, count >= 0 else {
            fail("Invalid execution count for \(path):\(number)")
        }
        executionsByLine[number] = (executionsByLine[number] ?? false) || count > 0
    }

    let fileCovered = executionsByLine.values.filter { $0 }.count
    let fileExecutable = executionsByLine.count
    coveredLines += fileCovered
    executableLines += fileExecutable
    if fileCovered < fileExecutable {
        uncoveredFiles.append((path, fileCovered, fileExecutable))
    }
}

guard executableLines > 0 else {
    fail("Coverage archive contains no executable app source lines.")
}

let percentage = Double(coveredLines) / Double(executableLines) * 100
print(String(format: "App code coverage: %.2f%% (%d/%d executable source lines)", percentage, coveredLines, executableLines))

let minimumCoveragePercentage = 99.0
guard percentage >= minimumCoveragePercentage else {
    fputs("App code coverage must be at least 99%. Uncovered files:\n", stderr)
    for file in uncoveredFiles {
        let filePercentage = Double(file.covered) / Double(file.executable) * 100
        fputs(String(format: "  %.2f%% (%d/%d): %@\n", filePercentage, file.covered, file.executable, file.path), stderr)
    }
    exit(EXIT_FAILURE)
}
