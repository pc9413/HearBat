import 'package:flutter/material.dart';
import 'package:hearbat/gamification/achievement_model.dart';
import 'package:confetti/confetti.dart';

class CelebrationDialog extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final int? xpReward;
  final VoidCallback? onDismiss;

  const CelebrationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.iconColor = Colors.amber,
    this.xpReward,
    this.onDismiss,
  });

  // Factory for achievement unlocked
  factory CelebrationDialog.achievement(Achievement achievement, {VoidCallback? onDismiss}) {
    return CelebrationDialog(
      title: 'Achievement Unlocked!',
      message: achievement.name,
      icon: Icons.emoji_events,
      iconColor: Colors.amber,
      xpReward: achievement.xpReward,
      onDismiss: onDismiss,
    );
  }

  // Factory for level up
  factory CelebrationDialog.levelUp(int newLevel, String newTitle, {VoidCallback? onDismiss}) {
    return CelebrationDialog(
      title: 'Level Up!',
      message: 'Level $newLevel - $newTitle',
      icon: Icons.trending_up,
      iconColor: Color.fromARGB(255, 110, 211, 97),
      onDismiss: onDismiss,
    );
  }

  // Factory for streak milestone
  factory CelebrationDialog.streak(int streakDays, {VoidCallback? onDismiss}) {
    return CelebrationDialog(
      title: 'Streak Milestone!',
      message: '$streakDays Days in a Row!',
      icon: Icons.local_fire_department,
      iconColor: Colors.orange,
      onDismiss: onDismiss,
    );
  }

  // Factory for perfect score
  factory CelebrationDialog.perfectScore({VoidCallback? onDismiss}) {
    return CelebrationDialog(
      title: 'Perfect Score!',
      message: '100% Accuracy!',
      icon: Icons.star,
      iconColor: Colors.amber,
      xpReward: 100,
      onDismiss: onDismiss,
    );
  }

  @override
  State<CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<CelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.iconColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated icon
                  Transform.rotate(
                    angle: _rotationAnimation.value * 0.2,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: widget.iconColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        size: 60,
                        color: widget.iconColor,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Title
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 7, 45, 78),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 12),

                  // Message
                  Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // XP Reward
                  if (widget.xpReward != null) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber[700], size: 24),
                          SizedBox(width: 8),
                          Text(
                            '+${widget.xpReward} XP',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 24),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onDismiss?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 7, 45, 78),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Awesome!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Helper function to show celebration
void showCelebration(BuildContext context, CelebrationDialog celebration) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => celebration,
  );
}
