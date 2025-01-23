package io.agora.agorachatquickstart;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Bundle;
import android.text.TextUtils;
import android.text.method.ScrollingMovementMethod;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import io.agora.CallBack;
import io.agora.ConnectionListener;
import io.agora.ValueCallBack;
import io.agora.agorachatquickstart.utils.LogUtils;
import io.agora.chat.ChatClient;
import io.agora.chat.ChatMessage;
import io.agora.chat.Conversation;
import io.agora.chat.CursorResult;
import io.agora.chat.FetchMessageOption;
import io.agora.chat.LoginExtensionInfo;

public class FetchMessagesFromServerActivity extends AppCompatActivity implements ConnectionListener {
    private Activity mContext;
    private TextView tv_log;
    private Button btnSignIn;
    private Button btnSignOut;
    private EditText etUsername;
    private EditText etChatToken;
    private Button btnFetchConversations;
    private Button btnFetchMessages;
    private List<Conversation> mConversations;
    private String userName="";
    private String chatToken="";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_fetch_messages_from_server);
        mContext = this;
        initView();
        initListener();
    }

    private void initView() {
        tv_log = findViewById(R.id.tv_log);
        tv_log.setMovementMethod(new ScrollingMovementMethod());
        btnSignIn = findViewById(R.id.btn_sign_in);
        btnSignOut = findViewById(R.id.btn_sign_out);
        etUsername = findViewById(R.id.et_username);
        etChatToken = findViewById(R.id.et_token);
        btnFetchConversations = findViewById(R.id.btn_fetch_conversations);
        btnFetchMessages = findViewById(R.id.btn_fetch_messages);
        userName = getString(R.string.user_name);
        chatToken = getString(R.string.chat_token);
        etUsername.setText(userName);
        etChatToken.setText(chatToken);
    }

    @SuppressLint("ClickableViewAccessibility")
    private void initListener() {
        // Register Agora Chat connect listener
        ChatClient.getInstance().addConnectionListener(this);
        btnSignIn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                loginToShengWang(etUsername.getText().toString().trim(), etChatToken.getText().toString().trim());
            }
        });

        btnSignOut.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                signOut();
            }
        });


        btnFetchConversations.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!ChatClient.getInstance().isLoggedIn()) {
                    LogUtils.showErrorToast(mContext, tv_log, getString(R.string.sign_in_first));
                    return;
                }
                fetchConversations();
            }
        });
        btnFetchMessages.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                fetchMessagesFromConversation();
            }
        });
    }

    private void loginToShengWang(String username, String chatToken) {
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
    public void signOut() {
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

    /**
     * Fetch conversation list from Agora Chat Server
     */
    private void fetchConversations() {
        List<Conversation> conversations = new ArrayList<>();
        doFetchConversations(conversations,null);
    }

    private void doFetchConversations(List<Conversation> conversations, String cursor) {
        ChatClient.getInstance().chatManager().asyncFetchConversationsFromServer(20, cursor, new ValueCallBack<CursorResult<Conversation>>() {
            @Override
            public void onSuccess(CursorResult<Conversation> conversationCursorResult) {
                List<Conversation> datas = conversationCursorResult.getData();
                conversations.addAll(datas);
                String cursor = conversationCursorResult.getCursor();
                if(!TextUtils.isEmpty(cursor)){
                    doFetchConversations(conversations,cursor);
                }else{
                    LogUtils.showLog(tv_log, getString(R.string.fetch_conversations_success)+" size: "+conversations.size());
                    runOnUiThread(()->btnFetchMessages.setVisibility(View.VISIBLE));
                    mConversations = conversations;
                    for (int i = 0; i < conversations.size(); i++) {
                        Conversation conv = conversations.get(i);
                        LogUtils.showLog(tv_log, getString(R.string.show_conversation, conv.conversationId(), conv.getType().name()));
                    }
                }

            }

            @Override
            public void onError(int code, String error) {
                LogUtils.showErrorToast(mContext, tv_log, getString(R.string.fetch_conversation_failed, code, error));
            }
        });
    }

    /**
     * Fetch messages from Agora Chat Server by conversation id
     */
    private void fetchMessagesFromConversation() {
        int size = mConversations.size();
        int target = (int) (Math.random() * size);
        int index = 0;
        Conversation targetConversation = null;
        for (Conversation conversation : mConversations) {
            if (target == index) {
                targetConversation = conversation;
                break;
            }
            index++;
        }
        if (targetConversation == null) {
            return;
        }
        FetchMessageOption option=new FetchMessageOption();

        ChatClient.getInstance().chatManager().asyncFetchHistoryMessages(
                targetConversation.conversationId(),
                targetConversation.getType(),
                20,
                null,
                option,
                new ValueCallBack<CursorResult<ChatMessage>>() {
                    @Override
                    public void onSuccess(CursorResult<ChatMessage> result) {
                        LogUtils.showLog(tv_log, getString(R.string.fetch_messages_success));
                        LogUtils.showLog(tv_log, getString(R.string.print_only_first_10_data));
                        List<ChatMessage> messages = result.getData();
                        for (int i = 0; i < messages.size(); i++) {
                            if (i >= 10) {
                                break;
                            }
                            ChatMessage message = messages.get(i);
                            LogUtils.showLog(tv_log, getString(R.string.show_message, i, message.conversationId(),
                                    message.getMsgId(), message.getType().name(), message.getFrom(), message.getTo()));
                        }
                    }

                    @Override
                    public void onError(int code, String error) {
                        LogUtils.showErrorToast(mContext, tv_log, getString(R.string.fetch_message_failed, code, error));
                    }
                }
        );
    }

    @Override
    public void onConnected() {
        LogUtils.showNormalLog(tv_log, "onConnected");
    }

    @Override
    public void onDisconnected(int error) {
        LogUtils.showErrorLog(tv_log, "onDisconnected: " + error);
    }

    @Override
    public void onTokenExpired() {
        showLog("ConnectionListener onTokenExpired", true);
    }

    @Override
    public void onTokenWillExpire() {
        showLog("ConnectionListener onTokenWillExpire", true);
    }

    @Override
    public void onLogout(int errorCode, LoginExtensionInfo info) {
        LogUtils.showErrorLog(tv_log, "onLogout: " + errorCode);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        // Unregister connect listener when activity is finishing
        ChatClient.getInstance().removeConnectionListener(this);
    }
}
