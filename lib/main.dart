import 'package:flutter/material.dart';

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
class AppNotification {
  final String title;
  final String body;
  final DateTime time;

  AppNotification({required this.title, required this.body, required this.time});
}

class TweetPost {
  final String id;
  final String author;
  final String authorBadge;
  final String content;
  int likes;
  List<String> likedBy;

  TweetPost({
    required this.id,
    required this.author,
    required this.authorBadge,
    required this.content,
    this.likes = 0,
    List<String>? likedBy,
  }) : likedBy = likedBy ?? [];
}

class UserProfile {
  String username;
  String email;
  String password;
  String avatarUrl;
  bool isOwner;
  String badgeType; // 'gold' (مالك), 'green' (إداري), 'blue' (موثق), 'none'
  List<String> following;
  List<String> followers;
  List<AppNotification> notifications;
  bool isBanned;

  UserProfile({
    required this.username,
    required this.email,
    required this.password,
    this.avatarUrl = '',
    this.isOwner = false,
    this.badgeType = 'none',
    List<String>? following,
    List<String>? followers,
    List<AppNotification>? notifications,
    this.isBanned = false,
  })  : following = following ?? [],
        followers = followers ?? [],
        notifications = notifications ?? [];
}

class ChatMessage {
  String text;
  final String sender;
  bool isDeleted;
  int status; // 1: مرسل، 2: واصل، 3: مقروء

  ChatMessage({
    required this.text,
    required this.sender,
    this.isDeleted = false,
    this.status = 1,
  });
}

class ChatRoom {
  final String chatId;
  final String chatName;
  final List<ChatMessage> messages;

  ChatRoom({
    required this.chatId,
    required this.chatName,
    required this.messages,
  });
}

class Ticket {
  final String id;
  final String username;
  final String type;
  final List<ChatMessage> messages;

  Ticket({required this.id, required this.username, required this.type, required this.messages});
}

// حساب المالك الرسمي (الصح الأصفر)
final UserProfile ownerUser = UserProfile(
  username: '@Lymon',
  email: 'Mmaymanmm2020@gmail.com',
  password: 'Mmaymanmm2020',
  avatarUrl: 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=500', 
  isOwner: true,
  badgeType: 'gold',
);

List<UserProfile> registeredUsers = [
  ownerUser,
  UserProfile(username: '@ahmed', email: 'ahmed@app.com', password: '123', badgeType: 'green'), // إداري
  UserProfile(username: '@sara', email: 'sara@app.com', password: '123', badgeType: 'blue'),
];

List<ChatRoom> allActiveChats = [];
List<Ticket> allTickets = [];
List<TweetPost> allTweets = [
  TweetPost(id: '1', author: '@Lymon', authorBadge: 'gold', content: 'مرحباً بكم في التحديث الجديد لـ Lymon Chat Pro! 🎉'),
];

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
                  child: Text(isLogin ? 'ليس لديك حساب؟ إنشاء حساب' : 'لديك حساب؟ سجل دخولك'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- 2. الصفحة الرئيسية (الدردشات والتغريدات والإشعارات) ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<String> myChats = ['@Lymai (الذكاء الاصطناعي 🤖)', 'تذاكر الدعم الفني 🎫'];

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
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('المستخدم غير موجود!')));
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
    bool hasAdminPower = currentUser?.isOwner == true || currentUser?.badgeType == 'green';

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
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (currentUser!.notifications.isNotEmpty)
                  const Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
                  )
              ],
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())).then((_) => setState(() {})),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // 1. قائمة الدردشات
          ListView.builder(
            itemCount: myChats.length,
            itemBuilder: (context, index) {
              String chat = myChats[index];
              bool isAI = chat.contains('Lymai');
              bool isTicketHub = chat.contains('تذاكر');

              UserProfile? peer = registeredUsers.firstWhere(
                (u) => u.username == chat,
                orElse: () => UserProfile(username: '', email: '', password: ''),
              );

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isAI ? Colors.indigo : (isTicketHub ? Colors.orange : const Color(0xFF00A884)),
                  backgroundImage: peer.avatarUrl.isNotEmpty ? NetworkImage(peer.avatarUrl) : null,
                  child: peer.avatarUrl.isEmpty && !isAI && !isTicketHub ? const Icon(Icons.person) : null,
                ),
                title: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!isAI && !isTicketHub) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileScreen(user: peer)))
                              .then((_) => setState(() {}));
                        }
                      },
                      child: Text(chat, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 4),
                    if (!isAI && !isTicketHub) _getBadgeIcon(peer.badgeType),
                  ],
                ),
                subtitle: const Text('انقر لفتح المحادثة...', style: TextStyle(color: Colors.grey)),
                onTap: () {
                  if (isTicketHub) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TicketsScreen()));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chatName: chat, isAI: isAI)))
                        .then((_) => setState(() {}));
                  }
                },
              );
            },
          ),

          // 2. صفحة التغريدات النصية والتفاعل
          const TweetsFeedScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF202C33),
        selectedItemColor: const Color(0xFF00A884),
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'الدردشات'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'التغريدات'),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF00A884),
              onPressed: _searchAndAdd,
              child: const Icon(Icons.person_add, color: Colors.white),
            )
          : null,
    );
  }
}

