import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class VideoPlayerWidget extends StatefulWidget {
  final String? url;
  final File? file;
  final VoidCallback? onReady;
  final ValueChanged<bool>? onBuffering;
  final VoidCallback? onPlaying;
  final VoidCallback? onFinished;
  final ValueChanged<double>? onPositionChanged;
  final VoidCallback? onError;

  const VideoPlayerWidget({
    Key? key,
    this.url,
    this.file,
    this.onReady,
    this.onBuffering,
    this.onPlaying,
    this.onFinished,
    this.onPositionChanged,
    this.onError,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;
  bool _wasBuffering = false;
  bool _isPlaying = false;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    setState(() {
      _hasError = false;
      _initialized = false;
      _isFinished = false;
    });

    if (widget.file != null) {
      if (kIsWeb) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.file!.path));
      } else {
        _controller = VideoPlayerController.file(widget.file!);
      }
    } else if (widget.url != null) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url!));
    } else {
      return;
    }

    _controller.addListener(_videoListener);

    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _initialized = true;
        });
        _controller.setLooping(false); // We don't loop statuses so we know when it ends
        _controller.play();
        if (widget.onReady != null) {
          widget.onReady!();
        }
      }
    }).catchError((error) {
      print("Error initializing video player: $error");
      if (mounted) {
        setState(() {
          _hasError = true;
        });
        if (widget.onError != null) {
          widget.onError!();
        }
      }
    });
  }

  void _videoListener() {
    if (!mounted || !_controller.value.isInitialized) return;

    if (_controller.value.hasError && !_hasError) {
      setState(() { _hasError = true; });
      if (widget.onError != null) widget.onError!();
      return;
    }

    // Buffering state changes
    final isBuffering = _controller.value.isBuffering;
    if (isBuffering != _wasBuffering) {
      _wasBuffering = isBuffering;
      if (widget.onBuffering != null) {
        widget.onBuffering!(isBuffering);
      }
    }

    // Playing state changes
    final isPlaying = _controller.value.isPlaying;
    if (isPlaying != _isPlaying) {
      _isPlaying = isPlaying;
      if (isPlaying && widget.onPlaying != null) {
        widget.onPlaying!();
      }
    }

    // Progress updates
    final position = _controller.value.position;
    final duration = _controller.value.duration;

    if (duration.inMilliseconds > 0) {
      final progress = position.inMilliseconds / duration.inMilliseconds;
      if (widget.onPositionChanged != null) {
        widget.onPositionChanged!(progress.clamp(0.0, 1.0));
      }

      // Check if finished
      if (position >= duration && !_isFinished) {
        _isFinished = true;
        if (widget.onFinished != null) {
          widget.onFinished!();
        }
      } else if (position < duration && _isFinished) {
        _isFinished = false; // Reset if seeking backwards
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.broken_image, color: Colors.white54, size: 48),
            const SizedBox(height: 16),
            const Text('Video not found or failed to load', style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _controller.removeListener(_videoListener);
                _controller.dispose();
                _initializePlayer();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            )
          ],
        ),
      );
    }
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)));
    }
    return GestureDetector(
      onTap: () {
        if (_controller.value.isPlaying) {
          _controller.pause();
          if (widget.onBuffering != null) widget.onBuffering!(true); // simulate buffering to pause timer
        } else {
          _controller.play();
          if (widget.onBuffering != null) widget.onBuffering!(false);
        }
        setState(() {}); // Update the play icon
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          if (!_controller.value.isPlaying && !_wasBuffering && !_isFinished)
            Container(
              decoration: const BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 64.0,
              ),
            ),
          if (_wasBuffering)
            const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107))),
        ],
      ),
    );
  }
}
