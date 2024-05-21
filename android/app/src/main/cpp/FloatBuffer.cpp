
#include "FloatBuffer.h"


FloatBuffer::FloatBuffer(int maxSize) : maxSize(maxSize) {}


int FloatBuffer::push(float* sourceBuffer, size_t length) {
    std::lock_guard<std::mutex> lock(m_mutex);
    for (int i = 0; i < length; i++) {
        if(m_queue.size() == maxSize) return i;
        m_queue.push(sourceBuffer[i]);
    }
    return length;
}

void FloatBuffer::forcePush(float *sourceBuffer, size_t length) {
    std::lock_guard<std::mutex> lock(m_mutex);
    for (int i = 0; i < length; i++) {
        if(m_queue.size() == maxSize) {
            m_queue.pop();
        };
        m_queue.push(sourceBuffer[i]);
    }
}

int FloatBuffer::pop(float* destBuffer, size_t length) {
    std::lock_guard<std::mutex> lock(m_mutex);
    for (int i = 0; i < length; i++) {
        if(m_queue.empty()) {
            return i;
        } else {
            destBuffer[i] = m_queue.front();
            m_queue.pop();
        }
    }
    return length;
}

void FloatBuffer::forcePop(float *destBuffer, size_t length) {
    std::lock_guard<std::mutex> lock(m_mutex);
    for (int i = 0; i < length; i++) {
        if(m_queue.empty()) {
            destBuffer[i] = 0;
        } else {
            destBuffer[i] = m_queue.front();
            m_queue.pop();
        }
    }
}

void FloatBuffer::clear() {
    std::lock_guard<std::mutex> lock(m_mutex);
    while(!m_queue.empty()) {
        m_queue.pop();
    }
}