// --- 3. صفحة التغريدات الكتابية والمشاركة ---
class TweetsFeedScreen extends StatefulWidget {
  const TweetsFeedScreen({super.key});

  @override
  State<TweetsFeedScreen> createState() => _TweetsFeedScreenState();
}

class _TweetsFeedScreenState extends State<TweetsFeedScreen> {
  final _tweetController = TextEditingController();

  void _postTweet() {
    if (_tweetController.text.trim().isEmpty) return;
    setState(() {
      allTweets.insert(
        0,
        TweetPost(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          author: currentUser!.username,
          authorBadge: currentUser!.badgeType,
          content: _tweetController.text.trim(),
        ),
      );
      _tweetController.clear();
    });
  }

  void _shareTweetWithFriends(TweetPost tweet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF202C33),
        title: const Text('مشاركة التغريدة مع المتابعين'),
        content: const Text('سيتم مشاركة رابط التغريدة في دردشات أصدقائك.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A884)),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم مشاركة التغريدة بنجاح!')));
            },
            child: const Text('مشاركة الآن'),
          )
        ],
      ),
    );
  }

  Widget _getBadgeIcon(String badge) {
    if (badge == 'gold') return const Icon(Icons.verified, color: Colors.amber, size: 16);
    if (badge == 'green') return const Icon(Icons.verified, color: Colors.green, size: 16);
    if (badge == 'blue') return const Icon(Icons.verified, color: Colors.blueAccent, size: 16);
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: const Color(0xFF202C33),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tweetController,
                  decoration: const InputDecoration(hintText: 'ماذا يدور في ذهنك؟ اكتب تغريدة...'),
                ),
              ),
              IconButton(icon: const Icon(Icons.send, color: Color(0xFF00A884)), onPressed: _postTweet),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: allTweets.length,
            itemBuilder: (context, index) {
              final post = allTweets[index];
              bool isLiked = post.likedBy.contains(currentUser!.username);

              return Card(
                color: const Color(0xFF202C33),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(post.author, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(width: 4),
                          _getBadgeIcon(post.authorBadge),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(post.content, style: const TextStyle(fontSize: 16, color: Colors.white70)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    if (isLiked) {
                                      post.likedBy.remove(currentUser!.username);
                                      post.likes--;
                                    } else {
                                      post.likedBy.add(currentUser!.username);
                                      post.likes++;
                                    }
                                  });
                                },
                              ),
                              Text('${post.likes}', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.grey),
                            onPressed: () => _shareTweetWithFriends(post),
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
      ],
    );
  }
}

// --- 4. شاشة الإشعارات ---
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var list = currentUser?.notifications ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات'), backgroundColor: const Color(0xFF202C33)),
      body: list.isEmpty
          ? const Center(child: Text('لا توجد إشعارات جديدة حالياً', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                var n = list[index];
                return ListTile(
                  leading: const Icon(Icons.notifications_active, color: Color(0xFF00A884)),
                  title: Text(n.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(n.body, style: const TextStyle(color: Colors.grey)),
                );
              },
            ),
    );
  }
}

// --- 5. شاشة ملف الشخص (رفع الصورة، الفولو، والإشعار) ---
class UserProfileScreen extends StatefulWidget {
  final UserProfile user;
  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    bool isFollowing = currentUser!.following.contains(widget.user.username);
    bool hasAdminPower = currentUser!.isOwner || currentUser!.badgeType == 'green';

