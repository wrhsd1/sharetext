# ShareText

一个简单的 Flutter 安卓 App，支持：
- 输入文本并保存到本地
- 作为系统分享目标，接收其他 App 分享的文本
- GitHub Actions 云端自动编译 APK

## 主要依赖
- shared_preferences
- receive_sharing_intent

## 云编译
推送到 main 分支后，GitHub Actions 会自动编译 APK 并在构建结束后提供下载。
