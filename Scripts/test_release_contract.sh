#!/bin/bash

set -euo pipefail

fail() {
    echo "FAIL: $1" >&2
    exit 1
}

rg -q 'GitHubReleaseManager\.Config\(user: "Sequel-PAce"' Source/Other/Extensions/BundleExtension.swift \
    || fail "direct builds must check Sequel PAce releases"

! rg -q 'xattr -dr com\.apple\.quarantine' Scripts/build.sh \
    || fail "the signed DMG must not bypass Gatekeeper"

rg -Fq 'find "${APP_PATH}/Contents/Frameworks" -type f -name "*.dylib"' Scripts/build.sh \
    || fail "all embedded dylibs must be signed before packaging"

rg -Fq -- '-derivedDataPath "$BUILD_DIR/tests"' Scripts/build.sh \
    || fail "unit tests must not share release DerivedData"

rg -q 'Contents/MacOS/SequelAceTunnelAssistant' Scripts/build.sh \
    || fail "the tunnel helper must be signed at its shipped path"

rg -q 'creating a standard drag-to-Applications DMG' Scripts/build.sh \
    || fail "headless release builds must tolerate Finder layout failures"

rg -q '<key>com\.apple\.security\.app-sandbox</key>' 'Entitlements/Sequel PAce.entitlements' \
    || fail "the Store build must declare App Sandbox"

rg -Fq '$(AppIdentifierPrefix)com.sequel-pace.sequel-pace' 'Entitlements/Sequel PAce.entitlements' \
    || fail "the Store keychain group must match the app identifier"

! rg -q 'XCRemoteSwiftPackageReference "appcenter-sdk-apple"' sequel-pace.xcodeproj/project.pbxproj \
    || fail "the retired AppCenter SDK must not ship"
