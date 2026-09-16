import java.net.URI
import java.util.Base64
import java.util.Properties

val validateProductionRelease = tasks.register("validateProductionRelease") {
    group = "verification"
    description = "Reject release builds without production URLs and upload signing."
    doLast {
        val defines = (project.findProperty("dart-defines") as? String).orEmpty()
            .split(',').filter { it.isNotBlank() }.associate { encoded ->
                val decoded = String(Base64.getDecoder().decode(encoded), Charsets.UTF_8)
                val parts = decoded.split('=', limit = 2)
                parts[0] to parts.getOrElse(1) { "" }
            }
        for (key in listOf("API_BASE_URL", "SOCKET_BASE_URL")) {
            val uri = runCatching { URI(defines[key].orEmpty()) }.getOrNull()
            val host = uri?.host.orEmpty().lowercase()
            val privateHost = host == "localhost" || !host.contains('.') ||
                host.endsWith(".localhost") || host.endsWith(".local") ||
                host.endsWith(".test") || host.endsWith(".invalid") ||
                host.endsWith(".example") || host == "example.com" ||
                host.endsWith(".example.com") ||
                host.matches(Regex("[0-9.]+")) || host.contains(':')
            check(uri?.scheme == "https" && !privateHost && uri.userInfo == null &&
                uri.rawQuery == null && uri.rawFragment == null &&
                (key != "API_BASE_URL" || uri.path.endsWith("/api"))) {
                "$key must be an explicit public HTTPS production URL (API path ends in /api)."
            }
        }
        val signing = Properties()
        val propertiesFile = rootProject.file("key.properties")
        if (propertiesFile.isFile) propertiesFile.inputStream().use { signing.load(it) }
        check(listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
            .all { !signing.getProperty(it).isNullOrBlank() }) {
            "Configure android/key.properties with your upload keystore; debug signing is not allowed for release."
        }
        check(rootProject.file(signing.getProperty("storeFile")).isFile) {
            "The configured upload keystore file does not exist."
        }
        check(signing.getProperty("keyAlias") != "androiddebugkey") {
            "Use a release upload key, not the Android debug key."
        }
    }
}
tasks.configureEach {
    if (name == "preReleaseBuild") dependsOn(validateProductionRelease)
}
