import 'package:flutter/material.dart';
import 'package:hearbat/gamification/achievement_model.dart';
import 'package:hearbat/gamification/gamification_db.dart';
import 'package:hearbat/widgets/gamification/achievement_grid_widget.dart';
import 'package:hearbat/widgets/top_bar_widget.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> with SingleTickerProviderStateMixin {
  final GamificationDatabase _db = GamificationDatabase();
  late TabController _tabController;

  List<Achievement> _allAchievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);

    try {
      final achievements = await _db.getAllAchievements();
      setState(() {
        _allAchievements = achievements;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading achievements: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: 'Achievements'),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatsHeader(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTabContent('all'),
                      _buildTabContent('streak'),
                      _buildTabContent('accuracy'),
                      _buildTabContent('completion'),
                      _buildTabContent('practice'),
                      _buildTabContent('companion'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsHeader() {
    final unlockedCount = _allAchievements.where((a) => a.isUnlocked).length;
    final totalCount = _allAchievements.length;
    final percentage = (unlockedCount / totalCount * 100).round();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 7, 45, 78),
            Color.fromARGB(255, 110, 211, 97),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: Colors.amber, size: 32),
              SizedBox(width: 12),
              Text(
                '$unlockedCount / $totalCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: unlockedCount / totalCount,
              backgroundColor: Colors.white30,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 12,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '$percentage% Complete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Color.fromARGB(255, 110, 211, 97),
        labelColor: Color.fromARGB(255, 7, 45, 78),
        unselectedLabelColor: Colors.grey,
        tabs: [
          Tab(text: 'All'),
          Tab(text: 'Streaks'),
          Tab(text: 'Accuracy'),
          Tab(text: 'Progress'),
          Tab(text: 'Practice'),
          Tab(text: 'Companion'),
        ],
      ),
    );
  }

  Widget _buildTabContent(String category) {
    List<Achievement> filteredAchievements;

    if (category == 'all') {
      filteredAchievements = _allAchievements;
    } else {
      filteredAchievements = _allAchievements
          .where((a) => a.category == category)
          .toList();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: AchievementGridWidget(achievements: filteredAchievements),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
