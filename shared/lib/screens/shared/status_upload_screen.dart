import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../providers/status_provider.dart';
import 'video_player_widget.dart';

class StatusUploadScreen extends StatefulWidget {
  final File file;
  final String type; // 'IMAGE' or 'VIDEO'
  final String currentUserId;
  final String currentUserName;

  const StatusUploadScreen({
    Key? key,
    required this.file,
    required this.type,
    required this.currentUserId,
    required this.currentUserName,
  }) : super(key: key);

  @override
  State<StatusUploadScreen> createState() => _StatusUploadScreenState();
}

class _StatusUploadScreenState extends State<StatusUploadScreen> {
  final TextEditingController _captionController = TextEditingController();

  void _sendStatus() {
    final statusProvider = Provider.of<StatusProvider>(context, listen: false);
    
    // We call postMediaStatus without awaiting so it happens in background.
    // The provider will handle the isUploading state.
    statusProvider.postMediaStatus(
      widget.currentUserId,
      widget.currentUserName,
      widget.type,
      widget.file,
      content: _captionController.text.trim(),
    );

    // Pop immediately
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Preview
            Center(
              child: widget.type == 'IMAGE'
                  ? (kIsWeb
                      ? Image.network(widget.file.path, fit: BoxFit.contain)
                      : Image.file(widget.file, fit: BoxFit.contain))
                  : VideoPlayerWidget(file: widget.file),
            ),
            
            // Top Bar
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  // Additional icons can go here (Crop, Text, Edit)
                  const Icon(Icons.crop_rotate, color: Colors.white, size: 24),
                  const SizedBox(width: 16),
                  const Icon(Icons.title, color: Colors.white, size: 24),
                  const SizedBox(width: 16),
                  const Icon(Icons.edit, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                ],
              ),
            ),

            // Bottom Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.black.withOpacity(0.5),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _captionController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Add a caption...',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.add_photo_alternate, color: Colors.white54),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _sendStatus,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send, color: Colors.white, size: 20),
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
