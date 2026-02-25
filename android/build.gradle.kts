import java.util.Properties

// Load local.properties so secrets stay off version control.
val localProps = Properties().apply {
    val f = file("local.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}

allprojects {
    repositories {
        google()
        mavenCentral()

        // ── Sybrin Identity SDK (private GitHub Packages) ─────────────────
        // Hosts: sybrin-android-sdk-identity (v2.3.2)
        // Credentials are read from android/local.properties — never committed.
        maven {
            url = uri("https://maven.pkg.github.com/sybrin-innovations/Sybrin-Android-SDK-Identity")
            credentials {
                username = localProps.getProperty("sybrin.username") ?: ""
                password = localProps.getProperty("sybrin.token")    ?: ""
            }
        }

        // ── JitPack ───────────────────────────────────────────────────────
        // Hosts: sybrin biometrics SDKs (liveness v1.6.1, facialcomparison v1.6.1)
        maven {
            url = uri("https://jitpack.io")
        }
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
