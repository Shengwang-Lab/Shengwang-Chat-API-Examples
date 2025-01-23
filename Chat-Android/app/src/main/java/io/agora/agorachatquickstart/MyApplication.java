package io.agora.agorachatquickstart;


import android.app.Application;
import android.text.TextUtils;
import android.widget.Toast;

import io.agora.chat.ChatClient;
import io.agora.chat.ChatOptions;

public class MyApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        initSDK();
    }

    private void initSDK() {
        ChatOptions options = new ChatOptions();
        // Set your appId applied from ShengWang Console
        String sdkAppId = getString(R.string.app_id);
        if(TextUtils.isEmpty(sdkAppId)) {
            Toast.makeText(this, "You should set your AppId first!", Toast.LENGTH_SHORT).show();
            return;
        }
        // Set your appId to options
        options.setAppId(sdkAppId);
        // To initialize ShengWang Chat SDK
        ChatClient.getInstance().init(this, options);
        // Make ShengWang Chat SDK debuggable
        ChatClient.getInstance().setDebugMode(true);

    }
}
