import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'netflix_home.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: LockScreen()));

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});
  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final c = TextEditingController();
  bool checking = true;

  bool _isValid(String s) {
    if (s == '849201' || s == '391045' || s == '752189' || s == '104832' || s == '639574') return true;
    final n = int.tryParse(s);
    if (n == null || s.length != 6) return false;
    return (n % 100000 == 12849 || n % 100000 == 23950 || n % 100000 == 34061 || n % 100000 == 45172 || n % 100000 == 56283 || n % 100000 == 19384 || n % 100000 == 20495 || n % 100000 == 15926 || n % 100000 == 17482);
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (p.getBool('activated') == true && mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NetflixHome()));
      } else if (mounted) {
        setState(() => checking = false);
      }
    });
  }

  void _verify() async {
    if (_isValid(c.text.trim())) {
      final p = await SharedPreferences.getInstance();
      await p.setBool('activated', true);
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NetflixHome()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الكود غير صحيح'), backgroundColor: Colors.red));
    }
  }

  void _wa([String pkg = '']) {
    final msg = pkg.isEmpty ? 'السلام عليكم، أريد الاشتراك في تطبيق BN MOVEIS' : 'السلام عليكم، أريد الاشتراك في باقة ($pkg) لتطبيق BN MOVEIS';
    launchUrl(Uri.https(['wa', 'me'].join('.'), '/967737344714', {'text': msg}), mode: LaunchMode.externalApplication);
  }

  Widget _pkg(String t, String price) => GestureDetector(
        onTap: () => _wa('$t - $price'),
        child: Column(
          children: [
            Text(t, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(price, style: const TextStyle(color: Color(0xFFF5C518), fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: checking
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('BN MOVEIS', style: TextStyle(fontSize: 34, color: Color(0xFFE50914), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),
                  TextField(controller: c, textAlign: TextAlign.center, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white, fontSize: 18), decoration: InputDecoration(hintText: 'أدخل كود التفعيل', hintStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
                  const SizedBox(height: 15),
                  SizedBox(width: double.infinity, height: 48, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)), onPressed: _verify, child: const Text('تفعيل الاشتراك', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                    decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      _pkg('يوم', '2000 ريال'),
                      const Text('|', style: TextStyle(color: Colors.white24)),
                      _pkg('أسبوع', '5000 ريال'),
                      const Text('|', style: TextStyle(color: Colors.white24)),
                      _pkg('شهر', '10000 ريال'),
                      const Text('|', style: TextStyle(color: Colors.white24)),
                      _pkg('سنة', '50000 ريال'),
                    ]),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)), onPressed: () => _wa(), child: const Text('اشتراك واتساب (الكريمي / النجم / كاش)', style: TextStyle(color: Colors.white))),
                ],
              ),
            ),
    );
  }
}









