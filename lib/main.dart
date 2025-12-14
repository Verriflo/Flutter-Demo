import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:verriflo_classroom/verriflo_classroom.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verriflo SDK Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const PlayerScreen(),
    );
  }
}

// ============================================
// PLAYER SCREEN - Complete Student Flow
// ============================================
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool showPlayer = false;
  bool isLoading = false;
  String? livekitToken;
  String serverUrl = 'wss://livek.verriflo.com';
  final List<String> logs = [];
  
  // API settings
  final apiUrlController = TextEditingController(
    text: 'https://api.verriflo.com',
  );
  final orgIdController = TextEditingController();
  
  // Student details
  final roomIdController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final photoUrlController = TextEditingController();

  void _addLog(String message) {
    setState(() {
      logs.insert(0, '[${DateTime.now().toString().substring(11, 19)}] $message');
      if (logs.length > 50) logs.removeLast();
    });
  }

  Future<void> _joinClass() async {
    // Validate inputs
    if (orgIdController.text.isEmpty) {
      _addLog('Error: Organization ID required');
      return;
    }
    if (roomIdController.text.isEmpty) {
      _addLog('Error: Room ID required');
      return;
    }
    if (nameController.text.isEmpty) {
      _addLog('Error: Name required');
      return;
    }
    if (emailController.text.isEmpty) {
      _addLog('Error: Email required');
      return;
    }
    
    setState(() => isLoading = true);
    _addLog('Calling API to join class...');
    
    try {
      final response = await http.post(
        Uri.parse('${apiUrlController.text}/v1/live/sdk/join'),
        headers: {
          'Content-Type': 'application/json',
          'VF-ORG-ID': orgIdController.text,
        },
        body: jsonEncode({
          'roomId': roomIdController.text,
          'name': nameController.text,
          'email': emailController.text,
          if (photoUrlController.text.isNotEmpty) 
            'photoUrl': photoUrlController.text,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['data'] != null) {
        livekitToken = data['data']['livekitToken'];
        serverUrl = data['data']['serverUrl'] ?? 'wss://livek.verriflo.com';
        
        _addLog('Token received! Starting player...');
        setState(() {
          showPlayer = true;
          isLoading = false;
        });
      } else {
        _addLog('API Error: ${data['message'] ?? response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      _addLog('Network Error: $e');
      setState(() => isLoading = false);
    }
  }

  void _disconnect() {
    setState(() {
      showPlayer = false;
      livekitToken = null;
    });
    _addLog('Player stopped');
  }

  void _onEvent(VerrifloEvent event) {
    _addLog('Event: ${event.type.name}${event.message != null ? " - ${event.message}" : ""}');
    
    if (event.type == VerrifloEventType.classEnded) {
      _addLog('Class ended!');
      setState(() {
        showPlayer = false;
        livekitToken = null;
      });
    }
  }

  @override
  void dispose() {
    apiUrlController.dispose();
    orgIdController.dispose();
    roomIdController.dispose();
    nameController.dispose();
    emailController.dispose();
    photoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verriflo SDK Demo'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Complete SDK Flow Demo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Fill in organization & student details\n'
                    '2. API call → /v1/live/sdk/join\n'
                    '3. Receive LiveKit token\n'
                    '4. Player connects & streams video',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            
            // Video player area
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.hardEdge,
                child: showPlayer && livekitToken != null
                    ? VerrifloPlayer(
                        config: VerrifloConfig(
                          serverUrl: serverUrl,
                          token: livekitToken!,
                          debug: true,
                        ),
                        onEvent: _onEvent,
                        borderRadius: BorderRadius.circular(12),
                        showQualitySelector: true,
                        showFullscreenButton: true,
                      )
                    : Center(
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.tv, size: 64, color: Colors.white30),
                                  SizedBox(height: 16),
                                  Text(
                                    'Fill in details and tap "Join Class"',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ],
                              ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            
            // API Settings Section
            const Text('API Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: apiUrlController,
              decoration: const InputDecoration(
                labelText: 'API URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cloud),
              ),
              enabled: !showPlayer,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: orgIdController,
              decoration: const InputDecoration(
                labelText: 'Organization ID (VF-ORG-ID)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              enabled: !showPlayer,
            ),
            const SizedBox(height: 20),
            
            // Student Details Section
            const Text('Student Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: roomIdController,
              decoration: const InputDecoration(
                labelText: 'Room ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.meeting_room),
              ),
              enabled: !showPlayer,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Student Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              enabled: !showPlayer,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Student Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              enabled: !showPlayer,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: photoUrlController,
              decoration: const InputDecoration(
                labelText: 'Photo URL (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.photo),
              ),
              enabled: !showPlayer,
            ),
            const SizedBox(height: 16),
            
            // Join/Disconnect button
            ElevatedButton.icon(
              onPressed: isLoading ? null : (showPlayer ? _disconnect : _joinClass),
              icon: Icon(showPlayer ? Icons.stop : Icons.play_arrow),
              label: Text(showPlayer ? 'Leave Class' : 'Join Class'),
              style: ElevatedButton.styleFrom(
                backgroundColor: showPlayer ? Colors.red : Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            
            // Logs
            const Text('Event Logs:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) => Text(
                    logs[index],
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
