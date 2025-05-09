## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

## 保留 receive_sharing_intent 插件相关类
-keep class com.example.sharetext.** { *; }
-keep class com.miguelbcr.** { *; }
-keep class androidx.core.content.** { *; }
-keep class androidx.core.app.** { *; }

## 第三方库
-keep class com.google.gson.** { *; }
-keep class okhttp3.** { *; }
-keep class okio.** { *; } 