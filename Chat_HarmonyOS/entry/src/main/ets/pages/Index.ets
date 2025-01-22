import { ChatClient, ChatLogLevel, ChatMessage, ChatOptions, LoginExtInfo, ContentType,
  TextMessageBody,
  ChatError} from '@shengwang/chatsdk';
import { promptAction } from '@kit.ArkUI';
import { intl } from '@kit.LocalizationKit';

@Entry
@Component
struct Index {
  private USERNAME: string = '';// 用户名，在 console 中注册。
  private TOKEN: string = ''; // 用户 Token，在 console 中获取。
  private APPID: string = ''; // 应用唯一标识，在 console 中获取。
  @State log: string = '';
  private toSendName: string = '';
  private content: string = '';

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
}

export function formatDate(date: Date, options: DateTimeOptions = {dateStyle: 'short', timeStyle: 'medium', hourCycle: 'h24'}, locale: string | Array<string> = 'zh-CN') {
  let dateFormat: intl.DateTimeFormat = new intl.DateTimeFormat(locale, options);
  return dateFormat.format(date);
}