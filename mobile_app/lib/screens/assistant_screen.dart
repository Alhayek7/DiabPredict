import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../models/health_data.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final ApiService _apiService = ApiService();
  final LocalStorageService _storageService = LocalStorageService();
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = true;
  bool _isSending = false;
  Map<String, dynamic>? _advice;
  
  // بيانات المستخدم
  double _riskPercentage = 0;
  Map<String, double> _shapValues = {};
  HealthData? _healthData;
  
  // أسئلة مقترحة
  final List<Map<String, String>> _suggestedQuestions = [
    {'icon': '🥗', 'question': 'ما هي الأطعمة التي تقلل خطر السكري؟'},
    {'icon': '🏃', 'question': 'كم مرة يجب أن أمارس الرياضة؟'},
    {'icon': '⚠️', 'question': 'ما هي أعراض السكري المبكرة؟'},
    {'icon': '📉', 'question': 'كيف يمكنني خفض السكر التراكمي؟'},
    {'icon': '💊', 'question': 'هل هناك أدوية وقائية للسكري؟'},
    {'icon': '🩺', 'question': 'متى يجب أن أزور الطبيب؟'},
  ];
  
@override
void initState() {
  super.initState();
  _loadData();
}
Future<void> _loadData() async {
  setState(() => _isLoading = true);
  
  final allPredictions = _storageService.getAllPredictions();
  
  if (allPredictions.isNotEmpty) {
    final lastData = allPredictions.last;
    
    _riskPercentage = lastData.localRisk ?? lastData.calculateRiskLocally();
    _healthData = lastData;
    
    // ✅ أضف هذا الكود هنا (بعد _healthData)
    final lastPrediction = await _storageService.getLastPrediction();
    if (lastPrediction != null) {
      _shapValues = lastPrediction.shapValues;
    } else {
      _shapValues = {};
    }
    
    await _getAdvice();
  } else {
    // ... رسالة ترحيب
    if (mounted) {
      setState(() {
        _advice = {
          'response': 'مرحباً بك في المساعد الذكي! 🎉\n\nقم بإجراء تنبؤ أولاً للحصول على نصائح مخصصة.',
          'suggestions': ['قم بإجراء تنبؤ جديد', 'اسألني عن الأطعمة المناسبة', 'اسألني عن التمارين الرياضية']
        };
      });
    }
    setState(() => _isLoading = false);
  }
}


