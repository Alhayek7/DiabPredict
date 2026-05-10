import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'health_data.g.dart';

@HiveType(typeId: 0)
class HealthData {
  @HiveField(0)
  final int age;

  @HiveField(1)
  final double bmi;

  @HiveField(2)
  final double hba1c;

  @HiveField(3)
  final double glucose;

  @HiveField(4)
  final double bloodPressureSystolic;

  @HiveField(5)
  final double bloodPressureDiastolic;

  @HiveField(6)
  final double cholesterol;

  @HiveField(7)
  final int familyHistory;

  @HiveField(8)
  final int smoking;

  @HiveField(9)
  final int physicalActivity;

  @HiveField(10)
  final double waistCircumference;

  @HiveField(11)
  final double? hba1cDetailed;

  @HiveField(12)
  final DateTime timestamp;

  @HiveField(13)
  final bool synced;

  @HiveField(14)
  final double? localRisk;

  HealthData({
    required this.age,
    required this.bmi,
    required this.hba1c,
    required this.glucose,
    required this.bloodPressureSystolic,
    required this.bloodPressureDiastolic,
    required this.cholesterol,
    required this.familyHistory,
    required this.smoking,
    required this.physicalActivity,
    this.waistCircumference = 85.0,
    this.hba1cDetailed,
    DateTime? timestamp,
    this.synced = false,
    this.localRisk,
  }) : timestamp = timestamp ?? DateTime.now();

  /// تحويل الكائن إلى JSON (للإرسال إلى الـ API)
  Map<String, dynamic> toJson() => {
        'age': age,
        'bmi': bmi,
        'hba1c': hba1c,
        'glucose': glucose,
        'blood_pressure_systolic': bloodPressureSystolic,
        'blood_pressure_diastolic': bloodPressureDiastolic,
        'cholesterol': cholesterol,
        'family_history': familyHistory,
        'smoking': smoking,
        'physical_activity': physicalActivity,
        'waist_circumference': waistCircumference,
        'hba1c_detailed': hba1cDetailed,
      };

