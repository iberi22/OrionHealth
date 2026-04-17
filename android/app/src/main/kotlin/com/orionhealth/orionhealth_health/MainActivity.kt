package com.orionhealth.orionhealth_health

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.orionhealth/llama"
    private val llamaNative = LlamaNative()
    private val llamaLock = Any()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "loadModel" -> {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        thread {
                            val success = llamaNative.loadModel(path)
                            runOnUiThread {
                                if (success) {
                                    result.success(null)
                                } else {
                                    result.error("LOAD_FAILED", "Failed to load model", null)
                                }
                            }
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Path is null", null)
                    }
                }
                "generate" -> {
                    val prompt = call.argument<String>("prompt") ?: ""
                    val maxTokens = call.argument<Int>("maxTokens") ?: 2048
                    val temperature = call.argument<Double>("temperature")?.toFloat() ?: 0.7f
                    thread {
                        synchronized(llamaLock) {
                            val response = llamaNative.generate(prompt, maxTokens, temperature)
                            runOnUiThread {
                                result.success(response)
                            }
                        }
                    }
                }
                "freeModel" -> {
                    llamaNative.freeModel()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
