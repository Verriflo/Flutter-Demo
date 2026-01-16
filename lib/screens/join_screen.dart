import 'package:flutter/material.dart';
import 'package:verriflo_classroom/verriflo_classroom.dart';

import '../services/api_service.dart';
import '../widgets/gradient_button.dart';
import 'classroom_screen.dart';

/*
 * Join/Create Screen
 * 
 * New tabbed interface to either join an existing room or create a new one.
 * Includes comprehensive customization options for room creation.
 */
class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Common controllers
  final _apiUrlController =
      TextEditingController(text: 'https://api.verriflo.com');
  final _orgIdController = TextEditingController();
  final _roomIdController = TextEditingController();
  final _nameController = TextEditingController(text: 'Test User');
  final _uidController = TextEditingController(text: 'user-123');

  // Create-specific controllers
  final _titleController = TextEditingController();

  bool _isLoading = false;

  // Customization state
  bool _showLobby = true;
  bool _showClassTitle = true;
  bool _showLogo = true;
  bool _showHeader = true;
  bool _showParticipantName = true;
  bool _showMicIndicator = true;
  bool _needChat = true;
  bool _needControlbar = true;
  bool _allowScreenShare = true;
  bool _allowHandRaise = true;
  bool _allowRecording = true;
  bool _allowIngress = false;
  final bool _validateDomain = true;
  ClassroomTheme _theme = ClassroomTheme.system;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _apiUrlController.dispose();
    _orgIdController.dispose();
    _roomIdController.dispose();
    _nameController.dispose();
    _uidController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Customization _buildCustomization() {
    return Customization(
      showLobby: _showLobby,
      showClassTitle: _showClassTitle,
      showLogo: _showLogo,
      showHeader: _showHeader,
      showParticipantName: _showParticipantName,
      showMicIndicator: _showMicIndicator,
      needChat: _needChat,
      needControlbar: _needControlbar,
      allowScreenShare: _allowScreenShare,
      allowHandRaise: _allowHandRaise,
      allowRecording: _allowRecording,
      allowIngress: _allowIngress,
      validateDomain: _validateDomain,
      theme: _theme,
    );
  }

  Future<void> _handleSubmit() async {
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
      final isCreate = _tabController.index == 1;
      JoinResult result;

      if (isCreate) {
        if (_titleController.text.trim().isEmpty) {
          _showError('Class Title is required for creation');
          setState(() => _isLoading = false);
          return;
        }
        result = await ApiService.createClassroom(
          apiUrl: _apiUrlController.text.trim(),
          orgId: _orgIdController.text.trim(),
          roomId: _roomIdController.text.trim(),
          title: _titleController.text.trim(),
          name: _nameController.text.trim(),
          uid: _uidController.text.trim(),
          customization: _buildCustomization(),
        );
      } else {
        result = await ApiService.joinClassroom(
          apiUrl: _apiUrlController.text.trim(),
          orgId: _orgIdController.text.trim(),
          roomId: _roomIdController.text.trim(),
          name: _nameController.text.trim(),
          uid: _uidController.text.trim(),
          customization: _buildCustomization(),
        );
      }

      if (!mounted) return;

      if (result.success && result.iframeUrl != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ClassroomScreen(
              iframeUrl: result.iframeUrl!,
              roomId: _roomIdController.text.trim(),
              orgId: _orgIdController.text.trim(),
            ),
          ),
        );
      } else {
        _showError(result.error ?? 'Request failed');
      }
    } catch (e) {
      if (mounted) _showError('Connection error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
      appBar: AppBar(
        title: const Text('Verriflo Classroom',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6B48FF),
          tabs: const [
            Tab(text: 'Join Class'),
            Tab(text: 'Create Class'),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Basic Configuration
              _buildFormSection(
                title: 'Basic Configuration',
                icon: Icons.settings_input_component,
                children: [
                  _buildTextField(
                    label: 'Organization ID',
                    controller: _orgIdController,
                    icon: Icons.business,
                    hint: 'Your Org ID',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'Room ID',
                    controller: _roomIdController,
                    icon: Icons.tag,
                    hint: 'math-101',
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: _tabController.index == 1
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _buildTextField(
                              label: 'Class Title',
                              controller: _titleController,
                              icon: Icons.title,
                              hint: 'Mathematics 101',
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Participant Profile
              _buildFormSection(
                title: 'Your Profile',
                icon: Icons.person,
                children: [
                  _buildTextField(
                    label: 'Display Name',
                    controller: _nameController,
                    icon: Icons.badge,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'User ID (UID)',
                    controller: _uidController,
                    icon: Icons.fingerprint,
                    hint: 'user-123',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // UI Customization
              _buildFormSection(
                title: 'UI Customization',
                icon: Icons.tune,
                children: [
                  _buildThemeDropdown(),
                  const Divider(color: Colors.white12, height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildToggle('Lobby', _showLobby,
                          (v) => setState(() => _showLobby = v)),
                      _buildToggle('Title', _showClassTitle,
                          (v) => setState(() => _showClassTitle = v)),
                      _buildToggle('Logo', _showLogo,
                          (v) => setState(() => _showLogo = v)),
                      _buildToggle('Header', _showHeader,
                          (v) => setState(() => _showHeader = v)),
                      _buildToggle('Names', _showParticipantName,
                          (v) => setState(() => _showParticipantName = v)),
                      _buildToggle('Mic Icon', _showMicIndicator,
                          (v) => setState(() => _showMicIndicator = v)),
                      _buildToggle('Chat', _needChat,
                          (v) => setState(() => _needChat = v)),
                      _buildToggle('Controls', _needControlbar,
                          (v) => setState(() => _needControlbar = v)),
                      _buildToggle('Screen Share', _allowScreenShare,
                          (v) => setState(() => _allowScreenShare = v)),
                      _buildToggle('Hand Raise', _allowHandRaise,
                          (v) => setState(() => _allowHandRaise = v)),
                      _buildToggle('Recording', _allowRecording,
                          (v) => setState(() => _allowRecording = v)),
                      _buildToggle('Ingress', _allowIngress,
                          (v) => setState(() => _allowIngress = v)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Advanced
              _buildFormSection(
                title: 'Environment',
                icon: Icons.dns,
                children: [
                  _buildTextField(
                    label: 'API URL',
                    controller: _apiUrlController,
                    icon: Icons.link,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              GradientButton(
                text: _tabController.index == 0
                    ? 'Join as Student'
                    : 'Create as Teacher',
                icon: Icons.rocket_launch,
                isLoading: _isLoading,
                onPressed: _handleSubmit,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6B48FF), size: 18),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
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
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }

  Widget _buildToggle(String label, bool value, Function(bool) onChanged) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: value,
      onSelected: onChanged,
      selectedColor: const Color(0xFF6B48FF).withValues(alpha: 0.2),
      checkmarkColor: const Color(0xFF6B48FF),
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildThemeDropdown() {
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: const Color(0xFF1A1A1A)),
      child: DropdownButtonFormField<ClassroomTheme>(
        initialValue: _theme,
        decoration: InputDecoration(
          labelText: 'UI Theme',
          prefixIcon:
              const Icon(Icons.palette, color: Colors.white38, size: 20),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
        ),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        items: ClassroomTheme.values.map((t) {
          return DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()));
        }).toList(),
        onChanged: (v) => setState(() => _theme = v!),
      ),
    );
  }
}

class _AnimatedSnackBar extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const _AnimatedSnackBar(
      {required this.message, required this.isError, required this.onDismiss});

  @override
  State<_AnimatedSnackBar> createState() => _AnimatedSnackBarState();
}

class _AnimatedSnackBarState extends State<_AnimatedSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _slide =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _controller.reverse().then((_) => widget.onDismiss());
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
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isError
                  ? Colors.red.shade900
                  : const Color(0xFF6B48FF),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 10)
              ],
            ),
            child: Row(
              children: [
                Icon(widget.isError ? Icons.error : Icons.check_circle,
                    color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(widget.message,
                        style: const TextStyle(color: Colors.white))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
