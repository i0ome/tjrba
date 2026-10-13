import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const TriviaGameApp());
}

class TriviaGameApp extends StatelessWidget {
  const TriviaGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تحدي المسابقات',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      ),
      home: const CategorySelectionScreen(),
    );
  }
}

// --- نماذج البيانات (Data Models) ---
class Question {
  final String text;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
  });
}

class Category {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final List<Question> questions;

  Category({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.questions,
  });
}

// --- قاعدة البيانات المدمجة لجميع الفئات ---
final List<Category> sampleCategories = [
  Category(
    id: 'quran',
    title: 'القرآن الكريم',
    icon: Icons.menu_book_rounded,
    color: Colors.green,
    questions: [
      Question(
        text: 'ما هي أطول سورة في القرآن الكريم؟',
        options: ['سورة النساء', 'سورة البقرة', 'سورة آل عمران', 'سورة المائدة'],
        correctAnswerIndex: 1,
      ),
      Question(
        text: 'ما هي السورة التي تسمى "عروس القرآن"؟',
        options: ['سورة يس', 'سورة الرحمن', 'سورة الملك', 'سورة الواقعة'],
        correctAnswerIndex: 1,
      ),
      Question(
        text: 'كم عدد سور القرآن الكريم؟',
        options: ['112', '114', '110', '116'],
        correctAnswerIndex: 1,
      ),
    ],
  ),
  Category(
    id: 'islamic',
    title: 'أسئلة دينية',
    icon: Icons.mosque_rounded,
    color: Colors.amber,
    questions: [
      Question(
        text: 'من هو أول الصحابة إسلاماً من الرجال؟',
        options: ['عمر بن الخطاب', 'علي بن أبي طالب', 'أبو بكر الصديق', 'عثمان بن عفان'],
        correctAnswerIndex: 2,
      ),
      Question(
        text: 'كم عدد أركان الإسلام؟',
        options: ['4', '5', '6', '7'],
        correctAnswerIndex: 1,
      ),
    ],
  ),
  Category(
    id: 'yemen',
    title: 'عن اليمن',
    icon: Icons.landscape_rounded,
    color: Colors.redAccent,
    questions: [
      Question(
        text: 'ما هي عاصمة اليمن التاريخية والمشهورة بباب اليمن؟',
        options: ['عدن', 'تعز', 'صنعاء', 'المكلا'],
        correctAnswerIndex: 2,
      ),
      Question(
        text: 'ما هي الشجرة الشهيرة التي تنمو في جزيرة سقطرى؟',
        options: ['دم الأخوين', 'شجرة الزيتون', 'الأرز', 'النخيل'],
        correctAnswerIndex: 0,
      ),
      Question(
        text: 'بماذا يلقب ميناء المخا اليمني تاريخياً في عالم القهوة؟',
        options: ['Mocha', 'Arabica', 'Espresso', 'Latte'],
        correctAnswerIndex: 0,
      ),
    ],
  ),
  Category(
    id: 'sports',
    title: 'الرياضة',
    icon: Icons.sports_soccer_rounded,
    color: Colors.blueAccent,
    questions: [
      Question(
        text: 'كم عدد أفراد فريق كرة القدم داخل الملعب؟',
        options: ['10', '11', '12', '9'],
        correctAnswerIndex: 1,
      ),
      Question(
        text: 'كم مدة شوط المباراة الرسمي في كرة القدم؟',
        options: ['40 دقيقة', '45 دقيقة', '50 دقيقة', '60 دقيقة'],
        correctAnswerIndex: 1,
      ),
    ],
  ),
];

// --- 1. شاشة اختيار الفئة ---
class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحدي المسابقات الجماعية', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF16213E),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'اختر الفئة لبدء الجولة:',
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: sampleCategories.length,
                itemBuilder: (context, index) {
                  final category = sampleCategories[index];
                  return Card(
                    color: const Color(0xFF0F3460),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(category: category),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: category.color.withOpacity(0.2),
                            child: Icon(category.icon, size: 32, color: category.color),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            category.title,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${category.questions.length} أسئلة',
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 2. شاشة اللعب والأسئلة مع العداد التنازلي وترتيب الأسئلة عشوائياً بكل جولة ---
class QuizScreen extends StatefulWidget {
  final Category category;

  const QuizScreen({super.key, required this.category});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Question> _roundQuestions;
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;

  Timer? _timer;
  int _timeLeft = 15; // 15 ثانية لكل سؤال

  @override
  void initState() {
    super.initState();
    _startNewRound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startNewRound() {
    _roundQuestions = List.from(widget.category.questions)..shuffle(); // خلط الأسئلة عشوائياً لكل جولة
    _currentIndex = 0;
    _score = 0;
    _resetQuestionState();
  }

  void _resetQuestionState() {
    _selectedAnswerIndex = null;
    _isAnswered = false;
    _timeLeft = 15;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
        _timeOutAnswer();
      }
    });
  }

  void _timeOutAnswer() {
    if (_isAnswered) return;
    setState(() {
      _isAnswered = true;
    });
    _nextQuestionWithDelay();
  }

  void _answerQuestion(int index) {
    if (_isAnswered) return;
    _timer?.cancel();

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;
      if (index == _roundQuestions[_currentIndex].correctAnswerIndex) {
        _score++;
      }
    });

    _nextQuestionWithDelay();
  }

  void _nextQuestionWithDelay() {
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (_currentIndex < _roundQuestions.length - 1) {
        setState(() {
          _currentIndex++;
          _resetQuestionState();
        });
      } else {
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F3460),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('انتهت الجولة! 🎉', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('النتيجة النهائية:', style: TextStyle(color: Colors.grey.shade300, fontSize: 16)),
            const SizedBox(height: 10),
            Text('$_score / ${_roundQuestions.length}',
                style: const TextStyle(color: Colors.amber, fontSize: 36, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _startNewRound(); // جولة جديدة بترتيب أسئلة عشوائي
              });
            },
            child: const Text('جولة جديدة (خلط الأسئلة)', style: TextStyle(color: Colors.greenAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('اختيار فئة أخرى'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _roundQuestions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
        backgroundColor: const Color(0xFF16213E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // شريط التقدم والعداد
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('السؤال ${_currentIndex + 1} من ${_roundQuestions.length}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _timeLeft <= 5 ? Colors.redAccent.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer, color: _timeLeft <= 5 ? Colors.redAccent : Colors.amber, size: 20),
                      const SizedBox(width: 6),
                      Text('$_timeLeft ثانية',
                          style: TextStyle(
                            color: _timeLeft <= 5 ? Colors.redAccent : Colors.amber,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _timeLeft / 15,
              backgroundColor: Colors.white10,
              color: _timeLeft <= 5 ? Colors.redAccent : widget.category.color,
            ),
            const SizedBox(height: 25),

            // كارت السؤال
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F3460),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                currentQ.text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 25),

            // قائمة خيارات الإجابة
            Expanded(
              child: ListView.builder(
                itemCount: currentQ.options.length,
                itemBuilder: (context, index) {
                  Color buttonColor = const Color(0xFF16213E);

                  if (_isAnswered) {
                    if (index == currentQ.correctAnswerIndex) {
                      buttonColor = Colors.green.shade700;
                    } else if (index == _selectedAnswerIndex) {
                      buttonColor = Colors.red.shade700;
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _answerQuestion(index),
                      child: Text(
                        currentQ.options[index],
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
