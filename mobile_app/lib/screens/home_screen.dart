import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/local_storage_service.dart';
import '../models/health_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalStorageService _storageService = LocalStorageService();

  
  bool _isConnected = true;
  PredictionResult? _lastPrediction;
  bool _isLoading = true;
  double _modelAccuracy = 0.73;
  int _datasetSize = 768;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadLastPrediction();
    _loadModelStats();
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = result != ConnectivityResult.none;
    });
    
    Connectivity().onConnectivityChanged.listen((result) {
      if (mounted) {
        setState(() {
          _isConnected = result != ConnectivityResult.none;
        });
      }
    });
  }

  Future<void> _loadLastPrediction() async {
  if (!mounted) return;
  setState(() => _isLoading = true);
  
  // ✅ استخدام Hive بدلاً من SharedPreferences
  final allPredictions = _storageService.getAllPredictions();
  
  if (allPredictions.isNotEmpty) {
    final lastData = allPredictions.last;
    final risk = lastData.localRisk ?? lastData.calculateRiskLocally();
    
    // تحويل HealthData إلى PredictionResult مؤقت
    final lastPrediction = PredictionResult(
      riskPercentage: risk,
      riskLevel: risk < 30 ? 'منخفض' : (risk < 60 ? 'متوسط' : 'مرتفع'),
      probability: risk / 100,
      recommendation: '',
      shapValues: {},
      topFactors: [],
      timestamp: lastData.timestamp.toIso8601String(),
      accuracy: _modelAccuracy,
    );
    
    setState(() {
      _lastPrediction = lastPrediction;
      _isLoading = false;
    });
  } else {
    setState(() {
      _lastPrediction = null;
      _isLoading = false;
    });
  }
}


  Future<void> _loadModelStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _modelAccuracy = prefs.getDouble('model_accuracy') ?? 0.73;
      _datasetSize = prefs.getInt('dataset_size') ?? 768;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _lastPrediction == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF0F9FF),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2563EB),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      body: RefreshIndicator(
        onRefresh: _loadLastPrediction,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // حالة الاتصال
              if (!_isConnected)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.wifi_off, color: Colors.orange),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'غير متصل بالإنترنت. سيتم حفظ البيانات محلياً.',
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),

              // بطاقة الترحيب
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'نظام ذكي للتنبؤ المبكر\nبخطر السكري',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'بتقنيات الذكاء الاصطناعي والتفسير الشفاف\nلضمان دقة النتائج وفهم مسببات الخطر الشخصية.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context, 
                              '/home', 
                              (route) => false,
                              arguments: 'open_predict',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                          ),
                          child: const Text(
                            'ابدأ الآن',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // آخر تنبؤ
              if (_lastPrediction != null && !_isLoading)
                _buildLastPredictionCard()
              else
                _buildEmptyPredictionCard(),

              const SizedBox(height: 24),

              // لوحة الإحصائيات
              Row(
                children: [
                  _buildStatCard(
                    '${(_modelAccuracy * 100).toStringAsFixed(1)}%',
                    'دقة النموذج',
                    const Color(0xFF2563EB),
                    Icons.analytics,
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    '$_datasetSize',
                    'سجل طبي',
                    const Color(0xFF10B981),
                    Icons.storage,
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    '< 1ث',
                    'وقت التحليل',
                    const Color(0xFFF59E0B),
                    Icons.speed,
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    '100%',
                    'تفسير SHAP',
                    const Color(0xFF7C3AED),
                    Icons.visibility,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // مميزات النظام
              const Text(
                'مميزات النظام',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildFeatureCard(
                      icon: Icons.rocket_launch,
                      title: 'محرك XGBoost',
                      description: 'أقوى خوارزميات التعلم الآلي لضمان سرعة ودقة التنبؤ اللحظي.',
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildFeatureCard(
                      icon: Icons.visibility,
                      title: 'تفسيرات SHAP',
                      description: 'فهم العوامل المؤثرة في نتيجتك بكل شفافية من خلال الرسوم البيانية.',
                      color: const Color(0xFF7C3AED),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildFeatureCard(
                      icon: Icons.auto_awesome,
                      title: 'مساعد Gemini AI',
                      description: 'استشارات طبية فورية مدعومة بالذكاء الاصطناعي التوليدي.',
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildFeatureCard(
                      icon: Icons.model_training,
                      title: 'محاكي السيناريوهات',
                      description: 'اختبر كيف يؤثر تغيير نمط حياتك على احتمالات إصابتك.',
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildFeatureCard(
                      icon: Icons.smartphone,
                      title: 'تطبيق الجوال',
                      description: 'واجهة مستخدم سهلة وبسيطة تتيح لك الوصول لبياناتك الصحية في أي وقت.',
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildFeatureCard(
                      icon: Icons.update,
                      title: 'تتبع زمني',
                      description: 'سجل تاريخي كامل لنتائج التنبؤ لمراقبة تحسن حالتك الصحية.',
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // كيف يعمل النظام
              const Text(
                'كيف يعمل النظام؟',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStepCard('1', 'إدخال البيانات', 'أدخل مؤشراتك الصحية مثل العمر والوزن وتاريخك الطبي.')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStepCard('2', 'تحليل ذكي', 'يقوم النظام بتحليل البيانات باستخدام خوارزميات الذكاء الاصطناعي.')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStepCard('3', 'متابعة النتائج', 'احصل على التقرير المفصل والتوصيات المخصصة لك.')),
                ],
              ),

              const SizedBox(height: 32),

              // بطاقة الدعوة
              _buildCallToActionCard(context),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ========== دوال مساعدة ==========

  Widget _buildStatCard(String value, String label, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastPredictionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getRiskColor(_lastPrediction!.riskLevel).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getRiskColor(_lastPrediction!.riskLevel).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getRiskColor(_lastPrediction!.riskLevel),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getRiskIcon(_lastPrediction!.riskLevel),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'آخر تنبؤ',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'نسبة الخطر: ${_lastPrediction!.riskPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getRiskColor(_lastPrediction!.riskLevel),
                  ),
                ),
                Text(
                  'المستوى: ${_lastPrediction!.riskLevel}',
                  style: TextStyle(
                    fontSize: 13,
                    color: _getRiskColor(_lastPrediction!.riskLevel),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
            child: const Text('عرض التفاصيل'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPredictionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.info_outline, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لا توجد تنبؤات سابقة',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'قم بإجراء تنبؤك الأول لرؤية النتائج هنا',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallToActionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'هل أنت جاهز لتأمين صحتك؟',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'ابدأ الآن واحصل على تقريرك الشخصي في أقل من دقيقة.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/home', 
                  (route) => false,
                  arguments: 'open_predict',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'ابدأ الآن',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(String number, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(String level) {
    switch (level) {
      case 'منخفض': return const Color(0xFF10B981);
      case 'متوسط': return const Color(0xFFF59E0B);
      case 'مرتفع': return const Color(0xFFEF4444);
      default: return Colors.grey;
    }
  }

  String _getRiskIcon(String level) {
    switch (level) {
      case 'منخفض': return '✅';
      case 'متوسط': return '⚠️';
      case 'مرتفع': return '🔴';
      default: return '📊';
    }
  }
}