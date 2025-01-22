# Shengwang chat 示例项目

_[English](README.md) | 中文_

## 简介

该仓库包含了使用 Shengwang Chat SDK 实现单聊的实例项目。

## 项目结构

此项目使用一个单独的 app 实现了多种功能。

| 功能         | 位置                                             |
| ------------ | ------------------------------------------------ |
| 页面内容     | [index.html](./index.html)                       |
| 发送文本消息 | [index.js](./src/index.js)                       |
| 发送语音消息 | [sendAudioMessage.js](./src/sendAudioMessage.js) |
| 录音         | [recordAudio.js](./utils/recordAudio.js)         |
| 获取会话列表 | [conversationList.js](./src/conversationList.js) |
| 获取历史消息 | [conversationList.js](./src/conversationList.js) |

## 如何运行示例项目

### 前提条件

- 有效的 Shengwang Chat 开发者账号。
- [创建 Shengwang Chat 项目并获取 appId](https://console.shengwang.cn/overview) 。
- [npm](https://www.npmjs.com/get-npm)
- SDK 支持 IE11+、FireFox10+、Chrome54+、Safari6+ 之间文本、表情、图片、音频、地址消息相互发送。

### 运行步骤

1. 替换自己的 appId
   将 src/index.js 文件中的 'your appId' 替换成你自己的 appId。

2. 安装依赖

```bash
  npm install
```

3. 启动项目

```bash
  npm run start
```

4. 浏览器打开 https://localhost:9000 运行项目。

一切就绪。你可以自由探索示例项目，体验 Shengwang Chat SDK 的丰富功能。

## 常见问题

为什么在本地运行项目时会报错 digital envelope routines::unsupported？

本文中的项目通过 webpack 打包并在本地运行。由于 Node.js 16 及以上版本更改了对 OpenSSL 的依赖，影响了项目中本地开发环境的依赖（详见 [webpack issue](https://github.com/webpack/webpack/issues/14532)
），运行项目会发生错误。解决方案如下：

- （推荐）运行如下命令，设置临时的环境变量：

```bash
export NODE_OPTIONS=--openssl-legacy-provider
```

- 暂时换用低版本的 Node.js。

然后再次尝试运行项目。

## 反馈

如果你有任何问题或建议，可以通过 issue 的形式反馈。

## 参考文档

- [Shengwang Chat SDK 产品概述](https://im.shengwang.cn/)
- [Shengwang Chat SDK API 参考](https://im.shengwang.cn/sdkdocs/chat1.x/web/)

## 相关资源

- 查看我们的 issue 记录[FAQ](https://doc.shengwang.cn/faq/list).

- 深入了解声网 SDK 示例代码库以查看更多教程 [Shengwang SDK Samples](https://github.com/Shengwang-Lab)

- 查看声网使用案例获取更多复杂的实际应用场景 [Agora Use Case](https://github.com/AgoraIO-usecase)

- 在声网开发者社区可以找到社区维护的开源项目 [Shengwang Community](https://github.com/Shengwang-Lab)

- 如果集成中遇到任何问题可以在这里提问 [Stack Overflow](https://stackoverflow.com/questions/tagged/agora.io)

## 代码许可

示例项目遵守 MIT 许可证。
