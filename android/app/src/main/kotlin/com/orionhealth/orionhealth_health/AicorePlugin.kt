package com.orionhealth.orionhealth_health

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*

class AicorePlugin : FlutterPlugin, MethodCallHandler {
    
    private lateinit var channel: MethodChannel
    private val engine = GemmaNativeEngine()
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "com.orionhealth/aicore")
        channel.setMethodCallHandler(this)
    }
    
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
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
            
            else -> result.notImplemented()
        }
    }
}