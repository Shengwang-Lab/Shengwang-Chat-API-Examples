// Get conversation list
document.getElementById("conversationList").onclick = function () {
  document
    .getElementById("log")
    .appendChild(document.createElement("div"))
    .append("getConversationlist...");
  window.chatClient
    .getConversationlist()
    .then((res) => {
      console.log("getConversationList success", res);
      document
        .getElementById("log")
        .appendChild(document.createElement("div"))
        .append("getConversationList success");
      let str = "";
      res.data.channel_infos.map((item) => {
        const chanelId = item.channel_id;
        let reg = /(?<=_).*?(?=@)/;
        const username = chanelId.match(reg)[0];
        str +=
          "\n" +
          JSON.stringify({
            conversationId: username,
            conversationType:
              chanelId.indexOf("@conference.easemob.com") >= 0
                ? "groupChat"
                : "singleChat",
          });
      });
      var odIV = document.createElement("div");
      odIV.style.whiteSpace = "pre";
      document
        .getElementById("log")
        .appendChild(odIV)
        .append("getConversationList:", str);
    })
    .catch(() => {
      document
        .getElementById("log")
        .appendChild(document.createElement("div"))
        .append("getConversationList failed");
    });
};

// Get roaming message
document.getElementById("roamingMessage").onclick = function () {
  document
    .getElementById("log")
    .appendChild(document.createElement("div"))
    .append("get history Messages...");
  let converationId = document.getElementById("converationId").value.toString();
  window.chatClient
    .getHistoryMessages({ targetId: converationId, chatType: "singleChat" })
    .then((res) => {
      document
        .getElementById("log")
        .appendChild(document.createElement("div"))
        .append("get history messages success");
      let str = "";
      res.messages.map((item) => {
        str +=
          "\n" +
          JSON.stringify({
            messageId: item.id,
            messageType: item.type,
            from: item.from,
            to: item.to,
          });
      });
      var odIV = document.createElement("div");
      odIV.style.whiteSpace = "pre";
      document
        .getElementById("log")
        .appendChild(odIV)
        .append("History Messages:", str);
    })
    .catch(() => {
      document
        .getElementById("log")
        .appendChild(document.createElement("div"))
        .append("get history messages failed");
    });
};
