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
    // onnxruntime 1.4.1 hard-codes `compileSdkVersion 33` in its Android library
    // module, and AGP 8.13 enforces the AAR metadata check on library modules
    // too: the androidx dependencies it pulls in (fragment 1.7.1, window 1.2.0,
    // exifinterface 1.4.1, ...) all require public API 34+. Without the
    // override `:onnxruntime:checkReleaseAarMetadata` fails with "15 issues",
    // which takes assembleProdDebug/Release down with it. Same afterEvaluate
    // reflection shape as the isar_flutter_libs override below.
    if (project.name == "onnxruntime") {
        afterEvaluate {
            try {
                val android = project.extensions.getByName("android")
                val setCompileSdkVersion = android.javaClass.getMethod("compileSdkVersion", Int::class.java)
                setCompileSdkVersion.invoke(android, 36)
            } catch (e: Exception) {
                println("Failed to set compileSdk for onnxruntime: ${e.message}")
            }
        }
    }
}

subprojects {
    if (project.name == "isar_flutter_libs") {
        afterEvaluate {
            try {
                val android = project.extensions.getByName("android")
                val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                setNamespace.invoke(android, "dev.isar.isar_flutter_libs")

                val setCompileSdkVersion = android.javaClass.getMethod("compileSdkVersion", Int::class.java)
                setCompileSdkVersion.invoke(android, 34)

                // Disable resource verification task for isar_flutter_libs
                tasks.matching {
                    it.name.contains("VerifyReleaseResources") || it.name.contains("VerifyLibraryResources")
                }.forEach {
                    it.enabled = false
                }
            } catch (e: Exception) {
                println("Failed to set namespace or compileSdk for isar_flutter_libs: ${e.message}")
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
