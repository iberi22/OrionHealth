plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.orionhealth.orionhealth_health"
    compileSdk = 36
    ndkVersion = "25.1.8937393"

    packaging {
        jniLibs {
            pickFirsts.add("**/libc++_shared.so")
            pickFirsts.add("**/libarm64-v8a/libonnxruntime.so")
            pickFirsts.add("**/libarmeabi-v7a/libonnxruntime.so")
            pickFirsts.add("**/libx86_64/libonnxruntime.so")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // ── Product flavors (dev / staging / prod) ─────────────
    flavorDimensions += listOf("environment")
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            manifestPlaceholders["appAuthRedirectScheme"] = "com.orionhealth.dev"
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            manifestPlaceholders["appAuthRedirectScheme"] = "com.orionhealth.staging"
        }
        create("prod") {
            dimension = "environment"
            manifestPlaceholders["appAuthRedirectScheme"] = "com.orionhealth.app"
        }
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

dependencies {
    implementation("com.google.mlkit:genai-prompt:1.0.0-beta2")
    implementation("com.google.android.gms:play-services-tasks:18.0.2")
}
