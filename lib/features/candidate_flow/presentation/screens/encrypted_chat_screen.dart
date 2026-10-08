import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/models/mentor_profile.dart';
import '../providers/candidate_flow_providers.dart';

class EncryptedChatScreen extends ConsumerStatefulWidget {
  final MentorProfile mentor;

  const EncryptedChatScreen({super.key, required this.mentor});

  @override
  ConsumerState<EncryptedChatScreen> createState() => _EncryptedChatScreenState();
}

class _EncryptedChatScreenState extends ConsumerState<EncryptedChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? presetText]) {
    final text = presetText ?? _messageController.text;
    if (text.trim().isEmpty) return;

    ref.read(chatStateProvider.notifier).sendMessage(widget.mentor.id, text);
    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allChats = ref.watch(chatStateProvider);
    final messages = allChats[widget.mentor.id] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.mentor.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.lock_outline, size: 14, color: AppColors.accent),
              ],
            ),
            Text(
              '${widget.mentor.role} • ${widget.mentor.company}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Disintermediation Security Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFEFF6FF),
              child: const Row(
                children: [
                  Icon(Icons.security_outlined, size: 16, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'End-to-End Encrypted • Contact sharing is filtered to protect session guarantee.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Chat Message List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg.isFromCandidate;

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.78,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: isMe
                                  ? null
                                  : Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg.text,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isMe ? Colors.white : AppColors.textPrimaryLight,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (msg.safetyNotice != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.info_outline, size: 12, color: Color(0xFFD97706)),
                                  const SizedBox(width: 4),
                                  Text(
                                    msg.safetyNotice!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFD97706),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Quick Testing Presets for Client Demo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text('Test Filter:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    ActionChip(
                      label: const Text('Simulate Phone Leak', style: TextStyle(fontSize: 11)),
                      onPressed: () => _sendMessage('Call me at +91 9876543210 for direct payment'),
                    ),
                    const SizedBox(width: 6),
                    ActionChip(
                      label: const Text('Simulate Email Leak', style: TextStyle(fontSize: 11)),
                      onPressed: () => _sendMessage('Email me: aditya@gmail.com to chat outside'),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),

            // Message Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                    onPressed: () => _sendMessage(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
