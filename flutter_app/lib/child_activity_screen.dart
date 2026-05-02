// import 'package:flutter/material.dart';
// import 'hide_and_seek_countdown_screen.dart';
// import 'learn_with_cards_screen.dart';

// class ChildActivityScreen extends StatelessWidget {
//   const ChildActivityScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6FB),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 20),

//               // 🧒 Title
//               const Text(
//                 "What would you like to do?",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 30,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),

//               const SizedBox(height: 40),

//               // 🎮 Hide and Seek Button
//               _ChildActionButton(
//                 icon: Icons.videogame_asset,
//                 label: "Play Hide & Seek",
//                 color: const Color(0xFF5A56E9),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => const HideAndSeekCountdownScreen(),
//                     ),
//                   );
//                 },
//               ),

//               const SizedBox(height: 25),

//               // 🃏 Learn with Cards Button
//               _ChildActionButton(
//                 icon: Icons.style,
//                 label: "Learn with Cards",
//                 color: const Color(0xFF2DB6A3),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => const LearnWithCardsScreen(),
//                     ),
//                   );
//                 },
//               ),

//               const Spacer(),

//               // 👈 Back
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text(
//                   "⬅ Back",
//                   style: TextStyle(fontSize: 18),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // =======================
// // Reusable cute button
// // =======================
// class _ChildActionButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final VoidCallback onTap;

//   const _ChildActionButton({
//     required this.icon,
//     required this.label,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 120,
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(24),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.3),
//               blurRadius: 10,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 50, color: Colors.white),
//             const SizedBox(width: 16),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'hide_and_seek_countdown_screen.dart';
import 'learn_with_cards_screen.dart';
import 'bmo_emotions.dart'; // اسم الملف اللي حطيتي فيه كود المشاعر

const String piIp = "172.23.165.228";
const String baseUrl = "http://172.23.165.228:5001";

class ChildActivityScreen extends StatelessWidget {
  const ChildActivityScreen({super.key});

  // ===== Raspberry Pi IP =====
  // static const String piIp = "192.168.1.18";
  //static const String piIp = "172.23.165.228";

  // ===== Emergency Request =====
  Future<void> sendEmergencyRequest() async {
    try {
      await http.post(
        Uri.parse("http://$piIp:5000/emergency_request"),
      );
      debugPrint("🚨 Emergency request sent");
    } catch (e) {
      debugPrint("❌ Emergency request failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // 🧒 Title
              const Text(
                "What would you like to do?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              // 🎮 Hide and Seek Button
              _ChildActionButton(
                icon: Icons.videogame_asset,
                label: "Play Hide & Seek",
                color: const Color(0xFF5A56E9),
                onTap: () async {
                  await startHideAndSeek(); // ✅ ابعثي للرازبري يبدأ اللعبة
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HideAndSeekCountdownScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              // 🃏 Learn with Cards Button
              _ChildActionButton(
                icon: Icons.style,
                label: "Learn with Cards",
                color: const Color(0xFF2DB6A3),
                onTap: () async {
                  await http.get(Uri.parse("$baseUrl/learn_cards"));

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LearnWithCardsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 25),

// 😊 Learn Emotions Button
              _ChildActionButton(
                icon: Icons.mood,
                label: "Learn Emotions",
                color: const Color(0xFFFFC857),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EmotionPickerPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // 🚨 EMERGENCY BUTTON (SMALL & CLEAN)
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: sendEmergencyRequest,
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 26,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "HELP",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // 👈 Back
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "⬅ Back",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> startHideAndSeek() async {
  try {
    final res = await http.post(
      Uri.parse("http://$piIp:5000/start_hide_seek"),
      headers: {"Content-Type": "application/json"},
      body: '{"target":"nuha"}', // ✏️ غيريها حسب الطفل
    );

    debugPrint("🎮 start_hide_seek: ${res.statusCode} ${res.body}");
  } catch (e) {
    debugPrint("❌ start_hide_seek failed: $e");
  }
}

// =======================
// Reusable cute button
// =======================
class _ChildActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ChildActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 26,
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
