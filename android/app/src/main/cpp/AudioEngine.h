
#ifndef AUDIO_STREAM_AUDIOENGINE_H
#define AUDIO_STREAM_AUDIOENGINE_H

#include "oboe/Oboe.h"
#include "FloatBuffer.h"
#include "cmath"
#include "android/log.h"

class AudioEngine : public oboe::AudioStreamCallback{
public:
    AudioEngine(int sampleRate, int framesPerCallback, int channelCount, int latencyFactor);
    ~AudioEngine();
    oboe::DataCallbackResult
    onAudioReady(oboe::AudioStream *oboeStream, void *audioData, int32_t numFrames) override;
    void startStream();
    void stopStream();
    int getSampleRate();
    int getFramesPerCallback();
    int getChannelCount();
    int getLatencyFactor();

    oboe::AudioStream * getOutStream();
    oboe::AudioStream * getInStream();

    float* getInputData();
    float* getOutputData();

    FloatBuffer *outputBuffer = nullptr;
    FloatBuffer *inputBuffer = nullptr;
private:
    oboe::AudioStream *m_outStream = nullptr;
    oboe::AudioStream *m_inStream = nullptr;
    float* m_inputData = nullptr;
    float* m_outputData = nullptr;
    int m_latencyFactor;
};

#endif //AUDIO_STREAM_AUDIOENGINE_H
