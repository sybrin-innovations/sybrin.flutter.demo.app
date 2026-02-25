package com.demo.bioid_flutter

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import com.sybrin.facecomparison.SybrinFacialComparison
import com.sybrin.facecomparison.SybrinFacialComparisonConfiguration
import com.sybrin.identity.SybrinIdentity
import com.sybrin.identity.SybrinIdentityConfiguration
import com.sybrin.identity.data.model.southafrica.SouthAfricaGreenBookModel
import com.sybrin.identity.data.model.southafrica.SouthAfricaIDCardModel
import com.sybrin.identity.data.model.southafrica.SouthAfricaPassportModel
import com.sybrin.identity.enums.Country
import com.sybrin.livenessdetection.SybrinLivenessDetection
import com.sybrin.livenessdetection.SybrinLivenessDetectionConfiguration
import com.sybrin.livenessdetection.SybrinLivenessVersion

/**
 * Flutter MethodChannel bridge for the BioID demo app.
 *
 * Only the properties confirmed in the original BioID Android app are accessed:
 *   - GreenBook  → model.documentImage
 *   - Passport   → model.portraitImage
 *   - IDCard     → model.documentImage
 *   - Liveness   → result.selfieImage
 *   - FaceCompare→ result.averageConfidence
 *
 * No other model fields (surname, names, etc.) are accessed – the original app
 * only logs the full model object and does not individually read those fields.
 */
class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.demo.bioid/sybrin"
    }

    private lateinit var sybrinIdentity: SybrinIdentity
    private lateinit var livenessDetection: SybrinLivenessDetection
    private lateinit var faceCompare: SybrinFacialComparison

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── SDK configuration (mirrors BioID/app/src/main/java/com/demo/bioid/MainActivity.kt) ──

        val identityConfig = SybrinIdentityConfiguration
            .Builder()
            .enableMultiPhaseVerification(false)
            .enableImageQualityAssessment(false)
            .enableAutoCropping(false)
            .setEnvironmentKey(SDKConfig.IDENTITY_KEY)
            .build()

        val livenessConfig = SybrinLivenessDetectionConfiguration
            .Builder()
            .setLivenessVersion(SybrinLivenessVersion.LIVENESS_V3)
            .setEnvironmentKey(SDKConfig.BIOMETRICS_KEY)
            .build()

        val faceCompareConfig = SybrinFacialComparisonConfiguration
            .Builder()
            .setEnvironmentKey(SDKConfig.BIOMETRICS_KEY)
            .build()

        sybrinIdentity = SybrinIdentity.getInstance(this, identityConfig)
        livenessDetection = SybrinLivenessDetection.getInstance(this, livenessConfig)
        faceCompare = SybrinFacialComparison.getInstance(this, faceCompareConfig)

        // ── Method channel ──────────────────────────────────────────────────────

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "scanGreenBook"  -> handleScanGreenBook(result)
                "scanPassport"   -> handleScanPassport(result)
                "scanIdCard"     -> handleScanIdCard(result)
                "startLiveness"  -> handleLiveness(result)
                "compareFaces"   -> {
                    val targetBytes  = call.argument<ByteArray>("targetFace")
                    val facesBytes   = call.argument<List<ByteArray>>("faces")
                    handleCompareFaces(targetBytes, facesBytes, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    // ── Identity handlers ───────────────────────────────────────────────────────

    private fun handleScanGreenBook(result: MethodChannel.Result) {
        sybrinIdentity.scanGreenBook()
            .addOnSuccessListener {
                val model = it.castToModel(SouthAfricaGreenBookModel::class.java)
                val data = mutableMapOf<String, Any?>()

                // Only documentImage is confirmed in the original BioID app.
                model.documentImage?.let { bmp -> data["portraitBytes"] = bitmapToBytes(bmp) }

                result.success(data)
            }
            .addOnFailureListener { ex ->
                result.error("GREEN_BOOK_FAILED", ex.message, null)
            }
            .addOnCancelListener {
                result.error("SCAN_CANCELLED", "Green Book scan was cancelled.", null)
            }
    }

    private fun handleScanPassport(result: MethodChannel.Result) {
        sybrinIdentity.scanPassport(Country.SouthAfrica)
            .addOnSuccessListener {
                val model = it.castToModel(SouthAfricaPassportModel::class.java)
                val data = mutableMapOf<String, Any?>()

                // portraitImage confirmed in BioID MainActivity.kt (line 94: targetFace = passport.portraitImage)
                model.portraitImage?.let { bmp -> data["portraitBytes"] = bitmapToBytes(bmp) }

                result.success(data)
            }
            .addOnFailureListener { ex ->
                result.error("PASSPORT_FAILED", ex.message, null)
            }
            .addOnCancelListener {
                result.error("SCAN_CANCELLED", "Passport scan was cancelled.", null)
            }
    }

    private fun handleScanIdCard(result: MethodChannel.Result) {
        sybrinIdentity.scanIDCard(Country.SouthAfrica)
            .addOnSuccessListener {
                val model = it.castToModel(SouthAfricaIDCardModel::class.java)
                val data = mutableMapOf<String, Any?>()

                // documentImage confirmed in BioID MainActivity.kt (line 108: targetFace = id.documentImage)
                model.documentImage?.let { bmp -> data["portraitBytes"] = bitmapToBytes(bmp) }

                result.success(data)
            }
            .addOnFailureListener { ex ->
                result.error("ID_CARD_FAILED", ex.message, null)
            }
            .addOnCancelListener {
                result.error("SCAN_CANCELLED", "ID Card scan was cancelled.", null)
            }
    }

    // ── Biometrics handlers ─────────────────────────────────────────────────────

    private fun handleLiveness(result: MethodChannel.Result) {
        livenessDetection.openPassiveLivenessDetection()
            .addOnSuccessListener {
                val data = mutableMapOf<String, Any?>()
                // selfieImage confirmed in BioID MainActivity.kt (line 121-122)
                it.selfieImage?.let { bmp -> data["portraitBytes"] = bitmapToBytes(bmp) }
                // Liveness SDK does not expose a confidence score in the original app;
                // default to 1.0 to indicate the check passed.
                data["confidence"] = 1.0
                result.success(data)
            }
            .addOnFailureListener { ex ->
                result.error("LIVENESS_FAILED", ex.message, null)
            }
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

        val targetBitmap = BitmapFactory.decodeByteArray(targetBytes, 0, targetBytes.size)
        // Build Bitmap array – mirrors BioID MainActivity.kt (line 134: faceCompare.compareFaces(target, faces.toTypedArray()))
        val faceBitmaps: Array<Bitmap?> = facesBytes
            .map { bytes -> BitmapFactory.decodeByteArray(bytes, 0, bytes.size) }
            .toTypedArray()

        faceCompare.compareFaces(targetBitmap, faceBitmaps)
            .addOnSuccessListener {
                // averageConfidence confirmed in BioID MainActivity.kt (line 136)
                result.success(mapOf("averageConfidence" to it.averageConfidence.toDouble()))
            }
            .addOnFailureListener { ex ->
                result.error("FACE_COMPARE_FAILED", ex.message, null)
            }
    }

    // ── Helpers ─────────────────────────────────────────────────────────────────

    private fun bitmapToBytes(bitmap: Bitmap): ByteArray {
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.JPEG, 90, stream)
        return stream.toByteArray()
    }
}
