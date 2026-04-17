package com.orionhealth.orionhealth_health

import android.util.Log
import com.google.mlkit.genai.prompt.*
import kotlinx.coroutines.flow.Flow

class GemmaNativeEngine {
    
    private var generativeModel: GenerativeModel? = null
    
    fun initialize(useFullModel: Boolean = false) {
        val config = generationConfig {
            modelConfig = ModelConfig {
                releaseTrack = ModelReleaseTrack.PREVIEW
                preference = if (useFullModel) {
                    ModelPreference.FULL
                } else {
                    ModelPreference.FAST
                }
            }
        }
        
        generativeModel = GenerativeModel.getClient(config)
        Log.d(TAG, "GemmaNativeEngine initialized with ${if (useFullModel) "E4B" else "E2B"} model")
    }
    
    suspend fun checkAvailability(): FeatureStatus {
        val model = generativeModel ?: throw IllegalStateException("Model not initialized")
        return model.checkStatus()
    }
    
    suspend fun downloadModel(onProgress: (Int) -> Unit): Boolean {
        val model = generativeModel ?: return false
        
        model.download().collect { status ->
            when (status) {
                is DownloadStatus.DownloadStarted -> {
                    Log.d(TAG, "Starting Gemma download")
                }
                is DownloadStatus.DownloadProgress -> {
                    val progress = ((status.totalBytesDownloaded.toDouble() / status.totalBytesToDownload) * 100).toInt()
                    onProgress(progress)
                }
                DownloadStatus.DownloadCompleted -> {
                    Log.d(TAG, "Gemma download complete")
                }
                is DownloadStatus.DownloadFailed -> {
                    Log.e(TAG, "Download failed: ${status.error}")
                }
            }
        }
        return true
    }
    
    fun generateContentStream(prompt: String): Flow<String> {
        val model = generativeModel ?: throw IllegalStateException("Model not initialized")
        return model.generateContentStream(prompt)
    }
    
    suspend fun generateContent(prompt: String): String {
        val model = generativeModel ?: throw IllegalStateException("Model not initialized")
        val response = model.generateContent(prompt)
        return response.candidates.firstOrNull()?.text ?: ""
    }
    
    suspend fun warmup() {
        generativeModel?.warmup()
        Log.d(TAG, "Gemma warmup completed")
    }
    
    fun close() {
        generativeModel?.close()
        generativeModel = null
    }
    
    companion object {
        private const val TAG = "GemmaNativeEngine"
    }
}