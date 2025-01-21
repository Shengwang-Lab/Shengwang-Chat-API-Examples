import 'package:flutter/material.dart';
import 'package:shengwang_chat_sdk/shengwang_chat_sdk.dart';

String appId = '';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController scrollController = ScrollController();
  String _username = "";
  String _token = "";
  String _messageContent = "";
  String _chatId = "";
  final List<String> _logText = [];

  @override
  void initState() {
    super.initState();
    _initSDK();
    _addChatListener();
  }

  @override
  void dispose() {
    // 移除消息状态监听
    ChatClient.getInstance.chatManager.removeMessageEvent("UNIQUE_HANDLER_ID");
    // 移除收消息监听
    ChatClient.getInstance.chatManager.removeEventHandler("UNIQUE_HANDLER_ID");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            TextField(
              decoration: const InputDecoration(hintText: "Enter username"),
              onChanged: (username) => _username = username,
            ),
            TextField(
              decoration: const InputDecoration(hintText: "Enter token"),
              onChanged: (token) => _token = token,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 1,
                  child: TextButton(
                    onPressed: _signIn,
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.lightBlue),
                    ),
                    child: const Text("SIGN IN"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: _signOut,
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.lightBlue),
                    ),
                    child: const Text("SIGN OUT"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                  hintText: "Enter the username you want to send"),
              onChanged: (chatId) => _chatId = chatId,
            ),
            TextField(
              decoration: const InputDecoration(hintText: "Enter content"),
              onChanged: (msg) => _messageContent = msg,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _sendMessage,
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white),
                backgroundColor: MaterialStateProperty.all(Colors.lightBlue),
              ),
              child: const Text("SEND TEXT"),
            ),
            Flexible(
              child: ListView.builder(
                controller: scrollController,
                itemBuilder: (_, index) {
                  return Text(_logText[index]);
                },
                itemCount: _logText.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _initSDK() async {
    ChatOptions options = ChatOptions.withAppId(
      appId,
      autoLogin: false,
    );
    await ChatClient.getInstance.init(options);
    await ChatClient.getInstance.startCallback();
  }

  void _addChatListener() {
    // 添加消息状态变更监听
    ChatClient.getInstance.chatManager.addMessageEvent(
        // ChatMessageEvent 对应的 key。
        "UNIQUE_HANDLER_ID",
        ChatMessageEvent(
          onSuccess: (msgId, msg) {
            _addLogToConsole("send message succeed");
          },
          onProgress: (msgId, progress) {
            _addLogToConsole("send message succeed");
          },
          onError: (msgId, msg, error) {
            _addLogToConsole(
              "send message failed, code: ${error.code}, desc: ${error.description}",
            );
          },
        ));

    // 添加收消息监听
    ChatClient.getInstance.chatManager.addEventHandler(
      // ChatEventHandler 对应的 key。
      "UNIQUE_HANDLER_ID",
      ChatEventHandler(
        onMessagesReceived: (messages) {
          for (var msg in messages) {
            switch (msg.body.type) {
              case MessageType.TXT:
                {
                  ChatTextMessageBody body = msg.body as ChatTextMessageBody;
                  _addLogToConsole(
                    "receive text message: ${body.content}, from: ${msg.from}",
                  );
                }
                break;
              case MessageType.IMAGE:
                {
                  _addLogToConsole(
                    "receive image message, from: ${msg.from}",
                  );
                }
                break;
              case MessageType.VIDEO:
                {
                  _addLogToConsole(
                    "receive video message, from: ${msg.from}",
                  );
                }
                break;
              case MessageType.LOCATION:
                {
                  _addLogToConsole(
                    "receive location message, from: ${msg.from}",
                  );
                }
                break;
              case MessageType.VOICE:
                {
                  _addLogToConsole(
                    "receive voice message, from: ${msg.from}",
                  );
                }
                break;
              case MessageType.FILE:
                {
                  _addLogToConsole(
                    "receive image message, from: ${msg.from}",
                  );
                }
                break;
              case MessageType.CUSTOM:
                {
                  _addLogToConsole(
                    "receive custom message, from: ${msg.from}",
                  );
                }
                break;
              case MessageType.COMBINE:
                {
                  _addLogToConsole(
                      "receive combine message, from: ${msg.from}");
                }
                break;
              case MessageType.CMD:
                {
                  // 当前回调中不会有 CMD 类型消息，CMD 类型消息通过 `ChatEventHandler#onCmdMessagesReceived` 回调接收
                }
                break;
            }
          }
        },
      ),
    );
  }

  void _signIn() async {
    if (_username.isEmpty || _token.isEmpty) {
      _addLogToConsole("username or token is null");
      return;
    }

    _addLogToConsole("sign in...");

    try {
      await ChatClient.getInstance.loginWithToken(_username, _token);
      _addLogToConsole("sign in succeed, username: $_username");
    } on ChatError catch (e) {
      _addLogToConsole("sign in failed, e: ${e.code} , ${e.description}");
    }
  }

  void _signOut() async {
    try {
      await ChatClient.getInstance.logout(true);
      _addLogToConsole("sign out succeed");
    } on ChatError catch (e) {
      _addLogToConsole(
          "sign out failed, code: ${e.code}, desc: ${e.description}");
    }
  }

  void _sendMessage() async {
    if (_chatId.isEmpty || _messageContent.isEmpty) {
      _addLogToConsole("single chat id or message content is null");
      return;
    }

    var msg = ChatMessage.createTxtSendMessage(
      targetId: _chatId,
      content: _messageContent,
    );

    ChatClient.getInstance.chatManager.sendMessage(msg);
  }

  void _addLogToConsole(String log) {
    _logText.add(_timeString + ": " + log);
    setState(() {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  String get _timeString {
    return DateTime.now().toString().split(".").first;
  }
}
