# Remove logging
-assumenosideeffects class android.util.Log { *; }

# Optimize code
-dontwarn org.jetbrains.**
-keep class androidx.lifecycle.** { *; }
-keep class com.google.gson.** { *; }