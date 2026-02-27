package com.demo.bioid_flutter

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import com.sybrin.facecomparison.SybrinFacialComparison
import com.sybrin.facecomparison.SybrinFacialComparisonConfiguration
import com.sybrin.identity.SybrinIdentity
import com.sybrin.identity.SybrinIdentityConfiguration
import com.sybrin.identity.enums.Document
import com.sybrin.identity.models.DocumentModel
import com.sybrin.livenessdetection.SybrinLivenessDetection
import com.sybrin.livenessdetection.SybrinLivenessDetectionConfiguration
import com.sybrin.livenessdetection.SybrinLivenessVersion
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.demo.bioid/sybrin"
        private val DATE_FMT = SimpleDateFormat("yyyy-MM-dd", Locale.US)
    }

    private lateinit var sybrinIdentity: SybrinIdentity
    private lateinit var livenessDetection: SybrinLivenessDetection
    private lateinit var faceCompare: SybrinFacialComparison

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        sybrinIdentity =
                SybrinIdentity.getInstance(
                        this,
                        SybrinIdentityConfiguration.Builder()
                                .enableMultiPhaseVerification(false)
                                .enableImageQualityAssessment(false)
                                .enableAutoCropping(false)
                                .setEnvironmentKey(SDKConfig.IDENTITY_KEY)
                                .build()
                )

        livenessDetection =
                SybrinLivenessDetection.getInstance(
                        this,
                        SybrinLivenessDetectionConfiguration.Builder()
                                .setLivenessVersion(SybrinLivenessVersion.LIVENESS_V3)
                                .setEnvironmentKey(SDKConfig.BIOMETRICS_KEY)
                                .build()
                )

        faceCompare =
                SybrinFacialComparison.getInstance(
                        this,
                        SybrinFacialComparisonConfiguration.Builder()
                                .setEnvironmentKey(SDKConfig.BIOMETRICS_KEY)
                                .build()
                )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call,
                result ->
            when (call.method) {
                "scanDocument" -> {
                    val docName = call.argument<String>("document")
                    val doc = docName?.let { runCatching { Document.valueOf(it) }.getOrNull() }
                    if (doc == null) {
                        result.error("INVALID_DOCUMENT", "Unknown document: $docName", null)
                    } else {
                        handleScanDocument(doc, result)
                    }
                }
                "startLiveness" -> handleLiveness(result)
                "compareFaces" ->
                        handleCompareFaces(
                                call.argument("targetFace"),
                                call.argument("faces"),
                                result
                        )
                else -> result.notImplemented()
            }
        }
    }

    // ── Universal document scanner ──────────────────────────────────────────────

    private fun handleScanDocument(doc: Document, result: MethodChannel.Result) {
        sybrinIdentity
                .scanDocument(doc)
                .addOnSuccessListener { model -> result.success(buildResultMap(doc, model)) }
                .addOnFailureListener { ex -> result.error("SCAN_FAILED", ex.message, null) }
                .addOnCancelListener { result.error("SCAN_CANCELLED", "Scan was cancelled.", null) }
    }

    /** Extracts all readable fields from any concrete DocumentModel via reflection. */
    private fun buildResultMap(doc: Document, model: DocumentModel): Map<String, Any?> {
        val data = mutableMapOf<String, Any?>()

        data["documentType"] = doc.name
        data["country"] = doc.country.name
        data["docCategory"] = doc.documentType.name

        model.portraitImage?.let { data["portraitBytes"] = bitmapToBytes(it) }
        model.croppedDocumentImage?.let { data["croppedDocumentBytes"] = bitmapToBytes(it) }
        model.documentImage?.let { data["documentImageBytes"] = bitmapToBytes(it) }

        // Walk the concrete class's declared fields (the @JvmField data-class properties)
        val skipTypes = setOf("Bitmap", "Rect", "DocumentCropOffsets")
        val skipNames =
                setOf(
                        "portraitImage",
                        "documentImage",
                        "croppedDocumentImage",
                        "documentBackImage",
                        "portraitBackImage",
                        "croppedDocumentBackImage"
                )

        for (field in model.javaClass.declaredFields) {
            field.isAccessible = true
            val name = field.name
            if (name.startsWith("$") || skipNames.contains(name)) continue
            if (skipTypes.contains(field.type.simpleName)) continue

            val value = field.get(model) ?: continue
            val label = camelToLabel(name)
            data[label] =
                    when (value) {
                        is java.util.Date -> DATE_FMT.format(value)
                        is Enum<*> -> value.name
                        else -> value.toString()
                    }
        }

        return data.filterValues { it != null && it.toString().isNotBlank() }
    }

    /** "dateOfBirth" → "Date Of Birth" */
    private fun camelToLabel(s: String): String =
            s.replaceFirstChar { it.uppercase() }.replace(Regex("([a-z])([A-Z])")) {
                "${it.groupValues[1]} ${it.groupValues[2]}"
            }

    // ── Biometrics ──────────────────────────────────────────────────────────────

    private fun handleLiveness(result: MethodChannel.Result) {
        livenessDetection
                .openPassiveLivenessDetection()
                .addOnSuccessListener {
                    val data = mutableMapOf<String, Any?>()
                    it.selfieImage?.let { bmp -> data["portraitBytes"] = bitmapToBytes(bmp) }
                    data["confidence"] = it.livenessConfidence.toDouble()
                    data["isAlive"] = it.isAlive
                    data["hasFaceMask"] = it.hasFaceMask()
                    result.success(data)
                }
                .addOnFailureListener { ex -> result.error("LIVENESS_FAILED", ex.message, null) }
                .addOnCancelListener {
                    result.error("SCAN_CANCELLED", "Liveness detection was cancelled.", null)
                }
    }

    private fun handleCompareFaces(
            targetBytes: ByteArray?,
            facesBytes: List<ByteArray>?,
            result: MethodChannel.Result
    ) {
        if (targetBytes == null || facesBytes.isNullOrEmpty()) {
            result.error("INVALID_ARGS", "targetFace and at least one face are required.", null)
            return
        }
        val target = BitmapFactory.decodeByteArray(targetBytes, 0, targetBytes.size)
        val faces =
                facesBytes
                        .map { BitmapFactory.decodeByteArray(it, 0, it.size) }
                        .toTypedArray<Bitmap?>()
        faceCompare
                .compareFaces(target, faces)
                .addOnSuccessListener {
                    result.success(mapOf("averageConfidence" to it.averageConfidence.toDouble()))
                }
                .addOnFailureListener { ex ->
                    result.error("FACE_COMPARE_FAILED", ex.message, null)
                }
    }

    // ── Helpers ─────────────────────────────────────────────────────────────────

    private fun bitmapToBytes(bitmap: Bitmap): ByteArray =
            ByteArrayOutputStream()
                    .also { bitmap.compress(Bitmap.CompressFormat.JPEG, 90, it) }
                    .toByteArray()

    private fun Date.fmt(): String = DATE_FMT.format(this)
}
