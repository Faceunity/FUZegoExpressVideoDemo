#!/bin/sh
if [ $CONFIGURATION == "Release" ]; then

    echo "[*] Build release, remove simulator architecture"

    cd Libs/ZegoExpressEngine.framework
    echo "[*] cd into: "`pwd`

    if [ -e "ZegoExpressEngine" ]; then

        lipo -info ZegoExpressEngine

        echo "[*] remove i386 architecture"
        lipo ZegoExpressEngine -remove i386 -output ZegoExpressEngine

        echo "[*] remove x86_64 architecture"
        lipo ZegoExpressEngine -remove x86_64 -output ZegoExpressEngine

        lipo -info ZegoExpressEngine

    fi

fi

