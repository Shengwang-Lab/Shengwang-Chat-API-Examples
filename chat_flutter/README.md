
## 项目简介

这是一个基于声网 Chat API 开发的 flutter 示例项目。

## 功能特性

- 登录
- 文本消息收发


## SDK 环境要求

- Xcode 12.4 或以上版本，包括命令行工具;
- iOS 11 或以上版本;
- Android SDK API 等级 21 或以上版本；
- Android Studio 4.0 或以上版本，包括 JDK 1.8 或以上版本;
- CocoaPods 包管理工具;
- Flutter 3.3.0 或以上版本;
- Dart 3.3.0 或以上版本;

## 快速开始

#### 如何使用自己的 AppID

- 将 `APP ID` 替换为您的 App ID

> 查看[启用和配置声网即时通讯服务](https://im.shengwang.cn/docs/sdk/ios/enable_im.html)了解如何启用和配置服务

```dart
//初始化 SDK
  void _initSDK() async {
    ChatOptions options = ChatOptions.withAppId(
      appId,
      autoLogin: false,
    );
    await ChatClient.getInstance.init(options);
  }

```

## 反馈

如果您对示例项目有任何问题或建议，欢迎提交 issue。

## 参考

- [产品简介](https://im.shengwang.cn/docs/sdk/ios/document_index.html)
- [API参考](https://im.shengwang.cn/sdkdocs/chat1.x/ios/)

## 相关资源

- 查看我们的issue记录[FAQ](https://doc.shengwang.cn/faq/list).

- 深入了解声网 SDK 示例代码库以查看更多教程 [Shengwang SDK Samples](https://github.com/Shengwang-Lab)

- 查看声网使用案例获取更多复杂的实际应用场景 [Agora Use Case](https://github.com/AgoraIO-usecase)

- 在声网开发者社区可以找到社区维护的开源项目 [Shengwang Community](https://github.com/Shengwang-Lab)

- 如果集成中遇到任何问题可以在这里提问 [Stack Overflow](https://stackoverflow.com/questions/tagged/agora.io)

## License

Example工程遵守MIT开源协议.
