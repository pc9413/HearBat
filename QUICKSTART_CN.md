# HearBat 快速开始指南 🚀

## 最简单的方法（3 步）

### 1️⃣ 安装 Flutter
```bash
# macOS
brew install --cask flutter

# Windows - 下载安装包
https://docs.flutter.dev/get-started/install/windows

# Linux
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.0-stable.tar.xz
tar xf flutter_linux_3.19.0-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"
```

验证安装：
```bash
flutter doctor
```

### 2️⃣ 克隆并安装依赖
```bash
# 克隆仓库
git clone https://github.com/pc9413/HearBat.git
cd HearBat

# 切换到游戏化功能分支
git checkout claude/review-repo-01D8apxXHQyVGZFhPxDBDa2Y

# 安装依赖
flutter pub get
```

### 3️⃣ 运行应用
```bash
# 连接设备或启动模拟器，然后运行
flutter run
```

就这么简单！🎉

---

## 🎮 快速体验游戏化功能

### 方法 A: 添加导航按钮（推荐）

在应用运行后，编辑 `lib/pages/home_page.dart`，在文件中添加：

```dart
// 1. 在文件顶部添加导入
import 'package:hearbat/pages/companion_chat_page.dart';
import 'package:hearbat/pages/achievements_page.dart';
import 'package:provider/provider.dart';
import 'package:hearbat/gamification/gamification_provider.dart';

// 2. 在 HomePage 的 Column children 中添加按钮
// 找到现有的 HomeCardWidget 列表，在后面添加：

Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    children: [
      // AI 伴侣按钮
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: Icon(Icons.pets, size: 28),
          label: Text('🤖 AI 伴侣聊天', style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 110, 211, 97),
            foregroundColor: Colors.white,
            padding: EdgeInsets.all(16),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CompanionChatPage()),
            );
          },
        ),
      ),

      SizedBox(height: 12),

      // 成就系统按钮
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: Icon(Icons.emoji_events, size: 28),
          label: Text('🏆 查看成就', style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 7, 45, 78),
            foregroundColor: Colors.white,
            padding: EdgeInsets.all(16),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AchievementsPage()),
            );
          },
        ),
      ),

      SizedBox(height: 12),

      // 测试 XP 按钮
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: Icon(Icons.star, size: 28),
          label: Text('⭐ 测试获得 500 XP', style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black87,
            padding: EdgeInsets.all(16),
          ),
          onPressed: () async {
            final provider = Provider.of<GamificationProvider>(context, listen: false);
            if (!provider.isInitialized) {
              await provider.initialize();
            }
            await provider.awardXP(500);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('获得 500 XP! 🎉')),
            );
          },
        ),
      ),
    ],
  ),
),
```

保存文件，然后在运行中的应用中按 `r` 热重载。

### 方法 B: 使用完整的游戏化组件

在 `lib/pages/home_page.dart` 的合适位置添加：

```dart
import 'package:hearbat/pages/gamification_home_widget.dart';

// 在 build 方法中添加
GamificationHomeWidget(),
```

---

## 🎯 功能测试清单

体验以下功能：

- [ ] 🤖 **AI 伴侣聊天** - 打开聊天页面，和伴侣对话
- [ ] 🏆 **查看成就** - 浏览 20+ 个成就
- [ ] ⭐ **获得 XP** - 点击测试按钮，看等级条增长
- [ ] 🎯 **每日挑战** - 查看今天的 3 个挑战
- [ ] 🎉 **解锁成就** - 完成练习解锁第一个成就
- [ ] 💕 **培养关系** - 和伴侣聊天增加好感度

---

## ⚡ 常见问题

### Q: Firebase 相关错误？
**A**: 游戏化的核心功能（XP、成就、挑战）不依赖 Firebase。只有 AI 伴侣需要。如果看到 Firebase 错误，可以暂时忽略，其他功能仍可使用。

### Q: 数据库错误？
**A**: 首次运行时会自动创建。如有问题：
```bash
flutter clean
flutter pub get
flutter run
```

### Q: 看不到新功能？
**A**: 确保：
1. 切换到正确的分支：`claude/review-repo-01D8apxXHQyVGZFhPxDBDa2Y`
2. 运行了 `flutter pub get`
3. 添加了导航按钮（见上方方法 A）

---

## 📱 设备要求

- **Android**: Android 5.0 (API 21) 或更高
- **iOS**: iOS 12.0 或更高
- **模拟器**: 推荐使用真实设备以获得最佳体验

---

## 🎊 现在开始体验！

```bash
# 确保在项目目录
cd HearBat

# 运行应用
flutter run

# 应用运行后，添加上面的导航按钮
# 然后按 'r' 热重载
```

**提示**: 第一次编译可能需要 5-10 分钟，请耐心等待。

祝您体验愉快！如有问题，查看详细指南：`如何运行HearBat应用.md` 📖
