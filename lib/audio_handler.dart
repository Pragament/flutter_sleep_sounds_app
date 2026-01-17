import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  List<String> _playlist = [];
  int _currentIndex = 0;

  MyAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());

    _player.playerStateStream.listen((state) {
      playbackState.add(
        playbackState.value.copyWith(
          playing: state.playing,
          controls: [
            MediaControl.skipToPrevious,
            state.playing ? MediaControl.pause : MediaControl.play,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.play,
            MediaAction.pause,
            MediaAction.skipToNext,
            MediaAction.skipToPrevious,
            MediaAction.stop,
          },
          processingState: const {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[state.processingState]!,
        ),
      );
    });
  }

  Future<void> setPlaylist(List<String> files, int startIndex) async {
    _playlist = files;
    _currentIndex = startIndex;
    await _playCurrent();
  }

  Future<void> _playCurrent() async {
    final file = _playlist[_currentIndex];
    if (file.startsWith('assets/')) {
      await _player.setAsset(file);
    } else {
      await _player.setFilePath(file);
    }
    await _player.play();
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> skipToNext() async {
    print("Bluetooth NEXT pressed");
    if (_playlist.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _playlist.length;
    await _playCurrent();
  }

  @override
  Future<void> skipToPrevious() async {
    print("Bluetooth NEXT skipToPrevious");
    if (_playlist.isEmpty) return;
    _currentIndex =
        (_currentIndex - 1 + _playlist.length) % _playlist.length;
    await _playCurrent();
  }

  @override
  Future<void> stop() => _player.stop();
}

