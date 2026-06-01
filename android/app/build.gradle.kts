plugins {
    id("com.android.application")
    id("kotlin-android")
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
        manifestPlaceholders["appAuthRedirectScheme"] = "com.orionhealth.app"
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

dependencies {
    implementation("com.google.mlkit:genai-prompt:1.0.0-beta2")
    implementation("com.google.android.gms:play-services-tasks:18.0.2")
}
