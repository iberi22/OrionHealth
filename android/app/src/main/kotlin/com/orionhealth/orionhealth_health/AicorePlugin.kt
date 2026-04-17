package com.orionhealth.orionhealth_health

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.app.ActivityManager
import android.content.Context
import android.os.Build
import kotlinx.coroutines.*

class AicorePlugin : FlutterPlugin, MethodCallHandler {
    
    private var context: Context? = null

    private lateinit var channel: MethodChannel
    private val engine = GemmaNativeEngine()
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "com.orionhealth/aicore")
        channel.setMethodCallHandler(this)
    }
    
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
        scope.cancel()
        engine.close()
    }
    
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> {
                val useFullModel = call.argument<Boolean>("useFullModel") ?: false
                engine.initialize(useFullModel)
                result.success(true)
            }
            
            "checkAvailability" -> {
                scope.launch {
                    val status = engine.checkAvailability()
                    result.success(status.name)
                }
            }
            
            "downloadModel" -> {
                scope.launch {
                    val success = engine.downloadModel { progress ->
                        channel.invokeMethod("onDownloadProgress", mapOf("progress" to progress))
                    }
                    result.success(success)
                }
            }
            
            "generateContent" -> {
                val prompt = call.argument<String>("prompt") ?: ""
                scope.launch {
                    try {
                        val response = engine.generateContent(prompt)
                        result.success(response)
                    } catch (e: Exception) {
                        result.error("GENERATION_ERROR", e.message, null)
                    }
                }
            }
            
            "generateContentStream" -> {
                val prompt = call.argument<String>("prompt") ?: ""
                scope.launch {
                    try {
                        engine.generateContentStream(prompt).collect { token ->
                            channel.invokeMethod("onToken", mapOf("token" to token))
                        }
                        channel.invokeMethod("onComplete", null)
                    } catch (e: Exception) {
                        channel.invokeMethod("onError", mapOf("error" to e.message))
                    }
                }
            }
            
            "warmup" -> {
                scope.launch {
                    engine.warmup()
                    result.success(true)
                }
            }

            "getSystemInfo" -> {
                val info = mutableMapOf<String, Any>()

                // RAM Info
                val activityManager = context?.getSystemService(Context.ACTIVITY_SERVICE) as? ActivityManager
                val memoryInfo = ActivityManager.MemoryInfo()
                activityManager?.getMemoryInfo(memoryInfo)

                val totalRamGb = memoryInfo.totalMem.toDouble() / (1024 * 1024 * 1024)
                info["totalRamGb"] = totalRamGb

                // Processor/GPU Info (Simplified for now, focusing on device model/brand as proxy)
                info["model"] = Build.MODEL
                info["manufacturer"] = Build.MANUFACTURER
                info["hardware"] = Build.HARDWARE
                info["glEsVersion"] = activityManager?.deviceConfigurationInfo?.glEsVersion ?: "Unknown"

                result.success(info)
            }
            
            else -> result.notImplemented()
        }
    }
}