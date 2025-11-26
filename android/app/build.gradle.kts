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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.orionhealth.orionhealth_health"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 35
        targetSdk = 36
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
    
    packaging {
        resources {
            excludes.add("assets")
            excludes.add("res")
        }
    }
    
    lint {
        disable.add("MissingDimensionActivityCreator")
    }
}

// Disable AAR metadata verification - isar_flutter_libs uses Material 3 attrs that might not match compile SDK
gradle.projectsEvaluated {
    rootProject.subprojects.forEach { subproject ->
        if (subproject.name == "isar_flutter_libs") {
            subproject.tasks.matching { 
                it.name.contains("VerifyReleaseResources") || it.name.contains("VerifyLibraryResources") || it.name.contains("CheckAarMetadata")
            }.forEach {
                it.enabled = false
            }
        }
    }
}

flutter {
    source = "../.."
}
