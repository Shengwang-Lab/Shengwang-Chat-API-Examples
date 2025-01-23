package io.agora.agorachatquickstart;

import android.os.Bundle;
import android.text.TextUtils;
import android.text.method.ScrollingMovementMethod;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import io.agora.CallBack;
import io.agora.ConnectionListener;
import io.agora.chat.ChatClient;
import io.agora.chat.ChatMessage;
import io.agora.chat.LoginExtensionInfo;
import io.agora.chat.TextMessageBody;


public class MainActivity extends AppCompatActivity {
    // Create a user from Agora Console or by your app server
    private  String username = "";
    // Gets token from Agora Console or generates by your app server
    private  String chatToken = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        initView();
        initListener();
    }

    private void initView() {
        ((TextView)findViewById(R.id.tv_log)).setMovementMethod(new ScrollingMovementMethod());
        username =getString(R.string.user_name);
        chatToken =getString(R.string.chat_token);
        // Show current user
        ((TextView)findViewById(R.id.tv_username)).setText("Current user: "+ username);
    }



    private void initListener() {
        ChatClient.getInstance().chatManager().addMessageListener(messages -> {
            for(ChatMessage message : messages) {
                StringBuilder builder = new StringBuilder();
                builder.append("Receive a ").append(message.getType().name())
                        .append(" message from: ").append(message.getFrom());
                if(message.getType() == ChatMessage.Type.TXT) {
                    builder.append(" content:")
                            .append(((TextMessageBody)message.getBody()).getMessage());
                }
                showLog(builder.toString(), false);
            }
        });
        ChatClient.getInstance().addConnectionListener(new ConnectionListener() {
            @Override
            public void onConnected() {
                showLog("onConnected",false);
            }

            @Override
            public void onDisconnected(int error) {
                showLog("onDisconnected: "+error,false);
            }

            @Override
            public void onLogout(int errorCode, LoginExtensionInfo info) {
                showLog("User needs to log out: "+errorCode, false);
                ChatClient.getInstance().logout(false, null);
            }

            @Override
            public void onTokenExpired() {
                showLog("ConnectionListener onTokenExpired", true);
            }

            @Override
            public void onTokenWillExpire() {
                showLog("ConnectionListener onTokenWillExpire", true);
            }
        });
    }

    /**
     * Login with token
     */
    public void signInWithToken(View view) {
        loginToShengWang();
    }

    private void loginToShengWang() {
        if(TextUtils.isEmpty(username) || TextUtils.isEmpty(chatToken)) {
            showLog("Username or token is empty!", true);
            return;
        }
        ChatClient.getInstance().loginWithToken(username, chatToken, new CallBack() {
            @Override
            public void onSuccess() {
                showLog("Sign in success!", true);
            }

            @Override
            public void onError(int code, String error) {
                showLog(error, true);
            }
        });
    }

    /**
     * Sign out
     */
    public void signOut(View view) {
        if(ChatClient.getInstance().isLoggedInBefore()) {
            ChatClient.getInstance().logout(true, new CallBack() {
                @Override
                public void onSuccess() {
                    showLog("Sign out success!", true);
                }

                @Override
                public void onError(int code, String error) {
                    showLog(error, true);
                }
            });
        }else {
            showLog("You were not logged in", false);
        }
    }

    /**
     * Send your first message
     */
    public void sendFirstMessage(View view) {
        String toSendName = ((EditText)findViewById(R.id.et_to_chat_name)).getText().toString().trim();
        String content = ((EditText)findViewById(R.id.et_msg_content)).getText().toString().trim();
        // Create a text message
        ChatMessage message = ChatMessage.createTextSendMessage(content, toSendName);
        // Set the message callback before sending the message
        message.setMessageStatusCallback(new CallBack() {
            @Override
            public void onSuccess() {
                showLog("Send message success!", true);
            }

            @Override
            public void onError(int code, String error) {
                showLog(error, true);
            }
        });
        // Send the message
        ChatClient.getInstance().chatManager().sendMessage(message);
    }

    private void showLog(String content, boolean showToast) {
        if(TextUtils.isEmpty(content)) {
            return;
        }
        runOnUiThread(()-> {
            if(showToast) {
                Toast.makeText(this, content, Toast.LENGTH_SHORT).show();
            }
            TextView tv_log = findViewById(R.id.tv_log);
            String preContent = tv_log.getText().toString().trim();
            StringBuilder builder = new StringBuilder();
            builder.append(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(new Date()))
                    .append(" ").append(content).append("\n").append(preContent);
            tv_log.setText(builder);
        });
    }
}