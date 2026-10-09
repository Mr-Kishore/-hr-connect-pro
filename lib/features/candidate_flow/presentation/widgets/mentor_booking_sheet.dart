import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/models/mentor_profile.dart';

class MentorBookingSheet extends StatefulWidget {
  final MentorProfile mentor;
  final bool isVideoSession;

  const MentorBookingSheet({
    super.key,
    required this.mentor,
    required this.isVideoSession,
  });

  static Future<void> show(
    BuildContext context, {
    required MentorProfile mentor,
    required bool isVideoSession,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => MentorBookingSheet(
        mentor: mentor,
        isVideoSession: isVideoSession,
      ),
    );
  }

  @override
  State<MentorBookingSheet> createState() => _MentorBookingSheetState();
}

class _MentorBookingSheetState extends State<MentorBookingSheet> {
  int _selectedSlotIndex = 1;
  bool _isProcessing = false;
  bool _isConfirmed = false;

  final List<String> _slots = [
    'Today, 7:30 PM',
    'Tomorrow, 11:00 AM',
    'Tomorrow, 6:00 PM',
    'Saturday, 4:00 PM',
  ];

  Future<void> _handleConfirmPayment() async {
    setState(() => _isProcessing = true);

    // Simulate Razorpay Gateway & Escrow Lock
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _isConfirmed = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    Navigator.pop(context);

    if (widget.isVideoSession) {
      context.push('/video-room', extra: widget.mentor);
    } else {
      context.push('/mentor-chat', extra: widget.mentor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mentor = widget.mentor;
    final total = mentor.hourlyRateInr;
    final mentorPayout = (total * 0.80).round();
    final platformFee = total - mentorPayout;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isVideoSession
                        ? 'Book 1:1 In-App Video Session'
                        : 'Book 1:1 Encrypted Chat Consultation',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'With ${mentor.name} (${mentor.role} @ ${mentor.company})',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Slot Selector
          const Text(
            'Select Dedicated Prep Slot',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_slots.length, (index) {
                final isSelected = _selectedSlotIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_slots[index]),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedSlotIndex = index);
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                    ),
                    backgroundColor: const Color(0xFFF8FAFC),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          // Pricing Breakdown (Demonstrates 20% Take Rate & Unit Economics)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mentor Consultation (45m)', style: TextStyle(fontSize: 13)),
                    Text('₹$mentorPayout', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text('Platform Protection & Tech (20%)', style: TextStyle(fontSize: 13)),
                        SizedBox(width: 4),
                        Icon(Icons.info_outline, size: 13, color: AppColors.textSecondaryLight),
                      ],
                    ),
                    Text('₹$platformFee', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Fee (Escrow)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '₹$total',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Escrow Guarantee Lock Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user_outlined, color: AppColors.accent, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '100% Escrow Protected: Payment released only after satisfactory session completion.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF166534),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Confirm Button
          ElevatedButton(
            onPressed: _isProcessing || _isConfirmed ? null : _handleConfirmPayment,
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : (_isConfirmed
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text('Escrow Locked • Connecting...'),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.payment_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text('Confirm & Pay ₹$total (Razorpay Mock)'),
                        ],
                      )),
          ),
        ],
      ),
    );
  }
}
