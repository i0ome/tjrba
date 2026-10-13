import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const BalootMatchmakingApp());
}

class BalootMatchmakingApp extends StatelessWidget {
  const BalootMatchmakingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'بلوت أونلاين ذكية',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
      ),
      home: const MatchmakingScreen(),
    );
  }
}

// --- 1. شاشة البحث عن لاعبين (Matchmaking) ---
class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  int _searchTime = 0;
  Timer? _matchTimer;
  int _realPlayersFound = 1; // أنت اللاعب الأول

  @override
  void initState() {
    super.initState();
    _startSearching();
  }

  @override
  void dispose() {
    _matchTimer?.cancel();
    super.dispose();
  }

  void _startSearching() {
    _matchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _searchTime++;
        
        // محاكاة دخول لاعب حقيقي بعد ثانيتين (اختياري)
        if (_searchTime == 2) {
          _realPlayersFound = 2;
        }

        // إذا مرّت 6 ثوانٍ ولم يكتمل العدد 4، نقوم بإكمال الطاولة بـ بوتات (AI) ونبدأ اللعبة
        if (_searchTime >= 6) {
          _matchTimer?.cancel();
          _goToTable(isUsingBots: true);
        }
      });
    });
  }

  void _goToTable({required bool isUsingBots}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SmartBalootTableScreen(isUsingBots: isUsingBots, realPlayersCount: _realPlayersFound),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث عن طاولة بلوت'),
        backgroundColor: const Color(0xFF1B263B),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.amber, strokeWidth: 4),
              const SizedBox(height: 30),
              const Text(
                'جاري البحث عن خصوم حقيقيين...',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                'اللاعبون المتصلون الآن: $_realPlayersFound / 4',
                style: const TextStyle(fontSize: 16, color: Colors.greenAccent),
              ),
              const SizedBox(height: 10),
              Text(
                'وقت الانتظار: $_searchTime ثوانٍ\n(إذا لم يكتمل العدد، سيتم إدخال بوتات تلقائياً)',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade800,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                onPressed: () {
                  _matchTimer?.cancel();
                  Navigator.pop(context);
                },
                child: const Text('إلغاء البحث'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 2. طاولة اللعب الذكية (تدمج بين الحقيقيين والـ AI) ---
class SmartBalootTableScreen extends StatelessWidget {
  final bool isUsingBots;
  final int realPlayersCount;

  const SmartBalootTableScreen({
    super.key,
    required this.isUsingBots,
    required this.realPlayersCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isUsingBots ? 'طاولة هجينة (أشخاص + بوتات AI)' : 'طاولة أونلاين حقيقية 100%'),
        backgroundColor: const Color(0xFF1B263B),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1B4332), // لون الطاولة الأخضر
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // الخصم الشمال (غالباً بوت أو حقيقي)
            const Column(
              children: [
                CircleAvatar(backgroundColor: Colors.orangeAccent, child: Icon(Icons.smart_toy)),
                SizedBox(height: 4),
                Text('الخصم 1 [بوت AI بديل]', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),

            // منتصف الطاولة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Column(
                  children: [
                    CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.person)),
                    Text('الخصم 2 [لاعب حقيقي]', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF081C15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.style, color: Colors.amber, size: 36),
                      const SizedBox(height: 8),
                      Text(
                        isUsingBots ? 'طاولة مكتملة بـ (بوتات ذكية)' : 'طاولة أونلاين صافية',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Column(
                  children: [
                    CircleAvatar(backgroundColor: Colors.orangeAccent, child: Icon(Icons.smart_toy)),
                    Text('خويك [بوت AI بديل]', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),

            // أوراقك في الأسفل
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF081C15),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Column(
                children: [
                  Text('أنت تلعب الآن بانتظام مع ميزة القيد والمشاريع!', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('♠ K   ♥ Q   ♦ 10   ♣ A   ♠ 9', style: TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
