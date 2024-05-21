import 'dart:typed_data';
import 'package:meta/meta.dart';
import 'audio_channel_view.dart';


/// An audio buffer
class AudioBuffer {
  /// Creates an empty audio buffer.
  ///
  /// The [numChannels] and [numFrames] arguments
  /// should be greater than or equal to 1.
  AudioBuffer({
    @required int numChannels,
    @required int numFrames,
  }) : this._(
            numChannels,
            numFrames,
            Float32List.fromList(List<double>.generate(
              numFrames * numChannels,
              (_) => 0,
              growable: false,
            )));

  /// Creates an audio buffer from the provided buffer.
  ///
  /// If the [buffer] argument is null, null is returned.
  /// The [numChannels] and [numFrames] arguments
  /// should be greater than or equal to 1.
  factory AudioBuffer.fromBuffer(AudioBuffer buffer) {
    if (buffer == null) return null;
    return AudioBuffer._(
      buffer.numChannels,
      buffer.numFrames,
      Float32List.fromList(buffer.raw.toList(growable: false)),
    );
  }

  /// Creates an audio buffer from raw audio data.
  ///
  /// If the [raw] argument is null, null is returned.
  /// The [numChannels] and [numFrames] arguments
  /// should be greater than or equal to 1.
  factory AudioBuffer.fromRaw({
    @required int numChannels,
    @required int numFrames,
    @required List<double> raw,
  }) {
    if (raw == null) return null;
    return AudioBuffer._(numChannels, numFrames, Float32List.fromList(raw.toList(growable: false)));
  }

  AudioBuffer._(this.numChannels, this.numFrames, this.raw)
      : assert(numChannels >= 0),
        assert(numFrames >= 0) {
    _audioChannels = List.generate(
      numChannels,
      (i) => AudioChannelView(channel: i, buffer: this),
      growable: false,
    );
  }

  /// The number of channels in the audio buffer.
  final int numChannels;

  /// The number of frames (or samples) per channel in the audio buffer.
  final int numFrames;

  /// The raw array data of the audio buffer.
  ///
  /// Avoid using this attribute to edit the audio buffer's data.
  /// Consider using [getChannel] to edit the buffer through the [AudioChannelView].
  final Float32List raw;

  List<AudioChannelView> _audioChannels;

  /// Returns the channel of the audio buffer as an [AudioChannelView].
  ///
  /// Indexing out of bounds returns null.
  AudioChannelView getChannel(int channel) {
    try {
      return _audioChannels[channel];
    } on RangeError {
      return null;
    }
  }

  /// Sets each sample in the audio buffer to 0.
  void clean() => raw.fillRange(0, raw.length, 0);

  /// Returns a copy of this audio buffer.
  AudioBuffer copy() => AudioBuffer.fromRaw(
        numChannels: this.numChannels,
        numFrames: this.numFrames,
        raw: this.raw,
      );
}
