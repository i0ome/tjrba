import 'package:flutter/material.dart';
import 'dart:async';

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
  bool isOwner; // المالك @Lymon
  String badgeType; // 'gold', 'green', 'blue', 'none'
  bool isBanned;
  bool isTimeout;

  UserProfile({
    required this.username,
    required this.email,
    required this.password,
    this.avatarUrl = '',
    this.isOwner = false,
    this.badgeType = 'none',
    this.isBanned = false,
    this.isTimeout = false,
  });
}

class ChatMessage {
  final String text;
  final String sender;
  int status; // 1: مرسل (صح)، 2: واصل (صحين رمادي)، 3: مقروء (صحين أزرق)

  ChatMessage({
    required this.text,
    required this.sender,
    this.status = 1,
  });
}

class ChatRoom {
  final String chatId;
  final String chatName;
  final List<ChatMessage> messages;
  bool isReadByPeer;

  ChatRoom({
    required this.chatId,
    required this.chatName,
    required this.messages,
    this.isReadByPeer = false,
  });
}

// الحساب الإداري المالك (الصح الأصفر)
final UserProfile ownerUser = UserProfile(
  username: '@Lymon',
  email: 'Mmaymanmm2020@gmail.com',
  password: 'Mmaymanmm2020',
  avatarUrl: 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=500', // شعار قريب للمالك
  isOwner: true,
  badgeType: 'gold',
);

List<UserProfile> registeredUsers = [
  ownerUser,
  UserProfile(username: '@ahmed', email: 'ahmed@app.com', password: '123', badgeType: 'none'),
  UserProfile(username: '@sara', email: 'sara@app.com', password: '123', badgeType: 'blue'),
];

List<ChatRoom> allActiveChats = [];
UserProfile? currentUser;

// --- 1. شاشة تسجيل الدخول ---
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
          _showMsg('حسابك محظور من الإدارة!');
          return;
        }
        currentUser = found;
        _navigateToHome();
      } else {
        _showMsg('البريد أو الرمز غير صحيح');
      }
    } else {
      if (!username.startsWith('@')) username = '@$username';
      var newUser = UserProfile(username: username, email: input, password: password, badgeType: 'none');
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
      appBar: AppBar(title: Text(isLogin ? 'تسجيل الدخول - Lymon Chat' : 'إنشاء حساب'), backgroundColor: const Color(0xFF202C33)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 45,
                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1550547660-d9450f859349?w=500'),
                ),
                const SizedBox(height: 20),
                const Text('Lymon Chat Pro', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 30),
                if (!isLogin) ...[
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'اسم المستخدم (يبدأ بـ @)', prefixText: '@', filled: true, fillColor: Color(0xFF202C33)),
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
  final List<String> myChats = ['@Lymai (الذكاء الاصطناعي 🤖)'];

  void _searchAndAdd() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF202C33),
        title: const Text('إضافة شخص باليوزر (@)'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: '@user')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A884)),
            onPressed: () {
              String q = controller.text.trim();
              if (!q.startsWith('@')) q = '@$q';
              Navigator.pop(context);

              bool exists = registeredUsers.any((u) => u.username.toLowerCase() == q.toLowerCase());
              if (exists) {
                setState(() {
                  if (!myChats.contains(q)) myChats.add(q);
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تمت الإضافة: $q')));
              } else {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF202C33),
                    title: const Text('خطأ'),
                    content: const Text('المستخدم غير موجود في النظام!'),
                    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسناً'))],
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

  Widget _getBadgeIcon(String badge) {
    if (badge == 'gold') return const Icon(Icons.verified, color: Colors.amber, size: 18);
    if (badge == 'green') return const Icon(Icons.verified, color: Colors.green, size: 18);
    if (badge == 'blue') return const Icon(Icons.verified, color: Colors.blueAccent, size: 18);
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Lymon Chat (${currentUser?.username})'),
            const SizedBox(width: 4),
            _getBadgeIcon(currentUser?.badgeType ?? 'none'),
          ],
        ),
        backgroundColor: const Color(0xFF202C33),
        actions: [
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
          UserProfile? peer = registeredUsers.firstWhere(
            (u) => u.username == chat,
            orElse: () => UserProfile(username: '', email: '', password: ''),
          );

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isAI ? Colors.indigo : const Color(0xFF00A884),
              backgroundImage: peer.avatarUrl.isNotEmpty ? NetworkImage(peer.avatarUrl) : null,
              child: peer.avatarUrl.isEmpty && !isAI ? const Icon(Icons.person) : null,
            ),
            title: Row(
              children: [
                Text(chat, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                if (!isAI) _getBadgeIcon(peer.badgeType),
              ],
            ),
            subtitle: const Text('انقر لفتح الدردشة...', style: TextStyle(color: Colors.grey)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chatName: chat, isAI: isAI)))
                  .then((_) => setState(() {}));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00A884),
        onPressed: _searchAndAdd,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}

