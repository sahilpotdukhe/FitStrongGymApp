pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.0.1" apply false
    // Declared but never applied (`apply false`) -- the app uses AGP 9's built-in Kotlin.
    // Keep it: if built-in Kotlin is ever disabled (`android.builtInKotlin=false`) or AGP is
    // downgraded below 9, the Flutter Gradle Plugin applies `kotlin-android` itself and needs
    // KGP resolvable from this block. Do not add `kotlin-android` to app/build.gradle.kts.
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
    // Firebase (firebase_core / cloud_firestore / firebase_auth) needs the Google Services
    // plugin to process android/app/google-services.json. Declared here with a version,
    // applied in app/build.gradle.kts.
    id("com.google.gms.google-services") version "4.5.0" apply false
    id("org.gradle.toolchains.foojay-resolver-convention") version "0.10.0"
}

include(":app")
