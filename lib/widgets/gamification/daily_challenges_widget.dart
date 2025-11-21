import 'package:flutter/material.dart';
import 'package:hearbat/gamification/daily_challenge_model.dart';

class DailyChallengesWidget extends StatelessWidget {
  final List<DailyChallenge> challenges;
  final VoidCallback? onRefresh;

  const DailyChallengesWidget({
    super.key,
    required this.challenges,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (challenges.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Daily Challenges',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            if (onRefresh != null)
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.grey[600]),
                onPressed: onRefresh,
              ),
          ],
        ),
        SizedBox(height: 12),
        ...challenges.map((challenge) => _buildChallengeCard(challenge)),
      ],
    );
  }

  Widget _buildChallengeCard(DailyChallenge challenge) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: challenge.isCompleted ? Colors.green[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: challenge.isCompleted
              ? Colors.green
              : Color.fromARGB(255, 7, 45, 78),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Challenge icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: challenge.isCompleted
                      ? Colors.green
                      : Color.fromARGB(255, 7, 45, 78),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconForType(challenge.type),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),

              // Challenge info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      challenge.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // XP reward
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber[700]),
                    SizedBox(width: 4),
                    Text(
                      '+${challenge.xpReward}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[900],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: challenge.progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      challenge.isCompleted
                          ? Colors.green
                          : Color.fromARGB(255, 110, 211, 97),
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Text(
                challenge.isCompleted
                    ? 'Complete!'
                    : '${challenge.currentProgress}/${challenge.targetValue}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: challenge.isCompleted ? Colors.green : Colors.grey[700],
                ),
              ),
            ],
          ),

          // Completion checkmark
          if (challenge.isCompleted) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 18),
                SizedBox(width: 6),
                Text(
                  'Challenge completed!',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            SizedBox(height: 12),
            Text(
              'No challenges available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'practice_time':
        return Icons.timer;
      case 'module_complete':
        return Icons.school;
      case 'accuracy':
        return Icons.insights;
      case 'streak':
        return Icons.local_fire_department;
      default:
        return Icons.flag;
    }
  }
}
