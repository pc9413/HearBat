import 'package:flutter/material.dart';
import 'package:hearbat/gamification/player_profile_model.dart';

class XPLevelWidget extends StatelessWidget {
  final PlayerProfile profile;
  final bool showDetailed;

  const XPLevelWidget({
    super.key,
    required this.profile,
    this.showDetailed = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showDetailed) {
      return _buildDetailedView(context);
    } else {
      return _buildCompactView(context);
    }
  }

  Widget _buildCompactView(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 7, 45, 78),
            Color.fromARGB(255, 110, 211, 97),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Level badge
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${profile.level}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 7, 45, 78),
                  ),
                ),
                Text(
                  'LVL',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),

          // Title and XP bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: profile.progressToNextLevel,
                    backgroundColor: Colors.white30,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${profile.currentXP - LevelSystem.xpForLevel(profile.level)} / ${profile.xpForNextLevel - LevelSystem.xpForLevel(profile.level)} XP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedView(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Level circle
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: profile.progressToNextLevel,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(255, 110, 211, 97),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${profile.level}',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 7, 45, 78),
                    ),
                  ),
                  Text(
                    'LEVEL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),

          // Title
          Text(
            profile.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 7, 45, 78),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),

          // XP progress
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '${profile.currentXP} XP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '${profile.xpForNextLevel - profile.currentXP} XP to Level ${profile.level + 1}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),

          SizedBox(height: 20),
          Divider(),
          SizedBox(height: 12),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.access_time,
                value: _formatTime(profile.totalPracticeTime),
                label: 'Practice',
              ),
              _buildStatItem(
                icon: Icons.check_circle,
                value: '${profile.totalModulesCompleted}',
                label: 'Completed',
              ),
              _buildStatItem(
                icon: Icons.star,
                value: '${profile.totalPerfectScores}',
                label: 'Perfect',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Color.fromARGB(255, 7, 45, 78), size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    if (hours > 0) {
      return '${hours}h';
    }
    final minutes = seconds ~/ 60;
    return '${minutes}m';
  }
}
