import 'package:flutter/material.dart';
import 'video_player_widget.dart';

class FullScreenViewer extends StatelessWidget {
  final String url;
  final bool isVideo;

  const FullScreenViewer({Key? key, required this.url, required this.isVideo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: isVideo 
            ? VideoPlayerWidget(url: url)
            : InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                ),
              ),
      ),
    );
  }
}
