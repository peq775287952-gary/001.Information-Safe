# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Pointycastle (crypto library)
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**
-keep class org.spongycastle.** { *; }
-dontwarn org.spongycastle.**

# SQLite
-keep class org.sqlite.** { *; }
-dontwarn org.sqlite.**

# flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# sqflite
-keep class com.tekartik.sqflite.** { *; }

# Google Play Core (deferred components)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
