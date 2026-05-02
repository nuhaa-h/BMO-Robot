import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'choice_screen.dart';
import 'child_activity_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin notifications =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Full screen on Android tablet (hide status + nav bars)
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

  const initSettings = InitializationSettings(android: androidSettings);

  await notifications.initialize(initSettings);

  runApp(const RoboKidsApp());
}

Future<void> sendNotification(String title, String body) async {
  const androidDetails = AndroidNotificationDetails(
    'env_alerts',
    'Environment Alerts',
    importance: Importance.max,
    priority: Priority.high,
  );

  const details = NotificationDetails(android: androidDetails);

  await notifications.show(
    0,
    title,
    body,
    details,
  );
}

class RoboKidsApp extends StatelessWidget {
  const RoboKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RoboKids',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF5A56E9),
      ),
      routes: {
        '/': (_) => const HomeScreen(),
        '/role': (_) => const RoleSelectScreen(),
        '/activity': (_) => const ActivityScreen(),
        '/parent-login': (_) => const ParentLoginScreen(), // 👈 جديد
        '/parent': (_) => const ParentDashboardScreen(),
        '/choice': (_) => const ChoiceScreen(),
      },
    );
  }
}

// =======================================================
// HOME SCREEN – FULL SCREEN BMO FACE
// =======================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ===== Raspberry Pi =====
  static const String piIp = "192.168.137.244";
  static const String statusUrl = "http://$piIp:5001/status";

  static const String talkUrl = "http://$piIp:5001/talk";

  Future<void> _startTalk() async {
    final uri = Uri.parse('http://192.168.137.244:5001/start_talk');

    try {
      await http.get(uri);
      print("🎤 Talk triggered");
    } catch (e) {
      print("❌ Error triggering talk: $e");
    }
  }

  bool happyTriggered = false;

  Timer? _pollTimer;

  String emotion = "Neutral";

  int mood = 1;

  late final AnimationController _blinkCtrl;
  late final AnimationController _mouthCtrl;

  @override
  void initState() {
    super.initState();

    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      lowerBound: 0,
      upperBound: 1,
    );

    _mouthCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fetchStatus();
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _fetchStatus();
      // 👈 هيك كل ثانية
    });

    _startBlinkLoop();
    _updateMouthLoop();
    _sayHelloFromPi();
  }

  // Future<void> _checkHappyTrigger() async {
  //   try {
  //     final res = await http.get(Uri.parse(happyUrl));
  //     if (res.statusCode != 200) return;

  //     final data = jsonDecode(res.body);
  //     if (data["happy"] == true && !happyTriggered) {
  //       happyTriggered = true;

  //       // 🗣️ الروبوت يحكي
  //       await http.post(
  //         Uri.parse("http://$piIp:5000/speak"),
  //         headers: {"Content-Type": "application/json"},
  //         body: jsonEncode(
  //             {"text": "You look so happy! What would you like to do?"}),
  //       );

  //       if (!mounted) return;
  //       Navigator.pushNamed(context, '/choice');
  //     }
  //   } catch (_) {}
  // }

  Future<void> _sayHelloFromPi() async {
    try {
      await http.post(
        Uri.parse("http://192.168.137.244:5001/speak"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": "Hello, I'm BMO"}),
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _blinkCtrl.dispose();
    _mouthCtrl.dispose();
    super.dispose();
  }

  void _startBlinkLoop() {
    Timer.periodic(const Duration(seconds: 4), (_) async {
      if (!mounted) return;

      await _blinkCtrl.forward();
      await _blinkCtrl.reverse();

      if (math.Random().nextBool()) {
        await Future.delayed(const Duration(milliseconds: 180));
        await _blinkCtrl.forward();
        await _blinkCtrl.reverse();
      }
    });
  }

  int _mapEmotionToMood(String e) {
    final x = e.toLowerCase();
    if (x.contains("happy") || x.contains("surprise")) return 0;
    if (x.contains("sad") || x.contains("fear")) return 3;
    if (x.contains("angry") || x.contains("disgust")) return 4;
    return 1;
  }

  void _updateMouthLoop() {
    if (mood == 0 || mood == 2) {
      if (!_mouthCtrl.isAnimating) {
        _mouthCtrl.repeat(reverse: true);
      }
    } else {
      if (_mouthCtrl.isAnimating) _mouthCtrl.stop();
      _mouthCtrl.value = 0;
    }
  }

  Future<void> _fetchStatus() async {
    try {
      final res = await http
          .get(Uri.parse(statusUrl))
          .timeout(const Duration(seconds: 2));
      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final newEmotion = (data["emotion"] ?? "Neutral").toString();
      final showChoice = data["show_choice"] == true;
      final newMood = _mapEmotionToMood(newEmotion);

      if (!mounted) return;
      setState(() {
        emotion = newEmotion;
        mood = newMood;
      });
      if (showChoice && !happyTriggered) {
        happyTriggered = true;

        if (!mounted) return;
        Navigator.pushNamed(context, '/choice');

        http.post(Uri.parse("http://$piIp:5001/clear_choice"));
      }

      _updateMouthLoop();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final title = _titleText();
    final subtitle = "Emotion: $emotion";

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        removeLeft: true,
        removeRight: true,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFF4F6FB),
          child: Stack(
            children: [
              _BmoFace(
                mood: mood,
                blink: _blinkCtrl,
                mouth: _mouthCtrl,
                title: title,
                subtitle: subtitle,
              ),
// 🎙️ TALK BUTTON – RIGHT
              Positioned(
                bottom: 40,
                right: 30, // 👈 يمين
                child: GestureDetector(
                  onTap: _startTalk,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 46,
                    ),
                  ),
                ),
              ),

              // ⭐ زر START (الإضافة الوحيدة)
// ▶️ START BUTTON – LEFT
              Positioned(
                bottom: 40,
                left: 30, // 👈 يسار
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/role');
                  },
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 86, 221, 233),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 46,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _titleText() {
    if (mood == 0) return "يا سلام 😄";
    if (mood == 2) return "شو هاي البطاقة؟ 🤖";
    if (mood == 3) return "لا بأس 🤍";
    if (mood == 4) return "خلّينا نهدى 🛡️";
    return "أهلًا!";
  }
}

// ===================== ACTIVITY SCREEN =====================
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("النشاط")),
      body: const Center(
        child: Text("هون بنكمّل لاحقًا 👌", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

// =======================================================
// BMO FACE WIDGET (UI)
// =======================================================
class _BmoFace extends StatelessWidget {
  const _BmoFace({
    required this.mood,
    required this.blink,
    required this.mouth,
    required this.title,
    required this.subtitle,
  });

  final int mood;
  final Animation<double> blink;
  final Animation<double> mouth;

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    const bodyColor = Color(0xFF7FD8C1);
    const borderColor = Color(0xFF2E6F63);
    const screenColor = Color(0xFFCFF7EA);

    final blushOpacity = switch (mood) {
      0 => 0.60,
      2 => 0.45,
      3 => 0.25,
      4 => 0.10,
      _ => 0.20,
    };

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Container(
        decoration: BoxDecoration(
          color: bodyColor,
          borderRadius: BorderRadius.circular(44),
          border: Border.all(color: borderColor, width: 7),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: screenColor,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                        color: borderColor.withOpacity(0.6), width: 5),
                  ),
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final w = c.maxWidth;
                      final h = c.maxHeight;

                      final blushY = h * 0.55;
                      final blushX = w * 0.22;

                      return Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedBuilder(
                                  animation: blink,
                                  builder: (context, _) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _BmoEye(blink: blink.value),
                                        SizedBox(width: w * 0.25),
                                        _BmoEye(blink: blink.value),
                                      ],
                                    );
                                  },
                                ),
                                SizedBox(height: h * 0.12),
                                AnimatedBuilder(
                                  animation: mouth,
                                  builder: (context, _) {
                                    return _BmoMouth(
                                        mood: mood, open: mouth.value);
                                  },
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: blushX - 32,
                            top: blushY - 20,
                            child: _Blush(opacity: blushOpacity),
                          ),
                          Positioned(
                            right: blushX - 32,
                            top: blushY - 20,
                            child: _Blush(opacity: blushOpacity),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Blush extends StatelessWidget {
  const _Blush({required this.opacity});
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 64,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFFF7AAE),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _BmoEye extends StatelessWidget {
  const _BmoEye({required this.blink});
  final double blink;

  @override
  Widget build(BuildContext context) {
    final h = lerpDouble(16, 2, blink)!;

    return Container(
      width: 16,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFF202020),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _BmoMouth extends StatelessWidget {
  const _BmoMouth({required this.mood, required this.open});
  final int mood;
  final double open;

  @override
  Widget build(BuildContext context) {
    final stroke = 6.0;
    final color = const Color(0xFF202020);

    if (mood == 1 || mood == 4) {
      return Container(
        width: 70,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
      );
    }

    final w = lerpDouble(70, 88, open)!;
    final h = lerpDouble(30, 46, open)!;

    return CustomPaint(
      size: Size(w, h),
      painter: _ArcPainter(color: color, stroke: stroke),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({required this.color, required this.stroke});

  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromLTWH(0, 0, size.width, size.height), math.pi,
        math.pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =======================================================
// ROLE SELECT SCREEN – BMO STYLE
// =======================================================
class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bodyColor = Color(0xFF7FD8C1);
    const borderColor = Color(0xFF2E6F63);
    const screenColor = Color(0xFFCFF7EA);

    return Scaffold(
      body: Container(
        color: const Color(0xFFF4F6FB),
        padding: const EdgeInsets.all(18),
        child: Container(
          decoration: BoxDecoration(
            color: bodyColor,
            borderRadius: BorderRadius.circular(44),
            border: Border.all(color: borderColor, width: 7),
            boxShadow: const [
              BoxShadow(blurRadius: 40, offset: Offset(0, 24)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                // شاشة BMO الداخلية
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: screenColor,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: borderColor.withOpacity(0.6),
                        width: 5,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2E6F63),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "who ",
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF2E6F63),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // 🧒 طفل
                          _CuteRoleButton(
                            icon: Icons.child_care,
                            label: "child🧒",
                            color: const Color(0xFF5A56E9),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ChildActivityScreen(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 18),

                          // 👩‍👧 ولي أمر
                          _CuteRoleButton(
                            icon: Icons.shield_outlined,
                            label: "parent👩‍👧",
                            color: const Color(0xFF2E6F63),
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                  context, '/parent-login');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // شريط سفلي مثل BMO
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1A18).withOpacity(0.65),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2147D9),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =======================================================
// CUTE ROLE BUTTON
// =======================================================
class _CuteRoleButton extends StatelessWidget {
  const _CuteRoleButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// 👩‍👧 PARENT DASHBOARD SCREEN
// =======================================================
class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

// =======================================================
// 🔐 PARENT LOGIN SCREEN
// =======================================================
class ParentLoginScreen extends StatefulWidget {
  const ParentLoginScreen({super.key});

  @override
  State<ParentLoginScreen> createState() => _ParentLoginScreenState();
}

class _ParentLoginScreenState extends State<ParentLoginScreen> {
  final TextEditingController _passwordCtrl = TextEditingController();

  final String correctPassword = "1234";

  String? error;

  void _login() {
    if (_passwordCtrl.text == correctPassword) {
      Navigator.pushReplacementNamed(context, '/parent');
    } else {
      setState(() {
        error = "wrong password ❌";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black26,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline,
                  size: 60, color: Color(0xFF5A56E9)),
              const SizedBox(height: 12),
              const Text(
                "دخول وليّ الأمر",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "insert password",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // 🔑 Password Field
              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "password",
                  errorText: error,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔓 Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A56E9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "log in",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/role');
                },
                child: const Text("BACKWARD"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  // ====== Safety Switches ======
  bool stopMovement = false;
  bool muteSound = false;
  bool disableRewards = false;
  double playTime = 30; // minutes

  // ====== Rewards ======
  int rewardsToday = 1;
  int maxRewards = 3;

  ///env
  EnvironmentData? env;
  bool envAlertShown = false;
//env

//emot
  EmotionStatus? emotionStatus;
  bool emotionAlertShown = false;
//emotion

// ===== Emergency =====
  Timer? _emergencyTimer;
  bool emergencyDialogOpen = false;

  int batteryPercent = 100;
  bool batteryLow = false;
  bool batteryAlertShown = false;
  Timer? _batteryTimer;

  // ====== HTTP helper ======
  static const String piIp = "192.168.137.244";
  Future<void> checkBattery() async {
    try {
      final res = await http.get(
        Uri.parse("http://$piIp:5001/battery"),
      );

      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body);

      batteryPercent = data["percent"];
      batteryLow = data["low"] == true;

      if (batteryLow && !batteryAlertShown && mounted) {
        batteryAlertShown = true;
        _showBatteryDialog();
      }

      if (!batteryLow) {
        batteryAlertShown = false; // reset لما تشحن
      }

      setState(() {});
    } catch (e) {
      debugPrint("❌ Battery check failed: $e");
    }
  }

  void _showBatteryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("🔋 Battery Low"),
        content: Text(
          "BMO battery is low ($batteryPercent%).\nPlease charge the robot.",
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (mounted) Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> checkEmergency() async {
    try {
      final res = await http.get(
        Uri.parse("http://$piIp:5001/emergency_status"),
      );

      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body);
      final bool emergency = data["emergency"] == true;

      if (emergency && !emergencyDialogOpen && mounted) {
        emergencyDialogOpen = true;
        _showEmergencyDialog();
      }
    } catch (e) {
      debugPrint("❌ Emergency check failed: $e");
    }
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("🚨 Child Needs You"),
        content: const Text(
          "Your child pressed the emergency button.\nDo you want to start a call?",
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await http.post(
                Uri.parse("http://$piIp:5001/clear_emergency"),
              );
              emergencyDialogOpen = false;
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Decline"),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await http.post(
                Uri.parse("http://$piIp:5001/clear_emergency"),
              );
              emergencyDialogOpen = false;
              if (mounted) Navigator.pop(context);

              // ⬅️ هون لاحقًا تفتحي صفحة المكالمة
              // Navigator.push(context, MaterialPageRoute(
              //   builder: (_) => ParentCallPage(piIp: piIp),
              // ));
            },
            icon: const Icon(Icons.call),
            label: const Text("Answer"),
          ),
        ],
      ),
    );
  }

  Future<void> sendCmd(String cmd) async {
    try {
      await http.post(
        Uri.parse("http://$piIp:5001/cmd"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"cmd": cmd}),
      );
    } catch (_) {}
  }

  Future<void> loadEnvironment() async {
    try {
      debugPrint("📡 Fetching environment...");

      final res = await http
          .get(Uri.parse("http://$piIp:5001/environment"))
          .timeout(const Duration(seconds: 3));

      debugPrint("📥 Status: ${res.statusCode}");
      debugPrint("📥 Body: ${res.body}");

      if (res.statusCode != 200) {
        throw Exception("Server error");
      }

      final json = jsonDecode(res.body);
      final data = EnvironmentData.fromJson(json);

      setState(() {
        env = data; // 🔥 هذا لازم ينفّذ
      });

      if (data.status == "ALERT" && !envAlertShown) {
        envAlertShown = true;

        showEnvironmentAlert(data.alerts);

        sendNotification(
          "🚨 تنبيه من BMO",
          data.alerts.join(", "),
        );
      }

      if (data.status == "SAFE") {
        envAlertShown = false;
      }
    } catch (e) {
      debugPrint("❌ Environment error: $e");
    }
  }

  Future<void> loadEmotion() async {
    try {
      final res = await http
          .get(Uri.parse("http://$piIp:5001/status"))
          .timeout(const Duration(seconds: 3));

      if (res.statusCode != 200) return;

      final data = EmotionStatus.fromJson(jsonDecode(res.body));

      setState(() {
        emotionStatus = data;
      });

      // 🚨 Alert only once for negative emotions
      if (data.faceDetected &&
          (data.emotion == "Sad" || data.emotion == "Angry") &&
          !emotionAlertShown) {
        emotionAlertShown = true;

        sendNotification(
          "🚨 Emotion Alert",
          "Child appears to be ${data.emotion}",
        );
      }

      if (data.emotion == "Happy") {
        emotionAlertShown = false;
      }
    } catch (e) {
      debugPrint("❌ Emotion error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadEnvironment();
    loadEmotion();

    Timer.periodic(const Duration(seconds: 3), (_) {
      loadEmotion();
    });

    _batteryTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => checkBattery());
  }

  @override
  void dispose() {
    _emergencyTimer?.cancel();
    _batteryTimer?.cancel();
    super.dispose();
  }

  void showEnvironmentAlert(List alerts) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🚨 تنبيه بيئي"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: alerts.map((a) => Text("• $a")).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("تم"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة تحكّم وليّ الأمر 👩‍👧"),
        backgroundColor: const Color(0xFF5A56E9),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(
                  Icons.battery_std,
                  color: batteryPercent <= 20 ? Colors.red : Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  "$batteryPercent%",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= 1️⃣ SAFETY =================
            _Section(
              title: "🛡️ الأمان والتحكم",
              children: [
                _switchTile(
                  "إيقاف الحركة",
                  "تعطيل حركة الروبوت فورًا",
                  stopMovement,
                  (v) {
                    setState(() => stopMovement = v);
                    sendCmd(v ? "STOP_MOVE" : "ALLOW_MOVE");
                  },
                ),
                _switchTile(
                  "كتم الصوت",
                  "إيقاف الصوت والمايك",
                  muteSound,
                  (v) {
                    setState(() => muteSound = v);
                    sendCmd(v ? "MUTE" : "UNMUTE");
                  },
                ),
                _switchTile(
                  "تعطيل المكافآت",
                  "منع خروج الحلوى",
                  disableRewards,
                  (v) {
                    setState(() => disableRewards = v);
                    sendCmd(v ? "NO_REWARD" : "ALLOW_REWARD");
                  },
                ),
                const SizedBox(height: 8),
                Text("⏱️ وقت اللعب: ${playTime.toInt()} دقيقة"),
                Slider(
                  min: 5,
                  max: 120,
                  divisions: 23,
                  value: playTime,
                  onChanged: (v) {
                    setState(() => playTime = v);
                    sendCmd("PLAYTIME_${v.toInt()}");
                  },
                ),
              ],
            ),

            // ================= 2️⃣ CONTROL =================
            _Section(
              title: "🎮 التحكم المباشر",
              children: [
                _ControlPad(onCommand: sendCmd),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => sendCmd("STOP"),
                  icon: const Icon(Icons.stop),
                  label: const Text("توقف فوري"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            // ================= 3️⃣ EDUCATION =================
            _Section(
              title: "📘 التعليم والمحتوى",
              children: const [
                _InfoTile("📚 البطاقات التعليمية", "مفعّلة"),
                _InfoTile("📖 القصص", "مفعّلة"),
                _InfoTile("🎵 الأغاني", "مفعّلة"),
                _InfoTile("🎯 المستوى", "مبتدئ"),
              ],
            ),

            // ================= 4️⃣ REWARDS =================
            _Section(
              title: "🍬 المكافآت",
              children: [
                Text("المكافآت اليوم: $rewardsToday / $maxRewards"),
                const SizedBox(height: 6),
                ElevatedButton(
                  onPressed: disableRewards || rewardsToday >= maxRewards
                      ? null
                      : () {
                          setState(() => rewardsToday++);
                          sendCmd("REWARD_NOW");
                        },
                  child: const Text("مكافأة الآن 🍭"),
                ),
              ],
            ),

// ================= 5️⃣ ENVIRONMENT =================
            _Section(
              title: "🌡️ مراقبة البيئة المحيطة",
              children: env == null
                  ? [const CircularProgressIndicator()]
                  : [
                      _InfoTile("🌡️ الحرارة", "${env!.temperature} °C"),
                      _InfoTile("💧 الرطوبة", "${env!.humidity} %"),
                      _InfoTile("☠️ الغاز", env!.gas.toString()),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              env!.status == "SAFE" ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          env!.status == "SAFE"
                              ? "✅ البيئة آمنة"
                              : "🚨 خطر بيئي",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: loadEnvironment,
                        icon: const Icon(Icons.refresh),
                        label: const Text("تحديث القيم"),
                      ),
                    ],
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     _showEmergencyDialog(); // نزوّر الطوارئ
            //   },
            //   child: const Text("TEST EMERGENCY 🚨"),
            // ),

            _Section(
              title: "😊 Emotion Monitoring",
              children: emotionStatus == null
                  ? [const CircularProgressIndicator()]
                  : [
                      _InfoTile(
                        "Face Detected",
                        emotionStatus!.faceDetected ? "Yes" : "No",
                      ),
                      _InfoTile(
                        "Current Emotion",
                        emotionStatus!.emotion,
                      ),
                    ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}

//enviorent
class EnvironmentData {
  final double temperature;
  final double humidity;
  final int gas;
  final String status;
  final List alerts;

  EnvironmentData({
    required this.temperature,
    required this.humidity,
    required this.gas,
    required this.status,
    required this.alerts,
  });

  factory EnvironmentData.fromJson(Map<String, dynamic> json) {
    return EnvironmentData(
      temperature: json['temperature'].toDouble(),
      humidity: json['humidity'].toDouble(),
      gas: json['gas'],
      status: json['status'],
      alerts: json['alerts'],
    );
  }
}

///////env
////emotion
class EmotionStatus {
  final bool faceDetected;
  final String emotion;

  EmotionStatus({
    required this.faceDetected,
    required this.emotion,
  });

  factory EmotionStatus.fromJson(Map<String, dynamic> json) {
    return EmotionStatus(
      faceDetected: json['face_detected'],
      emotion: json['emotion'],
    );
  }
}

//emotion
class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const _InfoTile(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ControlPad extends StatelessWidget {
  final Function(String) onCommand;
  const _ControlPad({required this.onCommand});

  Widget holdButton(IconData icon, String cmd) {
    return GestureDetector(
      onTapDown: (_) => onCommand(cmd),
      onTapUp: (_) => onCommand("STOP"),
      onTapCancel: () => onCommand("STOP"),
      child: Icon(icon, size: 50),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        holdButton(Icons.keyboard_arrow_up, "FORWARD"),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            holdButton(Icons.keyboard_arrow_left, "LEFT"),
            const SizedBox(width: 50),
            holdButton(Icons.keyboard_arrow_right, "RIGHT"),
          ],
        ),
        holdButton(Icons.keyboard_arrow_down, "BACKWARD"),
      ],
    );
  }
}
