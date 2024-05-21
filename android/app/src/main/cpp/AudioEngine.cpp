
#include "AudioEngine.h"

AudioEngine::AudioEngine(int sampleRate, int framesPerCallback, int channelCount, int latencyFactor) {
    oboe::AudioStreamBuilder inBuilder;
    inBuilder.setPerformanceMode(oboe::PerformanceMode::LowLatency);
    inBuilder.setSharingMode(oboe::SharingMode::Exclusive);
    inBuilder.setDirection(oboe::Direction::Input);
    inBuilder.setSampleRate(sampleRate);
    inBuilder.setFramesPerCallback(framesPerCallback);
    inBuilder.setChannelCount(channelCount);
    inBuilder.setFormat(oboe::AudioFormat::Float);
    inBuilder.openStream(&m_inStream);



    oboe::AudioStreamBuilder outBuilder;
	outBuilder.setPerformanceMode(oboe::PerformanceMode::LowLatency);
    outBuilder.setSharingMode(oboe::SharingMode::Exclusive);
    inBuilder.setDirection(oboe::Direction::Output);
    outBuilder.setCallback(this);
    outBuilder.setSampleRate(m_inStream->getSampleRate());
    outBuilder.setFramesPerCallback(m_inStream->getFramesPerBurst());
    outBuilder.setChannelCount(channelCount);
    outBuilder.openStream(&m_outStream);

    m_inputData = new float[m_inStream->getFramesPerBurst() *  m_inStream->getChannelCount()];
    m_outputData = new float[m_outStream->getFramesPerBurst() *  m_outStream->getChannelCount()];

    m_latencyFactor = latencyFactor;

    outputBuffer = new FloatBuffer(m_outStream->getFramesPerBurst() * m_outStream->getChannelCount() * m_latencyFactor);
    inputBuffer = new FloatBuffer(m_inStream->getFramesPerBurst() * m_inStream->getChannelCount() * m_latencyFactor);

    __android_log_print(ANDROID_LOG_ERROR, "AudioEngine", "Input---------");
    __android_log_print(ANDROID_LOG_ERROR, "AudioEngine", "FramesPerCallback: %d", m_inStream->getFramesPerBurst());
    __android_log_print(ANDROID_LOG_ERROR, "AudioEngine", "SampleRate: %d", m_inStream->getSampleRate());
    __android_log_print(ANDROID_LOG_ERROR, "AudioEngine", "ChannelCount: %d", m_inStream->getChannelCount());
    __android_log_print(ANDROID_LOG_ERROR, "AudioEngine", "Format: %s", oboe::convertToText( m_inStream->getFormat()));
    __android_log_print(ANDROID_LOG_ERROR, "AudioEngine", "FloatBuffer Size: %d", inputBuffer->maxSize);

    __android_log_print(ANDROID_LOG_ERROR, "AudioEngine", "Output---------");
	__android_log_print(ANDROID_LOG_ERROR, "AudioEngine", "FramesPerCallback: %d", m_outStream->getFramesPerBurst());
	__android_log_print(ANDROID_LOG_ERROR, "AudioEngine", "SampleRate: %d", m_outStream->getSampleRate());
	__android_log_print(ANDROID_LOG_ERROR, "AudioEngine", "ChannelCount: %d", m_outStream->getChannelCount());
    __android_log_print(ANDROID_LOG_ERROR, "AudioEngine", "Format: %s", oboe::convertToText( m_outStream->getFormat()));
    __android_log_print(ANDROID_LOG_ERROR, "AudioEngine", "FloatBuffer Size: %d", outputBuffer->maxSize);
}

AudioEngine::~AudioEngine() {
    m_outStream->close();
    m_inStream->close();
    delete(outputBuffer);
    delete(inputBuffer);
    delete(m_inputData);
    delete (m_outputData);
}

oboe::DataCallbackResult
AudioEngine::onAudioReady(oboe::AudioStream *oboeStream, void *audioData, int32_t numFrames) {
    auto *outputData = static_cast<float *>(audioData);

    // Silence output
    int32_t numBytes = numFrames * oboeStream->getBytesPerFrame();
    memset(outputData, 0 , numBytes);

    //return oboe::DataCallbackResult::Continue;


    // Read input
    auto result = m_inStream->read(m_inputData, numFrames, 0);
    if(result != oboe::Result::OK) {
        return oboe::DataCallbackResult::Stop;
    }
    int framesRead = result.value();
    //__android_log_print(ANDROID_LOG_ERROR, "AudioEngine", "framesRead: %d", framesRead);

    inputBuffer->forcePush(m_inputData, framesRead * oboeStream->getChannelCount());
    outputBuffer->forcePop(outputData, numFrames * oboeStream->getChannelCount());

    return oboe::DataCallbackResult::Continue;
}

void AudioEngine::startStream() {
    inputBuffer->clear();
    outputBuffer->clear();
    auto result = m_outStream->requestStart();
    m_inStream->requestStart();
    __android_log_print(ANDROID_LOG_ERROR, "AudioEngine", "Start Stream res: %s", oboe::convertToText(result));
}

void AudioEngine::stopStream() {
    m_outStream->requestStop();
    m_inStream->requestStop();
}

int AudioEngine::getSampleRate() {
    return m_outStream->getSampleRate();
}

int AudioEngine::getFramesPerCallback() {
    return m_outStream->getFramesPerBurst();
}

int AudioEngine::getChannelCount() {
    return m_outStream->getChannelCount();
}

int AudioEngine::getLatencyFactor() {
    return m_latencyFactor;
}

oboe::AudioStream *AudioEngine::getOutStream() {
    return m_outStream;
}

oboe::AudioStream *AudioEngine::getInStream() {
    return m_inStream;
}

float *AudioEngine::getInputData() {
    return m_inputData;
}

float *AudioEngine::getOutputData() {
    return m_outputData;
}
