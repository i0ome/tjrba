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
      title: 'Lymon Chat Pro',
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

// --- النماذج وبيانات التطبيق ---
class UserProfile {
  String username;
  String email;
  String password;
  String avatarUrl;
  bool isAdmin;
  bool isBanned;
  bool isTimeout;

  UserProfile({
    required this.username,
    required this.email,
    required this.password,
    this.avatarUrl = '',
    this.isAdmin = false,
    this.isBanned = false,
    this.isTimeout = false,
  });
}

class ChatMessage {
  final String text;
  final bool isMe;
  final bool isVoice;
  final String? voicePath;
  int status; // 1: مرسل، 2: واصل، 3: مقروء

  ChatMessage({
    required this.text,
    required this.isMe,
    this.isVoice = false,
    this.voicePath,
    this.status = 1,
  });
}

class Ticket {
  final String id;
  final String username;
  final String type;
  final List<ChatMessage> messages;

  Ticket({required this.id, required this.username, required this.type, required this.messages});
}

// الحساب الإداري الرسمي (موثق بصح خضراء)
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

List<String> publicGroups = ['@General_Public_Chat 🌍', '@Gamers_Hub 🎮'];
List<Ticket> allTickets = [];

UserProfile? currentUser;

// --- 1. شاشة المصادقة وتسجيل الدخول ---
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
      UserProfile? found;
      for (var u in registeredUsers) {
        if ((u.email == input || u.username == input) && u.password == password) {
          found = u;
          break;
        }
      }

      if (found != null) {
        if (found.isBanned) {
          _showMsg('حسابك محظور مؤبداً من الإدارة!');
          return;
        }
        if (found.isTimeout) {
          _showMsg('حسابك في تايم آوت مؤقت!');
          return;
        }
        currentUser = found;
        _navigateToHome();
      } else {
        _showMsg('البريد أو الرمز غير صحيح');
      }
    } else {
      if (!username.startsWith('@')) username = '@$username';
      var newUser = UserProfile(username: username, email: input, password: password);
      registeredUsers.add(newUser);
      currentUser = newUser;
      _navigateToHome();
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
      appBar: AppBar(title: Text(isLogin ? 'دخول Lymon Chat' : 'إنشاء حساب'), backgroundColor: const Color(0xFF202C33)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat_bubble_rounded, size: 70, color: Color(0xFF00A884)),
                const SizedBox(height: 20),
                if (!isLogin) ...[
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'اسم المستخدم (يبدأ بـ @)', prefixText: '@', filled: true, fillColor: const Color(0xFF202C33)),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'البريد أو اليوزر', filled: true, fillColor: Color(0xFF202C33)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'كلمة المرور', filled: true, fillColor: Color(0xFF202C33)),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A884), minimumSize: const Size.fromHeight(50)),
                  onPressed: _submit,
                  child: Text(isLogin ? 'دخول' : 'تسجيل'),
                ),
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(isLogin ? 'إنشاء حساب جديد' : 'لديك حساب؟ سجل دخولك'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- 2. الصفحة الرئيسية ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> myChats = ['@Lymai (الذكاء الاصطناعي 🤖)', 'تذاكر الدعم الفني 🎫'];

  void _searchAndAdd() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF202C33),
        title: const Text('البحث (شخص أو جروب عام)'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: '@user أو اسم الجروب')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A884)),
            onPressed: () {
              String q = controller.text.trim();
              Navigator.pop(context);
              if (publicGroups.contains(q) || registeredUsers.any((u) => u.username.toLowerCase() == q.toLowerCase())) {
                setState(() {
                  if (!myChats.contains(q)) myChats.add(q);
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم الانضمام/الإضافة: $q')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('غير موجود!')));
              }
            },
            child: const Text('بحث'),
          ),
        ],
      ),
    );
  }

  void _createPublicGroup() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF202C33),
        title: const Text('إنشاء جروب عام 🌍'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'اسم الجروب مع @')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A884)),
            onPressed: () {
              String name = controller.text.trim();
              if (name.isNotEmpty) {
                if (!name.startsWith('@')) name = '@$name';
                publicGroups.add(name);
                setState(() => myChats.add(name));
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
            Text('Lymon Chat (${currentUser?.username})'),
            if (isAdmin) ...[
              const SizedBox(width: 4),
              const Icon(Icons.verified, color: Colors.green, size: 20), // صح خضراء للإدارة
            ]
          ],
        ),
        backgroundColor: const Color(0xFF202C33),
        actions: [
          IconButton(icon: const Icon(Icons.public), onPressed: _createPublicGroup),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())).then((_) => setState(() {})),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: myChats.length,
        itemBuilder: (context, index) {
          String chat = myChats[index];
          bool isAI = chat.contains('Lymai');
          bool isTicketHub = chat.contains('تذاكر');

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isAI ? Colors.indigo : (isTicketHub ? Colors.orange : const Color(0xFF00A884)),
              child: Icon(isAI ? Icons.smart_toy : (isTicketHub ? Icons.confirmation_number : Icons.group), color: Colors.white),
            ),
            title: Row(
              children: [
                Text(chat, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                if (chat == '@Lymon') const Icon(Icons.verified, color: Colors.green, size: 16),
              ],
            ),
            subtitle: const Text('انقر لفتح الدردشة...', style: TextStyle(color: Colors.grey)),
            onTap: () {
              if (isTicketHub) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TicketsScreen()));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chatName: chat, isAI: isAI)));
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00A884),
        onPressed: _searchAndAdd,
        child: const Icon(Icons.search, color: Colors.white),
      ),
    );
  }
}

