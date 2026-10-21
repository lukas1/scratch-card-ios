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
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
process.arguments = ["xccov", "view", "--report", "--json", resultBundle]

let output = Pipe()
process.standardOutput = output
process.standardError = FileHandle.standardError

do {
    try process.run()
} catch {
    fail("Could not run xccov: \(error.localizedDescription)")
}

let reportData = output.fileHandleForReading.readDataToEndOfFile()
process.waitUntilExit()

guard process.terminationStatus == 0 else {
    fail("xccov failed with exit code \(process.terminationStatus).")
}

let report: [String: Any]
do {
    guard let decoded = try JSONSerialization.jsonObject(with: reportData) as? [String: Any] else {
        fail("Coverage report has an unexpected format.")
    }
    report = decoded
} catch {
    fail("Could not decode coverage report: \(error.localizedDescription)")
}

guard
    let targets = report["targets"] as? [[String: Any]],
    let appTarget = targets.first(where: { $0["name"] as? String == "Scratch_Card.app" }),
    let coveredLines = appTarget["coveredLines"] as? Int,
    let executableLines = appTarget["executableLines"] as? Int,
    let files = appTarget["files"] as? [[String: Any]]
else {
    fail("Could not find Scratch_Card.app coverage in the report.")
}

let percentage = executableLines == 0 ? 0 : Double(coveredLines) / Double(executableLines) * 100
print(String(format: "App code coverage: %.2f%% (%d/%d executable lines)", percentage, coveredLines, executableLines))

let minimumCoveragePercentage = 96.0
guard percentage >= minimumCoveragePercentage else {
    fputs("App code coverage must be at least 96%. Uncovered files:\n", stderr)
    for file in files where (file["coveredLines"] as? Int ?? 0) < (file["executableLines"] as? Int ?? 0) {
        let name = file["path"] as? String ?? "Unknown source file"
        let covered = file["coveredLines"] as? Int ?? 0
        let executable = file["executableLines"] as? Int ?? 0
        let filePercentage = executable == 0 ? 0 : Double(covered) / Double(executable) * 100
        fputs(String(format: "  %.2f%% (%d/%d): %@\n", filePercentage, covered, executable, name), stderr)
    }
    exit(EXIT_FAILURE)
}
