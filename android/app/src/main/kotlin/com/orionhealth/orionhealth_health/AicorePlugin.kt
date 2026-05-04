package com.orionhealth.orionhealth_health

import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*

class AicorePlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channelAicore: MethodChannel
    private lateinit var channelGemma4: MethodChannel
    private lateinit var context: Context
    private val TAG = "OrionAicorePlugin"
    private var aicoreService: AicoreServiceKt? = null
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channelAicore = MethodChannel(flutterPluginBinding.binaryMessenger, "com.orionhealth/aicore")
        channelGemma4 = MethodChannel(flutterPluginBinding.binaryMessenger, "com.orionhealth/gemma4")
        channelAicore.setMethodCallHandler(this)
        channelGemma4.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        aicoreService = AicoreServiceKt(context)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        Log.d(TAG, "onMethodCall: ${call.method}")
        when (call.method) {
            // AICore channel methods
            "initialize" -> handleInitialize(call, result)
            "checkAvailability" -> handleCheckAvailability(result)
            "downloadModel" -> handleDownloadModel(result)
            "generateContent" -> handleGenerateContent(call, result)
            "generateContentStream" -> handleGenerateContentStream(call)
            "warmup" -> handleWarmup(result)
            // Gemma4 channel methods
            "isAvailable" -> handleIsAvailable(result)
            "generate" -> handleGemmaGenerate(call, result)
            else -> result.notImplemented()
        }
    }

    // ==================== AICore Channel ====================

    private fun handleInitialize(call: MethodCall, result: Result) {
        val useFullModel = call.argument<Boolean>("useFullModel") ?: false
        scope.launch {
            try {
                Log.d(TAG, "Initializing AICore service...")
                val success = aicoreService?.initialize(useFullModel) ?: false
                Log.d(TAG, "AICore initialization result: $success")
                withContext(Dispatchers.Main) {
                    result.success(success)
                }
            } catch (e: Exception) {
                Log.e(TAG, "AICore initialization failed", e)
                withContext(Dispatchers.Main) {
                    result.success(false)
                }
            }
        }
    }

    private fun handleCheckAvailability(result: Result) {
        val status = aicoreService?.getDownloadStatus() ?: "unavailable"
        result.success(status)
    }

    private fun handleDownloadModel(result: Result) {
        scope.launch {
            try {
                // Emit download progress events via AICore channel
                for (progress in 0..100 step 10) {
                    withContext(Dispatchers.Main) {
                        channelAicore.invokeMethod("onDownloadProgress", mapOf("progress" to progress))
                    }
                    delay(100) // Simulate download time
                }
                withContext(Dispatchers.Main) {
                    channelAicore.invokeMethod("onComplete", null)
                }
                withContext(Dispatchers.Main) {
                    result.success(true)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    channelAicore.invokeMethod("onError", mapOf("error" to (e.message ?: "Download failed")))
                }
                withContext(Dispatchers.Main) {
                    result.success(false)
                }
            }
        }
    }

    private fun handleGenerateContent(call: MethodCall, result: Result) {
        val prompt = call.argument<String>("prompt") ?: ""
        scope.launch {
            try {
                val response = aicoreService?.generateContent(prompt) ?: ""
                withContext(Dispatchers.Main) {
                    result.success(response)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.success("")
                }
            }
        }
    }

    private fun handleGenerateContentStream(call: MethodCall) {
        val prompt = call.argument<String>("prompt") ?: ""
        scope.launch {
            try {
                // Simulate token-by-token streaming
                // In a real implementation, this would use AICore's streaming API
                val response = aicoreService?.generateContent(prompt) ?: ""
                if (response.isNotEmpty()) {
                    // Simulate streaming by sending the full response as tokens
                    val words = response.split(" ")
                    for (word in words) {
                        withContext(Dispatchers.Main) {
                            channelAicore.invokeMethod("onToken", mapOf("token" to "$word "))
                        }
                        delay(50)
                    }
                } else {
                    // When no real model, send a placeholder to prevent hang
                    withContext(Dispatchers.Main) {
                        channelAicore.invokeMethod("onToken", mapOf("token" to ""))
                    }
                }
                withContext(Dispatchers.Main) {
                    channelAicore.invokeMethod("onComplete", null)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Content stream generation failed", e)
                withContext(Dispatchers.Main) {
                    channelAicore.invokeMethod("onError", mapOf("error" to (e.message ?: "Stream failed")))
                }
            }
        }
    }

    private fun handleWarmup(result: Result) {
        scope.launch {
            try {
                val success = aicoreService?.warmup() ?: false
                withContext(Dispatchers.Main) {
                    result.success(success)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.success(false)
                }
            }
        }
    }

    // ==================== Gemma4 Channel ====================

    private fun handleIsAvailable(result: Result) {
        scope.launch {
            try {
                val available = aicoreService?.isModelDownloaded() ?: false
                withContext(Dispatchers.Main) {
                    result.success(available)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.success(false)
                }
            }
        }
    }

    private fun handleGemmaGenerate(call: MethodCall, result: Result) {
        val prompt = call.argument<String>("prompt") ?: ""
        val model = call.argument<String>("model") ?: "gemma-4-e2b"
        scope.launch {
            try {
                val response = aicoreService?.generateContent(prompt) ?: ""
                withContext(Dispatchers.Main) {
                    result.success(response)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.success("")
                }
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        scope.cancel()
        channelAicore.setMethodCallHandler(null)
        channelGemma4.setMethodCallHandler(null)
    }
}
