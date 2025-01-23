const path = require("path");
const webpack = require("webpack");
module.exports = {
  entry: [
    "./src/index.js",
    "./src/conversationList.js",
    "./src/sendAudioMessage.js",
  ],
  mode: "production",
  output: {
    filename: "bundle.js",
    path: path.resolve(__dirname, "./dist"),
    publicPath: "/",
  },
  devServer: {
    contentBase: "./",
    compress: true,
    port: 9000,
    https: true,
    hot: true,
    liveReload: true,
  },
  plugins: [new webpack.HotModuleReplacementPlugin()], // Enable HMR
};
