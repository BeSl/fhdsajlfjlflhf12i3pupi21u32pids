import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

/// Inline voice-message player: a play/pause button, a progress bar and a timer.
/// Plays either an out-of-band URL or inline (base64-decoded) bytes.
class VoicePlayer extends StatefulWidget {
  const VoicePlayer({
    super.key,
    this.url,
    this.bytes,
    required this.durationMs,
    required this.tint,
    required this.textColor,
  });

  final String? url;
  final Uint8List? bytes;
  final int durationMs;
  final Color tint;
  final Color textColor;

  @override
  State<VoicePlayer> createState() => _VoicePlayerState();
}

class _VoicePlayerState extends State<VoicePlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _total = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.durationMs > 0) {
      _total = Duration(milliseconds: widget.durationMs);
    }
    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _playing = state == PlayerState.playing);
    });
    _player.onDurationChanged.listen((d) {
      if (mounted && d > Duration.zero) setState(() => _total = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() {
        _playing = false;
        _position = Duration.zero;
      });
    });
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player.pause();
      return;
    }
    try {
      if (widget.url != null) {
        await _player.play(UrlSource(widget.url!));
      } else if (widget.bytes != null) {
        await _player.play(BytesSource(widget.bytes!));
      }
    } catch (_) {
      // Playback failed (unsupported codec / network); leave the button idle.
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString();
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final total = _total.inMilliseconds > 0 ? _total : Duration(milliseconds: widget.durationMs);
    final progress = total.inMilliseconds > 0
        ? (_position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final remaining = _playing && _position > Duration.zero ? (total - _position) : total;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      GestureDetector(
        onTap: _toggle,
        child: Icon(_playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
            color: widget.tint, size: 34),
      ),
      const SizedBox(width: 8),
      SizedBox(
        width: 120,
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 3,
          backgroundColor: widget.tint.withOpacity(0.3),
          color: widget.tint,
        ),
      ),
      const SizedBox(width: 8),
      Text(_fmt(remaining), style: TextStyle(color: widget.textColor, fontSize: 12)),
    ]);
  }
}
