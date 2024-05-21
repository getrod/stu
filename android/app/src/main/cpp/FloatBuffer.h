
#ifndef AUDIO_STREAM_FLOATBUFFER_H
#define AUDIO_STREAM_FLOATBUFFER_H
#include <mutex>
#include <queue>
#include <iostream>

class FloatBuffer {
public:
    FloatBuffer(int maxSize);
    int push(float* sourceBuffer, size_t length);
    void forcePush(float* sourceBuffer, size_t length);
    int pop(float* destBuffer, size_t length);
    void forcePop(float* destBuffer, size_t length);
    void clear();
	const int maxSize;
private:
    std::queue<float> m_queue;
    std::mutex m_mutex;
};

#endif //AUDIO_STREAM_FLOATBUFFER_H
