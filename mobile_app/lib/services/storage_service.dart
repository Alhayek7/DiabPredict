import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_data.dart';

class StorageService {
  static const String _historyKey = 'prediction_history';
  static const String _lastPredictionKey = 'last_prediction';
  static const String _lastHealthDataKey = 'last_health_data';

  // ✅ حفظ التنبؤ (الطريقة الرئيسية)
  Future<void> savePrediction({
    required PredictionResult result,
    required HealthData data,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1️⃣ حفظ السجل (History)
      List<String> history = prefs.getStringList(_historyKey) ?? [];
      
      final predictionRecord = {
        'timestamp': result.timestamp,
        'risk_percentage': result.riskPercentage,
        'risk_level': result.riskLevel,
        'health_data': data.toJson(),
        'waist_circumference': data.waistCircumference,
        'hba1c_detailed': data.hba1cDetailed,
      };
      
      history.add(jsonEncode(predictionRecord));
      
      // الاحتفاظ بآخر 50 تنبؤ فقط
      if (history.length > 50) {
        history = history.sublist(history.length - 50);
      }
      
      await prefs.setStringList(_historyKey, history);
      
      // 2️⃣ حفظ آخر تنبؤ
      await prefs.setString(_lastPredictionKey, jsonEncode(result.toJson()));
      
      // 3️⃣ حفظ آخر بيانات صحية
      await prefs.setString(_lastHealthDataKey, jsonEncode(data.toJson()));
      
      print('✅ Prediction saved successfully');
      print('📊 History size: ${history.length}');
      print('📊 Risk: ${result.riskPercentage}%');
      
    } catch (e) {
      print('❌ Error saving prediction: $e');
    }
  }

  // ✅ الحصول على السجل الكامل
  Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList(_historyKey) ?? [];
      
      print('📊 getHistory: ${history.length} records found');
      
      final result = history.map((item) {
        try {
          return jsonDecode(item) as Map<String, dynamic>;
        } catch (e) {
          print('❌ Error decoding history item: $e');
          return <String, dynamic>{};
        }
      }).toList();
      
      return result;
    } catch (e) {
      print('❌ Error getting history: $e');
      return [];
    }
  }

  // ✅ الحصول على آخر تنبؤ
  Future<PredictionResult?> getLastPrediction() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_lastPredictionKey);
      if (data == null) {
        print('⚠️ No last prediction found');
        return null;
      }
      final result = PredictionResult.fromJson(jsonDecode(data));
      print('📊 Loaded prediction - Risk: ${result.riskPercentage}%');
      return result;
    } catch (e) {
      print('❌ Error getting last prediction: $e');
      return null;
    }
  }

  // ✅ الحصول على آخر بيانات صحية
  Future<HealthData?> getLastHealthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_lastHealthDataKey);
      if (data == null) {
        print('⚠️ No last health data found');
        return null;
      }
      
      final Map<String, dynamic> json = jsonDecode(data);
      return HealthData(
        age: json['age'],
        bmi: json['bmi'].toDouble(),
        hba1c: json['hba1c'].toDouble(),
        glucose: json['glucose'].toDouble(),
        bloodPressureSystolic: json['blood_pressure_systolic'].toDouble(),
        bloodPressureDiastolic: json['blood_pressure_diastolic'].toDouble(),
        cholesterol: json['cholesterol'].toDouble(),
        familyHistory: json['family_history'],
        smoking: json['smoking'],
        physicalActivity: json['physical_activity'],
        waistCircumference: json['waist_circumference']?.toDouble() ?? 85.0,
        hba1cDetailed: json['hba1c_detailed']?.toDouble(),
      );
    } catch (e) {
      print('❌ Error getting last health data: $e');
      return null;
    }
  }

  // ✅ مسح السجل بالكامل
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
      await prefs.remove(_lastPredictionKey);
      await prefs.remove(_lastHealthDataKey);
      print('✅ History cleared successfully');
    } catch (e) {
      print('❌ Error clearing history: $e');
    }
  }

  // ✅ عدد التنبؤات في السجل
  Future<int> getHistoryCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> history = prefs.getStringList(_historyKey) ?? [];
      return history.length;
    } catch (e) {
      return 0;
    }
  }

  // ✅ حجم مجموعة البيانات
  Future<int> getDatasetSize() async {
    return 768;
  }

  // ✅ دالة مبسطة للحفظ (لـ PredictScreen)
  Future<void> savePredictionWithResult({
    required PredictionResult result,
    required HealthData data,
  }) async {
    await savePrediction(result: result, data: data);
  }
}