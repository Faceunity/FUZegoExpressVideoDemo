# Download ZegoExpressEngine

echo "\n[*] Start downloading the latest version of ZegoExpressEngine SDK...\n"

SRCROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SDKURL="https://storage.zego.im/rtc/ZegoExpressVideo/ios/ZegoExpressVideo-ios-shared-objc.zip"

cd $SRCROOT
echo "[*] cd into: "`pwd`

tempdir="$( mktemp -d)"
echo "[*] Downloading iOS SDK from: $SDKURL"
curl "$SDKURL" --output $tempdir/ZegoExpressVideo-ios-shared-objc.zip

cd $tempdir
echo "[*] cd into: "`pwd`

echo "[*] Unzip ZegoExpressVideo-ios-shared-objc.zip"
unzip -o ZegoExpressVideo-ios-shared-objc.zip

cd release/Library
echo "[*] cd into: "`pwd`

echo "[*] Remove folder: $SRCROOT/Libs/ZegoExpressEngine.xcframework"
rm -rf $SRCROOT/Libs/ZegoExpressEngine.xcframework

echo "[*] Move ZegoExpressEngine.xcframework from: "`pwd`" to: $SRCROOT/Libs"
mv ZegoExpressEngine.xcframework $SRCROOT/Libs

echo "[*] Remove temp folder: $tempdir"
rm -rf $tempdir

echo "\n[*] Success!\n"
