#!/usr/bin/env python3
"""Run the production dispatch-group source and XCTest tests without iOS/LoopKit.

Only Foundation is prepended (the Xcode target supplies it via its prefix header).
No production behavior is substituted. Build and run have process-level bounds
in addition to the regression's semaphore timeout. Requires Swift and Python 3.
"""
import pathlib
import subprocess
import sys
import tempfile

root = pathlib.Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix="eversense-dispatch-tests-") as directory:
    package = pathlib.Path(directory)
    sources = package / "Sources" / "DispatchGroupSubject"
    tests = package / "Tests" / "DispatchGroupSubjectTests"
    sources.mkdir(parents=True)
    tests.mkdir(parents=True)
    (package / "Package.swift").write_text('''// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "DispatchGroupRegression",
    targets: [
        .target(name: "DispatchGroupSubject"),
        .testTarget(name: "DispatchGroupSubjectTests",
                    dependencies: ["DispatchGroupSubject"],
                    swiftSettings: [.define("DISPATCH_GROUP_STANDALONE")])
    ])
''')
    (sources / "EversenseKitDispatchGroup.swift").write_text(
        "import Foundation\n" +
        (root / "Common/EversenseKitDispatchGroup.swift").read_text())
    (tests / "DispatchGroupLifecycleTests.swift").write_text(
        (root / "EversenseKitTests/DispatchGroupLifecycleTests.swift").read_text())
    try:
        subprocess.run(["swift", "build", "--build-tests", "--package-path", directory],
                       check=True, timeout=180)
        result = subprocess.run(["swift", "test", "--skip-build", "--package-path", directory],
                                timeout=30)
        sys.exit(result.returncode)
    except subprocess.TimeoutExpired as error:
        print(f"FAIL: process exceeded {error.timeout}s timeout", file=sys.stderr)
        sys.exit(124)
    except subprocess.CalledProcessError as error:
        sys.exit(error.returncode)
