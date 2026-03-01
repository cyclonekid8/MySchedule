# Keep awesome_notifications classes
-keep class me.carda.awesome_notifications.** { *; }
-keep class com.google.common.util.concurrent.** { *; }
-dontwarn com.google.j2objc.annotations.**
-dontwarn java.lang.ClassValue

# Keep Google Guava classes that R8 complains about
-keep class com.google.common.** { *; }
-dontwarn com.google.errorprone.annotations.**

# Keep notification related classes
-keep class * extends android.app.Service
-keep class * extends android.content.BroadcastReceiver
