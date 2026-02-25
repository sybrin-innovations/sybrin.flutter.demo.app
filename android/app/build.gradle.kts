plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.demo.bioid_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.demo.bioid_flutter"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Sybrin SDKs require at minimum Android API 24 (Android 7.0)
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // ── Sybrin Identity SDK ───────────────────────────────────────────────
    // Scans Green Books, Passports, and Smart ID Cards.
    // Repository: https://maven.pkg.github.com/sybrin-innovations/Sybrin-Android-SDK-Identity
    implementation("com.github.sybrin-innovations:sybrin-android-sdk-identity:2.3.2")

    // ── Sybrin Biometrics – Liveness Detection ────────────────────────────
    // Passive liveness detection without requiring user gestures.
    implementation("com.github.sybrin-innovations.sybrin-android-sdk-biometrics:livenessdetection:1.6.1")

    // ── Sybrin Biometrics – Facial Comparison ─────────────────────────────
    // Compares a target portrait against one or more selfie images.
    implementation("com.github.sybrin-innovations.sybrin-android-sdk-biometrics:facialcomparison:1.6.1")
}

flutter {
    source = "../.."
}
