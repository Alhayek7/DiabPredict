import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/health_data.dart';

class LocalStorageService {
  static const String _boxName = 'predictions';
  late Box<HealthData> _box;

  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(HealthDataAdapter()); 
    _box = await Hive.openBox<HealthData>(_boxName);
    print('✅ LocalStorageService initialized. Total: ${_box.length}');
  }

  /// حفظ توقع جديد (بسيط)
  Future<void> savePrediction(HealthData data) async {
    await _box.add(data);
    print('✅ Prediction saved locally. Total: ${_box.length}');
  }

  /// حفظ توقع مع نتيجة (متوافق مع PredictScreen)
  Future<void> savePredictionWithResult({
    required PredictionResult result,
    required HealthData data,
  }) async {
    await savePrediction(data);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_prediction', jsonEncode(result.toJson()));
    print('✅ Prediction and result saved');
  }

  /// الحصول على جميع التوقعات
  List<HealthData> getAllPredictions() {
    return _box.values.toList();
  }

  /// الحصول على آخر بيانات صحية
  Future<HealthData?> getLastHealthData() async {
    final all = getAllPredictions();
    if (all.isEmpty) return null;
    return all.last;
  }

  /// الحصول على آخر نتيجة تنبؤ
  Future<PredictionResult?> getLastPrediction() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString('last_prediction');
      if (data == null) return null;
      return PredictionResult.fromJson(jsonDecode(data));
    } catch (e) {
      print('❌ Error getting last prediction: $e');
      return null;
    }
  }

  /// الحصول على التوقعات غير المتزامنة
  List<HealthData> getUnsyncedPredictions() {
    return _box.values.where((item) => !item.synced).toList();
  }

  /// تحديث حالة المزامنة
  Future<void> markAsSynced(HealthData data) async {
    final all = _box.values.toList();
    final index = all.indexWhere((item) => item.timestamp == data.timestamp);
    
    if (index != -1) {
      final key = _box.keyAt(index);
      final updatedData = HealthData(
        age: data.age,
        bmi: data.bmi,
        hba1c: data.hba1c,
        glucose: data.glucose,
        bloodPressureSystolic: data.bloodPressureSystolic,
        bloodPressureDiastolic: data.bloodPressureDiastolic,
        cholesterol: data.cholesterol,
        familyHistory: data.familyHistory,
        smoking: data.smoking,
        physicalActivity: data.physicalActivity,
        waistCircumference: data.waistCircumference,
        hba1cDetailed: data.hba1cDetailed,
        timestamp: data.timestamp,
        synced: true,
        localRisk: data.localRisk,
      );
      await _box.put(key, updatedData);
      print('✅ Prediction marked as synced');
    }
  }

  /// حذف توقع معين
  Future<void> deletePrediction(HealthData data) async {
    final all = _box.values.toList();
    final index = all.indexWhere((item) => item.timestamp == data.timestamp);
    if (index != -1) {
      await _box.deleteAt(index);
      print('🗑️ Prediction deleted');
    }
  }

  /// حذف جميع البيانات
  Future<void> clearAll() async {
    await _box.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_prediction');
    print('🗑️ All predictions cleared');
  }

  /// عدد التوقعات
  int get count => _box.length;
}