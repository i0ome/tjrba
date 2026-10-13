import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

void main() {
  runApp(const LymonChatApp());
}

class LymonChatApp extends StatelessWidget {
  const LymonChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lymon Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111B21),
        primaryColor: const Color(0xFF00A884),
      ),
      home: const AuthScreen(),
    );
  }
}

// --- نماذج البيانات ---
class UserProfile {
  final String username;
  final String email;
  final String password;
  final bool isAdmin;

  UserProfile({
    required this.username,
    required this.email,
    required this.password,
    this.isAdmin = false,
  });
}

class ChatMessage {
  final String text;
  final bool isMe;
  final bool isVoice;
  final String? voicePath;
  int status; // 1: صح مرسل، 2: صحين واصل، 3: صحين زرق مقروء

  ChatMessage({
    required this.text,
    required this.isMe,
    this.isVoice = false,
    this.voicePath,
    this.status = 1,
  });
}

// الحساب الإداري (مخفي عن العامة وموثق)
final UserProfile adminUser = UserProfile(
  username: '@Lymon',
  email: 'Mmaymanmm2020@gmail.com',
  password: 'Mmaymanmm2020',
  isAdmin: true,
);

List<UserProfile> registeredUsers = [
  adminUser,
  UserProfile(username: '@ahmed', email: 'ahmed@app.com', password: '123'),
  UserProfile(username: '@sara', email: 'sara@app.com', password: '123'),
];

UserProfile? currentUser;

// --- 1. شاشة تسجيل الدخول والإنشاء ---
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  void _submit() {
    String input = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String username = _usernameController.text.trim();

    if (isLogin) {
      // التحقق من بيانات الإدارة سرا أو أي مستخدم مسجل
      UserProfile? found;
      for (var u in registeredUsers) {
        if ((u.email == input || u.username == input) && u.password == password) {
          found = u;
          break;
        }
      }

      if (found != null) {
        currentUser = found;
        _navigateToHome();
      } else {
        ScaffoldMessenger.contextOf(context)?.showSnackBar(
          const SnackBar(content: Text('البريد أو الرمز غير صحيح')),
        );
      }
    } else {
      if (!username.startsWith('@')) {
        username = '@$username';
      }
      var newUser = UserProfile(username: username, email: input, password: password);
      registeredUsers.add(newUser);
      currentUser = newUser;
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'تسجيل الدخول - Lymon Chat' : 'إنشاء حساب جديد'),
        backgroundColor: const Color(0xFF202C33),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat_bubble_rounded, size: 70, color: Color(0xFF00A884)),
                const SizedBox(height: 20),
                const Text('مرحباً بك في Lymon Chat', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 30),

                if (!isLogin) ...[
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'اسم المستخدم (يجب أن يبدأ بـ @)',
                      prefixText: '@',
                      filled: true,
                      fillColor: const Color(0xFF202C33),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني أو اسم المستخدم',
                    filled: true,
                    fillColor: const Color(0xFF202C33),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور (الرمز)',
                    filled: true,
                    fillColor: const Color(0xFF202C33),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A884),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submit,
                  child: Text(isLogin ? 'دخول' : 'تسجيل الحساب', style: const TextStyle(fontSize: 16, color: Colors.white)),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin ? 'ليس لديك حساب؟ إنشاء حساب جديد' : 'لديك حساب بالفعل؟ تسجيل الدخول',
                    style: const TextStyle(color: Color(0xFF00A884)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- 2. الصفحة الرئيسية والبحث الحقيقي ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> myChats = ['@Lymai (المساعد الذكي 🤖)'];

  void _searchAndAddUser() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF202C33),
        title: const Text('إضافة شخص باليوزر (@)'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'اكتب اليوزر مثل @ahmed'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A884)),
            onPressed: () {
              String query = controller.text.trim();
              if (!query.startsWith('@')) query = '@$query';

              // البحث الحقيقي في النظام
              bool exists = registeredUsers.any((u) => u.username.toLowerCase() == query.toLowerCase());

              Navigator.pop(context);

              if (exists) {
                setState(() {
                  if (!myChats.contains(query)) myChats.add(query);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم العثور على المستخدم وإضافته: $query')),
                );
              } else {
                // المستخدم غير موجود حقاً
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF202C33),
                    title: const Text('عذراً'),
                    content: const Text('المستخدم غير موجود في النظام!'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسناً'))
                    ],
                  ),
                );
              }
            },
            child: const Text('بحث وإضافة'),
          ),
        ],
      ),
    );
  }

  void _createGroupDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF202C33),
        title: const Text('إنشاء جروب خاص جديد 👥'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'اسم الجروب الخاص'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A884)),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  myChats.add('${controller.text} 👥');
                });
                Navigator.pop(context);
              }
            },
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = currentUser?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Lymon Chat (${currentUser?.username ?? ""})'),
            if (isAdmin) ...[
              const SizedBox(width: 6),
              const Icon(Icons.verified, color: Colors.amber, size: 20), // صح ذهبية للإدارة
            ]
          ],
        ),
        backgroundColor: const Color(0xFF202C33),
        actions: [
          IconButton(icon: const Icon(Icons.group_add), onPressed: _createGroupDialog),
        ],
      ),
      body: ListView.builder(
        itemCount: myChats.length,
        itemBuilder: (context, index) {
          bool isAI = myChats[index].contains('Lymai');
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isAI ? Colors.indigo : const Color(0xFF00A884),
              child: Icon(isAI ? Icons.smart_toy : Icons.person, color: Colors.white),
            ),
            title: Row(
              children: [
                Text(myChats[index], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                if (myChats[index] == '@Lymon') ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.verified, color: Colors.amber, size: 16),
                ]
              ],
            ),
            subtitle: const Text('انقر لفتح الدردشة...', style: TextStyle(color: Colors.grey)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(chatName: myChats[index], isAI: isAI),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00A884),
        onPressed: _searchAndAddUser,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}

