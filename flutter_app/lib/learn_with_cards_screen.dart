// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class LearnWithCardsScreen extends StatefulWidget {
//   const LearnWithCardsScreen({super.key});

//   @override
//   State<LearnWithCardsScreen> createState() => _LearnWithCardsScreenState();
// }

// class _LearnWithCardsScreenState extends State<LearnWithCardsScreen> {
//   // 🔗 Raspberry Pi
//   static const String piIp = "192.168.1.18";
//   static const String talkUrl = "http://$piIp:5000/talk";

//   // 🐄 Card data
//   final String word = "Cow";
//   final String speakWord = "cow";
//   final String infoText = "Cows give us milk 🥛\nThey live on a farm 🌾";

//   // ⭐ STARS
//   int stars = 0;

//   // ===============================
//   // 🔊 Text To Speech
//   // ===============================
//   Future<void> _speak(String text) async {
//     try {
//       await http.post(
//         Uri.parse(talkUrl),
//         body: {"text": text},
//       );
//     } catch (e) {
//       debugPrint("Speak error: $e");
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(milliseconds: 400), () {
//       _speak("This is a $speakWord");
//     });
//   }

//   // ===============================
//   // ℹ️ Fun Fact
//   // ===============================
//   void _showInfo() {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(24),
//         ),
//         title: const Text("Fun Fact ✨", textAlign: TextAlign.center),
//         content: Text(
//           infoText,
//           textAlign: TextAlign.center,
//           style: const TextStyle(fontSize: 18),
//         ),
//       ),
//     );
//   }

//   // ===============================
//   // ❓ Question
//   // ===============================
//   void _showQuestion() {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(24),
//         ),
//         title: const Text(
//           "Where does the cow live?",
//           textAlign: TextAlign.center,
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _answerButton(
//               text: "On a farm ✅",
//               correct: true,
//             ),
//             const SizedBox(height: 10),
//             _answerButton(
//               text: "In the sea",
//               correct: false,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _answerButton({
//     required String text,
//     required bool correct,
//   }) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: () {
//           Navigator.pop(context);
//           if (correct) {
//             setState(() {
//               stars++;
//             });
//             _speak("Great job!");
//             _showSnack("⭐ You earned a star!");
//           } else {
//             _speak("Try again");
//             _showSnack("🙂 Try again");
//           }
//         },
//         style: ElevatedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(vertical: 14),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(18),
//           ),
//         ),
//         child: Text(
//           text,
//           style: const TextStyle(fontSize: 18),
//         ),
//       ),
//     );
//   }

//   void _showSnack(String text) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(text, textAlign: TextAlign.center),
//         duration: const Duration(seconds: 2),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//       ),
//     );
//   }

//   // ===============================
//   // 🎨 UI
//   // ===============================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6FB),
//       appBar: AppBar(
//         title: const Text("Learn with Cards"),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 16),
//             child: Center(
//               child: Text(
//                 "⭐ $stars",
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // 🟦 Image Card
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(28),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 10,
//                     offset: Offset(0, 4),
//                   )
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Image.asset(
//                     "assets/images/cow.png",
//                     height: 200,
//                     fit: BoxFit.contain,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     "$word 🐄",
//                     style: const TextStyle(
//                       fontSize: 36,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   ElevatedButton.icon(
//                     onPressed: () => _speak("This is a $speakWord"),
//                     icon: const Icon(Icons.volume_up),
//                     label: const Text("Pronounce Word"),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.deepPurple,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 12,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(22),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 26),

//             // 🎮 Cute Buttons
//             cuteButton(
//               emoji: "🔊",
//               text: "Say the word again",
//               color: const Color(0xFFE3F2FD),
//               onTap: () => _speak("This is a $speakWord"),
//             ),

//             cuteButton(
//               emoji: "🗣️",
//               text: "Repeat with me",
//               color: const Color(0xFFFFF3E0),
//               onTap: () => _speak("Say it with me: $speakWord"),
//             ),

//             cuteButton(
//               emoji: "✨",
//               text: "Fun fact",
//               color: const Color(0xFFE8F5E9),
//               onTap: _showInfo,
//             ),

//             cuteButton(
//               emoji: "❓",
//               text: "Quick question",
//               color: const Color(0xFFF3E5F5),
//               onTap: _showQuestion,
//             ),

//             cuteButton(
//               emoji: "🎵",
//               text: "Animal sound",
//               color: const Color(0xFFFCE4EC),
//               onTap: () => _speak("Moo"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ===============================
//   // 🎀 Cute Button
//   // ===============================
//   Widget cuteButton({
//     required String emoji,
//     required String text,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 14),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(26),
//         child: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(26),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.08),
//                 blurRadius: 8,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               Text(
//                 emoji,
//                 style: const TextStyle(fontSize: 26),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Text(
//                   text,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class LearnWithCardsScreen extends StatefulWidget {
//   const LearnWithCardsScreen({super.key});

//   @override
//   State<LearnWithCardsScreen> createState() => _LearnWithCardsScreenState();
// }

// class _LearnWithCardsScreenState extends State<LearnWithCardsScreen> {
//   // 🔗 Raspberry Pi
//   static const String piIp = "172.23.165.228";
//   static const String baseUrl = "http://$piIp:5000";

//   // 🔄 Dynamic card data (from RFID)
//   String word = "Scan a card";
//   String imageName = "placeholder.png";
//   String infoText = "";
//   String animalSound = "";

//   // ⭐ Stars
//   int stars = 0;

//   Timer? _pollingTimer;

//   // ===============================
//   // 🔊 Text To Speech
//   // ===============================
//   Future<void> _speak(String text) async {
//     if (text.isEmpty) return;

//     try {
//       await http.post(
//         Uri.parse("$baseUrl/talk"),
//         body: {"text": text},
//       );
//     } catch (e) {
//       debugPrint("Speak error: $e");
//     }
//   }

//   // ===============================
//   // 📡 Fetch RFID card from Pi
//   // ===============================
//   Future<void> fetchCurrentCard() async {
//     try {
//       print("Fetching card...");
//       final res = await http.get(
//         Uri.parse("$baseUrl/current_card"),
//       );

//       print("Response: ${res.body}");

//       final data = jsonDecode(res.body);

//       if (data["status"] == "no_card") return;

//       setState(() {
//         word = data["name"];
//         imageName = data["image"];
//         infoText = data["fact"];
//         animalSound = data["sound"];
//       });
//     } catch (e) {
//       print("Fetch card error: $e");
//     }
//   }

//   @override
//   void initState() {
//     super.initState();

//     // ⏱️ Poll Raspberry Pi every 1 second
//     _pollingTimer =
//         Timer.periodic(const Duration(seconds: 1), (_) => fetchCurrentCard());
//   }

//   @override
//   void dispose() {
//     _pollingTimer?.cancel();
//     super.dispose();
//   }

//   // ===============================
//   // ℹ️ Fun Fact
//   // ===============================
//   void _showInfo() {
//     if (infoText.isEmpty) return;

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(24),
//         ),
//         title: const Text("Fun Fact ✨", textAlign: TextAlign.center),
//         content: Text(
//           infoText,
//           textAlign: TextAlign.center,
//           style: const TextStyle(fontSize: 18),
//         ),
//       ),
//     );
//   }

//   // ===============================
//   // ❓ Question (simple example)
//   // ===============================
//   void _showQuestion() {
//     if (word == "Scan a card") return;

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(24),
//         ),
//         title: Text(
//           "Where does the $word live?",
//           textAlign: TextAlign.center,
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _answerButton("On a farm ✅", true),
//             const SizedBox(height: 10),
//             _answerButton("In the sea", false),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _answerButton(String text, bool correct) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: () {
//           Navigator.pop(context);
//           if (correct) {
//             setState(() => stars++);
//             _speak("Great job!");
//             _showSnack("⭐ You earned a star!");
//           } else {
//             _speak("Try again");
//             _showSnack("🙂 Try again");
//           }
//         },
//         style: ElevatedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(vertical: 14),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(18),
//           ),
//         ),
//         child: Text(text, style: const TextStyle(fontSize: 18)),
//       ),
//     );
//   }

//   void _showSnack(String text) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(text, textAlign: TextAlign.center),
//         duration: const Duration(seconds: 2),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//       ),
//     );
//   }

//   // ===============================
//   // 🎨 UI
//   // ===============================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6FB),
//       appBar: AppBar(
//         title: const Text("Learn with Cards"),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 16),
//             child: Center(
//               child: Text(
//                 "⭐ $stars",
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // 🟦 Card Image
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(28),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 10,
//                     offset: Offset(0, 4),
//                   )
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Image.asset(
//                     "assets/images/$imageName",
//                     height: 200,
//                     fit: BoxFit.contain,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     word,
//                     style: const TextStyle(
//                       fontSize: 36,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   ElevatedButton.icon(
//                     onPressed: () => _speak("This is a $word"),
//                     icon: const Icon(Icons.volume_up),
//                     label: const Text("Pronounce"),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.deepPurple,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 12,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(22),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 26),

//             cuteButton(
//               emoji: "🔊",
//               text: "Say the word again",
//               color: const Color(0xFFE3F2FD),
//               onTap: () => _speak("This is a $word"),
//             ),

//             cuteButton(
//               emoji: "✨",
//               text: "Fun fact",
//               color: const Color(0xFFE8F5E9),
//               onTap: _showInfo,
//             ),

//             cuteButton(
//               emoji: "❓",
//               text: "Quick question",
//               color: const Color(0xFFF3E5F5),
//               onTap: _showQuestion,
//             ),

//             cuteButton(
//               emoji: "🎵",
//               text: "Animal sound",
//               color: const Color(0xFFFCE4EC),
//               onTap: () => _speak(animalSound),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ===============================
//   // 🎀 Cute Button Widget
//   // ===============================
//   Widget cuteButton({
//     required String emoji,
//     required String text,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 14),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(26),
//         child: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(26),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.08),
//                 blurRadius: 8,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               Text(emoji, style: const TextStyle(fontSize: 26)),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Text(
//                   text,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LearnWithCardsScreen extends StatefulWidget {
  const LearnWithCardsScreen({super.key});

  @override
  State<LearnWithCardsScreen> createState() => _LearnWithCardsScreenState();
}

class _LearnWithCardsScreenState extends State<LearnWithCardsScreen> {
  // 🔗 Raspberry Pi
  static const String piIp = "192.168.137.244"; // عدّليه حسب IP عندك
  static const String baseUrl = "http://$piIp:5001";

  // 🐾 Card data
  String word = "Scan a card";
  String imageName = "placeholder.png";
  String infoText = "";
  String animalSound = "";

  // ⭐ Stars
  int stars = 0;

  Timer? _pollingTimer;

  // ===============================
  // 🔊 Text To Speech
  // ===============================
  Future<void> _speak(String text) async {
    if (text.isEmpty) return;
    try {
      await http.post(
        Uri.parse("$baseUrl/talk"),
        body: {"text": text},
      );
    } catch (e) {
      debugPrint("Speak error: $e");
    }
  }

  // ===============================
  // 🎤 Say it with me (STT)
  // ===============================
  Future<void> listenAndCheck() async {
    if (word == "Scan a card") return;

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/listen"),
        body: {"expected": word.toLowerCase()},
      );

      final data = jsonDecode(res.body);

      if (data["result"] == "correct") {
        setState(() => stars = data["stars"]);
        _showSnack("⭐ Great job!");
      } else if (data["result"] == "wrong") {
        _showSnack("🙂 Try again");
      } else {
        _showSnack("🎤 I didn't hear you");
      }
    } catch (e) {
      debugPrint("Listen error: $e");
    }
  }

  // ===============================
  // 📡 Fetch RFID card
  // ===============================
  Future<void> fetchCurrentCard() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/current_card"));
      final data = jsonDecode(res.body);

      if (data["status"] == "no_card") return;

      setState(() {
        word = data["name"];
        imageName = data["image"];
        infoText = data["fact"];
        animalSound = data["sound"];
      });
    } catch (e) {
      debugPrint("Fetch card error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    http.get(Uri.parse("$baseUrl/learn_cards"));

    _pollingTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => fetchCurrentCard());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // ===============================
  // ℹ️ Fun Fact
  // ===============================
  void _showInfo() {
    if (infoText.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text("Fun Fact ✨", textAlign: TextAlign.center),
        content: Text(
          infoText,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  // ===============================
  // ❓ Quick Question
  // ===============================
  Future<void> _showQuestion() async {
    if (!hasCard) {
      _showSnack("📦 Scan a card first!");
      return;
    }

    final res = await http.get(Uri.parse("$baseUrl/question"));
    final q = jsonDecode(res.body);

    // ✅ حماية من null
    if (q == null || q["q"] == null || q["answers"] == null) {
      _showSnack("❗ No question available");
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(q["q"], textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(q["answers"].length, (i) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  final res = await http.post(
                    Uri.parse("$baseUrl/answer"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "answer": i,
                      "correct": q["correct"],
                    }),
                  );

                  final data = jsonDecode(res.body);

                  setState(() => stars = data["stars"]);

                  if (data["result"] == "correct") {
                    //_speak("Great job!");
                    _showSnack("⭐ Correct!");
                  } else {
                    // _speak("Try again");
                    _showSnack("🙂 Try again");
                  }

                  if (data["reward"] == true) {
                    _showSnack("🎉 You got a candy!");
                  }
                },
                child: Text(q["answers"][i]),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ===============================
  // 🔔 Snack
  // ===============================
  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, textAlign: TextAlign.center),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ===============================
  // 🎨 UI
  // ===============================

  bool get hasCard => word != "Scan a card";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text("Learn with Cards"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "⭐ $stars",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🟦 Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  Image.asset("assets/images/$imageName", height: 200),
                  const SizedBox(height: 16),
                  Text(word,
                      style: const TextStyle(
                          fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: hasCard ? () => _speak("This is a $word") : null,
                    icon: const Icon(Icons.volume_up),
                    label: const Text("Pronounce"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            cuteButton(
              emoji: "🔊",
              text: "Say the word again",
              color: const Color(0xFFE3F2FD),
              onTap: () {
                if (!hasCard) {
                  _showSnack("📦 Scan a card first!");
                  return;
                }
                _speak("This is a $word");
              },
            ),

            cuteButton(
              emoji: "🗣️",
              text: "Say it with me",
              color: const Color(0xFFFFF3E0),
              onTap: () {
                if (!hasCard) {
                  _showSnack("📦 Scan a card first!");
                  return;
                }
                listenAndCheck();
              },
            ),

            cuteButton(
              emoji: "✨",
              text: "Fun fact",
              color: const Color(0xFFE8F5E9),
              onTap: () {
                if (!hasCard) {
                  _showSnack("📦 Scan a card first!");
                  return;
                }
                _showInfo();
              },
            ),

            cuteButton(
              emoji: "❓",
              text: "Quick question",
              color: const Color(0xFFF3E5F5),
              onTap: () {
                if (!hasCard) {
                  _showSnack("📦 Scan a card first!");
                  return;
                }
                _showQuestion();
              },
            ),

            cuteButton(
              emoji: "🎵",
              text: "Animal sound",
              color: const Color(0xFFFCE4EC),
              onTap: () {
                if (!hasCard) {
                  _showSnack("📦 Scan a card first!");
                  return;
                }
                _speak(animalSound);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===============================
  // 🎀 Cute Button Widget
  // ===============================
  Widget cuteButton({
    required String emoji,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(text,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
