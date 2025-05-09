package com.example.sharetext

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    // 我们可以直接使用缓存引擎，或者在这里配置一个新引擎
    private val ENGINE_ID = "share_text_engine"
    
    // 使用我们在Application类中预热的引擎
    override fun getCachedEngineId(): String? {
        return ENGINE_ID
    }
    
    // 如果不使用缓存引擎，则确保配置新引擎
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // 通过调用GeneratedPluginRegistrant注册所有的插件
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}
