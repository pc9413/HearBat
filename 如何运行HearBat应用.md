# 如何运行 HearBat 应用（含新的游戏化功能）

## 📱 快速开始指南

### 方法一：下载 APK 直接安装（最简单）⭐

1. **下载现有的 APK**
   - 访问：https://drive.google.com/file/d/1-tColKYHCebwC9-nWBvgJw6OIdLreWvE/view?usp=drive_link
   - 下载 APK 文件到您的 Android 手机
   - 允许安装未知来源的应用
   - 安装并运行

   ⚠️ **注意**：这个 APK 是旧版本，**不包含新的游戏化功能**。要体验游戏化系统，请使用方法二。

---

### 方法二：本地编译运行（推荐 - 包含所有新功能）🚀

## 前置要求

### 1. 安装 Flutter

**macOS:**
```bash
# 使用 Homebrew
brew install --cask flutter

# 或手动下载
# 访问：https://docs.flutter.dev/get-started/install/macos
```

**Windows:**
- 访问：https://docs.flutter.dev/get-started/install/windows
- 下载 Flutter SDK
- 解压到您选择的目录（如 `C:\flutter`）
- 添加 `flutter\bin` 到系统 PATH

**Linux:**
```bash
# 下载 Flutter
cd ~/development
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.0-stable.tar.xz
tar xf flutter_linux_3.19.0-stable.tar.xz

# 添加到 PATH
export PATH="$PATH:`pwd`/flutter/bin"
```

### 2. 安装 Android Studio 或 Xcode

**Android (macOS/Windows/Linux):**
- 下载 Android Studio：https://developer.android.com/studio
- 安装 Android SDK
- 配置 Android 模拟器或连接真实设备

**iOS (仅 macOS):**
- 从 App Store 安装 Xcode
- 运行 `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
- 运行 `sudo xcodebuild -runFirstLaunch`

### 3. 验证 Flutter 安装

```bash
flutter doctor
```

确保看到绿色的勾号 ✓。如有问题，按照提示修复。

---

## 🚀 运行步骤

### Step 1: 克隆或拉取最新代码

如果您还没有克隆仓库：
```bash
git clone https://github.com/pc9413/HearBat.git
cd HearBat
```

如果已经有本地副本，拉取最新更改：
```bash
cd HearBat
git fetch origin
git checkout claude/review-repo-01D8apxXHQyVGZFhPxDBDa2Y
git pull origin claude/review-repo-01D8apxXHQyVGZFhPxDBDa2Y
```

### Step 2: 安装依赖

```bash
flutter pub get
```

这会自动下载所有需要的包，包括：
- 游戏化系统的数据库支持 (sqflite)
- Firebase Vertex AI (Gemini AI 支持)
- 其他所有依赖

### Step 3: 配置 Firebase（重要）

游戏化系统中的 AI 伴侣功能需要 Firebase 配置：

1. **检查 Firebase 配置文件**
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

2. **如果没有配置文件**，需要：
   - 访问 Firebase Console: https://console.firebase.google.com/
   - 创建/使用现有项目
   - 添加 Android/iOS 应用
   - 下载配置文件到相应位置

   或者，暂时禁用 AI 伴侣功能（见下方）

### Step 4: 启动模拟器或连接设备

**选项 A - Android 模拟器:**
```bash
# 查看可用设备
flutter emulators

# 启动模拟器
flutter emulators --launch <emulator_id>
```

**选项 B - iOS 模拟器 (仅 macOS):**
```bash
open -a Simulator
```

**选项 C - 真实设备:**
- Android: 启用 USB 调试，用 USB 连接
- iOS: 信任开发者证书，用 USB 连接

验证设备连接：
```bash
flutter devices
```

### Step 5: 运行应用 🎉

```bash
flutter run
```

或者指定设备：
```bash
# 运行在 Android
flutter run -d android

# 运行在 iOS
flutter run -d ios

# 运行在特定设备
flutter run -d <device_id>
```

首次运行可能需要 5-10 分钟编译。

---

## 🎮 如何体验游戏化功能

### 暂时的集成方案（用于测试）

由于游戏化功能是新添加的，需要简单集成到现有界面：

#### 快速测试方法：

1. **运行应用后**，您需要手动添加导航到游戏化页面

2. **创建测试按钮** - 编辑 `lib/pages/home_page.dart`:

```dart
// 在文件顶部添加导入
import 'package:hearbat/pages/companion_chat_page.dart';
import 'package:hearbat/pages/achievements_page.dart';
import 'package:hearbat/pages/gamification_home_widget.dart';

