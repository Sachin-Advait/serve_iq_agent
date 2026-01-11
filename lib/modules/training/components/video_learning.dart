import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:servelq_agent/models/training_model.dart';
import 'package:video_player/video_player.dart';

import '../cubit/training_cubit.dart';

class VideoLearning extends StatefulWidget {
  final TrainingAssignment material;

  const VideoLearning({super.key, required this.material});

  @override
  State<VideoLearning> createState() => _VideoLearningState();
}

class _VideoLearningState extends State<VideoLearning>
    with WidgetsBindingObserver {
  late VideoPlayerController _controller;

  double currentProgressPercent = 0;
  bool _sending = false;
  bool _showControls = true;

  Set<int> markedProgressPercents = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Set landscape orientation and hide system UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller =
        VideoPlayerController.networkUrl(
            Uri.parse(widget.material.cloudinaryUrl ?? 'N/A'),
          )
          ..initialize().then((_) {
            setState(() {});
            _controller.play(); // Auto-start video
          });

    _controller.addListener(_updateProgress);

    // Auto-hide controls after 3 seconds
    _autoHideControls();
  }

  void _autoHideControls() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _autoHideControls();
    }
  }

  double _getCurrentProgressPercent() {
    final v = _controller.value;
    if (!v.isInitialized || v.duration.inMilliseconds == 0) return 0;
    return ((v.position.inMilliseconds / v.duration.inMilliseconds) * 100)
        .clamp(0, 100);
  }

  Future<void> _updateProgress() async {
    currentProgressPercent = _getCurrentProgressPercent();
    print('This is percentage ==> $currentProgressPercent');

    /// For 10%
    if (currentProgressPercent >= 10 &&
        currentProgressPercent < 25 &&
        !markedProgressPercents.contains(10)) {
      markedProgressPercents.add(10);
      await _postProgress(widget.material.trainingId ?? '', 10);
    }
    /// For 25%
    else if (currentProgressPercent >= 25 &&
        currentProgressPercent < 50 &&
        !markedProgressPercents.contains(25)) {
      markedProgressPercents.add(25);
      await _postProgress(widget.material.trainingId ?? '', 25);
    }
    /// For 50%
    else if (currentProgressPercent >= 50 &&
        currentProgressPercent < 75 &&
        !markedProgressPercents.contains(50)) {
      markedProgressPercents.add(50);
      await _postProgress(widget.material.trainingId ?? '', 50);
    } else if (currentProgressPercent >= 75 &&
        currentProgressPercent < 90 &&
        !markedProgressPercents.contains(75)) {
      markedProgressPercents.add(75);
      await _postProgress(widget.material.trainingId ?? '', 75);
    } else if (currentProgressPercent >= 90 &&
        currentProgressPercent < 100 &&
        !markedProgressPercents.contains(90)) {
      markedProgressPercents.add(90);
      await _postProgress(widget.material.trainingId ?? '', 90);
    } else if (currentProgressPercent == 100 &&
        !markedProgressPercents.contains(100)) {
      markedProgressPercents.add(100);
      await _postProgress(widget.material.trainingId ?? '', 100);
    }
  }

  Future<void> _postProgress(String trainingId, int progress) async {
    if (_sending) return;
    _sending = true;

    try {
      context.read<TrainingCubit>().updateTrainingProgess(trainingId, progress);
    } finally {
      _sending = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _postProgress(
        widget.material.trainingId ?? '',
        currentProgressPercent.round(),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  void dispose() {
    // Restore orientation and system UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_updateProgress);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Player
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),

            // Controls Overlay
            if (_showControls)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              ),

            // Top Controls (Back Button & Title)
            if (_showControls)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.material.title!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Progress: ${currentProgressPercent.round()}%',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Bottom Controls (Play/Pause & Progress)
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: Colors.red,
                            bufferedColor: Colors.white30,
                            backgroundColor: Colors.white12,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),

                      // Control Buttons
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          children: [
                            // Time Display
                            Text(
                              _formatDuration(_controller.value.position),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),

                            // Rewind Button
                            IconButton(
                              icon: const Icon(
                                Icons.replay_10,
                                color: Colors.white,
                                size: 32,
                              ),
                              onPressed: () {
                                final newPosition =
                                    _controller.value.position -
                                    const Duration(seconds: 10);
                                _controller.seekTo(newPosition);
                              },
                            ),

                            const SizedBox(width: 16),

                            // Play/Pause Button
                            IconButton(
                              icon: Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 48,
                              ),
                              onPressed: () {
                                setState(() {
                                  _controller.value.isPlaying
                                      ? _controller.pause()
                                      : _controller.play();
                                });
                                if (_controller.value.isPlaying) {
                                  _autoHideControls();
                                }
                              },
                            ),

                            const Spacer(),

                            // Duration Display
                            Text(
                              _formatDuration(_controller.value.duration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
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
