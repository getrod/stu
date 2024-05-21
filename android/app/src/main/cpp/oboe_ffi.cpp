
#include "AudioEngine.h"
#include "android/log.h"

#ifdef __cplusplus
#define EXPORT_DART extern "C" __attribute__((visibility("default"))) __attribute__((used))
#else
#define EXPORT_DART
#endif

//extern "C" {
EXPORT_DART
void *create_stream(int32_t sampleRate, int32_t framesPerCallback, int32_t channelCount,
                    int32_t latencyFactor) {
    return new AudioEngine(sampleRate, framesPerCallback, channelCount, latencyFactor);
}

EXPORT_DART
void dispose_stream(void *stream) {
    if (stream == nullptr) return;
    auto *audioEngine = static_cast<AudioEngine *>(stream);
    delete (audioEngine);
}

EXPORT_DART
int32_t get_sample_rate(void *stream) {
    if (stream == nullptr) return -1;
    auto *audioEngine = static_cast<AudioEngine *>(stream);
    return audioEngine->getSampleRate();
}

EXPORT_DART
int32_t get_frames_per_callback(void *stream) {
    if (stream == nullptr) return -1;
    auto *audioEngine = static_cast<AudioEngine *>(stream);
    return audioEngine->getFramesPerCallback();
}

EXPORT_DART
int32_t get_channel_count(void *stream) {
    if (stream == nullptr) return -1;
    auto *audioEngine = static_cast<AudioEngine *>(stream);
    return audioEngine->getChannelCount();
}

EXPORT_DART
int32_t get_latency_factor(void *stream) {
    if (stream == nullptr) return -1;
    auto *audioEngine = static_cast<AudioEngine *>(stream);
    return audioEngine->getLatencyFactor();
}

EXPORT_DART
void start_stream(void *stream) {
    if (stream == nullptr) return;
    auto *audioEngine = static_cast<AudioEngine *>(stream);
    audioEngine->startStream();
}

EXPORT_DART
void stop_stream(void *stream) {
    if (stream == nullptr) return;
    auto *audioEngine = static_cast<AudioEngine *>(stream);
    audioEngine->stopStream();
}

EXPORT_DART
int push_to_output_buffer(void *stream, float *sourceBuffer, size_t length) {
    if (stream == nullptr) return -1;
    if (sourceBuffer == nullptr) return -1;
    auto *audioEngine = static_cast<AudioEngine *>(stream);
    return audioEngine->outputBuffer->push(sourceBuffer, length);
}
//int push_to_output_buffer(void *stream, float *sourceBuffer, size_t length) {
//    if (stream == nullptr) return -1;
//    if (sourceBuffer == nullptr) return -1;
//    auto *audioEngine = static_cast<AudioEngine *>(stream);
//
//    int samplesPushed = audioEngine->outputBuffer->push(sourceBuffer, length);
//    float* outputData = audioEngine->getOutputData();
//
//    audioEngine->outputBuffer->forcePop(outputData, audioEngine->getFramesPerCallback() * audioEngine->getChannelCount());
//
//    auto result = audioEngine->getOutStream()->write(outputData,  audioEngine->getOutStream()->getFramesPerBurst(), 200000000);
//
//    __android_log_print(ANDROID_LOG_ERROR, "AudioEngine", "write: %d", result.value());
//
//    return samplesPushed;
//}

EXPORT_DART
int get_from_input_buffer(void *stream, float *destBuffer, size_t length) {
    if (stream == nullptr) return -1;
    if (destBuffer == nullptr) return -1;
    auto *audioEngine = static_cast<AudioEngine *>(stream);
    int samplesRead = audioEngine->inputBuffer->pop(destBuffer, length);
    //__android_log_print(ANDROID_LOG_ERROR, "AudioEngine", "samplesRead: %d", samplesRead);
    return samplesRead;
}
//int get_from_input_buffer(void *stream, float *destBuffer, size_t length) {
//    if (stream == nullptr) return -1;
//    if (destBuffer == nullptr) return -1;
//    auto *audioEngine = static_cast<AudioEngine *>(stream);
//
//    float* inData = audioEngine->getInputData();
//    auto result = audioEngine->getInStream()->read(inData, audioEngine->getInStream()->getFramesPerBurst(), 0);
//    if(result != oboe::Result::OK) {
//        return -1;
//    }
//    int framesRead = result.value();
//
//    audioEngine->inputBuffer->forcePush(inData, framesRead * audioEngine->getInStream()->getChannelCount());
//
//    int samplesRead = audioEngine->inputBuffer->pop(destBuffer, length);
//    __android_log_print(ANDROID_LOG_ERROR, "AudioEngine", "samplesRead: %d", samplesRead);
//    return samplesRead;
//}


//}