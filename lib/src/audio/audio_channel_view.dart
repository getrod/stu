import 'package:meta/meta.dart';
import 'audio_buffer.dart';

/// A view that exposes an [AudioBuffer]'s channel.
class AudioChannelView {

  /// Creates an [AudioChannelView] which exposes the [channel] 
  /// data of the [AudioBuffer].
  /// 
  /// The [buffer] argument cannot be null.
  /// The [channel] argument must be less than the buffer's 
  /// total number of channels.
  AudioChannelView({
    @required this.channel,
    @required AudioBuffer buffer,
  })  : assert(buffer != null),
        assert(channel < buffer.numChannels) {
    _buffer = buffer;
  }

  /// The channel of the [AudioBuffer].
  final int channel;

  AudioBuffer _buffer;

  /// Return's [this] channel's sample at [sampleIdx].
  ///
  /// Indexing out of bounds will return 0.
  double getSample(int sampleIdx) {
    int i = (_buffer.numChannels * sampleIdx) + channel;
    return (i >= _buffer.raw.length || i.isNegative) ? 0 : _buffer.raw[i];
  }

  /// Sets the [channel]'s sample at [sampleIdx] to a new [sample].
  ///
  /// Indexing out of bounds will result in a no-op.
  void setSample(int sampleIdx, double sample) {
    int i = (_buffer.numChannels * sampleIdx) + channel;
    if (i >= _buffer.raw.length || i.isNegative) return;
    _buffer.raw[i] = sample;
  }

  void addSample(int sampleIdx, double sample) {
    int i = (_buffer.numChannels * sampleIdx) + channel;
    if (i >= _buffer.raw.length || i.isNegative) return;
    _buffer.raw[i] += sample;
  }

  void applyGain(int sampleIdx, double gain) {
    int i = (_buffer.numChannels * sampleIdx) + channel;
    if (i >= _buffer.raw.length || i.isNegative) return;
    _buffer.raw[i] *= gain;
  }
}