// --- 3. شاشة المحادثة (الفويس الحقيقي + الصحين الزرق + شات Lymai) ---
class ChatScreen extends StatefulWidget {
  final String chatName;
  final bool isAI;

  const ChatScreen({super.key, required this.chatName, required this.isAI});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> messages = [
    ChatMessage(text: 'مرحباً بك في الدردشة!', isMe: false, status: 3)
  ];
  final _msgController = TextEditingController();

  // أدوات تسجيل الصوت الحقيقي
  final _audioRecorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();
  bool isRecording = false;
  String? recordedPath;

  @override
  void initState() {
    super.initState();
    // محاكاة وصول الرسائل وصنعتها (صحين زرق بعد ثانية)
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          for (var m in messages) {
            m.status = 3; // صحين زرق (قراءة)
          }
        });
      }
    });
  }

  void _sendMessage({String? text, bool isVoice = false, String? path}) {
    String content = text ?? (isVoice ? '🎤 [رسالة صوتية حقيقية]' : '');
    if (content.isEmpty) return;

    setState(() {
      messages.add(ChatMessage(
        text: content,
        isMe: true,
        isVoice: isVoice,
        voicePath: path,
        status: 1, // صح واحد (أرسلت)
      ));
    });
    _msgController.clear();

    // محاكاة مراحل وصول الرسالة للطرف الآخر
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => messages.last.status = 2); // صحين رمادي (وصلت)
    });
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => messages.last.status = 3); // صحين زرق (شوهدت)
    });

    // إذا كانت المحادثة مع Lymai (الذكاء الاصطناعي)
    if (widget.isAI && !isVoice) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          setState(() {
            messages.add(ChatMessage(
              text: 'أهلاً بك! أنا مساعدك الذكي Lymai 🤖. كيف أقدر أساعدك اليوم؟',
              isMe: false,
              status: 3,
            ));
          });
        }
      });
    }
  }

  // بدء تسجيل الفويس الحقيقي
  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = Directory.systemTemp;
        String path = '${directory.path}/audio_note.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() {
          isRecording = true;
          recordedPath = path;
        });
      }
    } catch (e) {
      debugPrint('خطأ في التسجيل: $e');
    }
  }

  // إيقاف التسجيل وإرساله
  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        isRecording = false;
      });
      if (path != null) {
        _sendMessage(isVoice: true, path: path);
      }
    } catch (e) {
      debugPrint('خطأ في إيقاف التسجيل: $e');
    }
  }

  // تشغيل الفويس المسجل
  Future<void> _playVoice(String path) async {
    Source urlSource = UrlSource(path);
    await _audioPlayer.play(urlSource);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatName),
        backgroundColor: const Color(0xFF202C33),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Align(
                  alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.isMe ? const Color(0xFF005C4B) : const Color(0xFF202C33),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        msg.isVoice
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                                    onPressed: () => _playVoice(msg.voicePath ?? ''),
                                  ),
                                  const Text('رسالة صوتية (سماع)', style: TextStyle(color: Colors.white)),
                                ],
                              )
                            : Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 16)),
                        const SizedBox(height: 4),
                        if (msg.isMe)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                msg.status == 1
                                    ? '✓'
                                    : msg.status == 2
                                        ? '✓✓'
                                        : '✓✓',
                                style: TextStyle(
                                  color: msg.status == 3 ? Colors.blueAccent : Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: const Color(0xFF202C33),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: widget.isAI ? 'تحدث مع Lymai...' : 'اكتب رسالة...',
                      filled: true,
                      fillColor: const Color(0xFF2A3942),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTapDown: (_) => _startRecording(),
                  onTapUp: (_) => _stopRecording(),
                  child: CircleAvatar(
                    backgroundColor: isRecording ? Colors.red : const Color(0xFF00A884),
                    child: const Icon(Icons.mic, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF00A884)),
                  onPressed: () => _sendMessage(text: _msgController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
