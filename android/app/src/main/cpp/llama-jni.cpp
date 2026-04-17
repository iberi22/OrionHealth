#include <jni.h>
#include <string>
#include <vector>
#include "llama.h"
#include "common.h"
#include <android/log.h>
#include <algorithm>

#define TAG "LLAMA_JNI"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, TAG, __VA_ARGS__)

static llama_model* model = nullptr;
static llama_context* ctx = nullptr;

extern "C"
JNIEXPORT jboolean JNICALL
Java_com_orionhealth_orionhealth_1health_LlamaNative_loadModel(JNIEnv* env, jobject thiz, jstring path) {
    const char* model_path = env->GetStringUTFChars(path, nullptr);

    llama_backend_init();

    auto mparams = llama_model_default_params();
    model = llama_load_model_from_file(model_path, mparams);

    if (model == nullptr) {
        LOGE("Failed to load model from %s", model_path);
        env->ReleaseStringUTFChars(path, model_path);
        return JNI_FALSE;
    }

    auto cparams = llama_context_default_params();
    cparams.n_ctx = 2048;
    cparams.n_batch = 512;

    ctx = llama_new_context_with_model(model, cparams);

    if (ctx == nullptr) {
        LOGE("Failed to create context");
        llama_free_model(model);
        model = nullptr;
        env->ReleaseStringUTFChars(path, model_path);
        return JNI_FALSE;
    }

    LOGI("Model loaded successfully from %s", model_path);
    env->ReleaseStringUTFChars(path, model_path);
    return JNI_TRUE;
}

extern "C"
JNIEXPORT jstring JNICALL
Java_com_orionhealth_orionhealth_1health_LlamaNative_generate(JNIEnv* env, jobject thiz, jstring prompt, jint max_tokens, jfloat temperature) {
    if (ctx == nullptr) {
        return env->NewStringUTF("Model not loaded");
    }

    const char* prompt_text = env->GetStringUTFChars(prompt, nullptr);

    // Tokenize the prompt
    std::vector<llama_token> tokens_list;
    tokens_list.resize(strlen(prompt_text) + 1);
    int n_tokens = llama_tokenize(model, prompt_text, strlen(prompt_text), tokens_list.data(), tokens_list.size(), true, true);
    if (n_tokens < 0) {
        tokens_list.resize(-n_tokens);
        n_tokens = llama_tokenize(model, prompt_text, strlen(prompt_text), tokens_list.data(), tokens_list.size(), true, true);
    }
    tokens_list.resize(n_tokens);

    // Prepare for decoding
    llama_batch batch = llama_batch_init(512, 0, 1);
    for (size_t i = 0; i < tokens_list.size(); i++) {
        llama_batch_add(batch, tokens_list[i], i, { 0 }, i == tokens_list.size() - 1);
    }

    if (llama_decode(ctx, batch) != 0) {
        LOGE("llama_decode failed");
        llama_batch_free(batch);
        env->ReleaseStringUTFChars(prompt, prompt_text);
        return env->NewStringUTF("Error: llama_decode failed");
    }

    // Sampling loop
    std::string result_text = "";
    int n_cur = tokens_list.size();

    while (n_cur < n_tokens + max_tokens) {
        auto n_vocab = llama_n_vocab(model);
        auto* logits = llama_get_logits_ith(ctx, batch.n_tokens - 1);

        std::vector<llama_token_data> candidates;
        candidates.reserve(n_vocab);
        for (llama_token token_id = 0; token_id < n_vocab; token_id++) {
            candidates.push_back({ token_id, logits[token_id], 0.0f });
        }

        llama_token_data_array candidates_p = { candidates.data(), candidates.size(), false };

        // Sampling with temperature
        llama_token new_token_id;
        if (temperature <= 0.0f) {
            new_token_id = llama_sample_token_greedy(ctx, &candidates_p);
        } else {
            llama_sample_temp(ctx, &candidates_p, temperature);
            new_token_id = llama_sample_token(ctx, &candidates_p);
        }

        if (new_token_id == llama_token_eos(model)) {
            break;
        }

        char buf[128];
        int n = llama_token_to_piece(model, new_token_id, buf, sizeof(buf));
        if (n > 0) {
            result_text.append(buf, n);
        }

        llama_batch_clear(batch);
        llama_batch_add(batch, new_token_id, n_cur, { 0 }, true);

        n_cur++;

        if (llama_decode(ctx, batch) != 0) {
            LOGE("llama_decode failed in loop");
            break;
        }
    }

    llama_batch_free(batch);
    env->ReleaseStringUTFChars(prompt, prompt_text);
    return env->NewStringUTF(result_text.c_str());
}

extern "C"
JNIEXPORT void JNICALL
Java_com_orionhealth_orionhealth_1health_LlamaNative_freeModel(JNIEnv* env, jobject thiz) {
    if (ctx) {
        llama_free(ctx);
        ctx = nullptr;
    }
    if (model) {
        llama_free_model(model);
        model = nullptr;
    }
    llama_backend_free();
}
