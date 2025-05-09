# ShareText

一个简单的 Flutter 应用，用于接收其他应用分享的文本并保存。

## 功能特点

- 接收其他应用分享的文本
- 手动输入并保存文本
- 查看历史保存记录
- 将文本保存为文件

## 工作原理

当你在其他应用中选择文本并使用"分享"功能时，ShareText 会出现在分享选项列表中。选择 ShareText 后，文本会自动填充到应用中的输入框。然后，你可以选择保存该文本。

## 使用方法

1. 打开应用，可以直接在输入框中输入文本
2. 点击"保存"按钮将文本保存到历史记录和文件中
3. 在其他应用中，选择文本 → 点击分享 → 选择 ShareText
4. 分享的文本会自动填充到 ShareText 的输入框中
5. 查看历史记录，点击记录可以将内容重新加载到输入框

## 开发环境

- Flutter 3.10.0+
- Dart 3.0.0+
- Android SDK 30+

## 构建方法

本项目使用 GitHub Actions 自动构建 APK。每次推送到 `main` 分支时，都会触发构建并生成一个新的 Release。

手动构建：

```bash
flutter pub get
flutter build apk --release
```

生成的 APK 位于 `build/app/outputs/flutter-apk/app-release.apk`。

## 依赖库

- receive_sharing_intent: 用于接收分享意图
- shared_preferences: 用于本地存储
- path_provider: 用于文件操作
- intl: 用于日期格式化 