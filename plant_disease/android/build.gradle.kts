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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
subprojects {
    // 1. Tetap paksa Namespace seperti tadi
    if (name == "tflite_v2") {
        plugins.withType<com.android.build.gradle.LibraryPlugin> {
            extensions.configure<com.android.build.gradle.LibraryExtension> {
                namespace = "sq.flutter.tflite" // Gunakan namespace asli mereka agar sinkron
                compileSdk = 34
            }
        }

        // 2. Hapus atribut 'package' dari AndroidManifest.xml secara paksa
        afterEvaluate {
            val manifestFile = file("src/main/AndroidManifest.xml")
            if (manifestFile.exists()) {
                val content = manifestFile.readText()
                if (content.contains("package=\"sq.flutter.tflite\"")) {
                    println("Scrubbing package attribute from tflite_v2 manifest...")
                    val updatedContent = content.replace("package=\"sq.flutter.tflite\"", "")
                    manifestFile.writeText(updatedContent)
                }
            }
        }
    }
}