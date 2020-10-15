#!/bin/sh
if [ ! -e "Libs/ZegoExpressEngine.framework" ]; then

    cd $SRCROOT
    echo "[*] cd into: "`pwd`

    URL="https://storage.zego.im/express/video/ios/zego-express-video-ios.zip"

    if [ ! -d "Libs/__sdk_download_tmp__" ]; then
        mkdir Libs/__sdk_download_tmp__
    fi

    echo "[*] Downloading SDK from: $URL"
    curl "$URL" --output Libs/__sdk_download_tmp__/zego-express-video-ios.zip

    cd Libs/__sdk_download_tmp__
    echo "[*] cd into: "`pwd`

    echo "[*] Unzip zego-express-video-ios.zip"
    unzip -o zego-express-video-ios.zip

    for element in `ls`; do
        dir=$element
        if [ -d $dir ]; then
            cd $dir
            echo "[*] cd into: "`pwd`
            break
        fi
    done

    if [ -d "armv7-arm64-x86_64" ]; then
        cd armv7-arm64-x86_64
        echo "[*] cd into: "`pwd`
        echo "[*] Move ZegoExpressEngine.framework from: "`pwd`" to: $SRCROOT/Libs"
        mv ZegoExpressEngine.framework $SRCROOT/Libs
    fi

    echo "[*] Remove folder: $SRCROOT/Libs/__sdk_download_tmp__"
    rm -rf $SRCROOT/Libs/__sdk_download_tmp__
fi

