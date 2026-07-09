import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/status_provider.dart';
import '../../services/api_client.dart';
import 'video_player_widget.dart';

class StoryViewerWidget extends StatefulWidget {
  final List<StatusUpdate> statuses;
  final bool isCurrentUser;
  final String currentUserId;

  const StoryViewerWidget({
    Key? key,
    required this.statuses,
    required this.isCurrentUser,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<StoryViewerWidget> createState() => _StoryViewerWidgetState();
}

class _StoryViewerWidgetState extends State<StoryViewerWidget> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentIndex = 0;
  bool _isMediaLoaded = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });
    _startAnimation();
  }

  void _startAnimation() {
    _animationController.stop();
    _animationController.reset();
    _isMediaLoaded = false;
    
    final currentStatus = widget.statuses[_currentIndex];
    if (currentStatus.type == 'VIDEO') {
      _animationController.duration = const Duration(seconds: 15);
      // Will start animation when onReady is called
    } else if (currentStatus.type == 'IMAGE') {
      _animationController.duration = const Duration(seconds: 5);
      // Will start animation when loadingBuilder reports loadingProgress == null
    } else {
      _animationController.duration = const Duration(seconds: 5);
      _isMediaLoaded = true;
      _animationController.forward();
    }
  }

  void _nextStory() {
    if (_currentIndex < widget.statuses.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startAnimation();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startAnimation();
    } else {
      _startAnimation(); // restart current
    }
  }

  void _onTapDown(TapDownDetails details) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    if (dx < screenWidth / 3) {
      _previousStory();
    } else {
      _nextStory();
    }
  }

  Future<void> _deleteCurrentStatus() async {
    _animationController.stop();
    final statusId = widget.statuses[_currentIndex].id;
    final success = await Provider.of<StatusProvider>(context, listen: false).deleteStatus(statusId);
    if (success && mounted) {
      showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Notification"), content: Text('Status deleted!'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]));
      Navigator.pop(context);
    } else {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.statuses[_currentIndex];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onLongPressStart: (_) => _animationController.stop(),
        onLongPressEnd: (_) => _animationController.forward(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF0C1017),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.statuses.length,
                itemBuilder: (context, index) {
                  final s = widget.statuses[index];
                  final baseUrl = ApiClient.instance.options.baseUrl;
                  return Center(
                    child: s.type == 'IMAGE' && s.mediaUrl != null
                      ? Image.network(
                          '$baseUrl${s.mediaUrl}', 
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              if (index == _currentIndex && !_isMediaLoaded) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted) {
                                    setState(() { _isMediaLoaded = true; });
                                    _animationController.forward();
                                  }
                                });
                              }
                              return child;
                            }
                            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)));
                          },
                          errorBuilder: (context, error, stackTrace) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted && index == _currentIndex && !_isMediaLoaded) {
                                setState(() { _isMediaLoaded = true; });
                                _animationController.forward();
                              }
                            });
                            return const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.broken_image, color: Colors.white54, size: 48),
                                  SizedBox(height: 16),
                                  Text('Image not found', style: TextStyle(color: Colors.white54)),
                                ],
                              ),
                            );
                          },
                        )
                      : s.type == 'VIDEO' && s.mediaUrl != null
                        ? AbsorbPointer(
                            child: VideoPlayerWidget(
                              url: '$baseUrl${s.mediaUrl}',
                              onReady: () {
                                if (index == _currentIndex && !_isMediaLoaded) {
                                  if (mounted) {
                                    setState(() { _isMediaLoaded = true; });
                                    _animationController.forward();
                                  }
                                }
                              },
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              s.content,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 32, fontStyle: FontStyle.italic),
                            ),
                          ),
                  );
                },
              ),
              
              if (status.type != 'TEXT' && status.content.isNotEmpty)
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      status.content,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              
              // Top Bar with progress and user info
              Positioned(
                top: 40,
                left: 10,
                right: 10,
                child: Column(
                  children: [
                    Row(
                      children: List.generate(
                        widget.statuses.length,
                        (index) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return LinearProgressIndicator(
                                  value: _getProgressValue(index),
                                  backgroundColor: Colors.white38,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(status.userName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(_formatTime(status.createdAt), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (widget.isCurrentUser)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: _deleteCurrentStatus,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getProgressValue(int index) {
    if (index < _currentIndex) return 1.0;
    if (index == _currentIndex) return _animationController.value;
    return 0.0;
  }
}
