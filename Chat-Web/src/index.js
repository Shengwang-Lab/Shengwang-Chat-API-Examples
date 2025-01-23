import ChatSDK from "shengwang-chat";
let userId, token;
const chatClient = new ChatSDK.connection({
  appId: "your appId",
});
window.chatClient = chatClient;
// Register listening events
chatClient.addEventHandler("connection&message", {
  onConnected: () => {
    document
      .getElementById("log")
      .appendChild(document.createElement("div"))
      .append("Connect success !");
  },
  onDisconnected: () => {
    document
      .getElementById("log")
      .appendChild(document.createElement("div"))
      .append("Logout success !");
  },
  onTextMessage: (message) => {
    console.log(message);
    document
      .getElementById("log")
      .appendChild(document.createElement("div"))
      .append("Message from: " + message.from + " Message: " + message.msg);
  },
  onTokenWillExpire: (params) => {
    document
      .getElementById("log")
      .appendChild(document.createElement("div"))
      .append("Token is about to expire");
    refreshToken(userId);
  },
  onTokenExpired: (params) => {
    document
      .getElementById("log")
      .appendChild(document.createElement("div"))
      .append("The token has expired, please login again.");
  },
  onError: (error) => {
    console.log("on error", error);
  },
});

// Obtain and set the access token again
function refreshToken(userId) {
  const newToken = "new token";
  chatClient.renewToken(newToken);
  document
    .getElementById("log")
    .appendChild(document.createElement("div"))
    .append("Token has been updated");
}

// Button behavior definition
// login
document.getElementById("login").onclick = function () {
  document
    .getElementById("log")
    .appendChild(document.createElement("div"))
    .append("Logging in...");
  userId = document.getElementById("userID").value.toString();
  token = document.getElementById("token").value.toString();

  chatClient
    .open({
      user: userId,
      accessToken: token,
    })
    .then((res) => {
      console.log("res", res);
      document
        .getElementById("log")
        .appendChild(document.createElement("div"))
        .append(`Login success`);
    })
    .catch((res) => {
      console.log("res", res);
      document
        .getElementById("log")
        .appendChild(document.createElement("div"))
        .append(`Login failed`);
    });
};

// logout
document.getElementById("logout").onclick = function () {
  chatClient.close();
  document
    .getElementById("log")
    .appendChild(document.createElement("div"))
    .append("logout");
};

// Send a single chat message
document.getElementById("send_peer_message").onclick = function () {
  const peerId = document.getElementById("peerId").value.toString();
  const peerMessage = document.getElementById("peerMessage").value.toString();
  const option = {
    chatType: "singleChat", // Set it to single chat
    type: "txt", // Message type
    to: peerId, // The user receiving the message (user ID)
    msg: peerMessage, // The message content
  };
  const msg = ChatSDK.message.create(option);
  chatClient
    .send(msg)
    .then((res) => {
      console.log("send text message success");
      document
        .getElementById("log")
        .appendChild(document.createElement("div"))
        .append("Message send to: " + peerId + " Message: " + peerMessage);
    })
    .catch((err) => {
      console.log("send text message fail", err);
    });
};
