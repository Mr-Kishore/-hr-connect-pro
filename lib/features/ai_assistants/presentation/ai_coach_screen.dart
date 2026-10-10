import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../candidate_flow/presentation/providers/candidate_flow_providers.dart';

class AiCoachScreen extends ConsumerStatefulWidget {
  const AiCoachScreen({super.key});

  @override
  ConsumerState<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends ConsumerState<AiCoachScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'assistant',
      'text':
          'Hello Aditya! I am your sandboxed AI Career Coach. I can analyze your target job requirements, pinpoint skill gaps, or run an interactive L1 Technical Mock Interview with real-time scorecard evaluation.',
    },
  ];
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage({String? predefinedText}) {
    final text = predefinedText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      if (predefinedText == null) {
        _messageController.clear();
      }
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;

      String reply;
      final lower = text.toLowerCase();
      if (lower.contains('mock') || lower.contains('simulate')) {
        reply =
            '🎯 Great choice! Launching the interactive L1 Mock Technical Interview simulator below. You will be evaluated across Architecture Maturity, State Management, and Production Resilience.';
      } else if (lower.contains('skill gap') || lower.contains('fintech')) {
        reply =
            '📊 Fintech Innovations prioritizes: (1) Idempotent transaction handling in offline-first apps, (2) Redlock mutexes for preventing double-tap booking race conditions, and (3) SEC/DPDP data redaction in memory dumps.';
      } else {
        reply =
            '💡 Tip: When self-booking your interview rounds, choose morning slots between 10:00 AM - 12:00 PM for higher panel engagement. Make sure your GitHub project links in your profile are public!';
      }

      setState(() {
        _messages.add({'role': 'assistant', 'text': reply});
        _isLoading = false;
      });

      if (lower.contains('mock') || lower.contains('simulate')) {
        _launchMockSimulator();
      }
    });
  }

  Future<void> _launchMockSimulator() async {
    final repo = ref.read(candidateRepositoryProvider);
    final questions = await repo.generateMockInterviewQuestions(
      role: 'Senior Flutter Engineer',
      focusSkills: const ['Riverpod', 'Clean Architecture', 'Resilience'],
      stage: 'L1 Technical Screening',
    );

    if (!mounted) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _MockInterviewSimulatorSheet(
        questions: questions,
        onEvaluate: (question, answer) => repo.evaluateMockAnswer(
          question: question,
          candidateAnswer: answer,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final assistantBubbleColor = isDark
        ? AppColors.cardDark
        : AppColors.cardDark.withValues(alpha: 0.08);
    final assistantTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Career Coach & Mock Prep'),
        actions: [
          IconButton(
            tooltip: 'Simulate L1 Interview',
            icon: const Icon(Icons.psychology_outlined),
            onPressed: _launchMockSimulator,
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick action chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: const Border(
                bottom: BorderSide(color: AppColors.borderLight, width: 0.6),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActionChip(
                    avatar: const Icon(
                      Icons.play_circle_outline,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    label: const Text(
                      'Simulate L1 Mock Interview',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onPressed: _launchMockSimulator,
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(
                      Icons.analytics_outlined,
                      size: 16,
                      color: AppColors.accent,
                    ),
                    label: const Text('Analyze Skill Gaps'),
                    onPressed: () => _sendMessage(
                      predefinedText:
                          'What are my key skill gaps for Fintech Innovations?',
                    ),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    label: const Text('Interview Slot Tips'),
                    onPressed: () => _sendMessage(
                      predefinedText:
                          'Give me best practices for self-booking interview rounds.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Chat history
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 10.0,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primary : assistantBubbleColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['text'] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.white : assistantTextColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          // Input bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask about matches or request mock questions...',
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MockInterviewSimulatorSheet extends StatefulWidget {
  final List<String> questions;
  final Future<Map<String, dynamic>> Function(String question, String answer)
      onEvaluate;

  const _MockInterviewSimulatorSheet({
    required this.questions,
    required this.onEvaluate,
  });

  @override
  State<_MockInterviewSimulatorSheet> createState() =>
      _MockInterviewSimulatorSheetState();
}

class _MockInterviewSimulatorSheetState
    extends State<_MockInterviewSimulatorSheet> {
  int _currentIndex = 0;
  final _answerController = TextEditingController();
  bool _evaluating = false;
  Map<String, dynamic>? _lastEvaluation;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _submitForEvaluation() async {
    final text = _answerController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please type your response first.')),
      );
      return;
    }

    setState(() => _evaluating = true);
    final question = widget.questions[_currentIndex];
    final result = await widget.onEvaluate(question, text);

    if (mounted) {
      setState(() {
        _evaluating = false;
        _lastEvaluation = result;
      });
    }
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answerController.clear();
        _lastEvaluation = null;
      });
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.accent,
          content: Text('🎉 L1 Mock Interview completed! Check your scorecard.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions.isNotEmpty
        ? widget.questions[_currentIndex]
        : 'Describe your state management architecture in production.';

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'L1 Mock Simulator (${_currentIndex + 1}/${widget.questions.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                question,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _answerController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Provide your architectural explanation or coding approach...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (_evaluating)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_lastEvaluation != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'AI Scorecard Assessment',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${_lastEvaluation!['score']} / 10 • ${_lastEvaluation!['rating']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastEvaluation!['critique'] as String? ?? '',
                      style: const TextStyle(fontSize: 12, height: 1.3),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Identified Strengths:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                    ...((_lastEvaluation!['keyStrengths'] as List<dynamic>? ??
                            [])
                        .map(
                          (s) => Text(
                            '• $s',
                            style: const TextStyle(fontSize: 11),
                          ),
                        )),
                    const SizedBox(height: 6),
                    const Text(
                      'Areas to Refine:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                    ...((_lastEvaluation!['recommendedAdditions']
                                as List<dynamic>? ??
                            [])
                        .map(
                          (s) => Text(
                            '• $s',
                            style: const TextStyle(fontSize: 11),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _nextQuestion,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    _currentIndex < widget.questions.length - 1
                        ? 'Next Practice Question'
                        : 'Finish Mock Interview',
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitForEvaluation,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Evaluate My Answer (AI Scorecard)'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
