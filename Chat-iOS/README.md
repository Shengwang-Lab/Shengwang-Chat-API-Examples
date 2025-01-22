
## 项目简介
这是一个基于声网 Chat API 开发的 iOS 示例项目，展示了如何在 iOS 应用中集成和使用声网的即时通讯功能。

## 功能特性
- 消息收发
- 群组聊天
- 一对一私聊
- 多媒体消息支持（图片、语音等）

## 环境要求
- iOS 12.0 或更高版本
- Xcode 14.0 或更高版本
- CocoaPods 包管理工具

## 快速开始

#### 如何使用自己的 AppID

- 将 `YOUR APP ID` 替换为您的 App ID

> 查看[启用和配置声网即时通讯服务](https://im.shengwang.cn/docs/sdk/ios/enable_im.html)了解如何启用和配置服务
   
```Swift
//初始化 SDK
        let options = AgoraChatOptions(appId: <#App Id#><##>)
        options.enableConsoleLog = true
        AgoraChatClient.shared().initializeSDK(with: options)
```


### ShengwangChatApiExample 项目结构

1. AgoraChatLoginViewController：展示如何使用 SDK 进行注册和登录
2. MenuViewController：展示功能列表
3. AgoraChatConversationsViewController：展示如何加载会话
4. AgoraChatSendTextViewController：展示如何发送文本消息
5. AgoraChatSendImageVideoController：展示如何发送图片消息
6. AgoraChatSendVoiceViewController: 展示如何发送音频消息


## 如何运行示例项目

### 运行步骤

1. 进入 **iOS** 文件夹，选择一个文件夹运行以下命令安装项目依赖：
```shell
$ pod install
```

2. 用 Xcode 打开生成的 `ShengwangChatApiExample.xcworkspace` 文件
3. 在 iOS 设备或模拟器上构建并运行项目
4. 完成设置！现在您可以体验示例项目并探索声网即时通讯 SDK 的功能了

## 反馈

如果您对示例项目有任何问题或建议，欢迎提交 issue。

## 参考

- [Product Overview](https://docs.agora.io/en/agora-chat/agora_chat_get_started_ios?platform=iOS)
- [API Reference](https://docs.agora.io/en/agora-chat/agora_chat_overview?platform=iOS)

## 相关资源

- 查看我们的issue记录[FAQ](https://doc.shengwang.cn/faq/list).

- 深入了解声网 SDK 示例代码库以查看更多教程 [Shengwang SDK Samples](https://github.com/Shengwang-Lab) 

- 查看声网使用案例获取更多复杂的实际应用场景 [Agora Use Case](https://github.com/AgoraIO-usecase)

- 在声网开发者社区可以找到社区维护的开源项目 [Shengwang Community](https://github.com/Shengwang-Lab)

- 如果集成中遇到任何问题可以在这里提问 [Stack Overflow](https://stackoverflow.com/questions/tagged/agora.io)

## License

The sample projects are under the MIT license.
