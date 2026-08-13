allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// camera_android_camerax 0.6.30 은 camera-core:1.5.3 만 선언하고
// androidx.concurrent:concurrent-futures 는 선언하지 않는다. camera-core 의 POM 이
// 그것을 runtime 스코프로 두기 때문에 런타임 클래스패스에는 있지만 컴파일 클래스패스에는 없다.
//
// SurfaceRequest.mSurfaceRecreationCompleter 필드에 jspecify 타입 어노테이션이 붙어 있어
// javac 가 어노테이션을 붙이려면 CallbackToFutureAdapter 를 로드해야 하고, 없으면
// :camera_android_camerax:compileDebugJavaWithJavac 가 실패한다.
//
// 버전을 올리거나 내리지 않고 컴파일 시점에만 보이게 한다. 런타임 그래프는 그대로다.
// 버전은 camera-core POM 이 가리키는 것과 같게 맞춰 컴파일/런타임 어긋남을 없앤다.
// 플러그인이 이 의존성을 직접 선언하는 버전이 나오면 이 블록을 지운다.
subprojects {
    if (name == "camera_android_camerax") {
        plugins.withId("com.android.library") {
            dependencies.add("compileOnly", "androidx.concurrent:concurrent-futures:1.1.0")
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
