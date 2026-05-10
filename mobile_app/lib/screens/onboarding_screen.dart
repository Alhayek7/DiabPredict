import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'home_screen.dart';
// import 'predict_screen.dart';
// import 'assistant_screen.dart';
// import 'history_screen.dart';
// import 'profile_screen.dart';
// import 'about_screen.dart';
import '../main.dart';
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      icon: '🩺',
      title: 'تنبؤ دقيق',
      description: 'أدخل بياناتك الصحية واحصل على نسبة خطر الإصابة بدقة تصل إلى 94%',
      color: const Color(0xFF2563EB),
    ),
    OnboardingItem(
      icon: '📊',
      title: 'تفسير شفاف',
      description: 'تعرف على العوامل المؤثرة في نتيجتك من خلال رسوم بيانية واضحة',
      color: const Color(0xFF7C3AED),
    ),
    OnboardingItem(
      icon: '💬',
      title: 'مساعد ذكي',
      description: 'احصل على نصائح صحية مخصصة من مساعد Gemini AI باللغة العربية',
      color: const Color(0xFF10B981),
    ),
    OnboardingItem(
      icon: '🔒',
      title: 'مجاني وآمن',
      description: 'التطبيق مجاني بالكامل، وبياناتك محفوظة محلياً على جهازك فقط',
      color: const Color(0xFFF59E0B),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // مؤشر التقدم (Skip)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage < _onboardingItems.length - 1)
                  TextButton(
                    onPressed: _skipToEnd,
                    child: Text(
                      'تخطي',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 60),
                
                // نقاط التقدم
                Row(
                  children: List.generate(
                    _onboardingItems.length,
                    (index) => _buildDot(index),
                  ),
                ),
                
                const SizedBox(width: 60),
              ],
            ),
          ),
          
          // الصفحات المتحركة
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                  _isLastPage = index == _onboardingItems.length - 1;
                });
              },
              itemCount: _onboardingItems.length,
              itemBuilder: (context, index) {
                return _buildOnboardingPage(_onboardingItems[index]);
              },
            ),
          ),
          
          // زر الإجراء
          Padding(
            padding: const EdgeInsets.all(30),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLastPage ? _completeOnboarding : _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _onboardingItems[_currentPage].color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isLastPage ? '🚀 ابدأ الآن' : 'التالي',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          
          // نص تأكيد المجانية
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              '✓ مجاني بالكامل  ✓ لا يحتاج حساب  ✓ بياناتك آمنة',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? _onboardingItems[index].color
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [item.color, item.color.withValues(alpha: 0.7)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: item.color.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                item.icon,
                style: const TextStyle(fontSize: 64),
              ),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skipToEnd() {
    _pageController.jumpToPage(_onboardingItems.length - 1);
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }
}

class OnboardingItem {
  final String icon;
  final String title;
  final String description;
  final Color color;

  OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

// // ========== الصفحة الرئيسية بعد الدخول ==========
// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   int _currentIndex = 0;
//   final PageController _pageController = PageController();

//   // 5 صفحات فقط في الأسفل
//   final List<Widget> _screens = [
//     const HomeScreen(),
//     const PredictScreen(),
//     const AssistantScreen(),
//     const HistoryScreen(),
//     const AboutScreen(),
//   ];

//   // 5 أيقونات فقط في الشريط السفلي
//   final List<BottomNavigationBarItem> _navItems = const [
//     BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'الرئيسية'),
//     BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'التوقع'),
//     BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), activeIcon: Icon(Icons.smart_toy), label: 'المساعد'),
//     BottomNavigationBarItem(icon: Icon(Icons.history), activeIcon: Icon(Icons.history), label: 'السجل'),
//     BottomNavigationBarItem(icon: Icon(Icons.info_outline), activeIcon: Icon(Icons.info), label: 'عن النظام'),
//   ];

//   Future<void> _testServerConnection() async {
//     try {
//       final response = await http.get(Uri.parse('http://localhost:8000/health'));
//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('✅ الخادم متصل'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('⚠️ الخادم غير متصل'),
//             backgroundColor: Colors.orange,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('❌ لا يمكن الاتصال بالخادم'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('DiabPredict'),
//           centerTitle: true,
//           actions: [
//             // أيقونة اختبار الخادم
//             IconButton(
//               icon: const Icon(Icons.settings_ethernet),
//               onPressed: _testServerConnection,
//               tooltip: 'اختبار الاتصال بالخادم',
//             ),
//             // أيقونة الملف الشخصي
//             IconButton(
//               icon: const Icon(Icons.person_outline),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const ProfileScreen()),
//                 );
//               },
//               tooltip: 'الملف الشخصي',
//             ),
//           ],
//         ),
//         body: PageView(
//           controller: _pageController,
//           onPageChanged: (index) {
//             setState(() {
//               _currentIndex = index;
//             });
//           },
//           children: _screens,
//         ),
//         bottomNavigationBar: Container(
//           decoration: BoxDecoration(
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withValues(alpha: 0.1),
//                 spreadRadius: 1,
//                 blurRadius: 8,
//                 offset: const Offset(0, -2),
//               ),
//             ],
//           ),
//           child: BottomNavigationBar(
//             type: BottomNavigationBarType.fixed,
//             currentIndex: _currentIndex,
//             onTap: (index) {
//               setState(() {
//                 _currentIndex = index;
//                 _pageController.animateToPage(
//                   index,
//                   duration: const Duration(milliseconds: 300),
//                   curve: Curves.easeInOut,
//                 );
//               });
//             },
//             selectedItemColor: const Color(0xFF2563EB),
//             unselectedItemColor: Colors.grey,
//             selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
//             unselectedLabelStyle: const TextStyle(fontSize: 12),
//             backgroundColor: Colors.white,
//             elevation: 0,
//             items: _navItems,
//           ),
//         ),
//       ),
//     );
//   }
// }