    return Scaffold(
      appBar: AppBar(title: Text('ملف ${widget.user.username}'), backgroundColor: const Color(0xFF202C33)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: widget.user.avatarUrl.isNotEmpty ? NetworkImage(widget.user.avatarUrl) : null,
              child: widget.user.avatarUrl.isEmpty ? const Icon(Icons.person, size: 50) : null,
            ),
            const SizedBox(height: 16),
            Text(widget.user.username, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text('${widget.user.followers.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                    const Text('المتابعون', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                Column(
                  children: [
                    Text('${widget.user.following.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                    const Text('يتابع', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? Colors.grey.shade700 : const Color(0xFF00A884),
                minimumSize: const Size.fromHeight(45),
              ),
              onPressed: () {
                setState(() {
                  if (isFollowing) {
                    currentUser!.following.remove(widget.user.username);
                    widget.user.followers.remove(currentUser!.username);
                  } else {
                    currentUser!.following.add(widget.user.username);
                    widget.user.followers.add(currentUser!.username);
                    // إرسال إشعار للشخص المضاف
                    widget.user.notifications.insert(
                      0,
                      AppNotification(
                        title: 'متابع جديد 👤',
                        body: 'قام ${currentUser!.username} بمتابعتك الآن!',
                        time: DateTime.now(),
                      ),
                    );
                  }
                });
              },
              child: Text(isFollowing ? 'إلغاء المتابعة' : 'فولو (متابعة)'),
            ),
            const SizedBox(height: 16),
            if (hasAdminPower && widget.user.badgeType != 'gold') ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, minimumSize: const Size.fromHeight(45)),
                onPressed: () {
                  setState(() {
                    widget.user.isBanned = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تبنيد الحساب بنجاح!')));
                },
                child: const Text('تبنيد الحساب ⛔'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// --- 6. إعدادات الحساب مع اختيار وتحديث الصورة ---
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات الحساب'), backgroundColor: const Color(0xFF202C33)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'تغيير الاسم')),
            const SizedBox(height: 16),
            TextField(controller: _avatarController, decoration: const InputDecoration(labelText: 'رابط الصورة أو رفع صورة المعرض')),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A884), minimumSize: const Size.fromHeight(50)),
              onPressed: _save,
              child: const Text('حفظ التعديلات'),
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

// --- 7. نظام التذاكر للعملاء والإدارة (الصح الأخضر يملك الصلاحية للرد) ---
class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  void _openNewTicket(String type) {
    String tid = 'تذكرة #${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    Ticket newT = Ticket(id: tid, username: currentUser!.username, type: type, messages: [
      ChatMessage(text: 'تم فتح التذكرة بنجاح من نوع: $type. سيتم الرد قريباً من الإدارة.', sender: 'system')
    ]);
    setState(() {
      allTickets.add(newT);
    });
    Navigator.push(context, MaterialPageRoute(builder: (_) => TicketChatScreen(ticket: newT)));
  }

  @override
  Widget build(BuildContext context) {
    bool hasAdminPower = currentUser!.isOwner || currentUser!.badgeType == 'green';
    List<Ticket> visibleTickets = hasAdminPower 
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
      widget.ticket.messages.add(ChatMessage(text: _ctrl.text, sender: currentUser!.username));
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
                bool isMe = m.sender == currentUser?.username;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: isMe ? const Color(0xFF005C4B) : const Color(0xFF202C33), borderRadius: BorderRadius.circular(8)),
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

// --- 8. شاشة الدردشة وتصفية وحذف الرسائل ---
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
    String rid = '${currentUser?.username}_${widget.chatName}';
    var found = allActiveChats.where((c) => c.chatId == rid || c.chatId == '${widget.chatName}_${currentUser?.username}');
    if (found.isNotEmpty) {
      room = found.first;
    } else {
      room = ChatRoom(chatId: rid, chatName: widget.chatName, messages: [
        ChatMessage(text: 'أهلاً بك في الدردشة مع ${widget.chatName}', sender: 'system', status: 3)
      ]);
      allActiveChats.add(room);
    }

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
      var msg = ChatMessage(text: text, sender: currentUser!.username, status: 2);
      room.messages.add(msg);
      _msgController.clear();

      if (!widget.isAI) {
        UserProfile? peer = registeredUsers.firstWhere(
          (u) => u.username == widget.chatName,
          orElse: () => UserProfile(username: '', email: '', password: ''),
        );
        // إضافة إشعار رسالة جديدة للطرف الآخر
        peer.notifications.insert(
          0,
          AppNotification(
            title: 'رسالة جديدة من ${currentUser!.username}',
            body: text,
            time: DateTime.now(),
          ),
        );
      }
    });

    if (widget.isAI) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            room.messages.add(ChatMessage(
              text: 'أهلاً بك! أنا مساعدك الذكي Lymai 🤖. استلمت رسالتك.',
              sender: 'Lymai',
              status: 3,
            ));
          });
        }
      });
    }
  }

  void _deleteMessage(ChatMessage msg) {
    setState(() {
      msg.isDeleted = true;
      msg.text = 'تم حذف هذه الرسالة 🚫';
    });
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

                return GestureDetector(
                  onLongPress: () {
                    if (isMe && !m.isDeleted) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF202C33),
                          title: const Text('حذف الرسالة'),
                          content: const Text('هل تريد حذف هذه الرسالة لدى الجميع؟'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () {
                                Navigator.pop(ctx);
                                _deleteMessage(m);
                              },
                              child: const Text('حذف'),
                            )
                          ],
                        ),
                      );
                    }
                  },
                  child: Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: m.isDeleted 
                            ? Colors.grey.shade900 
                            : (isMe ? const Color(0xFF005C4B) : const Color(0xFF202C33)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            m.text,
                            style: TextStyle(
                              color: m.isDeleted ? Colors.grey : Colors.white,
                              fontStyle: m.isDeleted ? FontStyle.italic : FontStyle.normal,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isMe && !m.isDeleted)
                            Text(
                              m.status == 1 ? '✓' : '✓✓',
                              style: TextStyle(
                                color: m.status == 3 ? Colors.blueAccent : Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                        ],
                      ),
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
