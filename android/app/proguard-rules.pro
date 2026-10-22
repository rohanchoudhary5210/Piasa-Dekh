# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.**  { *; }

# SQLite3 & Native Database Drivers (sqlite3_flutter_libs)
-keep class org.sqlite.** { *; }
-keep class com.tekartik.sqflite.** { *; }
-keepclassmembers class * extends com.tekartik.sqflite.** { *; }
-keep class eu.simonbinder.sqlite3_flutter_libs.** { *; }

# Drift Database Runtime & Query Converters
-keep class * extends drift.** { *; }

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Biometric & Local Auth
-keep class io.flutter.plugins.localauth.** { *; }
-dontwarn androidx.biometric.**

# Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Java 8+ Desugaring
-dontwarn java.time.**
-dontwarn java.lang.invoke.**
