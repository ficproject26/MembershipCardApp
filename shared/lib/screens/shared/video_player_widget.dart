import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class VideoPlayerWidget extends StatefulWidget {
  final String? url;
  final File? file;
  final VoidCallback? onReady;

  const VideoPlayerWidget({Key? key, this.url, this.file, this.onReady}) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.file != null) {
      if (kIsWeb) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.file!.path));
      } else {
        _controller = VideoPlayerController.file(widget.file!);
      }
    } else if (widget.url != null) {
      // Use network for older versions or networkUrl for newer versions
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url!));
    } else {
      return;
    }

    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _initialized = true;
        });
        _controller.setLooping(true);
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
        if (widget.onReady != null) {
          // Trigger onReady anyway so the animation can proceed or the user can skip
          widget.onReady!();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image, color: Colors.white54, size: 48),
            SizedBox(height: 16),
            Text('Video not found or failed to load', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)));
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          _controller.value.isPlaying ? _controller.pause() : _controller.play();
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          if (!_controller.value.isPlaying)
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
        ],
      ),
    );
  }
}
