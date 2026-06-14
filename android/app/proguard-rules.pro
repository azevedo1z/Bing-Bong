#noinspection ShrinkerUnresolvedReference

# ============================================================
# Flutter — manter apenas o que é acessado via JNI/reflection
# ============================================================
-keep class io.flutter.embedding.engine.FlutterJNI { *; }
-keep class io.flutter.plugin.common.** { *; }
-keep class io.flutter.plugin.platform.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
-keep class io.flutter.embedding.engine.plugins.** { *; }
-dontwarn io.flutter.embedding.**
-dontwarn io.flutter.plugin.**

# ============================================================
# audioplayers — acessado via reflection pela Flutter engine
# ============================================================
-keep class xyz.luan.audioplayers.** { *; }
-dontwarn xyz.luan.audioplayers.**

# ============================================================
# url_launcher — registrado via reflection
# ============================================================
-keep class io.flutter.plugins.urllauncher.** { *; }
-dontwarn io.flutter.plugins.urllauncher.**

# ============================================================
# thermion_flutter — plugin Android (texture/surface) registrado
# via reflection; o renderer nativo (libthermion_dart.so) é
# carregado por dart:ffi e não é afetado pelo R8
# ============================================================
-keep class dev.thermion.android.** { *; }
-dontwarn dev.thermion.android.**

# ============================================================
# Play Core (Flutter deferred components — não usamos, mas
# o Flutter referencia em runtime)
# ============================================================
-dontwarn com.google.android.play.core.**

# ============================================================
# Remove logs em release
# ============================================================
-assumenosideeffects class android.util.Log {
    public static *** v(...);
    public static *** d(...);
    public static *** i(...);
}

# ============================================================
# Atributos necessários para reflection-aware libraries
# ============================================================
-keepattributes Signature
-keepattributes *Annotation*
