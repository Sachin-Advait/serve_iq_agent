import 'dart:html' as html; // ✅ Web fullscreen

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servelq_agent/models/training_model.dart';
import 'package:video_player/video_player.dart';

import '../cubit/training_cubit.dart';

class VideoLearningDialog extends StatefulWidget {
  final TrainingAssignment material;

  const VideoLearningDialog({super.key, required this.material});

  @override
  State<VideoLearningDialog> createState() => _VideoLearningDialogState();
}

class _VideoLearningDialogState extends State<VideoLearningDialog> {
  late VideoPlayerController _controller;
  double currentProgressPercent = 0;
  final Set<int> markedProgress = {};
  bool _sending = false;

  @override
  void initState() {
    super.initState();

    _controller =
        VideoPlayerController.networkUrl(
            Uri.parse(widget.material.cloudinaryUrl!),
          )
          ..initialize().then((_) {
            setState(() {});
            _controller.play();
          });

    _controller.addListener(_updateProgress);
  }

  double _progress() {
    final v = _controller.value;
    if (!v.isInitialized || v.duration.inMilliseconds == 0) return 0;
    return (v.position.inMilliseconds / v.duration.inMilliseconds * 100).clamp(
      0,
      100,
    );
  }

  Future<void> _updateProgress() async {
    currentProgressPercent = _progress();

    for (final p in [10, 25, 50, 75, 90, 100]) {
      if (currentProgressPercent >= p && !markedProgress.contains(p)) {
        markedProgress.add(p);
        await _postProgress(p);
      }
    }
  }

  Future<void> _postProgress(int progress) async {
    if (_sending) return;
    _sending = true;
    try {
      context.read<TrainingCubit>().updateTrainingProgess(
        widget.material.trainingId!,
        progress,
      );
    } finally {
      _sending = false;
    }
  }

  /// ✅ Browser fullscreen
  void _enterFullscreen() {
    html.document.documentElement?.requestFullscreen();
  }

  @override
  void dispose() {
    _controller.removeListener(_updateProgress);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.black,
      child: AspectRatio(
        aspectRatio: _controller.value.isInitialized
            ? _controller.value.aspectRatio
            : 16 / 9,
        child: Stack(
          children: [
            Center(
              child: _controller.value.isInitialized
                  ? VideoPlayer(_controller)
                  : const CircularProgressIndicator(color: Colors.white),
            ),

            /// 🔝 Top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.black54,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.material.title!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.fullscreen, color: Colors.white),
                      onPressed: _enterFullscreen,
                    ),
                  ],
                ),
              ),
            ),

            /// ⏯ Controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Colors.red,
                        bufferedColor: Colors.white30,
                        backgroundColor: Colors.white12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                            });
                          },
                        ),
                        const Spacer(),
                        Text(
                          '${currentProgressPercent.round()}%',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