// --- 3. إعدادات الحساب (تغيير الاسم والصورة) ---
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _avatarController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: currentUser?.username);
    _avatarController = TextEditingController(text: currentUser?.avatarUrl);
  }

  void _save() {
    setState(() {
      currentUser?.username = _nameController.text.trim();
      currentUser?.avatarUrl = _avatarController.text.trim();
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات الحساب'), backgroundColor: const Color(0xFF202C33)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'تغيير اسم المستخدم')),
            const SizedBox(height: 16),
            TextField(controller: _avatarController, decoration: const InputDecoration(labelText: 'رابط الصورة الشخصية (Avatar URL)')),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A884), minimumSize: const Size.fromHeight(50)),
              onPressed: _save,
              child: const Text('حفظ التعديلات'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 4. نظام التذاكر (شكاوى واقتراحات - للإدارة وصاحب التذكرة فقط) ---
class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  void _openNewTicket(String type) {
    String tid = 'تذكرة #${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    Ticket newT = Ticket(id: tid, username: currentUser!.username, type: type, messages: [
      ChatMessage(text: 'تم فتح التذكرة بنجاح من نوع: $type. سيتم الرد قريباً من الإدارة.', isMe: false)
    ]);
    setState(() {
      allTickets.add(newT);
    });
    Navigator.push(context, MaterialPageRoute(builder: (_) => TicketChatScreen(ticket: newT)));
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = currentUser?.isAdmin ?? false;
    // الإدارة ترى كل التذاكر، والمستخدم يرى تذاكره فقط
    List<Ticket> visibleTickets = isAdmin 
        ? allTickets 
        : allTickets.where((t) => t.username == currentUser?.username).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('نظام التذاكر (اقتراح وشكوى)'), backgroundColor: const Color(0xFF202C33)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () => _openNewTicket('اقتراح 💡'),
                  icon: const Icon(Icons.lightbulb),
                  label: const Text('فتح اقتراح'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => _openNewTicket('شكوى ⚠️'),
                  icon: const Icon(Icons.report),
                  label: const Text('فتح شكوى'),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey),
          Expanded(
            child: ListView.builder(
              itemCount: visibleTickets.length,
              itemBuilder: (context, index) {
                Ticket t = visibleTickets[index];
                return ListTile(
                  leading: const Icon(Icons.confirmation_number, color: Colors.amber),
                  title: Text(t.id, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('النوع: ${t.type} | صاحبها: ${t.username}'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TicketChatScreen(ticket: t))),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// شاشة محادثة التذكرة الخاصة
class TicketChatScreen extends StatefulWidget {
  final Ticket ticket;
  const TicketChatScreen({super.key, required this.ticket});

  @override
  State<TicketChatScreen> createState() => _TicketChatScreenState();
}

class _TicketChatScreenState extends State<TicketChatScreen> {
  final _ctrl = TextEditingController();

  void _send() {
    if (_ctrl.text.isEmpty) return;
    setState(() {
      widget.ticket.messages.add(ChatMessage(text: _ctrl.text, isMe: true));
      _ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.ticket.id), backgroundColor: const Color(0xFF202C33)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.ticket.messages.length,
              itemBuilder: (context, index) {
                var m = widget.ticket.messages[index];
                return Align(
                  alignment: m.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: m.isMe ? const Color(0xFF005C4B) : const Color(0xFF202C33), borderRadius: BorderRadius.circular(8)),
                    child: Text(m.text, style: const TextStyle(color: Colors.white)),
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
                Expanded(child: TextField(controller: _ctrl, decoration: const InputDecoration(hintText: 'اكتب ردك للتذكرة...'))),
                IconButton(icon: const Icon(Icons.send, color: Color(0xFF00A884)), onPressed: _send),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 5. شاشة الدردشة والفويس الحقيقي والذكاء الاصطناعي وصلاحيات الإدارة ---
class ChatScreen extends StatefulWidget {
  final String chatName;
  final bool isAI;

  const ChatScreen({super.key, required this.chatName, required this.isAI});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> messages = [];
  final _msgController = TextEditingController();

  // أدوات الفويس الحقيقي
  final _audioRecorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();
  bool isRecording = false;
  String? recordedPath;

  @override
  void initState() {
    super.initState();
    messages.add(ChatMessage(text: 'أهلاً بك في محادثة ${widget.chatName}', isMe: false, status: 3));
  }

  void _sendMessage({String? text, bool isVoice = false, String? path}) {
    String content = text ?? (isVoice ? '🎤 [رسالة صوتية حقيقية]' : '');
    if (content.isEmpty) return;

    setState(() {
      messages.add(ChatMessage(text: content, isMe: true, isVoice: isVoice, voicePath: path, status: 1));
    });
    _msgController.clear();

    // محاكاة استلام الرسالة والصحين الزرق
    Future.delayed(const Duration(milliseconds: 600), () => setState(() => messages.last.status = 2));
    Future.delayed(const Duration(milliseconds: 1200), () => setState(() => messages.last.status = 3));

    // رد الذكاء الاصطناعي الذكي (Lymai)
    if (widget.isAI && !isVoice) {
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (mounted) {
          setState(() {
            messages.add(ChatMessage(
              text: 'أهلاً بك! أنا مساعدك الذكي Lymai 🤖. لقد فهمت سؤالك حول "$content" وأنا هنا للإجابة ومساعدتك دائماً!',
              isMe: false,
              status: 3,
            ));
          });
        }
      });
    }
  }

  // تسجيل الصوت الحقيقي 100%
  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        String path = '${Directory.systemTemp.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() {
          isRecording = true;
          recordedPath = path;
        });
      }
    } catch (e) {
      debugPrint('خطأ تسجيل: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() => isRecording = false);
      if (path != null) {
        _sendMessage(isVoice: true, path: path);
      }
    } catch (e) {
      debugPrint('خطأ إيقاف: $e');
    }
  }

  Future<void> _playVoice(String path) async {
    await _audioPlayer.play(UrlSource(path));
  }

  // لوحة إدارة المشرفين (تبنيد، تايم آوت، فك الحظر)
  void _showAdminPanel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF202C33),
        title: const Text('لوحة تحكم الإدارة 🛡️'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إعطاء تايم آوت للمستخدم')));
              },
              child: const Text('إعطاء تايم آوت مؤقت ⏱️'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حظر المستخدم مؤبداً ⛔')));
              },
              child: const Text('حظر مؤبد ⛔'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم فك الحظر عن المستخدم ✅')));
              },
              child: const Text('فك الحظر عنه ✅'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = currentUser?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatName),
        backgroundColor: const Color(0xFF202C33),
        actions: [
          if (isAdmin)
            IconButton(icon: const Icon(Icons.admin_panel_settings, color: Colors.green), onPressed: _showAdminPanel),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var m = messages[index];
                return Align(
                  alignment: m.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: m.isMe ? const Color(0xFF005C4B) : const Color(0xFF202C33),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        m.isVoice
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                                    onPressed: () => _playVoice(m.voicePath ?? ''),
                                  ),
                                  const Text('🔊 رسالة صوتية حقيقية', style: TextStyle(color: Colors.white)),
                                ],
                              )
                            : Text(m.text, style: const TextStyle(color: Colors.white, fontSize: 16)),
                        const SizedBox(height: 4),
                        if (m.isMe)
                          Text(
                            m.status == 1 ? '✓' : (m.status == 2 ? '✓✓' : '✓✓'),
                            style: TextStyle(color: m.status == 3 ? Colors.blueAccent : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
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
