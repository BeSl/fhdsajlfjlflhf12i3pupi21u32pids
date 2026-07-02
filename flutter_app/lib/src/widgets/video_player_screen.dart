import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Full-screen video playback for attached videos and round video notes (кружки).
class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key, required this.url, this.round = false});

  final String url;
  final bool round;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final c = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller = c;
    c.initialize().then((_) {
      if (!mounted) return;
      setState(() => _ready = true);
      c.setLooping(widget.round);
      c.play();
    }).catchError((e) {
      if (mounted) setState(() => _error = e.toString());
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    Widget content;
    if (_error != null) {
      content = const Icon(Icons.error_outline, color: Colors.white54, size: 48);
    } else if (!_ready || c == null) {
      content = const CircularProgressIndicator();
    } else {
      final player = AspectRatio(aspectRatio: c.value.aspectRatio, child: VideoPlayer(c));
      content = widget.round ? ClipOval(child: SizedBox.square(dimension: 320, child: FittedBox(fit: BoxFit.cover, child: SizedBox(width: c.value.size.width, height: c.value.size.height, child: VideoPlayer(c))))) : player;
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: content),
          Positioned(
            top: 40,
            right: 12,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          if (_ready && c != null && !widget.round)
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: IconButton(
                  iconSize: 56,
                  icon: Icon(c.value.isPlaying ? Icons.pause_circle : Icons.play_circle, color: Colors.white),
                  onPressed: () => setState(() => c.value.isPlaying ? c.pause() : c.play()),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
