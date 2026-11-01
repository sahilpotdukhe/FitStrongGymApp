import java.io.FileInputStream
import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    // No `kotlin-android`: AGP 9 compiles Kotlin itself (`android.builtInKotlin=true` in
    // gradle.properties). Applying the Kotlin Gradle Plugin here is unsupported on AGP 9+.
    // https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers
    // The Flutter Gradle Plugin must be applied after the Android Gradle Plugin.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties().apply {
    // Local-only and gitignored. Absent on machines that only build debug -- the release
    // signing config below is then simply not registered.
    val f = rootProject.file("key.properties")
    if (f.exists()) FileInputStream(f).use { load(it) }
}
val hasUploadKeystore = keystoreProperties.getProperty("storeFile")?.let { file(it).exists() } == true

// Without a keystore a release build does not stop: it prints its ticks, writes the APKs,
// and they are unsigned and will not install on any phone. The failure only turns up when
// somebody tries to install it, which is far too late and exactly the silent outcome the
// signing config below is meant to avoid.
//
// So refuse up front, based on what was actually asked for. Debug builds ask for
// `assembleDebug` and neither need nor want a signing key, so they are untouched.
val buildingRelease = gradle.startParameter.taskNames.any { taskName ->
    taskName.contains("Release", ignoreCase = true)
}
if (buildingRelease && !hasUploadKeystore) {
    throw GradleException(
        "No signing key, so this release would be unsigned and could not be installed " +
            "on any device.\n\n" +
            "Create android/key.properties with storeFile, storePassword, keyAlias and " +
            "keyPassword. See \"One-time: signing key\" in the README for the keytool " +
            "command that generates one.",
    )
}

android {
    namespace = "com.fitstrong.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.fitstrong.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasUploadKeystore) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Deliberately no debug fallback: a release is signed with the real upload key
            // or it is not built at all. AGP on its own would simply write an unsigned APK
            // here, so the guard at the top of this file is what makes that refusal happen.
            if (hasUploadKeystore) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

    buildFeatures {
        viewBinding = true
    }
}

dependencies {
    // Required by `isCoreLibraryDesugaringEnabled = true` above: enabling desugaring without
    // supplying the library is a hard error on AGP 9.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-messaging")
}

// Top-level (not inside `android {}`) and no longer `android.kotlinOptions`: under built-in
// Kotlin this block is served by AGP, but it still uses the Kotlin Gradle DSL types.
kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
