plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.orionhealth.orionhealth_health"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
    defaultConfig {
        applicationId = "com.orionhealth.orionhealth_health"
        minSdk = 28
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

gradle.projectsEvaluated {
    rootProject.subprojects.forEach { subproject ->
        if (subproject.name == "isar_flutter_libs") {
            listOf("verifyReleaseResources", "verifyDebugResources").forEach { taskName ->
                subproject.tasks.findByName(taskName)?.setEnabled(false)
            }
        }
    }
}

flutter {
    source = "../.."
}
