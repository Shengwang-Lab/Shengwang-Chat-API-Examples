即时通讯连接了世界各地的人们，使他们能够实时与他人沟通。声网聊天 SDK 使你能够在任何应用、任何设备上嵌入实时消息传递。

本页展示了如何使用声网聊天 SDK 为 HarmonyOS 添加点对点消息传递的示例代码。

## 前提条件

为了按照本页的程序操作，你必须拥有：

- HarmonyOS NEXT.0.0.71 或以上版本的设备。
- DevEco Studio NEXT Release（5.0.3.900）及以上版本。
- HarmonyOS SDK API 12 及以上版本。

## 获取 AppID 及生成临时令牌

在声网控制台注册用户，获取 AppID 并生成临时令牌，请查看文档：[开通服务](https://im.shengwang.cn/docs/sdk/harmonyos/enable_im.html)

<div class="alert note">为发送者和接收者分别注册两个用户并生成两个用户令牌，以便在本演示的测试部分稍后使用。</div>

## 项目设置

按照以下步骤创建将声网聊天集成到你的应用中所需的环境。

1. 对于新项目，在 **DevEco Studio** 中创建一个带有 **Empty Ability** 的 **Phone and Tablet** [HarmonyOS 项目](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/ide-hello-world-V5#section58785576614)。
   <div class="alert note">创建项目后，<b>DevEco Studio</b> 自动开始同步。确保同步成功后再继续。</div>

2. 集成声网聊天 SDK 集成到你的项目中。

   打开 [SDK 下载](https://im.shengwang.cn/)页面，获取最新版的环信即时通讯 IM HarmonyOS SDK，得到 `har` 形式的 SDK 文件。

   将 SDK 文件，拷贝到 `entry` 模块或者其他需要的模块下的 `libs` 目录。

   修改模块目录的 `oh-package.json5` 文件，在 `dependencies` 节点增加依赖声明。

   ```json
   {
     "dependencies": {
       "@shengwang/chatsdk": "file:./libs/chatsdk-x.x.x.har"
     }
   }
   ```
   最后单击 **File > Sync and Refresh Project** 按钮，直到同步完成。

3. 添加项目权限。

   在模块的 `module.json5` ，例如：`entry` 模块的 `module.json5` 中，配置示例如下：

   ```json
   {
     module: {
       requestPermissions: [
         {
           name: "ohos.permission.GET_NETWORK_INFO",
         },
         {
           name: "ohos.permission.INTERNET",
         },
       ]
     },
   }
   ```

## 实现单聊

本节逐步展示如何使用声网聊天 SDK 在你的应用中实现单聊。

### 创建用户界面
在 `entry/src/main/ets/pages/Index.ets` 中，用如下代码替换原来 `build` 方法，以构建用户界面：

   ```typescript
   build() {
    Column() {
      Scroll() {
         Column() {
            Text(this.USERNAME)
               .commonStyle()
            Button("登录")
               .commonStyle()
               .onClick(() => {
                  this.signInWithToken();
               })
            Button("退出")
               .commonStyle()
               .onClick(() => {
                  this.signOut();
               })
            TextInput({placeholder: "输入接收者的userId"})
               .commonStyle()
               .onChange((value) => {
                  this.toSendName = value;
               })
            TextInput({placeholder: "输入消息内容"})
               .commonStyle()
               .onChange((value) => {
                  this.content = value;
               })
            Button("发送")
               .commonStyle()
               .onClick(() => {
                  this.sendFirstMessage();
               })
         }
         .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
            .margin({
               left: 20,
               right: 20
            })
            .height('100%')
      }
      .layoutWeight(1)
         .width('100%')

      Scroll() {
         Text(this.log)
            .width('100%')
      }
      .width('100%')
         .height(200)
         .padding(10)

    }
    .justifyContent(FlexAlign.Start)
      .width('100%')
      .height('100%')
   }

   @Styles
   commonStyle() {
      .margin({ top: 10 })
         .width('100%')
   }
   ```

### 实现消息的发送和接收

要使你的应用能够在用户之间发送和接收消息，请执行以下操作：

1. 导入。

   在 `entry/src/main/ets/pages/Index.ets` 的顶部添加如下 :

   ```typescript
   import { ChatClient, ChatLogLevel, ChatMessage, ChatOptions, LoginExtInfo, ContentType,
   TextMessageBody,
   ChatError} from '@shengwang/chatsdk';
   import { promptAction } from '@kit.ArkUI';
   import { intl } from '@kit.LocalizationKit';
   ```

2. 定义变量。  
   在 `entry/src/main/ets/pages/Index.ets`中添加如下变量：

   ```typescript
   @Entry
   @Component
   struct Index {
    private USERNAME: string = '';// 用户名，在 console 中注册。
    private TOKEN: string = ''; // 用户 Token，在 console 中获取。
    private APPID: string = ''; // 应用唯一标识，在 console 中获取。
    @State log: string = '';
    private toSendName: string = '';
    private content: string = '';
    ......
   }
   ```

3. 初始化声网 IM SDK 并注册监听。

   在 `entry/src/main/ets/pages/Index.ets` 的 `aboutToAppear` 方法中初始化 SDK:

   ```typescript
   aboutToAppear(): void {
    this.initSDK();
    this.initListener();
   }
   
   initSDK() {
    if (!this.APPID) {
      promptAction.showToast({message: "请先设置AppId！"})
      return;
    }
    // 创建 options 并设置 AppId
    const options = new ChatOptions({
      appId: this.APPID
    });
    // 设置 SDK 为 debug 级别
    options.setLogLevel(ChatLogLevel.DEBUG_LEVEL);
    // 初始化 SDK
    ChatClient.getInstance().init(getContext(this), options);
   }
   
   initListener() {
    // 注册消息监听器
    ChatClient.getInstance().chatManager()?.addMessageListener({
      onMessageReceived: (messages: ChatMessage[]): void => {
        messages.forEach(msg => {
          let message = `Receive a ${ContentType[msg.getType()]} message from: ${msg.getFrom()}`
          if (msg.getType() === ContentType.TXT) {
            message += ` content: ${(msg.getBody() as TextMessageBody).getContent()}`
          }
          this.showLog(message, false);
        })
      }
    })
    // 注册连接状态监听器。
    ChatClient.getInstance().addConnectionListener({
      onConnected: (): void => {
        this.showLog("onConnected", false);
      },
      onDisconnected: (errorCode: number): void => {
        this.showLog("onDisconnected: "+errorCode, false);
      },
      onLogout: (errorCode: number, info: LoginExtInfo) => {
        this.showLog("ser needs to log out: "+errorCode, false);
        ChatClient.getInstance().logout(false);
      },
      onTokenExpired: () => {
        this.showLog("ConnectionListener onTokenExpired", true);
      },
      onTokenWillExpire: () => {
        this.showLog("ConnectionListener onTokenWillExpire", true);
      }
    })
   }
   ```

4. 添加登录和退出方法。  
   在 `entry/src/main/ets/pages/Index.ets` 的 `initListener` 方法下面增加登录和退出方法:

   ```typescript
   signInWithToken() {
    if (!this.USERNAME || !this.TOKEN) {
      this.showLog("Username or token is empty!", true);
      return;
    }
    ChatClient.getInstance().loginWithToken(this.USERNAME, this.TOKEN).then(()=> {
      this.showLog("Sign in success!", true);
    }).catch((e: ChatError) => {
      this.showLog(e.description, true);
    })
   }
   
   signOut() {
    if (ChatClient.getInstance().isLoggedIn()) {
      ChatClient.getInstance().logout(false).then(() => {
        this.showLog("Sign out success!", true);
      }).catch((e: ChatError) => {
        this.showLog(e.description, true);
      })
    } else {
      this.showLog("You were not logged in", false);
    }
   }
   ```

5. 添加输出日志的方法.  
   在 `entry/src/main/ets/pages/Index.ets` 中的 `signOut` 方法后添加输出日志的方法:

   ```typescript
   showLog(content: string, showToast: boolean = true) {
    if (!content) {
      return;
    }
    if (showToast) {
      promptAction.showToast({message: content})
    }
    let date = formatDate(new Date());
    const preLog = this.log;
    this.log = `${date} ${content}\n${preLog}`;
   }
   ```
   
   在 `entry/src/main/ets/pages/Index.ets` 中的 `Index` 自定义组件外添加日期格式化方法：

   ```typescript
   export function formatDate(date: Date, options: DateTimeOptions = {dateStyle: 'short', timeStyle: 'medium', hourCycle: 'h24'}, locale: string | Array<string> = 'zh-CN') {
    let dateFormat: intl.DateTimeFormat = new intl.DateTimeFormat(locale, options);
    return dateFormat.format(date);
   }
   ```

6. 发送第一条消息.  
   为了能够发送第一条消息，需要在 `showLog` 后面添加发送消息的方法:

   ```typescript
   sendFirstMessage() {
    if (!this.toSendName) {
      this.showLog("请输入消息接收者的userId");
      return;
    }
    if (!this.content) {
      this.showLog("请输入要发送的消息");
      return;
    }
    // 构建一条文本消息
    const message = ChatMessage.createTextSendMessage(this.toSendName, this.content);
    if (message) {
      // 设置消息状态变化的回调。
      message.setMessageStatusCallback({
        onSuccess: () => {
          this.showLog("Send message success!", true);
        },
        onError: (code: number, error: string) => {
          this.showLog(error, true);
        }
      });
      // 发送消息
      ChatClient.getInstance().chatManager()?.sendMessage(message);
    }
   }
   ```

7. 点击 **File > Sync and Refresh Project** 按钮，直到同步完成。现在你可以开始测试应用了.


## 测试应用

为了确保您已在应用中实现点对点消息传递：

1. 为第一个用户创建一个应用：

   - 在[声网控制台](https://console.shengwang.cn)注册一个用户并[生成一个用户 token](https://im.shengwang.cn/docs/sdk/harmonyos/enable_im.html#_4-%E8%8E%B7%E5%8F%96%E4%B8%B4%E6%97%B6-token)。

   - 在 `entry/src/main/ets/pages/Index.ets` 中，使用声网控制台中的值更新 `USERNAME`、`TOKEN` 和 `APPID`。

   - 将 `HarmonyOS` 真机连接到您的开发设备。

   - 在 `DevEco Studio` 中，点击“Run `entry`”。片刻之后，你就会看到项目安装在你的设备上了。

2. 为第二个用户创建一个应用：

   - 在[声网控制台](https://console.shengwang.cn)中注册第二个用户并生成用户令牌。

   - 在 `entry/src/main/ets/pages/Index.ets` 中，使用第二个用户的信息更新 `USERNAME` 和 `TOKEN` 。确保使用的 `APPID` 与第一个用户相同。

   - 在模拟器或第二台 `HarmonyOS` 真机上运行修改后的应用程序。

3. 在每台设备上，单击 `登录` 按钮。

4. 在每台设备上的 `userId` 输入框中输入另外一台设备上的 `USERNAME` 所对应的值。

5. 在任一设备的消息框中键入消息，然后 `发送` 按钮。

6. 消息已发送并出现在另一台设备上。

7. 按 `退出` 按钮退出聊天。

## 可能遇到的问题
1. 安装HAP时提示“code:9568320 error: no signature file”。

   点击 `Open signing configs` 登录华为账号后，在签名页面，选择自动签名，然后点击确定。
   
   如果还有问题，参考官方解决方案：[安装HAP时提示“code:9568320 error: no signature file”](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs-V5/faqs-app-debugging-27-V5)

## 参考

 - [声网控制台](https://console.shengwang.cn)
 - [下载 SDK](https://im.shengwang.cn/)
 - [开通 IM 服务，获取 AppID 及获取临时令牌](https://im.shengwang.cn/docs/sdk/harmonyos/enable_im.html)