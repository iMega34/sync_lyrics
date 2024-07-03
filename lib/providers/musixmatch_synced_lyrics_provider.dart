
import 'package:process_run/cmd_run.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef SyncedLyrics = List<Map<String, String>>;

class SyncedLyricsState {
  const SyncedLyricsState({this.syncedLyrics});

  final List<SyncedLyrics>? syncedLyrics;

  SyncedLyricsState copyWith({List<SyncedLyrics>? syncedLyrics}) =>
    SyncedLyricsState(syncedLyrics: syncedLyrics ?? this.syncedLyrics);
}

class SyncedLyricsNotifier extends StateNotifier<SyncedLyricsState> {
  SyncedLyricsNotifier() : super(const SyncedLyricsState());

  void loadSyncedLyrics(String lyrics) {
    final lines = List<String>.from(lyrics.split("\n"))
      ..removeLast()..removeLast();
    final syncedLyrics = List<SyncedLyrics>.from(
      lines.map((String line) => {line.substring(0, 10) : line.substring(11)})
    );
  }
}

final syncedLyricsProvider = StateNotifierProvider<SyncedLyricsNotifier, SyncedLyricsState>(
  (ref) => SyncedLyricsNotifier(),
);

/// Musixmatch synced lyrics stream provider
/// 
/// Musixmatch client to fetch synchronized lyrics for a track given its Musixmatch ID
/// 
/// Parameters:
/// - [trackID] is the Musixmatch ID for the track
/// 
/// Returns:
/// - A stream of synchronized lyrics for the track
final musixmatchSyncedLyricsStreamProvider = StreamProvider.autoDispose.family<String, String>((ref, trackID) async* {
  // Execute the Python script to fetch the synchronized lyrics
  final script = await run("python lib/utils/musixmatch.py $trackID");
  final output = script[0];

  // Check if the Python script was executed successfully
  if (output.exitCode != 0) throw ("Error executing Python script: ${output.stderr}");

  // Yield the synchronized lyrics from the Python script
  final syncedLyrcis = output.stdout;
  yield syncedLyrcis;
});
