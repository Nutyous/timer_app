#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
APP_PATH="${1:-$HOME/Applications/TickTock.app}"
BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ticktock-app-build.XXXXXX")"
ICON_SOURCE="$ROOT_DIR/TickTock/TickTock/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png"
ICONSET_PATH="$BUILD_DIR/AppIcon.iconset"

if [ -e "$APP_PATH" ]; then
    printf 'Refusing to overwrite existing path: %s\n' "$APP_PATH" >&2
    exit 1
fi

swift build --package-path "$ROOT_DIR" --configuration release --scratch-path "$BUILD_DIR/build"
BIN_PATH="$(swift build --package-path "$ROOT_DIR" --configuration release --scratch-path "$BUILD_DIR/build" --show-bin-path)"

mkdir -p "$APP_PATH/Contents/MacOS" "$APP_PATH/Contents/Resources" "$ICONSET_PATH"
cp "$BIN_PATH/TickTock" "$APP_PATH/Contents/MacOS/TickTock"
cp "$ROOT_DIR/TickTock/TickTock/Info.plist" "$APP_PATH/Contents/Info.plist"

sips -z 16 16 "$ICON_SOURCE" --out "$ICONSET_PATH/icon_16x16.png" >/dev/null
sips -z 32 32 "$ICON_SOURCE" --out "$ICONSET_PATH/icon_16x16@2x.png" >/dev/null
sips -z 32 32 "$ICON_SOURCE" --out "$ICONSET_PATH/icon_32x32.png" >/dev/null
sips -z 64 64 "$ICON_SOURCE" --out "$ICONSET_PATH/icon_32x32@2x.png" >/dev/null
sips -z 128 128 "$ICON_SOURCE" --out "$ICONSET_PATH/icon_128x128.png" >/dev/null
sips -z 256 256 "$ICON_SOURCE" --out "$ICONSET_PATH/icon_128x128@2x.png" >/dev/null
sips -z 256 256 "$ICON_SOURCE" --out "$ICONSET_PATH/icon_256x256.png" >/dev/null
sips -z 512 512 "$ICON_SOURCE" --out "$ICONSET_PATH/icon_256x256@2x.png" >/dev/null
sips -z 512 512 "$ICON_SOURCE" --out "$ICONSET_PATH/icon_512x512.png" >/dev/null
cp "$ICON_SOURCE" "$ICONSET_PATH/icon_512x512@2x.png"
iconutil -c icns "$ICONSET_PATH" -o "$APP_PATH/Contents/Resources/AppIcon.icns"

xattr -cr "$APP_PATH"
codesign --force --deep --sign - "$APP_PATH"
printf 'Created %s\n' "$APP_PATH"