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
    if (project.name == "isar_flutter_libs") {
        afterEvaluate {
            try {
                val android = project.extensions.getByName("android")
                val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                setNamespace.invoke(android, "dev.isar.isar_flutter_libs")

                // Disable resource verification task for isar_flutter_libs
                tasks.matching {
                    it.name.contains("VerifyReleaseResources") || it.name.contains("VerifyLibraryResources")
                }.forEach {
                    it.enabled = false
                }
            } catch (e: Exception) {
                println("Failed to set namespace for isar_flutter_libs: ${e.message}")
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
