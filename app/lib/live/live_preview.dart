import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import '../api/api_client.dart';

/// A video-only subscription to the same LiveKit room used by the web app.
class LivePreview extends StatefulWidget {
  const LivePreview({super.key, required this.liveId});
  final int liveId;
  @override
  State<LivePreview> createState() => _LivePreviewState();
}

class _LivePreviewState extends State<LivePreview> {
  final _room = Room(roomOptions: const RoomOptions(adaptiveStream: true));
  late final EventsListener<RoomEvent> _events;
  String? _error;

  @override
  void initState() {
    super.initState();
    _room.addListener(_changed);
    _events = _room.createListener()
      ..on<TrackPublishedEvent>((event) {
        if (event.publication.kind == TrackType.VIDEO) {
          event.publication.subscribe().catchError((Object error) {
            _failed(error);
          });
        }
      });
    _connect();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  void _failed(Object error) {
    if (mounted) setState(() => _error = apiErrorMessage(error));
  }

  Future<void> _connect() async {
    try {
      final media = await ApiClient.instance.dio.post(
        '/live/${widget.liveId}/media-token',
      );
      if (!mounted) return;
      await _room.connect(
        '${media.data['url']}',
        '${media.data['token']}',
        connectOptions: const ConnectOptions(autoSubscribe: false),
      );
      if (!mounted) {
        await _room.disconnect();
        return;
      }
      for (final participant in _room.remoteParticipants.values) {
        for (final publication in participant.videoTrackPublications) {
          await publication.subscribe();
        }
      }
      _changed();
    } catch (error) {
      _failed(error);
    }
  }

  @override
  void dispose() {
    _room.removeListener(_changed);
    _events.dispose();
    _room.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tracks = _room.remoteParticipants.values
        .expand((p) => p.videoTrackPublications)
        .map((p) => p.track)
        .whereType<VideoTrack>();
    return ColoredBox(
      color: Colors.black,
      child: tracks.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _error ?? 'Waiting for creator…',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : VideoTrackRenderer(tracks.first, fit: VideoViewFit.cover),
    );
  }
}
