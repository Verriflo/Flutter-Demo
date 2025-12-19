import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:verriflo_classroom/verriflo_classroom.dart';

import '../widgets/classroom_tabs.dart';

/*
 * Classroom Screen
 * 
 * Main viewing area for live class content using the Verriflo SDK.
 * Features:
 * - Adaptive layout (portrait/landscape)
 * - Fullscreen mode with system UI hiding
 * - Event handling for class ended, kicked, etc.
 * - Chat/Polls overlay in fullscreen mode
 * 
 * The VerrifloPlayer widget handles all video streaming via WebView.
 */
class ClassroomScreen extends StatefulWidget {
  final String token;

  const ClassroomScreen({super.key, required this.token});

  @override
  State<ClassroomScreen> createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen> {
  // Preserve player state across layout changes
  final GlobalKey _playerKey = GlobalKey();

  bool _isFullscreen = false;
  bool _showChatOverlay = false;

  /*
   * Toggle fullscreen mode.
   * Hides system UI and locks to landscape orientation.
   */
  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      _showChatOverlay = false;
    }
  }

  void _toggleChatOverlay() {
    setState(() => _showChatOverlay = !_showChatOverlay);
  }

  /*
   * Handle SDK events for logging and UI feedback.
   * Critical events (class ended, kicked) are handled via convenience callbacks.
   */
  void _handleEvent(VerrifloEvent event) {
    debugPrint('[Classroom] Event: ${event.type} - ${event.message ?? event.reason ?? ''}');

    // Track participant activity for demo purposes
    if (event.type == VerrifloEventType.participantJoined) {
      debugPrint('[Classroom] ${event.participantName} joined');
    }
    if (event.type == VerrifloEventType.participantLeft) {
      debugPrint('[Classroom] ${event.participantName} left');
    }
  }

  void _handleStateChanged(ClassroomState state) {
    debugPrint('[Classroom] State: $state');
  }

  /*
   * Handle class ended - show confirmation and navigate back.
   */
  void _handleClassEnded() {
    if (!mounted) return;

    // Exit fullscreen if active
    if (_isFullscreen) {
      _toggleFullscreen();
    }

    // Wait briefly then show dialog
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text('Class Ended', style: TextStyle(color: Colors.white)),
          content: const Text(
            'The instructor has ended this session.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  /*
   * Handle being kicked from classroom.
   */
  void _handleKicked(String? reason) {
    if (!mounted) return;

    if (_isFullscreen) {
      _toggleFullscreen();
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Row(
            children: [
              Icon(Icons.block, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Removed', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(
            reason ?? 'You have been removed from this classroom.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Leave'),
            ),
          ],
        ),
      );
    });
  }

  void _handleError(String message, dynamic error) {
    debugPrint('[Classroom] Error: $message - $error');
  }

  @override
  void dispose() {
    // Reset orientation lock on exit
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isFullscreen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isFullscreen) {
          _toggleFullscreen();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return _buildAdaptiveLayout(context, constraints);
          },
        ),
      ),
    );
  }

  Widget _buildAdaptiveLayout(BuildContext context, BoxConstraints constraints) {
    final isPortrait = constraints.maxHeight > constraints.maxWidth;
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    // Calculate player and content dimensions
    double playerTop, playerLeft, playerWidth, playerHeight;
    double contentTop, contentLeft, contentWidth, contentHeight;

    if (_isFullscreen) {
      // Fullscreen covers entire screen
      playerTop = 0;
      playerLeft = 0;
      playerWidth = screenWidth;
      playerHeight = screenHeight;
      contentWidth = 0;
      contentHeight = 0;
      contentTop = 0;
      contentLeft = 0;
    } else if (isPortrait) {
      // Portrait: video on top, content below
      playerLeft = 0;
      playerTop = topPadding;
      playerWidth = screenWidth;

      final ratioHeight = screenWidth * (9 / 16);
      final maxHeight = (screenHeight - topPadding) * 0.45;
      playerHeight = ratioHeight > maxHeight ? maxHeight : ratioHeight;

      contentLeft = 0;
      contentTop = playerTop + playerHeight;
      contentWidth = screenWidth;
      contentHeight = screenHeight - contentTop;
    } else {
      // Landscape: video on left, content sidebar on right
      playerTop = topPadding;
      playerLeft = 0;
      playerHeight = screenHeight - topPadding;

      final sidebarWidth = screenWidth * 0.4 < 350 ? screenWidth * 0.4 : 350.0;
      playerWidth = screenWidth - sidebarWidth;

      contentLeft = playerWidth;
      contentTop = topPadding;
      contentWidth = sidebarWidth;
      contentHeight = playerHeight;
    }

    return Stack(
      children: [
        // Content area (chat/polls) - behind video in portrait
        if (!_isFullscreen)
          Positioned(
            top: contentTop,
            left: contentLeft,
            width: contentWidth,
            height: contentHeight,
            child: const ClassroomTabs(),
          ),

        // Video player with animated position
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: playerTop,
          left: playerLeft,
          width: playerWidth,
          height: playerHeight,
          child: VerrifloPlayer(
            key: _playerKey,
            token: widget.token,
            backgroundColor: Colors.black,
            isFullscreen: _isFullscreen,
            onFullscreenToggle: _toggleFullscreen,
            onChatToggle: _isFullscreen ? _toggleChatOverlay : null,
            onEvent: _handleEvent,
            onStateChanged: _handleStateChanged,
            onClassEnded: _handleClassEnded,
            onKicked: _handleKicked,
            onError: _handleError,
          ),
        ),

        // App bar (hidden in fullscreen)
        if (!_isFullscreen)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topPadding,
            child: AppBar(
              title: const Text('Live Session'),
              backgroundColor: Colors.black.withValues(alpha: 0.8),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

        // Fullscreen chat overlay (slide from right)
        if (_isFullscreen && _showChatOverlay)
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            width: isPortrait ? screenWidth * 0.8 : 350,
            child: _buildChatOverlay(isPortrait),
          ),
      ],
    );
  }

  Widget _buildChatOverlay(bool isPortrait) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        boxShadow: const [BoxShadow(blurRadius: 20, color: Colors.black)],
        border: const Border(left: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chat & Polls',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleChatOverlay,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white10),
            const Expanded(child: ClassroomTabs()),
          ],
        ),
      ),
    );
  }
}