Future<void> _getAdvice({String? question}) async {
  if (_healthData == null) {
    _showErrorSnackBar('لا توجد بيانات صحية. قم بإجراء تنبؤ أولاً.');
    return;
  }
  
  setState(() {
    if (question != null) {
      _isSending = true;
    } else {
      _isLoading = true;
    }
  });
  
  // ✅ متغير لتتبع ما إذا كنا نستخدم الوضع المحلي
  bool usedLocal = false;
  Map<String, dynamic>? result;
  
  try {
    // محاولة الاتصال بالـ API أولاً
    result = await _apiService.getAssistantAdvice(
      _riskPercentage,
      _shapValues,
      _healthData!,
      question: question,
    );
    
    if (result == null) {
      // ✅ إذا فشل API، استخدم الردود المحلية
      usedLocal = true;
      result = _getLocalAdvice(question: question);
    }
  } catch (e) {
    // ✅ في حالة الخطأ، استخدم الردود المحلية
    usedLocal = true;
    result = _getLocalAdvice(question: question);
    print('⚠️ Using local advice due to error: $e');
  }
  
  if (result != null && mounted) {
    setState(() {
      _advice = result;
    });
    
    // التمرير إلى أعلى الصفحة
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    
    if (question != null) {
      _questionController.clear();
    }
    
    // ✅ إظهار رسالة توضح وضع التشغيل
    if (usedLocal && mounted) {
      _showInfoSnackBar('📡 لا يوجد اتصال بالإنترنت. يتم عرض نصائح محلية.', Colors.orange);
    }
  } else if (mounted) {
    _showErrorSnackBar('لم نتمكن من الحصول على رد من المساعد. حاول مرة أخرى.');
  }
  
  if (mounted) {
    setState(() {
      _isLoading = false;
      _isSending = false;
    });
  }
}
  
  void _askSuggestedQuestion(String question) {
    _getAdvice(question: question);
  }
  

  void _showErrorSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ),
  );
}

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      appBar: AppBar(
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios),
    onPressed: () {
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/home', 
        (route) => false,
      );
    },
    tooltip: 'العودة إلى الرئيسية',
  ),
  title: const Row(
    mainAxisSize: MainAxisSize.min,  // ✅ مهم لمنع Overflow
    children: [
      Icon(Icons.auto_awesome, size: 24),
      SizedBox(width: 8),
      Text(
        'المساعد الذكي',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ],
  ),
  backgroundColor: Colors.white,
  foregroundColor: Color(0xFF1E293B),
  elevation: 0,
  centerTitle: true,
  actions: [
    IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: _loadData,
      tooltip: 'تحديث',
    ),
  ],
),
      body: _isLoading
          ? _buildLoadingState()
          : _healthData == null
              ? _buildEmptyState()
              : _buildMainContent(),
    );
  }
  void _showInfoSnackBar(String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ),
  );
}

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: const Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'جاري تحليل بياناتك...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'المساعد الذكي يقرأ حالتك الصحية',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.chat_bubble_outline,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'لا توجد بيانات صحية',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'قم بإجراء تنبؤ أولاً للحصول على نصائح مخصصة',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('العودة'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    side: const BorderSide(color: Color(0xFF64748B)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/predict');
                  },
                  icon: const Icon(Icons.analytics),
                  label: const Text(
                    'الذهاب إلى التنبؤ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMainContent() {
    return Column(
      children: [
        // بطاقة نسبة الخطر المحسنة
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getRiskGradientColors(),
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _getRiskColor().withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getRiskIcon(),
                    style: const TextStyle(fontSize: 34),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نسبة الخطر الحالية',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '${_riskPercentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'مستوى ${_getRiskLevelText()}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'تحديث',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
        
        // منطقة المحادثة
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_advice != null) ...[
                  _buildAssistantMessage(_advice!['response']),
                  const SizedBox(height: 20),
                  if (_advice!['suggestions'] != null)
                    _buildSuggestionsSection(_advice!['suggestions'] as List),
                  const SizedBox(height: 20),
                ],
                _buildSuggestedQuestionsSection(),
                const SizedBox(height: 20),
                _buildCustomQuestionInput(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAssistantMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, const Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🤖 مساعد DiabPredict',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    'رد ذكي مبني على بياناتك',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuggestionsSection(List suggestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📝 نصائح مقترحة لك',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        ...suggestions.map((suggestion) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  suggestion,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
  
  Widget _buildSuggestedQuestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '❓ أسئلة قد تهمك',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _suggestedQuestions.map((item) {
            return ActionChip(
              avatar: Text(item['icon']!, style: const TextStyle(fontSize: 16)),
              label: Text(
                item['question']!,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: _isSending ? null : () => _askSuggestedQuestion(item['question']!),
              backgroundColor: Colors.white,
              side: BorderSide(color: const Color(0xFF2563EB).withOpacity(0.3)),
              labelStyle: const TextStyle(color: Color(0xFF2563EB)),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildCustomQuestionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '✏️ اسأل سؤالاً محدداً',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _questionController,
                  enabled: !_isSending,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 14),
                  onSubmitted: (_) {
                    if (!_isSending && _questionController.text.trim().isNotEmpty) {
                      _getAdvice(question: _questionController.text.trim());
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'اكتب سؤالك هنا...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _isSending
                    ? null
                    : () {
                        if (_questionController.text.trim().isNotEmpty) {
                          _getAdvice(question: _questionController.text.trim());
                        }
                      },
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  // ========== دوال مساعدة للألوان ==========
  
  Color _getRiskColor() {
    if (_riskPercentage < 30) return const Color(0xFF10B981);
    if (_riskPercentage < 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
  
  List<Color> _getRiskGradientColors() {
    if (_riskPercentage < 30) {
      return [const Color(0xFF10B981), const Color(0xFF059669)];
    }
    if (_riskPercentage < 60) {
      return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
    }
    return [const Color(0xFFEF4444), const Color(0xFFDC2626)];
  }
  
  String _getRiskIcon() {
    if (_riskPercentage < 30) return '✅';
    if (_riskPercentage < 60) return '⚠️';
    return '🔴';
  }
  
  String _getRiskLevelText() {
    if (_riskPercentage < 30) return 'منخفض';
    if (_riskPercentage < 60) return 'متوسط';
    return 'مرتفع';
  }


  /// الحصول على رد محلي احترافي (بدون إنترنت)
Map<String, dynamic> _getLocalAdvice({String? question}) {
  // بناء سياق المستخدم
  final riskLevel = _riskPercentage < 30 ? 'منخفض' : (_riskPercentage < 60 ? 'متوسط' : 'مرتفع');
  
  // إذا كان هناك سؤال محدد، حاول فهمه
  if (question != null && question.isNotEmpty) {
    return _getLocalAnswerForQuestion(question, riskLevel);
  }
  
  // رد عام حسب مستوى الخطر
  if (_riskPercentage < 30) {
    return {
      'response': '''🌟 **نسبة الخطر لديك منخفضة (${_riskPercentage.toStringAsFixed(1)}%)** 🎉

هذا مؤشر ممتاز! استمر في الحفاظ على نمط حياتك الصحي.

📋 **نصائح للحفاظ على صحتك:**
• مارس الرياضة بانتظام (30 دقيقة يومياً)
• تناول غذاءً متوازناً غنياً بالخضروات والفواكه
• تجنب السكريات والمشروبات الغازية
• قم بفحص السكر كل 6 أشهر للاطمئنان

💡 **تذكر:** الوقاية خير من العلاج! استمر في عاداتك الصحية.''',
      'suggestions': [
        '🚶 30 دقيقة مشي يومياً',
        '🥗 تناول الخضروات الورقية',
        '💧 اشرب 8 أكواب ماء يومياً',
        '😴 نام 7-8 ساعات يومياً'
      ]
    };
  } else if (_riskPercentage < 60) {
    return {
      'response': '''⚠️ **نسبة الخطر لديك متوسطة (${_riskPercentage.toStringAsFixed(1)}%)**

لا تقلق، يمكنك تحسين صحتك ببعض التغييرات البسيطة.

📋 **خطة تحسين مقترحة:**
• قلل من تناول السكريات والنشويات المكررة
• زد من النشاط البدني تدريجياً (مشي، سباحة)
• تابع وزنك وحاول إنقاص 5-10% منه
• استشر طبيبك لوضع خطة متابعة

🎯 **العوامل الأكثر تأثيراً عليك:**
يمكنك تحسين حالتك بالتركيز على إنقاص الوزن وزيادة النشاط البدني.''',
      'suggestions': [
        '🍎 قلل السكريات والنشويات',
        '🏃 زد النشاط البدني اليومي',
        '⚖️ تابع وزنك أسبوعياً',
        '🩺 استشر طبيبك لمتابعة دورية'
      ]
    };
  } else {
    return {
      'response': '''🔴 **تنبيه: نسبة الخطر لديك مرتفعة (${_riskPercentage.toStringAsFixed(1)}%)** 🚨

يجب اتخاذ إجراءات فورية لتحسين حالتك الصحية.

📋 **الخطوات العاجلة الموصى بها:**
1. **راجع طبيب الغدد الصماء فوراً** لإجراء الفحوصات اللازمة
2. قم بفحص السكر التراكمي (HbA1c) بشكل عاجل
3. ابدأ خطة غذائية تحت إشراف مختص
4. قم بقياس سكر الدم وضغط الدم بانتظام

⚠️ **لا تتأخر في مراجعة الطبيب** - التشخيص المبكر يمكن أن يغير حياتك.''',
      'suggestions': [
        '🩺 راجع طبيب الغدد الصماء فوراً',
        '📊 قم بفحص السكر التراكمي',
        '🍽️ اتبع خطة غذائية تحت إشراف مختص',
        '📈 راقب سكر وضغط الدم بانتظام'
      ]
    };
  }
}

/// الإجابة على أسئلة محددة محلياً
Map<String, dynamic> _getLocalAnswerForQuestion(String question, String riskLevel) {
  final q = question.toLowerCase();
  
  // أسئلة عن الأكل والطعام
  if (q.contains('طعام') || q.contains('أكل') || q.contains('غذاء') || q.contains('اكل')) {
    return {
      'response': '''🥗 **نصائح غذائية للوقاية من السكري**

📊 **حسب حالتك (نسبة الخطر ${_riskPercentage.toStringAsFixed(1)}%):**

**✅ أطعمة مفيدة:**
• الخضروات الورقية (سبانخ، خس، كرنب)
• الحبوب الكاملة (شوفان، قمح كامل، أرز بني)
• البقوليات (عدس، حمص، فول)
• المكسرات غير المملحة (لوز، جوز)
• الأسماك الدهنية (سلمون، تونة)

**❌ أطعمة قلل منها:**
• السكريات والمشروبات الغازية
• الخبز الأبيض والمعجنات
• الأطعمة المصنعة والوجبات السريعة

💡 **نصيحة:** ابدأ وجبتك بالخضروات، واشرب الماء قبل الأكل.''',
      'suggestions': [
        '🥬 أضف الخضروات لكل وجبة',
        '🍞 استبدل الخبز الأبيض بالأسمر',
        '💧 اشرب الماء بدلاً من المشروبات الغازية',
        '🍎 تناول الفواكه بدلاً من الحلويات'
      ]
    };
  }
  
  // أسئلة عن الرياضة
  if (q.contains('رياض') || q.contains('تمرين') || q.contains('مشي') || q.contains('حركة')) {
    return {
      'response': '''🏃 **التمارين الرياضية المناسبة لحالتك**

📊 **نسبة الخطر: ${_riskPercentage.toStringAsFixed(1)}%**

**🏆 أفضل التمارين:**
• المشي السريع (30-45 دقيقة يومياً)
• السباحة (ممتازة للمفاصل والقلب)
• ركوب الدراجة (هوائية أو ثابتة)
• تمارين المقاومة (أوزان خفيفة - مرتين أسبوعياً)

**📋 جدول مقترح:**
• الأحد - الأربعاء: مشي 30 دقيقة
• الثلاثاء - الخميس: تمارين مقاومة
• الجمعة: سباحة أو ركوب دراجة
• السبت: راحة أو مشي خفيف

💡 **نصيحة:** ابدأ ببطء وزد المدة تدريجياً. استشر طبيبك قبل بدء أي برنامج رياضي جديد.''',
      'suggestions': [
        '🚶 امشِ 30 دقيقة يومياً',
        '🏊 جرب السباحة مرتين أسبوعياً',
        '🪜 استخدم الدرج بدلاً من المصعد',
        '🧘 مارس تمارين الإطالة صباحاً'
      ]
    };
  }
  
  // أسئلة عن الأعراض
  if (q.contains('أعراض') || q.contains('اعراض') || q.contains('علامات')) {
    return {
      'response': '''⚠️ **الأعراض المبكرة لمرض السكري**

**الأعراض الشائعة:**
• العطش الشديد وكثرة التبول
• الجوع المستمر رغم تناول الطعام
• فقدان الوزن غير المبرر
• التعب والإرهاق
• عدم وضوح الرؤية
• بطء التئام الجروح
• وخز أو تنميل في اليدين والقدمين

🚨 **متى يجب استشارة الطبيب فوراً؟**
• إذا ظهرت لديك 3 أعراض أو أكثر
• إذا كان هناك تاريخ عائلي للسكري
• إذا كانت لديك عوامل خطر (سمنة، ضغط مرتفع)

📌 **تذكر:** التشخيص المبكر يمكن أن يمنع المضاعفات!''',
      'suggestions': [
        '👀 راقب أي أعراض غير طبيعية',
        '🩸 قم بفحص السكر إذا ظهرت أعراض',
        '🩺 استشر طبيبك للتقييم',
        '⚠️ لا تتجاهل الأعراض المبكرة'
      ]
    };
  }
  
  // أسئلة عن السكر التراكمي
  if (q.contains('سكر تراكمي') || q.contains('hba1c')) {
    return {
      'response': '''📊 **ما هو تحليل السكر التراكمي (HbA1c)؟**

**تعريفه:** يقيس متوسط سكر الدم خلال 2-3 أشهر الماضية.

**المستويات ومعناها:**
• أقل من 5.7%: طبيعي ✅
• 5.7% - 6.4%: مقدمات السكري ⚠️
• 6.5% أو أكثر: سكري 🔴

**نصائح لتحسين HbA1c:**
• التزم بنظام غذائي صحي
• مارس الرياضة بانتظام
• تناول أدويتك إذا كان لديك
• تابع مع طبيبك بانتظام

📌 **تذكر:** تحسين HbA1c بنسبة 1% يقلل مضاعفات السكري بنسبة 40%!''',
      'suggestions': [
        '📉 تابع HbA1c كل 3 أشهر',
        '🥗 حسن نظامك الغذائي تدريجياً',
        '🏃 مارس الرياضة 30 دقيقة يومياً',
        '🩺 تابع مع طبيبك بانتظام'
      ]
    };
  }
  
  // أسئلة عن الضغط
  if (q.contains('ضغط') || q.contains('hypertension')) {
    return {
      'response': '''🩺 **الضغط وصحة السكري**

**المستويات الطبيعية:**
• مثالي: أقل من 120/80 mmHg ✅
• مرتفع نسبياً: 120-129/80-84 ⚠️
• ارتفاع: 130-139/85-89 ⚠️
• ارتفاع شديد: 140/90 فأكثر 🔴

**العلاقة بين الضغط والسكري:**
ارتفاع الضغط يزيد خطر السكري، والعكس صحيح.

💡 **لتحسين ضغط دمك:**
• قلل من الملح في الطعام
• مارس الرياضة بانتظام
• حافظ على وزن صحي
• قلل من التوتر
• تجنب الكحول والتدخين''',
      'suggestions': [
        '🧂 قلل من الملح في طعامك',
        '🚶 مارس رياضة المشي يومياً',
        '🍎 تجنب الأطعمة المصنعة',
        '🧘 تعلم تقنيات الاسترخاء'
      ]
    };
  }
  
  // الرد الافتراضي إذا لم يتم التعرف على السؤال
  return {
    'response': '🤔 **شكراً على سؤالك!**\n\nسؤالك: "$question"\n\n📊 **بناءً على حالتك** (نسبة الخطر ${_riskPercentage.toStringAsFixed(1)}%، مستوى $riskLevel):\n\nيمكنني مساعدتك في الأسئلة التالية:\n• 🥗 ما هي الأطعمة المفيدة والضارة للسكري؟\n• 🏃 ما هي التمارين الرياضية المناسبة؟\n• ⚠️ ما هي أعراض السكري المبكرة؟\n• 📊 ما هو تحليل السكر التراكمي (HbA1c)؟\n• 🩺 ما هي العلاقة بين الضغط والسكري؟\n\n💡 **نصيحة:** اسألني بطريقة مختلفة أو اختر أحد الأسئلة المقترحة أعلاه.\n\n📌 **تذكر:** عند توفر الاتصال بالإنترنت، يمكنني تقديم إجابات أكثر تفصيلاً باستخدام الذكاء الاصطناعي.',
    'suggestions': [
      '🥗 ما هي الأطعمة المفيدة للسكري؟',
      '🏃 ما هي التمارين المناسبة لي؟',
      '⚠️ ما هي أعراض السكري؟',
      '📊 ما هو تحليل HbA1c؟'
    ]
  };

  
// أسئلة عن وزن الجسم (BMI)
if (q.contains('وزن') || q.contains('bmi') || q.contains('سمنة') || q.contains('بدانة')) {
  final bmiValue = _healthData?.bmi ?? 0;
  return {
    'response': '''⚖️ **نصائح مهمة للحفاظ على وزن صحي**

📊 **الوزن وصحتك:**
• مؤشر كتلة الجسم الحالي: ${bmiValue.toStringAsFixed(1)}
• النطاق الصحي: 18.5 - 24.9

🔬 **العلاقة بين الوزن والسكري:**
زيادة الوزن تزيد مقاومة الأنسولين بنسبة تصل إلى 50-70%.

📋 **خطة إنقاص الوزن:**
• اخسر 5-10% من وزنك الحالي لتحسين حساسية الأنسولين
• تناول وجبات صغيرة متعددة (4-5 وجبات)
• قلل السعرات الحرارية بـ 500 سعرة يومياً
• سجل ما تأكله يومياً

💡 **تذكر:** فقدان 5-7% فقط من وزنك يقلل خطر السكري بنسبة 58%!''',
    'suggestions': [
      '📝 سجل طعامك يومياً',
      '🍽️ تناول وجبات صغيرة متعددة',
      '🏃 زد نشاطك البدني تدريجياً',
      '💧 اشرب الماء قبل الوجبات'
    ]
  };
}

// أسئلة عن الكوليسترول
if (q.contains('كوليسترول') || q.contains('دهون') || q.contains('cholesterol')) {
  final cholesterolValue = _healthData?.cholesterol ?? 0;
  return {
    'response': '''🩺 **الكوليسترول وصحة القلب**

📊 **مستوى الكوليسترول الحالي:**
• القيمة: ${cholesterolValue} mg/dL
• المستوى المثالي: أقل من 200 mg/dL

🔬 **أنواع الكوليسترول:**
• **LDL (الضار):** يجب أن يكون أقل من 100 mg/dL
• **HDL (الجيد):** يجب أن يكون أكثر من 40 mg/dL
• **الدهون الثلاثية:** أقل من 150 mg/dL

🥗 **لتحسين الكوليسترول:**
• تناول أوميغا 3 (أسماك، زيت زيتون)
• قلل الدهون المشبعة والمتحولة
• زد من الألياف القابلة للذوبان (شوفان، تفاح)
• مارس الرياضة 30 دقيقة يومياً

⚠️ **تنبيه:** ارتفاع الكوليسترول يضاعف خطر الإصابة بأمراض القلب والسكري!''',
    'suggestions': [
      '🐟 تناول الأسماك مرتين أسبوعياً',
      '🥑 أضف الأفوكادو لوجباتك',
      '🌰 تناول حفنة من المكسرات يومياً',
      '🏃 تمرن بانتظام لرفع HDL'
    ]
  };
}

// أسئلة عن التوتر والقلق
if (q.contains('توتر') || q.contains('قلق') || q.contains('stress') || q.contains('نفسي')) {
  return {
    'response': '''🧘 **العلاقة بين التوتر والسكري**

🔬 **كيف يؤثر التوتر على السكري؟**
• يرفع مستوى الكورتيزول (هرمون التوتر)
• يزيد مقاومة الأنسولين بنسبة 40%
• يرفع مستوى السكر في الدم
• يزيد الرغبة في تناول السكريات

📋 **تقنيات تخفيف التوتر:**
١. **تمارين التنفس العميق:** تنفس لمدة 4 ثوانٍ، احبس 7 ثوانٍ، ازفر 8 ثوانٍ
٢. **التأمل واليوغا:** 10-15 دقيقة يومياً
٣. **المشي في الطبيعة:** 20 دقيقة يومياً
٤. **النوم الكافي:** 7-8 ساعات ليلاً

💡 **نصيحة:** خصص 10 دقائق يومياً للاسترخاء - صحتك النفسية تؤثر على صحتك الجسدية!''',
    'suggestions': [
      '😮‍💨 مارس التنفس العميق صباحاً ومساءً',
      '🚶 امشِ في الطبيعة يومياً',
      '📵 ابتعد عن الشاشات قبل النوم بساعة',
      '😴 نم 7-8 ساعات يومياً'
    ]
  };
}

// أسئلة عن الفحوصات والتحاليل
if (q.contains('فحص') || q.contains('تحليل') || q.contains('check') || q.contains('تحاليل')) {
  return {
    'response': '''🩸 **الفحوصات الدورية المهمة للوقاية من السكري**

📋 **الفحوصات الأساسية:**
• **سكر صائم (FBS):** كل 6 أشهر
• **سكر تراكمي (HbA1c):** كل 3-6 أشهر
• **دهون (Lipid profile):** سنوياً
• **ضغط الدم:** شهرياً
• **وظائف الكلى:** سنوياً

🎯 **المستويات المستهدفة:**
• سكر صائم: أقل من 100 mg/dL
• سكر تراكمي: أقل من 5.7%
• ضغط الدم: أقل من 120/80 mmHg

⚠️ **إذا كان لديك تاريخ عائلي أو عوامل خطر:**
• ابدأ الفحوصات من سن 30 عاماً
• زد الفحوصات إلى كل 3 أشهر

📌 **التشخيص المبكر يمكن أن يمنع تطور المرض!**''',
    'suggestions': [
      '📅 نظم مواعيد فحوصاتك الدورية',
      '🩸 تابع سكر الدم شهرياً',
      '📊 احتفظ بسجل للفحوصات',
      '🩺 استشر طبيبك لتفسير النتائج'
    ]
  };
}

}

/// الحصول على نصائح مخصصة حسب بيانات المستخدم
String _getPersonalizedTip() {
  final bmi = _healthData?.bmi ?? 0;
  final age = _healthData?.age ?? 0;
  final cholesterol = _healthData?.cholesterol ?? 0;
  final risk = _riskPercentage;
  
  List<String> tips = [];
  
  // نصائح حسب BMI
  if (bmi > 30) {
    tips.add('⚖️ مؤشر كتلة جسمك مرتفع (${bmi.toStringAsFixed(1)}). فقدان 5-7% من وزنك يقلل خطر السكري بنسبة 58%');
  } else if (bmi < 18.5) {
    tips.add('🥗 وزنك أقل من الطبيعي. استشر أخصائي تغذية لوضع خطة غذائية متوازنة');
  } else if (bmi >= 18.5 && bmi <= 24.9) {
    tips.add('🌟 وزنك مثالي! استمر في الحفاظ على نمط حياتك الصحي');
  }
  
  // نصائح حسب العمر
  if (age > 45) {
    tips.add('📈 مع التقدم في العمر (أكثر من 45 سنة)، يزداد خطر السكري. استمر في الفحوصات الدورية');
  } else if (age < 30) {
    tips.add('🌱 عمرك صغير، هذه فرصة ممتازة لبناء عادات صحية تدوم مدى الحياة');
  }
  
  // نصائح حسب الكوليسترول
  if (cholesterol > 200) {
    tips.add('🩺 مستوى الكوليسترول لديك مرتفع (${cholesterol} mg/dL). قلل الدهون المشبعة وزد من الألياف');
  } else if (cholesterol < 200 && cholesterol > 0) {
    tips.add('🩺 مستوى الكوليسترول لديك جيد! استمر في نظامك الغذائي الصحي');
  }
  
  // نصائح حسب نسبة الخطر
  if (risk > 60) {
    tips.add('🚨 نسبة الخطر مرتفعة. يرجى استشارة الطبيب فوراً لوضع خطة علاجية');
  } else if (risk > 30) {
    tips.add('⚠️ نسبة الخطر متوسطة. يمكنك تحسينها بتغييرات بسيطة في نمط الحياة');
  } else if (risk > 0) {
    tips.add('✅ نسبة الخطر منخفضة. استمر في عاداتك الصحية الجيدة');
  }
  
  if (tips.isEmpty) {
    tips.add('🌟 استمر في نمط حياتك الصحي - الوقاية خير من العلاج');
  }
  
  return '📋 **نصائح مخصصة لك:**\n\n' + tips.map((t) => '• $t').join('\n\n');
}

}