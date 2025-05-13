#!/bin/bash

APP_NAME="JSON_Reader"
PUBLISH_DIR="./publish"
APP_BUNDLE="$PUBLISH_DIR/$APP_NAME.app"
PKG_OUTPUT="$PUBLISH_DIR/${APP_NAME}-1.0.pkg"

echo "🛠 Cleaning previous builds..."
rm -rf "$PUBLISH_DIR"
rm -rf ./bin/ ./obj/

echo "🛠 Building MAUI project..."
dotnet publish -f net9.0-maccatalyst -c Release -o "$PUBLISH_DIR"

echo "🛠 Creating .app bundle structure..."
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

echo "🛠 Moving executable into app bundle..."
cp "$PUBLISH_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

echo "🛠 Creating Info.plist..."
cat > "$APP_BUNDLE/Contents/Info.plist" <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.seminant.jsonreader</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
</dict>
</plist>
EOL

echo "🛠 Signing app (adhoc)..."
codesign --force --deep --sign - "$APP_BUNDLE"

echo "🛠 Building .pkg installer..."
productbuild --component "$APP_BUNDLE" /Applications "$PKG_OUTPUT"

echo "✅ Done! Your installer is ready: $PKG_OUTPUT"


