package com.example.sharetext;

import android.app.Application;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugins.GeneratedPluginRegistrant;

// 使用标准Android Application类而不是旧的FlutterApplication
public class ShareTextApp extends Application {
    private static final String ENGINE_ID = "share_text_engine";
    
    @Override
    public void onCreate() {
        super.onCreate();
        // 预热一个FlutterEngine以避免冷启动延迟
        FlutterEngine flutterEngine = new FlutterEngine(this);
        flutterEngine.getDartExecutor().executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        );
        // 注册所有插件
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        // 缓存引擎以便MainActivity可以使用它
        FlutterEngineCache.getInstance().put(ENGINE_ID, flutterEngine);
    }
}
