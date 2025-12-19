import 'package:flutter/material.dart';

/*
 * Classroom Tabs
 * 
 * Tabbed content area showing Chat and Polls sections.
 * Currently displays demo/placeholder content.
 * In production, this would connect to real chat and poll systems.
 */
class ClassroomTabs extends StatelessWidget {
  const ClassroomTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            indicatorColor: Color(0xFF6B48FF),
            labelColor: Color(0xFF6B48FF),
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Chat'),
              Tab(text: 'Polls'),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _DemoChatList(),
                _DemoPolls(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*
 * Demo chat message list.
 * Shows placeholder messages to demonstrate the chat UI.
 */
class _DemoChatList extends StatelessWidget {
  const _DemoChatList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 20,
      reverse: true,
      itemBuilder: (context, index) {
        final isMe = index % 3 == 0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.primaries[index % Colors.primaries.length],
                  child: Text(
                    'U$index',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFF6B48FF) : const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                ),
                child: Text(
                  'This is a demo chat message #$index',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/*
 * Demo polls section.
 * Shows placeholder poll cards to demonstrate the poll UI.
 */
class _DemoPolls extends StatelessWidget {
  const _DemoPolls();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPollCard(
          question: 'What is the capital of France?',
          options: ['London', 'Berlin', 'Paris', 'Madrid'],
        ),
        _buildPollCard(
          question: 'Which framework is best?',
          options: ['Flutter', 'React Native', 'SwiftUI', 'Jetpack Compose'],
        ),
      ],
    );
  }

  Widget _buildPollCard({
    required String question,
    required List<String> options,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.poll, color: Color(0xFF6B48FF), size: 20),
              const SizedBox(width: 8),
              Text(
                'Live Poll',
                style: TextStyle(
                  color: Colors.purple[200],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          ...options.map((opt) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(opt, style: const TextStyle(color: Colors.white70)),
                    const Spacer(),
                    const Icon(Icons.circle_outlined, color: Colors.white24, size: 20),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
