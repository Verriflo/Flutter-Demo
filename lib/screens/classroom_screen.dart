import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:verriflo_classroom/verriflo_classroom.dart';

import '../widgets/classroom_tabs.dart';

/*
 * Classroom Screen
 * 
 * Main viewing area for live class content using the Verriflo SDK.
 * Features:
 * - Session sharing (Room ID & Org ID)
 * - Adaptive layout (portrait/landscape)
 * - Event handling (ended, kicked, etc.)
 */
class ClassroomScreen extends StatefulWidget {
  final String iframeUrl;
  final String roomId;
  final String orgId;

  const ClassroomScreen({
    super.key,
    required this.iframeUrl,
    required this.roomId,
    required this.orgId,
  });

  @override
  State<ClassroomScreen> createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen> {
  final GlobalKey _playerKey = GlobalKey();

  bool _isFullscreen = false;
  bool _showChatOverlay = false;

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

  void _handleShare() {
    final String message = '''
Join my Verriflo Classroom! 🚀

📍 Room ID: ${widget.roomId}
🏢 Org ID: ${widget.orgId}

Jump in here: ${widget.iframeUrl}
''';

    Share.share(message, subject: 'Invite to Verriflo Classroom');
  }

  void _handleEvent(VerrifloEvent event) {
    debugPrint(
        '[Classroom] Event: ${event.type} - ${event.message ?? event.reason ?? ''}');
  }

  void _handleStateChanged(ClassroomState state) {
    debugPrint('[Classroom] State: $state');
  }

  void _handleClassEnded() {
    if (!mounted) return;
    if (_isFullscreen) _toggleFullscreen();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title:
              const Text('Class Ended', style: TextStyle(color: Colors.white)),
          content: const Text('The instructor has ended this session.',
              style: TextStyle(color: Colors.white70)),
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

  void _handleKicked(String? reason) {
    if (!mounted) return;
    if (_isFullscreen) _toggleFullscreen();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Removed', style: TextStyle(color: Colors.white)),
          content: Text(reason ?? 'You have been removed from this classroom.',
              style: const TextStyle(color: Colors.white70)),
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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isFullscreen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isFullscreen) _toggleFullscreen();
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

  Widget _buildAdaptiveLayout(
      BuildContext context, BoxConstraints constraints) {
    final isPortrait = constraints.maxHeight > constraints.maxWidth;
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    double playerTop, playerLeft, playerWidth, playerHeight;
    double infoTop, infoHeight; // For the share section
    double contentTop, contentHeight;

    if (_isFullscreen) {
      playerTop = 0;
      playerLeft = 0;
      playerWidth = screenWidth;
      playerHeight = screenHeight;
      infoTop = 0;
      infoHeight = 0;
      contentTop = 0;
      contentHeight = 0;
    } else if (isPortrait) {
      playerLeft = 0;
      playerTop = topPadding;
      playerWidth = screenWidth;
      playerHeight = screenWidth * (9 / 16);

      infoTop = playerTop + playerHeight;
      infoHeight = 60;

      contentTop = infoTop + infoHeight;
      contentHeight = screenHeight - contentTop;
    } else {
      playerTop = topPadding;
      playerLeft = 0;
      playerHeight = screenHeight - topPadding;
      final sidebarWidth = screenWidth * 0.4 < 350 ? screenWidth * 0.4 : 350.0;
      playerWidth = screenWidth - sidebarWidth;

      infoTop = 0;
      infoHeight = 0; // Hide info bar in landscape to save space
      contentTop = topPadding;
      contentHeight = playerHeight;
    }

    return Stack(
      children: [
        if (!_isFullscreen) ...[
          // Content
          Positioned(
            top: contentTop,
            left: isPortrait ? 0 : playerWidth,
            width: isPortrait ? screenWidth : (screenWidth - playerWidth),
            height: contentHeight,
            child: const ClassroomTabs(),
          ),

          // Share bar (Portrait only)
          if (isPortrait)
            Positioned(
              top: infoTop,
              left: 0,
              width: screenWidth,
              height: infoHeight,
              child: _buildShareBar(),
            ),
        ],

        // Video Player
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: playerTop,
          left: playerLeft,
          width: playerWidth,
          height: playerHeight,
          child: VerrifloPlayer(
            key: _playerKey,
            iframeUrl: widget.iframeUrl,
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

        // App Bar
        if (!_isFullscreen)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topPadding,
            child: AppBar(
              title: const Text('Live Session'),
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                if (!isPortrait) // Show share in appbar for landscape
                  IconButton(
                    icon: const Icon(Icons.share, size: 20),
                    onPressed: _handleShare,
                  ),
              ],
            ),
          ),

        if (_isFullscreen && _showChatOverlay)
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            width: isPortrait ? screenWidth * 0.8 : 350,
            child: _buildChatOverlay(),
          ),
      ],
    );
  }

  Widget _buildShareBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Room: ${widget.roomId}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                Text('Org: ${widget.orgId}',
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _handleShare,
            icon: const Icon(Icons.share, size: 16),
            label: const Text('Invite'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B48FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.95),
        border: const Border(left: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Chat & Polls',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  IconButton(
                      onPressed: _toggleChatOverlay,
                      icon: const Icon(Icons.close, color: Colors.white)),
                ],
              ),
            ),
            const Expanded(child: ClassroomTabs()),
          ],
        ),
      ),
    );
  }
}
