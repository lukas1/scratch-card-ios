#!/bin/bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
result_directory="$(mktemp -d "${TMPDIR:-/tmp}/scratch-card-coverage.XXXXXX")"
result_bundle="${result_directory}/TestResults.xcresult"

xcodebuild test \
    -quiet \
    -enableCodeCoverage YES \
    -parallel-testing-enabled NO \
    -resultBundlePath "${result_bundle}" \
    -project "${repo_root}/Scratch Card.xcodeproj" \
    -scheme "Scratch Card" \
    -destination "platform=iOS Simulator,name=iPhone 17"

swift "${repo_root}/scripts/check-coverage.swift" "${result_bundle}"
echo "Coverage results: ${result_bundle}"
