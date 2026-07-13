import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/call_provider.dart';
import '../../shared.dart';
import 'call_screen.dart';

class IncomingCallOverlay extends StatefulWidget {
  final Widget child;
  const IncomingCallOverlay({super.key, required this.child});

  @override
  State<IncomingCallOverlay> createState() => _IncomingCallOverlayState();
}

class _IncomingCallOverlayState extends State<IncomingCallOverlay> {
  bool _isShowing = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Consumer<CallProvider>(
          builder: (context, callProvider, _) {
            if (callProvider.callState == CallState.incoming && !_isShowing) {
              _isShowing = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showIncomingCallDialog(context, callProvider);
              });
            } else if (callProvider.callState != CallState.incoming && _isShowing) {
              _isShowing = false;
              // If the state changes (e.g. caller hung up), the dialog will be dismissed
              final navState = sharedNavigatorKey.currentState;
              if (navState != null && navState.canPop()) {
                navState.pop();
              }
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  void _showIncomingCallDialog(BuildContext context, CallProvider callProvider) {
    final navContext = sharedNavigatorKey.currentContext ?? context;
    showDialog(
      context: navContext,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (BuildContext dialogContext) {
        return WillPopScope(
          onWillPop: () async => false, // Prevent back button
          child: AlertDialog(
            backgroundColor: const Color(0xFF131A22),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Column(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFF1A3B6E),
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  callProvider.remoteUserName ?? 'Unknown Caller',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  callProvider.isVideo ? 'Incoming Video Call' : 'Incoming Voice Call',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              InkWell(
                onTap: () {
                  callProvider.rejectCall();
                  Navigator.of(dialogContext).pop();
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Icon(Icons.call_end, color: Colors.white, size: 30),
                ),
              ),
              InkWell(
                onTap: () {
                  callProvider.acceptCall();
                  Navigator.of(dialogContext).pop();
                  final navState = sharedNavigatorKey.currentState;
                  navState?.push(
                    MaterialPageRoute(builder: (_) => const CallScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  child: const Icon(Icons.call, color: Colors.white, size: 30),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      _isShowing = false;
    });
  }
}
