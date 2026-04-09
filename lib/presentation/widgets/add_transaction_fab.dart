import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Floating Action Button for adding new transactions.
///
/// Features premium micro-interactions:
/// - Slight scale down on press (0.96)
/// - Soft ripple effect
/// - Light haptic feedback
/// - Smooth animations (≤150ms)
class AddTransactionFAB extends StatefulWidget {
  /// Callback when FAB is pressed
  final VoidCallback onPressed;

  /// Custom tooltip text (default: "Thêm giao dịch")
  final String? tooltip;

  /// Custom hero tag (set to null to disable hero animation)
  final Object? heroTag;

  /// Disable haptic feedback
  final bool disableHapticFeedback;

  const AddTransactionFAB({
    super.key,
    required this.onPressed,
    this.tooltip,
    this.heroTag,
    this.disableHapticFeedback = false,
  });

  @override
  State<AddTransactionFAB> createState() => _AddTransactionFABState();
}

class _AddTransactionFABState extends State<AddTransactionFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  Future<void> _handlePress() async {
    // Trigger light haptic feedback
    if (!widget.disableHapticFeedback) {
      HapticFeedback.lightImpact();
    }

    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: (details) {
              _handleTapUp(details);
              _handlePress();
            },
            onTapCancel: _handleTapCancel,
            child: FloatingActionButton(
              onPressed: null, // Handled by GestureDetector
              tooltip: widget.tooltip ?? 'Thêm giao dịch',
              heroTag: widget.heroTag,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              focusElevation: 6,
              hoverElevation: 8,
              highlightElevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }
}
