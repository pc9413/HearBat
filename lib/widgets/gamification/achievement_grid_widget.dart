import 'package:flutter/material.dart';
import 'package:hearbat/gamification/achievement_model.dart';

class AchievementGridWidget extends StatelessWidget {
  final List<Achievement> achievements;
  final bool showOnlyUnlocked;

  const AchievementGridWidget({
    super.key,
    required this.achievements,
    this.showOnlyUnlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayAchievements = showOnlyUnlocked
        ? achievements.where((a) => a.isUnlocked).toList()
        : achievements;

    if (displayAchievements.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: displayAchievements.length,
      itemBuilder: (context, index) {
        return _buildAchievementCard(context, displayAchievements[index]);
      },
    );
  }

  Widget _buildAchievementCard(BuildContext context, Achievement achievement) {
    final isLocked = !achievement.isUnlocked;

    return GestureDetector(
      onTap: () => _showAchievementDetail(context, achievement),
      child: Container(
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey[200] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLocked
                ? Colors.grey[300]!
                : Color.fromARGB(255, 110, 211, 97),
            width: 2,
          ),
          boxShadow: [
            if (!isLocked)
              BoxShadow(
                color: Color.fromARGB(255, 110, 211, 97).withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              _getIconData(achievement.iconName),
              size: 40,
              color: isLocked
                  ? Colors.grey[400]
                  : _getCategoryColor(achievement.category),
            ),
            SizedBox(height: 8),

            // Name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                achievement.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isLocked ? Colors.grey[500] : Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // XP badge
            if (!isLocked) ...[
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 12, color: Colors.amber[700]),
                    SizedBox(width: 2),
                    Text(
                      '+${achievement.xpReward}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[900],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Lock icon
            if (isLocked) ...[
              SizedBox(height: 4),
              Icon(Icons.lock, size: 16, color: Colors.grey[400]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No achievements yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Keep practicing to unlock achievements!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetail(BuildContext context, Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getIconData(achievement.iconName),
              color: achievement.isUnlocked
                  ? _getCategoryColor(achievement.category)
                  : Colors.grey[400],
              size: 32,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                achievement.name,
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Text(
                  '${achievement.xpReward} XP',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (achievement.isUnlocked) ...[
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Unlocked ${_formatDate(achievement.unlockedAt!)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'hearing':
        return Icons.hearing;
      case 'star':
        return Icons.star;
      case 'check_circle':
        return Icons.check_circle;
      case 'abc':
        return Icons.abc;
      case 'record_voice_over':
        return Icons.record_voice_over;
      case 'music_note':
        return Icons.music_note;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'access_time':
        return Icons.access_time;
      case 'military_tech':
        return Icons.military_tech;
      case 'chat':
        return Icons.chat;
      case 'favorite':
        return Icons.favorite;
      default:
        return Icons.emoji_events;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'streak':
        return Colors.orange;
      case 'accuracy':
        return Colors.blue;
      case 'completion':
        return Colors.green;
      case 'practice':
        return Colors.purple;
      case 'companion':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
