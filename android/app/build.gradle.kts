plugins {
    id("com.android.application")
    // settings.gradle.kts 가 이 플러그인을 apply false 로 선언만 해두고 여기서 적용하지
    // 않아 빌드가 깨져 있었다. MainActivity 가 Kotlin 이고 아래 kotlin { } 블록도
    // 이 플러그인이 등록하는 확장이라, 없으면 assembleDebug 가 컴파일 전에 실패한다.
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "app.skinplate.skinplate"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "app.skinplate.skinplate"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")

            // **여기서 proguardFiles 를 걸지 않는다.** Flutter 의 Gradle 플러그인이
            // 릴리스에 minify 를 켜면서 기본 규칙 · flutter_proguard_rules.pro ·
            // 이 디렉터리의 proguard-rules.pro 를 이미 다 붙인다
            // (FlutterPlugin.kt 의 releaseBuildType.proguardFiles.add 세 줄).
            // 여기 다시 적으면 축소 스위치가 여기 있는 것처럼 읽히는데, 실제 on/off 는
            // Flutter 의 -Pshrink 다. 규칙은 proguard-rules.pro 에만 둔다.
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
