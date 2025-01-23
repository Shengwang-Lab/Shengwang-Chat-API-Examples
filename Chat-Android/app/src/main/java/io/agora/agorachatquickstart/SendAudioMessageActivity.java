package io.agora.agorachatquickstart;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.net.Uri;
import android.os.Bundle;
import android.os.PowerManager;
import android.text.TextUtils;
import android.text.method.ScrollingMovementMethod;
import android.util.TypedValue;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import io.agora.CallBack;
import io.agora.ConnectionListener;
import io.agora.Error;
import io.agora.agorachatquickstart.record.EaseChatRowVoicePlayer;
import io.agora.agorachatquickstart.record.EaseVoiceRecorder;
import io.agora.agorachatquickstart.utils.LogUtils;
import io.agora.agorachatquickstart.utils.PermissionsManager;
import io.agora.chat.ChatClient;
import io.agora.chat.ChatMessage;
import io.agora.chat.LoginExtensionInfo;

public class SendAudioMessageActivity extends AppCompatActivity implements ConnectionListener {
    private Activity mContext;
    private Button btnStartRecording;
    private TextView tv_log;
    private EditText etToChatName;
    private EaseVoiceRecorder voiceRecorder;
    private PowerManager.WakeLock wakeLock;
    private String toChatUsername;
    private Button btnSignIn;
    private EditText etUsername;
    private Button btnSignOut;

