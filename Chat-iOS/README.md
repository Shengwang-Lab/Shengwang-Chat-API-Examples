
# <声网即时通讯 iOS API 示例> *声网即时通讯 iOS SDK 的示例项目*

## 概述

本仓库包含三个使用声网即时通讯 iOS SDK 的示例项目：

1. ShengwangChatApiExample：展示如何使用 AgoraChatSDK API 构建聊天应用

### ShengwangChatApiExample 项目结构

1. ApiExample：展示如何初始化 SDK、登录、发送消息和加入群组。

#### 如何使用自己的 AppID

- 将 `YOUR APP ID` 替换为您的 App ID

> 查看[启用和配置声网即时通讯服务](https://docs.agora.io/cn/agora-chat/enable_agora_chat?platform=iOS)了解如何启用和配置服务
   
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

### 前提条件

- Xcode 13.0+
- 支持所有 iOS 设备
- 平台要求：iOS 11 及以上

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

- 查看我们的issue记录[FAQ](https://docs.agora.io/en/faq).

- 深入了解声网 SDK 示例代码库以查看更多教程 [Agora SDK Samples](https://github.com/AgoraIO) 

- 查看声网使用案例获取更多复杂的实际应用场景 [Agora Use Case](https://github.com/AgoraIO-usecase)

- 在声网开发者社区可以找到社区维护的开源项目 [Agora Community](https://github.com/AgoraIO-Community)

- 如果集成中遇到任何问题可以在这里提问 [Stack Overflow](https://stackoverflow.com/questions/tagged/agora.io)

## License

The sample projects are under the MIT license.
