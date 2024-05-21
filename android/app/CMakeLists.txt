cmake_minimum_required(VERSION 3.4.1)

set (APP_SOURCES
        src/main/cpp/oboe_ffi.cpp
        src/main/cpp/FloatBuffer.cpp
        src/main/cpp/AudioEngine.cpp
)

add_library (oboe_ffi SHARED ${APP_SOURCES})

# Build the Oboe library
set (OBOE_DIR ../../../../../../oboe)
add_subdirectory (${OBOE_DIR} ./oboe)

# Make the Oboe public headers available to our app
include_directories (${OBOE_DIR}/include )

# Specify the libraries which our native library is dependent on, including Oboe
target_link_libraries (oboe_ffi android log oboe)