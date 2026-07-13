import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../providers/call_provider.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CallProvider>(
      builder: (context, callProvider, child) {
        if (callProvider.callState == CallState.idle) {
          // If the call ended, automatically pop the screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          });
          return const Scaffold(body: Center(child: Text("Call ended")));
        }

        final isIncoming = callProvider.callState == CallState.incoming;
        final isOutgoing = callProvider.callState == CallState.outgoing;
        final inCall = callProvider.callState == CallState.inCall;

        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                // Remote Video Fullscreen
                if (callProvider.isVideo && inCall && callProvider.remoteUid != null && callProvider.engine != null)
                  Positioned.fill(
                    child: AgoraVideoView(
                      controller: VideoViewController.remote(
                        rtcEngine: callProvider.engine!,
                        canvas: VideoCanvas(uid: callProvider.remoteUid),
                        connection: RtcConnection(channelId: callProvider.channelName),
                      ),
                    ),
                  ),

                // Background gradient for text readability / voice calls
                if (!inCall || !callProvider.isVideo || callProvider.remoteUid == null)
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A3B6E), Colors.black],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                // Top Info Section
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        callProvider.remoteUserName ?? 'Unknown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isIncoming
                            ? 'Incoming ${callProvider.isVideo ? 'Video' : 'Voice'} Call...'
                            : isOutgoing
                                ? 'Calling...'
                                : callProvider.formattedDuration,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (callProvider.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Text(
                            callProvider.errorMessage!,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Local Video PIP (Picture in Picture)
                if (callProvider.isVideo && (inCall || isOutgoing) && callProvider.engine != null)
                  Positioned(
                    right: 20,
                    bottom: 120,
                    width: 100,
                    height: 150,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white30, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: callProvider.engine!,
                            canvas: const VideoCanvas(uid: 0),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Bottom Action Buttons
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (inCall || isOutgoing) ...[
                        // Mute Button
                        _buildActionButton(
                          icon: callProvider.isMicMuted ? Icons.mic_off : Icons.mic,
                          color: callProvider.isMicMuted ? Colors.white : Colors.white24,
                          iconColor: callProvider.isMicMuted ? Colors.black : Colors.white,
                          onPressed: () => callProvider.toggleMic(),
                        ),
                        // Video Toggle Button
                        if (callProvider.isVideo)
                          _buildActionButton(
                            icon: callProvider.isCameraOff ? Icons.videocam_off : Icons.videocam,
                            color: callProvider.isCameraOff ? Colors.white : Colors.white24,
                            iconColor: callProvider.isCameraOff ? Colors.black : Colors.white,
                            onPressed: () => callProvider.toggleCamera(),
                          ),
                        // Switch Camera Button
                        if (callProvider.isVideo)
                          _buildActionButton(
                            icon: Icons.switch_camera,
                            color: Colors.white24,
                            iconColor: Colors.white,
                            onPressed: () => callProvider.switchCamera(),
                          ),
                        // Speakerphone Toggle Button
                        _buildActionButton(
                          icon: callProvider.isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                          color: callProvider.isSpeakerOn ? Colors.white : Colors.white24,
                          iconColor: callProvider.isSpeakerOn ? Colors.black : Colors.white,
                          onPressed: () => callProvider.toggleSpeaker(),
                        ),
                        // Hang Up Button
                        _buildActionButton(
                          icon: Icons.call_end,
                          color: Colors.red,
                          iconColor: Colors.white,
                          onPressed: () => callProvider.endCall(),
                        ),
                      ],
                      if (isIncoming) ...[
                        // Accept Call
                        _buildActionButton(
                          icon: Icons.call,
                          color: Colors.green,
                          iconColor: Colors.white,
                          onPressed: () => callProvider.acceptCall(),
                        ),
                        // Reject Call
                        _buildActionButton(
                          icon: Icons.call_end,
                          color: Colors.red,
                          iconColor: Colors.white,
                          onPressed: () => callProvider.rejectCall(),
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 30),
      ),
    );
  }
}
