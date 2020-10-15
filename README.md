# Zego Express Video Example Topics iOS (Objective-C)

[English](README.md) | [中文](README_zh.md)

Zego Express Video Example Topics iOS Demo (Objective-C)

## Prepare the environment

Please ensure that the development environment meets the following technical requirements:

* Xcode 6.0 or higher
* iOS devices or simulators with iOS version no less than 8.0 and audio and video support (the real machine is recommended).
* iOS device already connected to Internet

## Download SDK

The SDK `ZegoExpressEngine.framework` required to run the Demo project is missing from this Repository, and needs to be downloaded and placed in the `Libs` folder of the Demo project

> Run Demo directly, if the pre-compilation script detects that there is no SDK Framework under `Libs`, it will automatically download the SDK. You can also download it yourself and put it in the `Libs` folder.

[https://storage.zego.im/express/video/ios/zego-express-video-ios.zip](https://storage.zego.im/express/video/ios/zego-express-video-ios.zip)

> Note that there are two folders in the zip file: `armv7-arm64` and `armv7-arm64-x86_64`, differences:

1. The dynamic framework in `armv7-arm64` contains only the architecture of the real machine (armv7, arm64). Developers need to use `ZegoExpressEngine.framework` in this folder when distributing the app, otherwise it may be rejected by App Store.

2. The dynamic framework in `armv7-arm64-x86_64` contains the real machine and simulator architecture (armv7, arm64, x86_64). If developers need to use the simulator to develop and debug, they need to use `ZegoExpressEngine.framework` in this folder. But when the app is finally distributed, you need to switch back to the Framework under the `armv7-arm64` folder. (Note: If you use CocoaPods to integrate, you do n’t need to worry about the framework architecture. CocoaPods will automatically cut the simulator architecture when Archive)

> Please unzip and put the `ZegoExpressEngine.framework` under `Libs`

```tree
.
├── Libs
│   └── ZegoExpressEngine.framework
├── README_zh.md
├── README.md
├── ZegoExpressExample-iOS-OC
└── ZegoExpressExample-iOS-OC.xcodeproj
```

## Running the sample code

1. Install Xcode: Open `AppStore`, search `Xcode`, download and install.

    <img src="https://storage.zego.im/sdk-doc/Pics/iOS/ZegoExpressEngine/Common/appstore-xcode.png" width=40% height=40%>

2. Open `ZegoExpressExample-iOS-OC.xcodeproj` with Xcode.

    Open Xcode, and click `File` -> `Open...` in the upper left corner.

    <img src="https://storage.zego.im/sdk-doc/Pics/iOS/ZegoExpressEngine/Common/xcode-open-file.png" width=70% height=70%>

    Find the `ZegoExpressExample-iOS-OC.xcodeproj` in the sample code folder downloaded and unzipped in the first step, and click `Open`.

    <img src="https://storage.zego.im/sdk-doc/Pics/iOS/ZegoExpressEngine/Common/xcode-select-file.png" width=70% height=70%>

3. Sign in Apple ID account.

    Open Xcode, click `Xcode` -> `Preference` in the upper left corner, select the `Account` tab, click the `+` sign in the lower left corner, and select Apple ID.

    <img src="https://storage.zego.im/sdk-doc/Pics/iOS/ZegoExpressEngine/Common/xcode-account.png" width=90% height=90%>

    Enter your Apple ID and password to sign in.

    <img src="https://storage.zego.im/sdk-doc/Pics/iOS/ZegoExpressEngine/Common/xcode-login-apple-id.png" width=70% height=70%>

4. Modify Bundle Identifier and Apple Developer Certificate.

    Open Xcode, click the `ZegoExpressExample-iOS-OC` project in left side.

    <img src="https://storage.zego.im/sdk-doc/Pics/iOS/ZegoExpressEngine/Common/xcode-select-project.png" width=50% height=50%>

    Change `Bundle Identifier` in the `General` tab. (Can be modified to `com.your-name.ZegoExpressExample-iOS-OC`)

    <img src="https://storage.zego.im/sdk-doc/Pics/iOS/ZegoExpressEngine/Common/bundle-identifier.png" width=90% height=90%>

    Click on the `Signing & Capabilities` tab and select your developer certificate in `Team`.

    <img src="https://storage.zego.im/sdk-doc/Pics/iOS/ZegoExpressEngine/Common/team-signing.png" width=90% height=90%>

5. The AppID and AppSign required for SDK initialization are missing from the downloaded Demo source. Please refer to [Instructions for getting AppID and AppSign](https://doc.zego.im/API/HideDoc/GetExpressAppIDGuide/GetAppIDGuideline.html) to get AppID and AppSign. If you don't fill in the correct AppID and AppSign, the source code will not run properly, so you need to modify `ZGKeyCenter.m` under the directory `ZegoExpressExample-iOS-OC/Helper` to fill in the correct AppID and AppSign.

    <img src="https://storage.zego.im/sdk-doc/Pics/iOS/ZegoExpressEngine/Common/appid-appsign-en.png" width=80% height=80%>

6. Connect your iOS device to the computer, click `🔨 Generic iOS Device` in the upper left corner of Xcode to select the iOS device (or Simulator)

    <img src="https://storage.zego.im/sdk-doc/Pics/iOS/ZegoExpressEngine/Common/xcode-select-device.png" width=80% height=80%>

    <img src="https://storage.zego.im/sdk-doc/Pics/iOS/ZegoExpressEngine/Common/xcode-select-real-device.png" width=80% height=80%>

7. Click the Build button to compile and run.

    <img src="https://storage.zego.im/sdk-doc/Pics/iOS/ZegoExpressEngine/Common/build-and-run.png" width=50% height=50%>

## FAQ

1. `The app ID "im.zego.ZegoExpressExample-iOS-OC" cannot be registered to your development team. Change your bundle identifier to a unique string to try again.`

    Refer to **Modify Bundle Identifier and Apple Developer Certificate** above, switch to your own development certificate in `Targets` -> `Signing & Capabilities` and modify `Bundle Identifier` before running.

2. `dyld: Library not loaded`

    This is [bug](https://forums.developer.apple.com/thread/128435) of iOS 13.3.1, please upgrade to iOS 13.4 or above.