// --- 3. إعدادات الحساب وزر تسجيل الخروج ---
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

  void _logout() {
    currentUser = null;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  // لوحة تحكم المالك لإعطاء الصح الأخضر أو الأزرق
  void _openOwnerBadgePanel() {
    showDialog(
      context: context,
      builder: (context) {
        String targetUser = '';
        return AlertDialog(
          backgroundColor: const Color(0xFF202C33),
          title: const Text('لوحة المالك: توزيع التوثيق 🌟'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (v) => targetUser = v,
                decoration: const InputDecoration(hintText: 'يوزر المستخدم مثل @ahmed'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      for (var u in registeredUsers) {
                        if (u.username.toLowerCase() == targetUser.trim().toLowerCase()) {
                          u.badgeType = 'green';
                        }
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إعطاء الصح الأخضر!')));
                    },
                    child: const Text('صح أخضر 🟢'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    onPressed: () {
                      for (var u in registeredUsers) {
                        if (u.username.toLowerCase() == targetUser.trim().toLowerCase()) {
                          u.badgeType = 'blue';
                        }
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إعطاء الصح الأزرق!')));
                    },
                    child: const Text('صح أزرق 🔵'),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isOwner = currentUser?.isOwner ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات الحساب'), backgroundColor: const Color(0xFF202C33)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'تغيير الاسم')),
            const SizedBox(height: 16),
            TextField(controller: _avatarController, decoration: const InputDecoration(labelText: 'رابط الصورة الشخصية')),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A884), minimumSize: const Size.fromHeight(50)),
              onPressed: _save,
              child: const Text('حفظ التعديلات'),
            ),
            const SizedBox(height: 12),
            if (isOwner)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800, minimumSize: const Size.fromHeight(50)),
                onPressed: _openOwnerBadgePanel,
                child: const Text('لوحة المالك (منح الصح الأخضر والأزرق) 👑', style: TextStyle(color: Colors.white)),
              ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, minimumSize: const Size.fromHeight(50)),
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 4. شاشة الدردشة الحقيقية (الصحين لا يصبحان أزرق إلا عند فتحها) ---
class ChatScreen extends StatefulWidget {
  final String chatName;
  final bool isAI;

  const ChatScreen({super.key, required this.chatName, required this.isAI});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatRoom room;
  final _msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // البحث عن غرفة محادثة سابقة أو إنشاء واحدة جديدة
    String rid = '${currentUser?.username}_${widget.chatName}';
    var found = allActiveChats.where((c) => c.chatId == rid);
    if (found.isNotEmpty) {
      room = found.first;
    } else {
      room = ChatRoom(chatId: rid, chatName: widget.chatName, messages: [
        ChatMessage(text: 'أهلاً بك في الدردشة مع ${widget.chatName}', sender: 'system', status: 3)
      ]);
      allActiveChats.add(room);
    }

    // بمجرد أن يفتح المستخدم الدردشة، تتحول جميع رسائل الطرف الآخر إلى "مقروءة" (صحين أزرق) حقيقياً
    for (var m in room.messages) {
      if (m.sender != currentUser?.username && m.sender != 'system') {
        m.status = 3;
      }
    }
  }

  void _sendMessage() {
    String text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      // حالة الرسالة تبدأ بـ 1 (صح أُرسلت)، وعند تسليمها تصبح 2 (صحين رمادي لأن الشخص قد لا يكون فاتحاً الآن)
      var msg = ChatMessage(text: text, sender: currentUser!.username, status: 2);
      room.messages.add(msg);
      _msgController.clear();
    });

    // رد الذكاء الاصطناعي Lymai فوراً
    if (widget.isAI) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            room.messages.add(ChatMessage(
              text: 'أهلاً بك! أنا مساعدك الذكي Lymai 🤖. استلمت رسالتك وأنا هنا لخدمتك.',
              sender: 'Lymai',
              status: 3,
            ));
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.chatName), backgroundColor: const Color(0xFF202C33)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: room.messages.length,
              itemBuilder: (context, index) {
                var m = room.messages[index];
                bool isMe = m.sender == currentUser?.username;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF005C4B) : const Color(0xFF202C33),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(m.text, style: const TextStyle(color: Colors.white, fontSize: 16)),
                        const SizedBox(height: 4),
                        if (isMe)
                          Text(
                            m.status == 1
                                ? '✓'
                                : m.status == 2
                                    ? '✓✓'
                                    : '✓✓',
                            style: TextStyle(
                              color: m.status == 3 ? Colors.blueAccent : Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
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
