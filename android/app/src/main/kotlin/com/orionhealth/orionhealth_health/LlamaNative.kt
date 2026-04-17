package com.orionhealth.orionhealth_health

class LlamaNative {
    init {
        System.loadLibrary("llama-jni")
    }

    external fun loadModel(path: String): Boolean
    external fun generate(prompt: String, maxTokens: Int, temperature: Float): String
    external fun freeModel()
}
