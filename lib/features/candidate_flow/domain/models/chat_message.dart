class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isFromCandidate;
  final bool isRedacted;
  final String? safetyNotice;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isFromCandidate,
    this.isRedacted = false,
    this.safetyNotice,
  });
}