// 在 HomePage 的 build 方法中添加测试按钮
// 在现有的 HomeCardWidget 列表之后添加：

ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CompanionChatPage()),
    );
  },
  child: Text('🤖 聊天伴侣 (AI Companion)'),
),

ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AchievementsPage()),
    );
  },
  child: Text('🏆 成就系统 (Achievements)'),
),
```

3. **或者使用完整的游戏化主页小部件**：

在 `lib/pages/home_page.dart` 中添加：
```dart
GamificationHomeWidget(), // 显示 XP、等级、挑战、伴侣等所有功能
```

4. **热重载**：
```bash
# 在 flutter run 运行时，按 'r' 热重载
r
```

---

## 🧪 测试游戏化功能

### 1. 测试 XP 和等级系统
```dart
// 在任何页面添加测试按钮
final gamificationProvider = Provider.of<GamificationProvider>(context);

ElevatedButton(
  onPressed: () async {
    await gamificationProvider.awardXP(500); // 获得 500 XP
  },
  child: Text('测试获得 XP'),
),
```

### 2. 测试成就解锁
```dart
ElevatedButton(
  onPressed: () async {
    await gamificationProvider.unlockAchievement('first_module');
  },
  child: Text('解锁首个成就'),
),
```

### 3. 测试 AI 伴侣
- 直接导航到 `CompanionChatPage`
- 开始聊天
- 伴侣会根据你的等级和进度做出响应

### 4. 测试每日挑战
- 查看 `GamificationHomeWidget`
- 完成练习会自动更新挑战进度

---

## 🔧 常见问题和解决方案

### 问题 1: Firebase 错误

**错误信息**: `MissingPluginException` 或 Firebase 初始化失败

**解决方案**:
```bash
# 重新生成 Firebase 文件
flutter clean
flutter pub get
cd ios && pod install && cd ..  # 仅 iOS
flutter run
```

或者暂时禁用 AI 功能（在代码中注释掉 Firebase 初始化）

### 问题 2: 数据库错误

**错误信息**: `DatabaseException` 或找不到表

**解决方案**:
```bash
# 清除应用数据并重新安装
flutter clean
flutter pub get
flutter run
```

应用首次运行时会自动创建游戏化数据库。

### 问题 3: 依赖冲突

**错误信息**: 版本冲突

**解决方案**:
```bash
flutter pub upgrade
flutter pub get
```

### 问题 4: 构建失败

**Android:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter run
```

**iOS:**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

### 问题 5: AI 伴侣无响应

**检查**:
1. Firebase Vertex AI 是否配置正确
2. 是否有网络连接
3. 检查 Firebase Console 中的 API 配额

**临时解决方案**: 伴侣会显示备用响应（fallback responses）

---

## 📊 游戏化功能清单

运行应用后，您可以体验：

✅ **XP 和等级系统**
- 完成练习获得 XP
- 50 个等级，从"新手听者"到"传奇听者"
- 动态称号系统

✅ **成就系统**
- 20+ 个可解锁成就
- 5 个类别：连续性、准确度、完成度、练习时间、伴侣

✅ **每日挑战**
- 每天 3 个自动生成的挑战
- 练习时间、模块完成、准确度挑战

✅ **AI 伴侣**
- 5 种个性：鼓励型、激励型、友好型、智慧型、活泼型
- 15 级关系系统
- 基于 Gemini AI 的对话
- 庆祝你的成就

✅ **视觉反馈**
- 动画庆祝对话框
- 进度条和等级显示
- 成就画廊

---

## 🎯 完整集成（可选）

如果您想完全集成游戏化功能到现有应用：

1. **阅读集成指南**:
   - `GAMIFICATION_INTEGRATION_GUIDE.md`（英文）
   - `GAMIFICATION_README.md`（功能概述）

2. **集成到主应用流程**:
   - 在练习完成时调用 `recordPracticeSession()`
   - 在模块完成时调用 `recordModuleCompletion()`
   - 添加游戏化 UI 到主页和个人资料页

3. **自定义**:
   - 修改 XP 奖励值
   - 添加自定义成就
   - 调整伴侣个性

---

## 📱 推荐的测试流程

1. **启动应用** - `flutter run`
2. **查看主页** - 看到现有的模块
3. **添加测试按钮** - 导航到游戏化功能
4. **体验 AI 伴侣** - 打开聊天页面，开始对话
5. **查看成就** - 打开成就页面
6. **完成练习** - 观察 XP 增长和挑战进度
7. **解锁成就** - 触发庆祝动画

---

## 🆘 需要帮助？

### 查看日志
```bash
flutter run --verbose
```

### 调试模式
应用运行时按：
- `r` - 热重载
- `R` - 热重启
- `p` - 显示网格
- `o` - 切换平台
- `q` - 退出

### 联系支持
- GitHub Issues: https://github.com/pc9413/HearBat/issues
- 查看代码文档中的注释

---

## 🎊 开始体验！

现在您已经准备好体验 HearBat 的新游戏化功能了！

**推荐体验顺序**:
1. 🤖 先试试 AI 伴侣聊天
2. 🏆 查看成就系统
3. 🎯 看看今天的每日挑战
4. 📈 完成一个练习模块，观察 XP 增长
5. 🎉 解锁第一个成就！

祝您体验愉快！🚀