  /// إنشاء كائن من JSON (من الـ API)
  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      age: json['age'],
      bmi: (json['bmi'] as num).toDouble(),
      hba1c: (json['hba1c'] as num).toDouble(),
      glucose: (json['glucose'] as num).toDouble(),
      bloodPressureSystolic:
          (json['blood_pressure_systolic'] as num).toDouble(),
      bloodPressureDiastolic:
          (json['blood_pressure_diastolic'] as num).toDouble(),
      cholesterol: (json['cholesterol'] as num).toDouble(),
      familyHistory: json['family_history'],
      smoking: json['smoking'],
      physicalActivity: json['physical_activity'],
      waistCircumference:
          (json['waist_circumference'] as num?)?.toDouble() ?? 85.0,
      hba1cDetailed: (json['hba1c_detailed'] as num?)?.toDouble(),
    );
  }

  /// حساب نسبة الخطر محلياً (بدون إنترنت) - خوارزمية معتمدة على المعايير الطبية
  double calculateRiskLocally() {
    double risk = 0.0;

    // ═══════════════════════════════════════════════════════════════
    // 1. العمر - عامل خطر رئيسي
    // ═══════════════════════════════════════════════════════════════
    if (age >= 80) risk += 0.50;
    else if (age >= 70) risk += 0.40;
    else if (age >= 60) risk += 0.30;
    else if (age >= 50) risk += 0.20;
    else if (age >= 40) risk += 0.10;
    else if (age <= 30) risk -= 0.05;

    // ═══════════════════════════════════════════════════════════════
    // 2. مؤشر كتلة الجسم (BMI) - السمنة
    // ═══════════════════════════════════════════════════════════════
    if (bmi >= 35) risk += 0.25;
    else if (bmi >= 30) risk += 0.20;
    else if (bmi >= 25) risk += 0.12;
    
    // محيط الخصر (مؤشر إضافي)
    if (waistCircumference > 102) risk += 0.10;
    else if (waistCircumference > 88) risk += 0.05;

    // ═══════════════════════════════════════════════════════════════
    // 3. السكر التراكمي (HbA1c) - أقوى عامل تنبؤي
    // ═══════════════════════════════════════════════════════════════
    final effectiveHba1c = hba1cDetailed ?? hba1c;
    if (effectiveHba1c >= 9.0) risk += 0.40;
    else if (effectiveHba1c >= 7.5) risk += 0.30;
    else if (effectiveHba1c >= 6.5) risk += 0.20;
    else if (effectiveHba1c >= 5.7) risk += 0.10;

    // ═══════════════════════════════════════════════════════════════
    // 4. سكر الدم الصائم
    // ═══════════════════════════════════════════════════════════════
    if (glucose >= 200) risk += 0.20;
    else if (glucose >= 140) risk += 0.15;
    else if (glucose >= 126) risk += 0.10;
    else if (glucose >= 100) risk += 0.05;

    // ═══════════════════════════════════════════════════════════════
    // 5. ضغط الدم
    // ═══════════════════════════════════════════════════════════════
    if (bloodPressureSystolic >= 160) risk += 0.15;
    else if (bloodPressureSystolic >= 140) risk += 0.10;
    else if (bloodPressureSystolic >= 130) risk += 0.05;

    if (bloodPressureDiastolic >= 100) risk += 0.10;
    else if (bloodPressureDiastolic >= 90) risk += 0.05;

    // ═══════════════════════════════════════════════════════════════
    // 6. الكوليسترول
    // ═══════════════════════════════════════════════════════════════
    if (cholesterol >= 280) risk += 0.10;
    else if (cholesterol >= 240) risk += 0.06;
    else if (cholesterol >= 200) risk += 0.03;

    // ═══════════════════════════════════════════════════════════════
    // 7. التاريخ العائلي
    // ═══════════════════════════════════════════════════════════════
    if (familyHistory == 1) risk += 0.15;
    if (familyHistory == 2) risk += 0.25;

    // ═══════════════════════════════════════════════════════════════
    // 8. التدخين
    // ═══════════════════════════════════════════════════════════════
    if (smoking == 2) risk += 0.10;
    else if (smoking == 1) risk += 0.05;

    // ═══════════════════════════════════════════════════════════════
    // 9. النشاط البدني (عامل وقائي)
    // ═══════════════════════════════════════════════════════════════
    if (physicalActivity == 0) risk += 0.10;
    else if (physicalActivity == 2) risk -= 0.05;

    // التأكد من أن النسبة بين 1% و 99%
    double finalRisk = risk.clamp(0.01, 0.99) * 100;
    
    return double.parse(finalRisk.toStringAsFixed(1));
  }

  /// الحصول على مستوى الخطر كنص
  String getRiskLevel() {
    final risk = localRisk ?? calculateRiskLocally();
    if (risk < 30) return 'منخفض';
    if (risk < 60) return 'متوسط';
    return 'مرتفع';
  }

  /// الحصول على لون الخطر
  Color getRiskColor() {
    final risk = localRisk ?? calculateRiskLocally();
    if (risk < 30) return Colors.green;
    if (risk < 60) return Colors.orange;
    return Colors.red;
  }

  /// الحصول على وصف الخطر
  String getRiskDescription() {
    final risk = localRisk ?? calculateRiskLocally();
    if (risk < 30) {
      return '✅ حالتك جيدة. استمر في نمط حياتك الصحي.';
    } else if (risk < 60) {
      return '⚠️ هناك بعض عوامل الخطر. يمكنك تحسين صحتك.';
    } else {
      return '🔴 خطر مرتفع. يُرجى استشارة الطبيب فوراً.';
    }
  }
}

/// كلاس PredictionResult (نتيجة التنبؤ من الـ API)
class PredictionResult {
  final double riskPercentage;
  final String riskLevel;
  final double probability;
  final String recommendation;
  final Map<String, double> shapValues;
  final List<Map<String, dynamic>> topFactors;
  final String timestamp;
  final double accuracy;

  PredictionResult({
    required this.riskPercentage,
    required this.riskLevel,
    required this.probability,
    required this.recommendation,
    required this.shapValues,
    required this.topFactors,
    required this.timestamp,
    required this.accuracy,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      riskPercentage: (json['risk_percentage'] as num).toDouble(),
      riskLevel: json['risk_level'],
      probability: (json['probability'] as num).toDouble(),
      recommendation: json['recommendation'],
      shapValues: Map<String, double>.from(json['shap_values']),
      topFactors: List<Map<String, dynamic>>.from(json['top_factors']),
      timestamp: json['timestamp'],
      accuracy: (json['accuracy'] ?? 0.73).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'risk_percentage': riskPercentage,
        'risk_level': riskLevel,
        'probability': probability,
        'recommendation': recommendation,
        'shap_values': shapValues,
        'top_factors': topFactors,
        'timestamp': timestamp,
        'accuracy': accuracy,
      };
}