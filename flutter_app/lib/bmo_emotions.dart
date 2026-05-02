import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = "http://192.168.137.244:5001";

void main() {
  runApp(const RoboKidsApp());
}

class RoboKidsApp extends StatelessWidget {
  const RoboKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BMO Emotions',
      theme: ThemeData(useMaterial3: true),
      home: const EmotionPickerPage(),
    );
  }
}

// =======================
// 1) Emotion Model
// =======================
enum BmoEmotion {
  happy,
  sad,
  angry,
  excited,
  confused,
  proud,
  frightened,
  bored,
}

class EmotionItem {
  final BmoEmotion emotion;
  final String labelEn;
  const EmotionItem(this.emotion, this.labelEn);
}

const emotions = <EmotionItem>[
  EmotionItem(BmoEmotion.happy, 'Happy'),
  EmotionItem(BmoEmotion.sad, 'Sad'),
  EmotionItem(BmoEmotion.angry, 'Angry'),
  EmotionItem(BmoEmotion.excited, 'Excited'),
  EmotionItem(BmoEmotion.confused, 'Confused'),
  EmotionItem(BmoEmotion.proud, 'Proud'),
  EmotionItem(BmoEmotion.frightened, 'Frightened'),
  EmotionItem(BmoEmotion.bored, 'Bored'),
];

// =======================
// 2) Page 1: Emotion Picker
// =======================
class EmotionPickerPage extends StatelessWidget {
  const EmotionPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a Feeling'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: emotions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final item = emotions[index];

            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EmotionDisplayPage(emotion: item),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black12),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 10,
                      offset: Offset(0, 6),
                      color: Color(0x11000000),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: BmoFace(emotion: item.emotion),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.labelEn,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// =======================
// 3) Page 2: Emotion Display
// =======================
class EmotionDisplayPage extends StatefulWidget {
  final EmotionItem emotion;
  const EmotionDisplayPage({super.key, required this.emotion});

  @override
  State<EmotionDisplayPage> createState() => _EmotionDisplayPageState();
}

class _EmotionDisplayPageState extends State<EmotionDisplayPage> {
  @override
  void initState() {
    super.initState();
    sendEmotionToPi(widget.emotion.emotion);
  }

  Future<void> sendEmotionToPi(BmoEmotion emotion) async {
    try {
      await http.get(
        Uri.parse("$baseUrl/set_emotion?name=${emotion.name}"),
      );
    } catch (e) {
      debugPrint("Error sending emotion: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.emotion.labelEn),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BmoFace(emotion: widget.emotion.emotion),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFF5F7FA),
                border: Border.all(color: Colors.black12),
              ),
              child: Text(
                _sentence(widget.emotion.emotion),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.grid_view_rounded),
              label: const Text('Choose Another'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  String _sentence(BmoEmotion e) {
    switch (e) {
      case BmoEmotion.happy:
        return 'This is a happy face.';
      case BmoEmotion.sad:
        return 'This is a sad face.';
      case BmoEmotion.angry:
        return 'This is an angry face.';
      case BmoEmotion.excited:
        return 'This is an excited face.';
      case BmoEmotion.confused:
        return 'This is a confused face.';
      case BmoEmotion.proud:
        return 'This is a proud face.';
      case BmoEmotion.frightened:
        return 'This is a scared face.';
      case BmoEmotion.bored:
        return 'This is a bored face.';
    }
  }
}

// =======================
// 4) BMO Face (CustomPainter)
// =======================
class BmoFace extends StatelessWidget {
  final BmoEmotion emotion;
  const BmoFace({super.key, required this.emotion});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BmoPainter(emotion: emotion),
    );
  }
}

class _BmoPainter extends CustomPainter {
  final BmoEmotion emotion;
  _BmoPainter({required this.emotion});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final facePaint = Paint()..color = const Color(0xFFBFEFE2);
    final borderPaint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.12, w * 0.76, h * 0.76),
      Radius.circular(w * 0.1),
    );

    canvas.drawRRect(rect, facePaint);
    canvas.drawRRect(rect, borderPaint);

    final eyePaint = Paint()..color = const Color(0xFF2C3E50);
    canvas.drawCircle(Offset(w * 0.4, h * 0.4), w * 0.035, eyePaint);
    canvas.drawCircle(Offset(w * 0.6, h * 0.4), w * 0.035, eyePaint);

    final mouthPaint = Paint()
      ..color = const Color(0xFF2C3E50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03
      ..strokeCap = StrokeCap.round;

    final y = h * 0.58;

    if (emotion == BmoEmotion.happy) {
      canvas.drawArc(
        Rect.fromCenter(
            center: Offset(w * 0.5, y), width: w * 0.25, height: h * 0.15),
        0,
        3.14,
        false,
        mouthPaint,
      );
    } else if (emotion == BmoEmotion.sad) {
      canvas.drawArc(
        Rect.fromCenter(
            center: Offset(w * 0.5, y + 20), width: w * 0.25, height: h * 0.15),
        3.14,
        3.14,
        false,
        mouthPaint,
      );
    } else {
      canvas.drawLine(Offset(w * 0.43, y), Offset(w * 0.57, y), mouthPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
