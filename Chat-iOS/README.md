
## 项目简介
这是一个基于声网 Chat API 开发的 iOS 示例项目，展示了如何在 iOS 应用中集成和使用声网的即时通讯功能。

## 功能特性
- 消息收发
- 群组聊天
- 一对一私聊
- 多媒体消息支持（图片、语音等）

## SDK 环境要求
- iOS 11 及其以上

## Example环境要求
- iOS 15.0 或更高版本
- Xcode 16.0 或更高版本（项目执行pod init是Xcode16）
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
5. 如果`pod install`失败报错 
    > RuntimeError - `PBXGroup` attempted to initialize an object with unknown ISA `PBXFileSystemSynchronizedRootGroup` from attributes: `{"isa"=>"PBXFileSystemSynchronizedRootGroup"`，请尝试升级pod版本为1.14.3
6. Xcode16及其以下版本打开会报错 `Adjust the project format using a compatible version of Xcode to allow it to be opened by this version of Xcode.`
7. Build 报错rsync相关权限问题
    > ⚠️Xcode15编译报错 ```Sandbox: rsync.samba(47334) deny(1) file-write-create...```

    > 解决方法: Build Setting里搜索 ```ENABLE_USER_SCRIPT_SANDBOXING```把```User Script Sandboxing```改为```NO```

### 快速开始
> 如果低版本Xcode与cocoapods的情况可以使用快速开始集成IMSDK

1. 新建一个工程命名为 `ShengwangChatApiExample`

2. cd到工程文件夹下，执行`pod init`命令，然后在Podfile文件中添加以下代码：

```
  pod 'ShengwangChat_iOS'
```

3. 执行`pod install`命令，安装SDK

4. 在`AppDelegate.swift`文件中引入SDK，初始化SDK

```Swift
//初始化 SDK
        let options = AgoraChatOptions(appId: <#App Id#><##>)
        options.enableConsoleLog = true
        AgoraChatClient.shared().initializeSDK(with: options)
```

5. 在`ViewController.swift`文件中引入SDK，使用console中生成的用户以及token登录

```Swift
        AgoraChatClient.shared().login(withUsername: "userId", token: "user token") { (userId,error) in
            if error == nil {
            
            } else {
                printf("login error:\(error?.errorDescription ?? "")")
            }
        }
```

6. 发送消息

```Swift
        let message = AgoraChatMessage(conversationID: "receive user id", body: AgoraChatTextMessageBody(text: text), ext: [:])
        AgoraChatClient.shared().chatManager?.send(message, progress: nil) { [weak self] sendMessage, error in
            guard let self = self else { return }
            if error == nil {
                
            } else {
                print("\(error?.errorDescription ?? "")")
            }
        }
```

7. 运行项目，查看日志，发送成功后会在控制台打印发送成功的日志

> 
[0][2025/01/22 13:59:34:724]: log: level: 0, area: 1, SEND:
{ verison : MSYNC_V1, compress_algorimth : 0, command : SYNC, encrypt_type : [ 0 ], payload : { meta : { id : 17375255747180004, to : p3, ns : CHAT, payload : { chattype : CHAT, from : p1, to : p3, contents : [ { contenttype : TEXT, text : 666 } ] } } } }

[0][2025/01/22 13:59:34:724]: [Chat TCP] sendBuffer length:56
[0][2025/01/22 13:59:34:780]: [Chat TCP] OnData length:40
[0][2025/01/22 13:59:34:780]: log: level: 0, area: 1, RECV:
{ verison : MSYNC_V1, command : SYNC, payload : { status : { error_code : 0 }, meta_id : 17375255747180004, server_id : 1374221063398884136, timestamp : 1737525574756 } }
>

8. 发送其他类型消息参看Example源码以及[官网文档](https://im.shengwang.cn/docs/sdk/ios/message_send_receive.html)

## 反馈

如果您对示例项目有任何问题或建议，欢迎提交 issue。

## 参考

- [Product Overview](https://im.shengwang.cn/docs/sdk/ios/document_index.html)
- [API Reference](https://docs.agora.io/en/agora-chat/agora_chat_overview?platform=iOS)

## 相关资源

- 查看我们的issue记录[FAQ](https://doc.shengwang.cn/faq/list).

- 深入了解声网 SDK 示例代码库以查看更多教程 [Shengwang SDK Samples](https://github.com/Shengwang-Lab) 

- 查看声网使用案例获取更多复杂的实际应用场景 [Agora Use Case](https://github.com/AgoraIO-usecase)

- 在声网开发者社区可以找到社区维护的开源项目 [Shengwang Community](https://github.com/Shengwang-Lab)

- 如果集成中遇到任何问题可以在这里提问 [Stack Overflow](https://stackoverflow.com/questions/tagged/agora.io)

## License

The sample projects are under the MIT license.
