import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/gradient_button.dart';
import 'classroom_screen.dart';

/*
 * Join Screen
 * 
 * Collects session configuration from user:
 * - Organization ID (from your dashboard)
 * - Room ID (the classroom identifier)
 * - Participant name and email
 * - API URL (for testing against different environments)
 * 
 * Validates input before attempting API call to get token.
 */
class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  // Form controllers
  final _apiUrlController = TextEditingController(text: 'https://api.verriflo.com');
  final _orgIdController = TextEditingController();
  final _roomIdController = TextEditingController();
  final _nameController = TextEditingController(text: 'Test User');
  final _emailController = TextEditingController(text: 'test@example.com');

  bool _isLoading = false;

  @override
  void dispose() {
    _apiUrlController.dispose();
    _orgIdController.dispose();
    _roomIdController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /*
   * Attempts to join the classroom using provided credentials.
   * On success, navigates to the ClassroomScreen with the join URL.
   */
  Future<void> _handleJoin() async {
    // Validate required fields
    if (_orgIdController.text.trim().isEmpty) {
      _showError('Organization ID is required');
      return;
    }
    if (_roomIdController.text.trim().isEmpty) {
      _showError('Room ID is required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.joinClassroom(
        apiUrl: _apiUrlController.text.trim(),
        orgId: _orgIdController.text.trim(),
        roomId: _roomIdController.text.trim(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      if (result.success && result.joinUrl != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ClassroomScreen(joinUrl: result.joinUrl!),
          ),
        );
      } else {
        _showError(result.error ?? 'Failed to join classroom');
      }
    } catch (e) {
      if (mounted) _showError('Connection error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /*
   * Displays error message in a top-positioned snackbar.
   */
  void _showError(String message) {
    _showTopSnackBar(message, isError: true);
  }

  void _showTopSnackBar(String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _AnimatedSnackBar(
        message: message,
        isError: isError,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Join Session', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final horizontalPadding = isWide ? constraints.maxWidth * 0.15 : 20.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // Session details section
                  _buildFormCard(
                    title: 'Session Details',
                    icon: Icons.meeting_room_outlined,
                    children: [
                      _buildTextField(
                        label: 'Organization ID',
                        controller: _orgIdController,
                        icon: Icons.business_outlined,
                        hint: 'Enter your org ID',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Room ID',
                        controller: _roomIdController,
                        icon: Icons.tag,
                        hint: 'Enter room ID',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Participant info section
                  _buildFormCard(
                    title: 'Participant Info',
                    icon: Icons.person_outline,
                    children: [
                      _buildTextField(
                        label: 'Display Name',
                        controller: _nameController,
                        icon: Icons.badge_outlined,
                        hint: 'Your name',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Email Address',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        hint: 'your@email.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Advanced settings
                  _buildFormCard(
                    title: 'Advanced Settings',
                    icon: Icons.settings_outlined,
                    children: [
                      _buildTextField(
                        label: 'API URL',
                        controller: _apiUrlController,
                        icon: Icons.link,
                        hint: 'https://api.verriflo.com',
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Submit button
                  GradientButton(
                    text: 'Join Classroom',
                    icon: Icons.login_rounded,
                    isLoading: _isLoading,
                    onPressed: _handleJoin,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6B48FF), size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      cursorColor: const Color(0xFF6B48FF),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.5), size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6B48FF), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }
}

/*
 * Animated snackbar that slides in from the top.
 * Automatically dismisses after 3 seconds.
 */
class _AnimatedSnackBar extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const _AnimatedSnackBar({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  @override
  State<_AnimatedSnackBar> createState() => _AnimatedSnackBarState();
}

class _AnimatedSnackBarState extends State<_AnimatedSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
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
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _opacity,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: widget.isError ? Colors.red.shade700 : const Color(0xFF6B48FF),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isError ? Colors.red : const Color(0xFF6B48FF))
                        .withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
