import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HideAndSeekCountdownScreen extends StatefulWidget {
  const HideAndSeekCountdownScreen({super.key});

  @override
  State<HideAndSeekCountdownScreen> createState() =>
      _HideAndSeekCountdownScreenState();
}

class _HideAndSeekCountdownScreenState
    extends State<HideAndSeekCountdownScreen> {
  int countdown = 10;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _startHideAndSeekOnRobot();
  }

  // ⏳ Countdown UI
  void _startCountdown() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (countdown == 0) {
        t.cancel();
      } else {
        setState(() {
          countdown--;
        });
      }
    });
  }

  // 🤖 Call Raspberry Pi server
  Future<void> _startHideAndSeekOnRobot() async {
    try {
      await http.post(
        Uri.parse("http://192.168.1.18:5000/hide_and_seek"),
      );
    } catch (e) {
      debugPrint("Robot connection failed: $e");
    }
  }

  // 🎙️ Talk with Robot
// Future<void> _startTalkWithRobot() async {
//   try {
//     await http.post(
//       Uri.parse("http://192.168.1.18:5000/talk"),
//     );
//   } catch (e) {
//     debugPrint("Talk connection failed: $e");
//   }
// }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Hide now!",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              countdown.toString(),
              style: const TextStyle(
                fontSize: 120,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5A56E9),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "The robot is counting...",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
