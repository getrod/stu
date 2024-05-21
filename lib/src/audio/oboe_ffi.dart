import 'dart:ffi';

typedef create_stream = Pointer<Void> Function(Int32, Int32, Int32, Int32);
typedef OboeffiCreateStream = Pointer<Void> Function(int, int, int, int);

typedef dispose_stream = Void Function(Pointer<Void>);
typedef OboeffiDisposeStream = void Function(Pointer<Void>);

typedef get_sample_rate = Int32 Function(Pointer<Void>);
typedef OboeffiGetSampleRate = int Function(Pointer<Void>);

typedef get_frames_per_callback = Int32 Function(Pointer<Void>);
typedef OboeffiGetFramesPerCallback = int Function(Pointer<Void>);

typedef get_channel_count = Int32 Function(Pointer<Void>);
typedef OboeffiGetChannelCount = int Function(Pointer<Void>);

typedef get_latency_factor = Int32 Function(Pointer<Void>);
typedef OboeffiGetLatencyFactor = int Function(Pointer<Void>);

typedef start_stream = Void Function(Pointer<Void>);
typedef OboeffiStartStream = void Function(Pointer<Void>);

typedef stop_stream = Void Function(Pointer<Void>);
typedef OboeffiStopStream = void Function(Pointer<Void>);

typedef push_to_output_buffer = Int32 Function(Pointer<Void>, Pointer<Float>, Int32);
typedef OboeffiPushToOutputBuffer = int Function(Pointer<Void> instance, Pointer<Float> buffer, int length);

typedef get_from_input_buffer = Int32 Function(Pointer<Void>, Pointer<Float>, Int32);
typedef OboeffiGetFromInputBuffer = int Function(Pointer<Void> instance, Pointer<Float> buffer, int length);

class Oboeffi {
  static Oboeffi _instance;

  factory Oboeffi() {
    if(_instance == null) {
      _instance = Oboeffi._();
    }
    return _instance;
  }

  OboeffiCreateStream createStream;
  OboeffiDisposeStream disposeStream;
  OboeffiGetSampleRate getSampleRate;
  OboeffiGetFramesPerCallback getFramesPerCallback;
  OboeffiGetChannelCount getChannelCount;
  OboeffiGetLatencyFactor getLatencyFactor;
  OboeffiStartStream startStream;
  OboeffiStopStream stopStream;
  OboeffiPushToOutputBuffer pushToOutputBuffer;
  OboeffiGetFromInputBuffer getFromInputBuffer;

  Oboeffi._() {
    final nativeOboeLib = DynamicLibrary.open("liboboe_ffi.so");
    
    createStream = nativeOboeLib
      .lookup<NativeFunction<create_stream>>("create_stream")
      .asFunction();

    disposeStream = nativeOboeLib
      .lookup<NativeFunction<dispose_stream>>("dispose_stream")
      .asFunction();
    
    getSampleRate = nativeOboeLib
      .lookup<NativeFunction<get_sample_rate>>("get_sample_rate")
      .asFunction();
    
    getFramesPerCallback = nativeOboeLib
      .lookup<NativeFunction<get_frames_per_callback>>("get_frames_per_callback")
      .asFunction();

    getChannelCount = nativeOboeLib
      .lookup<NativeFunction<get_channel_count>>("get_channel_count")
      .asFunction();

    getLatencyFactor = nativeOboeLib
      .lookup<NativeFunction<get_latency_factor>>("get_latency_factor")
      .asFunction();
    
    startStream = nativeOboeLib
      .lookup<NativeFunction<start_stream>>("start_stream")
      .asFunction();

    stopStream = nativeOboeLib
      .lookup<NativeFunction<stop_stream>>("stop_stream")
      .asFunction();

    pushToOutputBuffer = nativeOboeLib
      .lookup<NativeFunction<push_to_output_buffer>>("push_to_output_buffer")
      .asFunction();
    
    getFromInputBuffer = nativeOboeLib
      .lookup<NativeFunction<get_from_input_buffer>>("get_from_input_buffer")
      .asFunction();
  }
}