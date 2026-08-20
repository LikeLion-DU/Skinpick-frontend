import java.util.Properties

plugins {
    id("com.android.application")
    // settings.gradle.kts 가 이 플러그인을 apply false 로 선언만 해두고 여기서 적용하지
    // 않아 빌드가 깨져 있었다. MainActivity 가 Kotlin 이고 아래 kotlin { } 블록도
    // 이 플러그인이 등록하는 확장이라, 없으면 assembleDebug 가 컴파일 전에 실패한다.
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 릴리스 서명 키. **저장소 밖에 둔다** — `android/key.properties` 는 .gitignore
// 대상이고 .jks 도 저장소에 없다. 시크릿을 커밋하지 않는다는 규칙이 빌드 설정에도
// 그대로 걸린다.
//
// 그래서 이 파일이 없는 환경(팀원 · CI · 새로 클론한 맥)이 정상 상태다. 그때는
// debug 서명으로 떨어뜨린다 — 여기서 예외를 던지면 서명 키가 없다는 이유로
// `flutter run --release` 조차 못 돌리게 된다.
val keystoreProperties = Properties().apply {
    val keystoreFile = rootProject.file("key.properties")
    if (keystoreFile.exists()) keystoreFile.inputStream().use { load(it) }
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

    signingConfigs {
        // key.properties 가 있을 때만 만든다. 없는데 create 하면 storeFile 이 null 인
        // 채로 남아 평가 시점에 터진다 — 설정이 없는 것과 잘못된 것은 다르다.
        if (keystoreProperties.containsKey("storeFile")) {
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
            // 릴리스 키가 없으면 debug 로 떨어진다. **조용히 떨어지면 안 된다** —
            // debug 서명 APK 는 설치까지 멀쩡히 되고, 스토어에 올리려는 순간에야
            // 거부당한다. 빌드 로그에 한 줄 남겨서 그때 알아채게 한다.
            signingConfig = signingConfigs.findByName("release")
                ?: signingConfigs.getByName("debug").also {
                    // logger.lifecycle 은 flutter build 출력에서 걸러진다. println 이라야
                    // 실제로 눈에 닿는다 — 안 보이는 경고는 없는 것과 같다.
                    println("[signing] key.properties 가 없어 debug 키로 서명한다 — 배포용이 아니다")
                }

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
