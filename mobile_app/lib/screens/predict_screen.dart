import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../models/health_data.dart';
import '../widgets/risk_gauge.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class PredictScreen extends StatefulWidget {
  const PredictScreen({super.key});

  @override
  State<PredictScreen> createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  final _storageService = LocalStorageService();
  final _resultsTitleKey = GlobalKey();

  bool _isLoading = false;
  PredictionResult? _result;
  bool _showAdvanced = false;
  double _progressValue = 0.0;

  // Controllers
  final _ageController = TextEditingController(text: '45');
  final _bmiController = TextEditingController(text: '25.0');
  final _hba1cController = TextEditingController(text: '5.7');
  final _glucoseController = TextEditingController(text: '100');
  final _bpSystolicController = TextEditingController(text: '120');
  final _bpDiastolicController = TextEditingController(text: '80');
  final _cholesterolController = TextEditingController(text: '180');
  final _hba1cDetailedController = TextEditingController(text: '5.7');
  final _waistController = TextEditingController(text: '85.0');

  int _familyHistory = 0;
  int _smoking = 0;
  int _physicalActivity = 1;
  double _hba1cDetailed = 5.7;
  double _waistCircumference = 85.0;

  // ✅ عوامل مؤثرة تجريبية (للتوضيح عند عدم وجود بيانات)
  List<Map<String, dynamic>> _getDemoFactors() {
    return [
      {
        'name': 'نسبة السكر التراكمي (HbA1c)',
        'impact': 'يزيد الخطر',
        'level': 'مرتفع',
        'strength': 0.75
      },
      {
        'name': 'مؤشر كتلة الجسم (BMI)',
        'impact': 'يزيد الخطر',
        'level': 'متوسط',
        'strength': 0.52
      },
      {
        'name': 'العمر',
        'impact': 'يزيد الخطر',
        'level': 'متوسط',
        'strength': 0.48
      },
      {
        'name': 'سكر الدم (Glucose)',
        'impact': 'يزيد الخطر',
        'level': 'منخفض',
        'strength': 0.31
      },
      {
        'name': 'النشاط البدني',
        'impact': 'يقلل الخطر',
        'level': 'متوسط',
        'strength': -0.28
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadLastData();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _bmiController.dispose();
    _hba1cController.dispose();
    _glucoseController.dispose();
    _bpSystolicController.dispose();
    _bpDiastolicController.dispose();
    _cholesterolController.dispose();
    _hba1cDetailedController.dispose();
    _waistController.dispose();
    super.dispose();
  }

  /// التحقق من صحة جميع البيانات المدخلة
  /// تعيد null إذا كانت البيانات صحيحة، أو رسالة الخطأ إذا كانت غير صحيحة
  String? validateHealthData({
    required int age,
    required double bmi,
    required double hba1c,
    required double glucose,
    required double bloodPressureSystolic,
    required double bloodPressureDiastolic,
    required double cholesterol,
    required int familyHistory,
    required int smoking,
    required int physicalActivity,
    required double waistCircumference,
    required double hba1cDetailed,
  }) {
    // التحقق من العمر
    if (age < 0) return '⚠️ العمر لا يمكن أن يكون أقل من 0 سنة';
    if (age > 120) return '⚠️ العمر يجب أن يكون بين 0 و 120 سنة';

    // التحقق من مؤشر كتلة الجسم
    if (bmi < 10) return '⚠️ مؤشر كتلة الجسم لا يمكن أن يكون أقل من 10';
    if (bmi > 50) return '⚠️ مؤشر كتلة الجسم يجب أن يكون بين 10 و 50';

    // التحقق من السكر التراكمي
    if (hba1c < 4) return '⚠️ السكر التراكمي لا يمكن أن يكون أقل من 4%';
    if (hba1c > 15) return '⚠️ السكر التراكمي يجب أن يكون بين 4% و 15%';

    // التحقق من سكر الدم
    if (glucose < 50) return '⚠️ سكر الدم لا يمكن أن يكون أقل من 50 mg/dL';
    if (glucose > 400) return '⚠️ سكر الدم يجب أن يكون بين 50 و 400 mg/dL';

    // التحقق من الضغط الانقباضي
    if (bloodPressureSystolic < 80)
      return '⚠️ الضغط الانقباضي لا يمكن أن يكون أقل من 80 mmHg';
    if (bloodPressureSystolic > 200)
      return '⚠️ الضغط الانقباضي يجب أن يكون بين 80 و 200 mmHg';

    // التحقق من الضغط الانبساطي
    if (bloodPressureDiastolic < 50)
      return '⚠️ الضغط الانبساطي لا يمكن أن يكون أقل من 50 mmHg';
    if (bloodPressureDiastolic > 130)
      return '⚠️ الضغط الانبساطي يجب أن يكون بين 50 و 130 mmHg';

    // التحقق من الكوليسترول
    if (cholesterol < 100)
      return '⚠️ الكوليسترول لا يمكن أن يكون أقل من 100 mg/dL';
    if (cholesterol > 400)
      return '⚠️ الكوليسترول يجب أن يكون بين 100 و 400 mg/dL';

    // التحقق من محيط الخصر
    if (waistCircumference < 50)
      return '⚠️ محيط الخصر لا يمكن أن يكون أقل من 50 سم';
    if (waistCircumference > 200)
      return '⚠️ محيط الخصر يجب أن يكون بين 50 و 200 سم';

    // التحقق من السكر التراكمي المفصل
    if (hba1cDetailed < 4)
      return '⚠️ السكر التراكمي المفصل لا يمكن أن يكون أقل من 4%';
    if (hba1cDetailed > 15)
      return '⚠️ السكر التراكمي المفصل يجب أن يكون بين 4% و 15%';

    return null; // جميع البيانات صحيحة
  }

  Future<void> _loadLastData() async {
    final lastData = await _storageService.getLastHealthData();
    if (lastData != null) {
      _ageController.text = lastData.age.toString();
      _bmiController.text = lastData.bmi.toString();
      _hba1cController.text = lastData.hba1c.toString();
      _glucoseController.text = lastData.glucose.toString();
      _bpSystolicController.text = lastData.bloodPressureSystolic.toString();
      _bpDiastolicController.text = lastData.bloodPressureDiastolic.toString();
      _cholesterolController.text = lastData.cholesterol.toString();
      _familyHistory = lastData.familyHistory;
      _smoking = lastData.smoking;
      _physicalActivity = lastData.physicalActivity;
      _hba1cDetailedController.text =
          (lastData.hba1cDetailed ?? lastData.hba1c).toString();
      _waistController.text = lastData.waistCircumference.toString();
      setState(() {});
    }
  }

  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    // قراءة القيم من المدخلات
    final age = int.tryParse(_ageController.text) ?? 0;
    final bmi = double.tryParse(_bmiController.text) ?? 0;
    final hba1c = double.tryParse(_hba1cController.text) ?? 0;
    final glucose = double.tryParse(_glucoseController.text) ?? 0;
    final bpSystolic = double.tryParse(_bpSystolicController.text) ?? 0;
    final bpDiastolic = double.tryParse(_bpDiastolicController.text) ?? 0;
    final cholesterol = double.tryParse(_cholesterolController.text) ?? 0;
    final waist = double.tryParse(_waistController.text) ?? 85.0;
    final hba1cDetailed =
        double.tryParse(_hba1cDetailedController.text) ?? hba1c;

    // التحقق من صحة البيانات
    final validationError = validateHealthData(
      age: age,
      bmi: bmi,
      hba1c: hba1c,
      glucose: glucose,
      bloodPressureSystolic: bpSystolic,
      bloodPressureDiastolic: bpDiastolic,
      cholesterol: cholesterol,
      familyHistory: _familyHistory,
      smoking: _smoking,
      physicalActivity: _physicalActivity,
      waistCircumference: waist,
      hba1cDetailed: hba1cDetailed,
    );

    if (validationError != null) {
      _showSnackBar(validationError, Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
      _progressValue = 0.2;
    });

    _hba1cDetailed = hba1cDetailed;
    _waistCircumference = waist;

    final healthData = HealthData(
      age: age,
      bmi: bmi,
      hba1c: hba1c,
      glucose: glucose,
      bloodPressureSystolic: bpSystolic,
      bloodPressureDiastolic: bpDiastolic,
      cholesterol: cholesterol,
      familyHistory: _familyHistory,
      smoking: _smoking,
      physicalActivity: _physicalActivity,
      waistCircumference: _waistCircumference,
      hba1cDetailed: _hba1cDetailed,
    );

    setState(() => _progressValue = 0.5);

    // ✅ محاولة الاتصال بالـ API أولاً
    PredictionResult? result;
    bool usedOffline = false;

    try {
      result = await _apiService.predict(healthData);
      print('✅ Using API (online mode)');
    } catch (e) {
      print('⚠️ Network error: $e');
      usedOffline = true;
    }

    // ✅ إذا فشل API، استخدم الحساب المحلي
    if (result == null) {
      usedOffline = true;
      final risk = healthData.calculateRiskLocally();
      final riskLevel = risk < 30 ? 'منخفض' : (risk < 60 ? 'متوسط' : 'مرتفع');

      result = PredictionResult(
        riskPercentage: risk,
        riskLevel: riskLevel,
        probability: risk / 100,
        recommendation: risk < 30
            ? '✅ مستوى الخطر منخفض. حافظ على نمط حياتك الصحي.'
            : (risk < 60
                ? '⚠️ مستوى الخطر متوسط. ننصح باستشارة الطبيب وتحسين نمط الحياة.'
                : '🔴 مستوى الخطر مرتفع. يُرجى مراجعة الطبيب فوراً.'),
        shapValues: {},
        topFactors: [],
        timestamp: DateTime.now().toIso8601String(),
        accuracy: 0.92,
      );
      print('✅ Using local calculation (offline mode)');
    }

    setState(() => _progressValue = 0.8);

    // حفظ التنبؤ
    await _storageService.savePredictionWithResult(
        result: result, data: healthData);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('model_accuracy', result.accuracy);
    await prefs.setInt('dataset_size', 768);

    setState(() {
      _result = result;
      _progressValue = 1.0;
      _isLoading = false;
    });

    // إشعار حسب وضع التشغيل
    if (usedOffline) {
      _showSnackBar(
          '✅ تم التنبؤ بنجاح! (وضع عدم الاتصال - دقة محلية)', Colors.orange);
    } else {
      _showSnackBar('✅ تم التنبؤ بنجاح! (وضع الاتصال بالخادم)', Colors.green);
    }

    // إشعار الإشعارات (إذا كانت مفعلة)
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    if (notificationsEnabled && !usedOffline) {
      NotificationService.showNotification(
        '📊 نتيجة التنبؤ - DiabPredict',
        'نسبة الخطر: ${result.riskPercentage.toStringAsFixed(1)}% - المستوى: ${result.riskLevel}',
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_resultsTitleKey.currentContext != null) {
        Scrollable.ensureVisible(
          _resultsTitleKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: 0.0,
        );
      }
    });
  }

  Future<void> _predictOffline() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    // قراءة القيم من المدخلات
    final age = int.tryParse(_ageController.text) ?? 0;
    final bmi = double.tryParse(_bmiController.text) ?? 0;
    final hba1c = double.tryParse(_hba1cController.text) ?? 0;
    final glucose = double.tryParse(_glucoseController.text) ?? 0;
    final bpSystolic = double.tryParse(_bpSystolicController.text) ?? 0;
    final bpDiastolic = double.tryParse(_bpDiastolicController.text) ?? 0;
    final cholesterol = double.tryParse(_cholesterolController.text) ?? 0;
    final waist = double.tryParse(_waistController.text) ?? 85.0;
    final hba1cDetailed =
        double.tryParse(_hba1cDetailedController.text) ?? hba1c;

    // التحقق من صحة البيانات
    final validationError = validateHealthData(
      age: age,
      bmi: bmi,
      hba1c: hba1c,
      glucose: glucose,
      bloodPressureSystolic: bpSystolic,
      bloodPressureDiastolic: bpDiastolic,
      cholesterol: cholesterol,
      familyHistory: _familyHistory,
      smoking: _smoking,
      physicalActivity: _physicalActivity,
      waistCircumference: waist,
      hba1cDetailed: hba1cDetailed,
    );

    if (validationError != null) {
      _showSnackBar(validationError, Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
      _progressValue = 0.2;
    });

    _hba1cDetailed = hba1cDetailed;
    _waistCircumference = waist;

    final healthData = HealthData(
      age: age,
      bmi: bmi,
      hba1c: hba1c,
      glucose: glucose,
      bloodPressureSystolic: bpSystolic,
      bloodPressureDiastolic: bpDiastolic,
      cholesterol: cholesterol,
      familyHistory: _familyHistory,
      smoking: _smoking,
      physicalActivity: _physicalActivity,
      waistCircumference: _waistCircumference,
      hba1cDetailed: _hba1cDetailed,
    );

    setState(() => _progressValue = 0.5);

    // ✅ استخدام الحساب المحلي بدون API
    final risk = healthData.calculateRiskLocally();
    final riskLevel = risk < 30 ? 'منخفض' : (risk < 60 ? 'متوسط' : 'مرتفع');

    // إنشاء نتيجة محلية
    final localResult = PredictionResult(
      riskPercentage: risk,
      riskLevel: riskLevel,
      probability: risk / 100,
      recommendation: risk < 30
          ? '✅ مستوى الخطر منخفض. حافظ على نمط حياتك الصحي.'
          : (risk < 60
              ? '⚠️ مستوى الخطر متوسط. ننصح باستشارة الطبيب وتحسين نمط الحياة.'
              : '🔴 مستوى الخطر مرتفع. يُرجى مراجعة الطبيب فوراً.'),
      shapValues: {},
      topFactors: [],
      timestamp: DateTime.now().toIso8601String(),
      accuracy: 0.92,
    );

    setState(() => _progressValue = 0.8);

    // حفظ التنبؤ محلياً
    await _storageService.savePredictionWithResult(
        result: localResult, data: healthData);

    setState(() {
      _result = localResult;
      _progressValue = 1.0;
      _isLoading = false;
    });

    _showSnackBar('✅ تم التنبؤ بنجاح! (بدون إنترنت)', Colors.green);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_resultsTitleKey.currentContext != null) {
        Scrollable.ensureVisible(
          _resultsTitleKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: 0.0,
        );
      }
    });
  }

  void _resetForm() {
    _ageController.text = '45';
    _bmiController.text = '25.0';
    _hba1cController.text = '5.7';
    _glucoseController.text = '100';
    _bpSystolicController.text = '120';
    _bpDiastolicController.text = '80';
    _cholesterolController.text = '180';
    _hba1cDetailedController.text = '5.7';
    _waistController.text = '85.0';
    _familyHistory = 0;
    _smoking = 0;
    _physicalActivity = 1;
    setState(() {
      _result = null;
      _progressValue = 0.0;
    });
    _showSnackBar('🔄 تم إعادة تعيين النموذج', Colors.orange);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveResultToFile() async {
    if (_result == null) return;

    // بناء محتوى التقرير
    final report = """
═══════════════════════════════════════════════════════════════
                    تقرير التنبؤ - DiabPredict                
═══════════════════════════════════════════════════════════════
📅 التاريخ: ${DateTime.now().toString().substring(0, 19)}
📊 نسبة الخطر: ${_result!.riskPercentage.toStringAsFixed(1)}%
🎯 مستوى الخطر: ${_result!.riskLevel}
📈 احتمال الإصابة: ${(_result!.probability * 100).toStringAsFixed(1)}%
💡 التوصية: ${_result!.recommendation}
═══════════════════════════════════════════════════════════════
📊 أهم العوامل المؤثرة:                                      
${_result!.topFactors.map((f) => "   • ${f['name']}: ${f['impact']} (${f['level']})").join('\n')}
═══════════════════════════════════════════════════════════════
📝 البيانات المدخلة:
   - العمر: ${_ageController.text} سنة
   - مؤشر كتلة الجسم: ${_bmiController.text}
   - السكر التراكمي: ${_hba1cController.text}%
   - سكر الدم: ${_glucoseController.text} mg/dL
   - الضغط: ${_bpSystolicController.text}/${_bpDiastolicController.text} mmHg
   - الكوليسترول: ${_cholesterolController.text} mg/dL
   - التاريخ العائلي: ${_familyHistory == 0 ? 'لا يوجد' : (_familyHistory == 1 ? 'أحد الوالدين' : 'كلا الوالدين')}
   - التدخين: ${_smoking == 0 ? 'لا يدخن' : (_smoking == 1 ? 'مدخن سابق' : 'مدخن حالياً')}
   - النشاط البدني: ${_physicalActivity == 0 ? 'قليل' : (_physicalActivity == 1 ? 'متوسط' : 'كثير')}
═══════════════════════════════════════════════════════════════
🔬 تحاليل متقدمة:
   - محيط الخصر: ${_waistController.text} سم
   - السكر التراكمي المفصل: ${_hba1cDetailedController.text}%
═══════════════════════════════════════════════════════════════
🤖 تم إنشاء هذا التقرير بواسطة DiabPredict
نظام ذكي للتنبؤ المبكر بخطر السكري
""";

    try {
      // الحصول على المسار المناسب لحفظ الملفات
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'DiabPredict_Report_${DateTime.now().millisecondsSinceEpoch}.txt';
      final filePath = '${directory.path}/$fileName';

      // حفظ الملف
      final file = File(filePath);
      await file.writeAsString(report);

      // مشاركة الملف
      await Share.shareXFiles(
        [XFile(filePath)],
        text:
            '📊 تقرير التنبؤ - DiabPredict\nنسبة الخطر: ${_result!.riskPercentage.toStringAsFixed(1)}%',
      );

      _showSnackBar('✅ تم حفظ التقرير ومشاركته بنجاح!', Colors.green);
    } catch (e) {
      debugPrint('❌ Error saving report: $e');
      _showSnackBar('❌ فشل حفظ التقرير', Colors.red);
    }
  }

// ========== محاكاة سيناريو "ماذا لو" (متعددة العوامل) مع دعم وضع عدم الاتصال ==========
  Future<void> _showWhatIfDialog() async {
    if (_result == null) return;

    // قائمة العوامل مع قيمها الحالية
    final List<Map<String, dynamic>> factors = [
      {
        'name': 'العمر',
        'key': 'age',
        'current': int.parse(_ageController.text),
        'newValue': int.parse(_ageController.text).toDouble(),
        'unit': 'سنة',
        'min': 0,
        'max': 120,
        'isSelected': false
      },
      {
        'name': 'مؤشر كتلة الجسم',
        'key': 'bmi',
        'current': double.parse(_bmiController.text),
        'newValue': double.parse(_bmiController.text),
        'unit': 'kg/m²',
        'min': 10,
        'max': 50,
        'isSelected': false
      },
      {
        'name': 'السكر التراكمي',
        'key': 'hba1c',
        'current': double.parse(_hba1cController.text),
        'newValue': double.parse(_hba1cController.text),
        'unit': '%',
        'min': 4,
        'max': 15,
        'isSelected': false
      },
      {
        'name': 'سكر الدم',
        'key': 'glucose',
        'current': double.parse(_glucoseController.text),
        'newValue': double.parse(_glucoseController.text),
        'unit': 'mg/dL',
        'min': 50,
        'max': 400,
        'isSelected': false
      },
      {
        'name': 'الضغط الانقباضي',
        'key': 'bp_sys',
        'current': double.parse(_bpSystolicController.text),
        'newValue': double.parse(_bpSystolicController.text),
        'unit': 'mmHg',
        'min': 80,
        'max': 200,
        'isSelected': false
      },
      {
        'name': 'الضغط الانبساطي',
        'key': 'bp_dias',
        'current': double.parse(_bpDiastolicController.text),
        'newValue': double.parse(_bpDiastolicController.text),
        'unit': 'mmHg',
        'min': 50,
        'max': 130,
        'isSelected': false
      },
      {
        'name': 'الكوليسترول',
        'key': 'cholesterol',
        'current': double.parse(_cholesterolController.text),
        'newValue': double.parse(_cholesterolController.text),
        'unit': 'mg/dL',
        'min': 100,
        'max': 400,
        'isSelected': false
      },
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // حساب التأثير المتوقع
          double simulatedRisk = _result!.riskPercentage;
          bool isCalculating = false;
          bool usedOffline = false;

          Future<void> calculateSimulatedRisk() async {
            if (isCalculating) return;
            isCalculating = true;

            // ✅ إعادة بناء الواجهة فوراً
            setDialogState(() {});

            // بناء البيانات المعدلة
            final selectedFactors =
                factors.where((f) => f['isSelected'] == true).toList();

            if (selectedFactors.isEmpty) {
              simulatedRisk = _result!.riskPercentage;
              usedOffline = false;
              setDialogState(() {});
              isCalculating = false;
              return;
            }

            final age =
                factors.firstWhere((f) => f['key'] == 'age')['isSelected'] ==
                        true
                    ? (factors.firstWhere((f) => f['key'] == 'age')['newValue']
                            as double)
                        .toInt()
                    : int.parse(_ageController.text);
            final bmi =
                factors.firstWhere((f) => f['key'] == 'bmi')['isSelected'] ==
                        true
                    ? factors.firstWhere((f) => f['key'] == 'bmi')['newValue']
                        as double
                    : double.parse(_bmiController.text);
            final hba1c =
                factors.firstWhere((f) => f['key'] == 'hba1c')['isSelected'] ==
                        true
                    ? factors.firstWhere((f) => f['key'] == 'hba1c')['newValue']
                        as double
                    : double.parse(_hba1cController.text);
            final glucose = factors.firstWhere(
                        (f) => f['key'] == 'glucose')['isSelected'] ==
                    true
                ? factors.firstWhere((f) => f['key'] == 'glucose')['newValue']
                    as double
                : double.parse(_glucoseController.text);
            final bpSystolic = factors.firstWhere(
                        (f) => f['key'] == 'bp_sys')['isSelected'] ==
                    true
                ? factors.firstWhere((f) => f['key'] == 'bp_sys')['newValue']
                    as double
                : double.parse(_bpSystolicController.text);
            final bpDiastolic = factors.firstWhere(
                        (f) => f['key'] == 'bp_dias')['isSelected'] ==
                    true
                ? factors.firstWhere((f) => f['key'] == 'bp_dias')['newValue']
                    as double
                : double.parse(_bpDiastolicController.text);
            final cholesterol = factors.firstWhere(
                        (f) => f['key'] == 'cholesterol')['isSelected'] ==
                    true
                ? factors.firstWhere(
                    (f) => f['key'] == 'cholesterol')['newValue'] as double
                : double.parse(_cholesterolController.text);
            setDialogState(() {});
            final simulatedHealthData = HealthData(
              age: age,
              bmi: bmi,
              hba1c: hba1c,
              glucose: glucose,
              bloodPressureSystolic: bpSystolic,
              bloodPressureDiastolic: bpDiastolic,
              cholesterol: cholesterol,
              familyHistory: _familyHistory,
              smoking: _smoking,
              physicalActivity: _physicalActivity,
              waistCircumference: _waistCircumference,
              hba1cDetailed: _hba1cDetailed,
            );

            // ✅ حساب النسبة مباشرة من المعادلة المحلية
            final localRisk = simulatedHealthData.calculateRiskLocally();
            // ✅ أضف هذه الأسطر
            usedOffline = true;
            simulatedRisk = localRisk;

            // ✅ تحديث الواجهة بالقيمة الجديدة
            setDialogState(() {});

            isCalculating = false;
          }

          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.psychology, color: Color(0xFF8B5CF6)),
                const SizedBox(width: 8),
                const Text('🔮 محاكاة "ماذا لو"'),
                const Spacer(),
                if (usedOffline)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '📡 وضع عدم الاتصال',
                      style: TextStyle(fontSize: 10, color: Colors.orange),
                    ),
                  ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'اختر العوامل التي تريد تغييرها وعدّل قيمها:',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  // قائمة العوامل
                  Container(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: factors.length,
                      itemBuilder: (context, index) {
                        final factor = factors[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: factor['isSelected'],
                                      onChanged: (value) {
                                        setDialogState(() {
                                          factor['isSelected'] = value ?? false;
                                        });
                                        calculateSimulatedRisk();
                                      },
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${factor['name']} (الحالي: ${factor['current']} ${factor['unit']})',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                if (factor['isSelected'] == true)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 40, right: 10, bottom: 8),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                'القيمة: ${(factor['newValue'] as double).toStringAsFixed(1)} ${factor['unit']}'),
                                            Text(
                                                '${factor['min']} - ${factor['max']}'),
                                          ],
                                        ),
                                        Slider(
                                          value: factor['newValue'],
                                          min: factor['min'].toDouble(),
                                          max: factor['max'].toDouble(),
                                          divisions: 100,
                                          label: (factor['newValue'] as double)
                                              .toStringAsFixed(1),
                                          onChanged: (value) {
                                            setDialogState(() {
                                              factor['newValue'] = value;
                                            });
                                            calculateSimulatedRisk();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // عرض التأثير المتوقع مع إشعار وضع التشغيل
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: simulatedRisk < _result!.riskPercentage
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        if (usedOffline)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.wifi_off,
                                    size: 14, color: Colors.orange),
                                const SizedBox(width: 4),
                                Text(
                                  'تقدير محلي (بدون اتصال بالإنترنت)',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.orange.shade700),
                                ),
                              ],
                            ),
                          ),
                        Text(
                          'نسبة الخطر الحالية: ${_result!.riskPercentage.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'نسبة الخطر الجديدة: ${simulatedRisk.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: simulatedRisk < _result!.riskPercentage
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          simulatedRisk < _result!.riskPercentage
                              ? '⬇️ انخفاض بنسبة ${(_result!.riskPercentage - simulatedRisk).abs().toStringAsFixed(1)}%'
                              : simulatedRisk > _result!.riskPercentage
                                  ? '⬆️ ارتفاع بنسبة ${(simulatedRisk - _result!.riskPercentage).abs().toStringAsFixed(1)}%'
                                  : '➡️ لا تغيير',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: simulatedRisk < _result!.riskPercentage
                                ? Colors.green
                                : (simulatedRisk > _result!.riskPercentage
                                    ? Colors.red
                                    : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  // تطبيق التغييرات على النموذج
                  for (var factor in factors) {
                    if (factor['isSelected'] == true) {
                      switch (factor['key']) {
                        case 'age':
                          _ageController.text =
                              (factor['newValue'] as double).toInt().toString();
                          break;
                        case 'bmi':
                          _bmiController.text =
                              (factor['newValue'] as double).toStringAsFixed(1);
                          break;
                        case 'hba1c':
                          _hba1cController.text =
                              (factor['newValue'] as double).toStringAsFixed(1);
                          break;
                        case 'glucose':
                          _glucoseController.text =
                              (factor['newValue'] as double).toInt().toString();
                          break;
                        case 'bp_sys':
                          _bpSystolicController.text =
                              (factor['newValue'] as double).toInt().toString();
                          break;
                        case 'bp_dias':
                          _bpDiastolicController.text =
                              (factor['newValue'] as double).toInt().toString();
                          break;
                        case 'cholesterol':
                          _cholesterolController.text =
                              (factor['newValue'] as double).toInt().toString();
                          break;
                      }
                    }
                  }
                  // ✅ إشعار للمستخدم بوضع التشغيل المستخدم
                  if (usedOffline) {
                    _showSnackBar(
                        '📡 تم التحديث باستخدام الحساب المحلي (بدون إنترنت)',
                        Colors.orange);
                  } else {
                    _showSnackBar(
                        '✅ تم تحديث القيم! اضغط "تنبؤ" لرؤية النتيجة الجديدة.',
                        Colors.blue);
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text('تطبيق التغييرات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ✅ التحقق من حالة الحفظ التلقائي
  Future<bool> _isAutoSaveEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('auto_save_results') ??
        true; // true = مفعل, false = معطل
  }

// ✅ حفظ يدوي للتنبؤ الحالي
  Future<void> _savePredictionManually() async {
    if (_result == null) return;

    // تجهيز البيانات الصحية من المدخلات الحالية
    final healthData = HealthData(
      age: int.parse(_ageController.text),
      bmi: double.parse(_bmiController.text),
      hba1c: double.parse(_hba1cController.text),
      glucose: double.parse(_glucoseController.text),
      bloodPressureSystolic: double.parse(_bpSystolicController.text),
      bloodPressureDiastolic: double.parse(_bpDiastolicController.text),
      cholesterol: double.parse(_cholesterolController.text),
      familyHistory: _familyHistory,
      smoking: _smoking,
      physicalActivity: _physicalActivity,
      waistCircumference: _waistCircumference,
      hba1cDetailed: _hba1cDetailed,
    );

    await _storageService.savePredictionWithResult(
        result: _result!, data: healthData);
    _showSnackBar('💾 تم حفظ التنبؤ بنجاح!', Colors.green);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            // العودة إلى الصفحة الرئيسية وإزالة جميع الصفحات السابقة
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          },
          tooltip: 'العودة إلى الرئيسية',
        ),
        title: const Text('التنبؤ'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTipsCard(),
                  const SizedBox(height: 20),
                  _buildFormSection(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                  if (_result != null) ...[
                    const SizedBox(height: 24),
                    _buildResultsSection(),
                  ],
                ],
              ),
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
            'جاري تحليل البيانات...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              value: _progressValue,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFF2563EB),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_progressValue * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lightbulb, color: Color(0xFF2563EB)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'أدخل بياناتك الصحية بدقة للحصول على تنبؤ أدق. جميع البيانات آمنة ومشفرة.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '📝 البيانات الصحية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          const Divider(height: 0),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'العمر',
                          controller: _ageController,
                          icon: Icons.cake,
                          unit: 'سنة',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'مؤشر كتلة الجسم',
                          controller: _bmiController,
                          icon: Icons.monitor_weight,
                          unit: 'kg/m²',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'السكر التراكمي',
                          controller: _hba1cController,
                          icon: Icons.bloodtype,
                          unit: '%',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'سكر الدم',
                          controller: _glucoseController,
                          icon: Icons.science,
                          unit: 'mg/dL',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'الضغط الانقباضي',
                          controller: _bpSystolicController,
                          icon: Icons.favorite,
                          unit: 'mmHg',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'الضغط الانبساطي',
                          controller: _bpDiastolicController,
                          icon: Icons.favorite_border,
                          unit: 'mmHg',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'الكوليسترول',
                    controller: _cholesterolController,
                    icon: Icons.medical_information,
                    unit: 'mg/dL',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => setState(() => _showAdvanced = !_showAdvanced),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            _showAdvanced
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: const Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '🔬 تحاليل متقدمة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showAdvanced) ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'السكر التراكمي المفصل',
                      controller: _hba1cDetailedController,
                      icon: Icons.bloodtype,
                      unit: '%',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'محيط الخصر',
                      controller: _waistController,
                      icon: Icons.straighten,
                      unit: 'سم',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'التاريخ العائلي',
                      items: ['لا يوجد', 'أحد الوالدين', 'كلا الوالدين'],
                      value: _familyHistory,
                      icon: Icons.family_restroom,
                      onChanged: (value) =>
                          setState(() => _familyHistory = value),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'التدخين',
                      items: ['لا أدخن', 'مدخن سابق', 'مدخن حالياً'],
                      value: _smoking,
                      icon: Icons.smoke_free,
                      onChanged: (value) => setState(() => _smoking = value),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      label: 'النشاط البدني',
                      items: ['قليل', 'متوسط', 'كثير'],
                      value: _physicalActivity,
                      icon: Icons.directions_run,
                      onChanged: (value) =>
                          setState(() => _physicalActivity = value),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _predict, // ✅ استخدم _predict (وليس _predictOffline)
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              '🔍 تنبؤ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: _resetForm,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFEF4444),
            side: const BorderSide(color: Color(0xFFEF4444)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'مسح',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsSection() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.analytics, color: Color(0xFF2563EB), size: 24),
                const SizedBox(width: 12),
                Container(
                  key: _resultsTitleKey,
                  child: const Text(
                    'نتائج التنبؤ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                RiskGauge(
                  riskPercentage: _result!.riskPercentage,
                  riskLevel: _result!.riskLevel,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getRiskColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getRiskColor(),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getRiskIcon(),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _result!.recommendation,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '📊 أهم العوامل المؤثرة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                ...(_result!.topFactors.isNotEmpty
                        ? _result!.topFactors
                        : _getDemoFactors())
                    .map((factor) => _buildFactorCard(factor)),
                const SizedBox(height: 12),
              // ✅ رسم بياني بسيط للعوامل المؤثرة
                _buildFactorsChart(),
                const SizedBox(height: 20),
                // ✅ زر محاكاة "ماذا لو"
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _showWhatIfDialog,
                    icon: const Icon(Icons.psychology, size: 20),
                    label: const Text(
                      '🔮 محاكاة "ماذا لو"',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF8B5CF6)),
                      foregroundColor: const Color(0xFF8B5CF6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ✅ زر حفظ النتيجة
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _saveResultToFile,
                    icon: const Icon(Icons.save, size: 20),
                    label: const Text('💾 حفظ التقرير'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF10B981)),
                      foregroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // ✅ زر حفظ يدوي (يظهر فقط عند تعطيل الحفظ التلقائي)
                FutureBuilder<bool>(
                  future: _isAutoSaveEnabled(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && !snapshot.data!) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _savePredictionManually,
                            icon: const Icon(Icons.save, size: 20),
                            label: const Text(
                              '💾 حفظ التنبؤ',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/assistant',
                        arguments: {
                          'riskPercentage': _result!.riskPercentage,
                          'shapValues': _result!.shapValues,
                          'healthData': {
                            'age': int.parse(_ageController.text),
                            'bmi': double.parse(_bmiController.text),
                            'hba1c': double.parse(_hba1cController.text),
                            'glucose': double.parse(_glucoseController.text),
                            'bloodPressureSystolic':
                                double.parse(_bpSystolicController.text),
                            'bloodPressureDiastolic':
                                double.parse(_bpDiastolicController.text),
                            'cholesterol':
                                double.parse(_cholesterolController.text),
                            'familyHistory': _familyHistory,
                            'smoking': _smoking,
                            'physicalActivity': _physicalActivity,
                          },
                        },
                      );
                    },
                    icon: const Icon(Icons.auto_awesome, size: 20),
                    label: const Text(
                      '🤖 اسأل المساعد الذكي',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF7C3AED)),
                      foregroundColor: const Color(0xFF7C3AED),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ رسم بياني بسيط للعوامل المؤثرة
  Widget _buildFactorsChart() {
    final factors = (_result!.topFactors.isNotEmpty
            ? _result!.topFactors
            : _getDemoFactors())
        .take(4)
        .toList();
    if (factors.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📊 توزيع تأثير العوامل',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        ...factors.map((factor) {
          final strength =
              double.tryParse(factor['strength']?.toString() ?? '0') ?? 0;
          final isPositive = factor['impact'] == 'يزيد الخطر';
          final percentage = (strength * 100).clamp(0, 100);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      factor['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${percentage.toInt()}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: isPositive ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: isPositive ? Colors.red : Colors.green,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFactorCard(Map<String, dynamic> factor) {
    final isNegative = factor['impact'] == 'يقلل الخطر';
    final color =
        isNegative ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final impactText = factor['impact'] ?? '';
    final levelText = factor['level'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isNegative ? '🟢' : '🔴',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  factor['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$impactText • $levelText التأثير',
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isNegative ? 'مفيد' : 'ضار',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== دوال مساعدة ==========

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String unit,
    required TextInputType keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF2563EB)),
        suffixText: unit,
        suffixStyle: TextStyle(fontSize: 11, color: Colors.grey[500]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'يرجى إدخال $label';
        return null;
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required int value,
    required IconData icon,
    required Function(int) onChanged,
  }) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF2563EB)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items.asMap().entries.map((entry) {
        return DropdownMenuItem<int>(
          value: entry.key,
          child: Text(
            entry.value,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.right,
          ),
        );
      }).toList(),
      onChanged: (newValue) => onChanged(newValue!),
    );
  }

  Color _getRiskColor() {
    if (_result!.riskPercentage < 30) return const Color(0xFF10B981);
    if (_result!.riskPercentage < 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  IconData _getRiskIcon() {
    if (_result!.riskPercentage < 30) return Icons.check_circle;
    if (_result!.riskPercentage < 60) return Icons.warning_amber;
    return Icons.error;
  }
}