    private boolean canRecord = false;
    private String userName;
    private String chatToken;
    private EditText etChatToken;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_send_audio_message);
        mContext = this;
        initView();
        initListener();
        initData();
    }

    private void initView() {
        btnStartRecording = findViewById(R.id.btn_start_recording);
        tv_log = findViewById(R.id.tv_log);
        tv_log.setMovementMethod(new ScrollingMovementMethod());
        etToChatName = findViewById(R.id.et_to_chat_name);
        btnSignIn = findViewById(R.id.btn_sign_in);
        btnSignOut = findViewById(R.id.btn_sign_out);
        etUsername = findViewById(R.id.et_username);
        etChatToken = findViewById(R.id.et_token);

        userName = getString(R.string.user_name);
        chatToken = getString(R.string.chat_token);
        etUsername.setText(userName);
        etChatToken.setText(chatToken);
    }

    @SuppressLint("ClickableViewAccessibility")
    private void initListener() {
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

        btnStartRecording.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                return false;
            }
        });
        btnStartRecording.setOnTouchListener((v, event) -> {
            switch (event.getAction()) {
                case MotionEvent.ACTION_DOWN:
                    if(!ChatClient.getInstance().isLoggedIn()) {
                        LogUtils.showErrorToast(mContext, tv_log, getString(R.string.sign_in_first));
                        return false;
                    }
                    if (!checkRecordPermission()) {
                        LogUtils.showErrorLog(tv_log, getString(R.string.recording_without_permission));
                        return false;
                    }
                    toChatUsername = etToChatName.getText().toString().trim();
                    if(TextUtils.isEmpty(toChatUsername)) {
                        LogUtils.showErrorLog(tv_log, getString(R.string.not_find_send_audio_name));
                        return false;
                    }
                    canRecord = true;
                    startRecord();
                    return true;
                case MotionEvent.ACTION_MOVE:
                    if(!canRecord) {
                        return false;
                    }
                    moveAction(event);
                    return true;
                case MotionEvent.ACTION_UP:
                    if(!canRecord) {
                        return false;
                    }
                    stopRecord(event);
                    canRecord = false;
                    return true;
                default:
                    return false;
            }
        });
        // Register Agora Chat connect listener
        ChatClient.getInstance().addConnectionListener(this);
    }

    /**
     * Check record audio permission
     * @return
     */
    private boolean checkRecordPermission() {
        // Check if have the permission of RECORD_AUDIO
        if (!PermissionsManager.getInstance().hasPermission(this, Manifest.permission.RECORD_AUDIO)) {
            PermissionsManager.getInstance().requestPermissions(this, new String[]{Manifest.permission.RECORD_AUDIO}, 100);
            return false;
        }
        return true;
    }

    @SuppressLint("InvalidWakeLockTag")
    private void initData() {
        voiceRecorder = new EaseVoiceRecorder(null);
        wakeLock = ((PowerManager) this.getSystemService(Context.POWER_SERVICE)).newWakeLock(
                PowerManager.SCREEN_DIM_WAKE_LOCK, "sendAudio");

    }

    /**
     * Send audio message
     * @param length
     */
    private void sendAudioMessage(int length) {
        LogUtils.showLog(tv_log, getString(R.string.start_to_send_audio));
        String voiceFilePath = voiceRecorder.getVoiceFilePath();
        ChatMessage message = ChatMessage.createVoiceSendMessage(Uri.parse(voiceFilePath), length, toChatUsername);
        message.setMessageStatusCallback(new CallBack() {
            @Override
            public void onSuccess() {
                LogUtils.showLog(tv_log, getString(R.string.send_audio_message_success));
            }

            @Override
            public void onError(int code, String error) {
                LogUtils.showErrorToast(mContext, tv_log,
                        getString(R.string.message_sent_failed, code, error));
            }

            @Override
            public void onProgress(int progress, String status) {

            }
        });
        // send message
        ChatClient.getInstance().chatManager().sendMessage(message);
    }

    /**
     * Start to record
     */
    private void startRecord() {
        try {
            EaseChatRowVoicePlayer voicePlayer = EaseChatRowVoicePlayer.getInstance(this);
            if (voicePlayer.isPlaying())
                voicePlayer.stop();
            startRecording();
        } catch (Exception e) {

        }
    }

    /**
     * Move action, do nothing
     * @param event
     */
    private void moveAction(MotionEvent event) {
        if (event.getY() < dip2px(this, 10)) {
            //showReleaseToCancelHint();
        } else {
            //showMoveUpToCancelHint();
        }
    }

    /**
     * Stop recording
     * @param event
     */
    private void stopRecord(MotionEvent event) {
        if (event.getY() < 0) {
            // discard the recorded audio.
            discardRecording();
        } else {
            // stop recording and send voice file
            try {
                int length = stopRecoding();
                if (length > 0) {
                    sendAudioMessage(length);
                } else if (length == Error.FILE_INVALID) {
                    LogUtils.showErrorToast(this, tv_log, getString(R.string.recording_without_permission));
                } else {
                    LogUtils.showErrorToast(this, tv_log, getString(R.string.recording_time_is_too_short));
                }
            } catch (Exception e) {
                e.printStackTrace();
                LogUtils.showErrorToast(this, tv_log, getString(R.string.send_failure_please));
            }
        }
    }

    /**
     * Start to record
     */
    private void startRecording() {
        if (!android.os.Environment.getExternalStorageState().equals(android.os.Environment.MEDIA_MOUNTED)) {
            LogUtils.showErrorToast(this, tv_log, getString(R.string.send_voice_need_sdcard_support));
            return;
        }
        LogUtils.showLog(tv_log, getString(R.string.start_record));
        try {
            wakeLock.acquire();
            voiceRecorder.startRecording(this);
        } catch (Exception e) {
            e.printStackTrace();
            if (wakeLock.isHeld())
                wakeLock.release();
            if (voiceRecorder != null)
                voiceRecorder.discardRecording();
            LogUtils.showErrorToast(this, tv_log, getString(R.string.recoding_fail));
            return;
        }
    }

    /**
     * Stop recording
     * @return
     */
    private int stopRecoding() {
        if (wakeLock.isHeld())
            wakeLock.release();
        LogUtils.showLog(tv_log, getString(R.string.stop_record));
        return voiceRecorder.stopRecoding();
    }

    /**
     * Discard recording
     */
    private void discardRecording() {
        if (wakeLock.isHeld())
            wakeLock.release();
        try {
            // stop recording
            if (voiceRecorder.isRecording()) {
                voiceRecorder.discardRecording();
            }
        } catch (Exception e) {
        }
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

    /**
     * dip to px
     *
     * @param context
     * @param value
     * @return
     */
    public static float dip2px(Context context, float value) {
        return TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, value, context.getResources().getDisplayMetrics());
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
}
