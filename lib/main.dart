import 'package:flutter/material.dart';

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

// نموذج بيانات المستخدم
class UserProfile {
  final String username;
  final String email;
  final String password;

  UserProfile({required this.username, required this.email, required this.password});
}

// قاعدة بيانات محلية تجريبية للتطبيق
final UserProfile adminUser = UserProfile(
  username: '@Lymon',
  email: 'Mmaymanmm2020@gmail.com',
  password: 'Mmaymanmm2020',
);

List<UserProfile> registeredUsers = [adminUser];
UserProfile? currentUser;

// --- 1. شاشة تسجيل الدخول وإنشاء الحساب ---
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
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String username = _usernameController.text.trim();

    if (isLogin) {
      // التحقق من تسجيل الدخول (يدعم الحساب الإداري أو أي حساب مسجل)
      if ((email == adminUser.email || email == adminUser.username) && password == adminUser.password) {
        currentUser = adminUser;
      } else {
        // تسجيل دخول افتراضي تجريبي
        currentUser = UserProfile(username: username.isEmpty ? '@user' : username, email: email, password: password);
      }
      _navigateToHome();
    } else {
      // إنشاء حساب جديد
      if (!username.startsWith('@')) {
        username = '@$username';
      }
      currentUser = UserProfile(username: username, email: email, password: password);
      registeredUsers.add(currentUser!);
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
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(
                    isLogin ? 'ليس لديك حساب؟ إنشاء حساب جديد' : 'لديك حساب بالفعل؟ تسجيل الدخول',
                    style: const TextStyle(color: Color(0xFF00A884)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '💡 حساب الإداري التجريبي:\nالبريد: Mmaymanmm2020@gmail.com\nالرمز: Mmaymanmm2020\nالاسم: @Lymon',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- 2. الصفحة الرئيسية (الدردشات والجروبات) ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> chats = ['@Lymon (الحساب الإداري)', 'مجموعة التطوير الخاصة 👥'];

  void _addContactDialog() {
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
              if (controller.text.isNotEmpty) {
                setState(() {
                  chats.add(controller.text.startsWith('@') ? controller.text : '@${controller.text}');
                });
                Navigator.pop(context);
              }
            },
            child: const Text('إضافة'),
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
                  chats.add('${controller.text} 👥');
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Lymon Chat (${currentUser?.username ?? ""})'),
        backgroundColor: const Color(0xFF202C33),
        actions: [
          IconButton(icon: const Icon(Icons.group_add), onPressed: _createGroupDialog),
        ],
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF00A884),
              child: Text(chats[index][0], style: const TextStyle(color: Colors.white)),
            ),
            title: Text(chats[index], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('انقر لبدء المحادثة...', style: TextStyle(color: Colors.grey)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen(chatName: chats[index])),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'group',
            backgroundColor: const Color(0xFF202C33),
            onPressed: _createGroupDialog,
            child: const Icon(Icons.group, color: Colors.white),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'contact',
            backgroundColor: const Color(0xFF00A884),
            onPressed: _addContactDialog,
            child: const Icon(Icons.person_add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// --- 3. شاشة المحادثة وتسجيل الفويس (Voice Notes) ---
class ChatScreen extends StatefulWidget {
  final String chatName;
  const ChatScreen({super.key, required this.chatName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<String> messages = ['مرحباً بك في المحادثة!'];
  final _msgController = TextEditingController();
  bool isRecordingVoice = false;

  void _sendMessage() {
    if (_msgController.text.isNotEmpty) {
      setState(() {
        messages.add(_msgController.text);
        _msgController.clear();
      });
    }
  }

  void _sendVoiceNote() {
    setState(() {
      messages.add('🎤 [رسالة صوتية Voice Note (0:05)]');
    });
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
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF005C4B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(messages[index], style: const TextStyle(color: Colors.white, fontSize: 16)),
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
                      hintText: 'اكتب رسالة...',
                      filled: true,
                      fillColor: const Color(0xFF2A3942),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onLongPressStart: (_) => setState(() => isRecordingVoice = true),
                  onLongPressEnd: (_) {
                    setState(() => isRecordingVoice = false);
                    _sendVoiceNote();
                  },
                  child: CircleAvatar(
                    backgroundColor: isRecordingVoice ? Colors.red : const Color(0xFF00A884),
                    child: IconButton(
                      icon: const Icon(Icons.mic, color: Colors.white),
                      onPressed: _sendVoiceNote, // ضغطة لإرسال فويس تجريبي أو مطول
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF00A884)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
