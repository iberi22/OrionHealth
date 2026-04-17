cmake_minimum_required(VERSION 3.22.1)

project(llama-android)

set(CMAKE_CXX_STANDARD 17)

# llama.cpp directory
set(LLAMA_DIR ${CMAKE_CURRENT_SOURCE_DIR}/llama.cpp)

# Optimization for Android
if (ANDROID_ABI STREQUAL "arm64-v8a")
    add_compile_definitions(GGML_USE_CPU_HGET)
endif()

# Define the JNI library
# Use file(GLOB ...) to be more robust against internal structure changes,
# though explicit is usually better, GLOB is safer for this environment.
file(GLOB LLAMA_SOURCES
    "${LLAMA_DIR}/src/*.cpp"
    "${LLAMA_DIR}/common/*.cpp"
    "${LLAMA_DIR}/ggml/src/*.c"
    "${LLAMA_DIR}/ggml/src/*.cpp"
)

# Filter out main files or other binaries if necessary
list(FILTER LLAMA_SOURCES EXCLUDE REGEX ".*main\\.cpp$")
list(FILTER LLAMA_SOURCES EXCLUDE REGEX ".*server\\.cpp$")

add_library(llama-jni SHARED
        llama-jni.cpp
        ${LLAMA_SOURCES}
)

target_include_directories(llama-jni PRIVATE
        ${LLAMA_DIR}/include
        ${LLAMA_DIR}/src
        ${LLAMA_DIR}/common
        ${LLAMA_DIR}/ggml/include
        ${LLAMA_DIR}/ggml/src
)

target_link_libraries(llama-jni
        android
        log
)
