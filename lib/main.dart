import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

void main() {
  runApp(const BNMoveisApp());
}

class BNMoveisApp extends StatelessWidget {
  const BNMoveisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BN MOVEIS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.redAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const ActivationScreen(),
    );
  }
}

// 1. شاشة التفعيل والدفع عبر الصرافات اليمنية
class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final TextEditingController _codeController = TextEditingController();
  final String _secretCode = "BN2026"; // كود التفعيل السري الخاص بك
  final String _whatsappNumber = "967737344714"; // ضع رقمك اليمني هنا بدون أصفار

  void _verifyCode() {
    if (_codeController.text.trim() == _secretCode) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainMenuScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('كود التفعيل غير صحيح! تواصل معنا للحصول على كود.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openWhatsApp() async {
    final Uri url = Uri.parse(
      "https://wa.me عليكم، أريد الاشتراك في تطبيق BN MOVEIS وتفعيل حسابي",
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح تطبيق الواتساب')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BN MOVEIS - التفعيل'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie_filter, size: 80, color: Colors.redAccent),
            const SizedBox(height: 15),
            const Text(
              'مرحباً بك في BN MOVEIS',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: _codeController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'أدخل كود التفعيل هنا',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _verifyCode,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text('تفعيل الحساب', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'للاشتراك: حوّل قيمة الاشتراك عبر (الكريمي، النجم، العمقي، المحضار، أو محفظة كاش)، ثم أرسل السند عبر الواتساب لاستلام كود التفعيل فوراً.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _openWhatsApp,
                icon: const Icon(Icons.chat, color: Colors.white),
                label: const Text('تواصل عبر الواتساب للاشتراك', style: TextStyle(fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. الشاشة الرئيسية للأقسام والقنوات
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  final List<Map<String, String>> items = const [
    {
      "title": "قناة رياضية 1 (بث تجريبي)",
      "category": "رياضة",
      "url": "https://mux.dev"
    },
    {
      "title": "فيلم أكشن (تجريبي)",
      "category": "أفلام",
      "url": "https://googleapis.com"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BN MOVEIS')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.play_circle_fill, color: Colors.redAccent, size: 40),
              title: Text(items[index]['title']!),
              subtitle: Text(items[index]['category']!),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerScreen(
                      title: items[index]['title']!,
                      videoUrl: items[index]['url']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// 3. شاشة مشغل الفيديو
class PlayerScreen extends StatefulWidget {
  final String title;
  final String videoUrl;

  const PlayerScreen({super.key, required this.title, required this.videoUrl});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
            ? Chewie(controller: _chewieController!)
            : const CircularProgressIndicator(color: Colors.redAccent),
      ),
    );
  }
}
