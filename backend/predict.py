"""
التنبؤ باستخدام النموذج المدرب - DiabPredict
"""

import sys
import os
import json

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from utils.model import DiabetesPredictor


def predict_single(features: dict) -> dict:
    """التنبؤ لبيانات فردية"""
    predictor = DiabetesPredictor()
    
    if not predictor.load():
        print("❌ فشل تحميل النموذج. قم بتدريب النموذج أولاً.")
        return None
    
    prediction, probability, shap_values = predictor.predict(features)
    
    # تحديد مستوى الخطر
    if probability < 30:
        risk_level = "منخفض"
        risk_color = "#10B981"
    elif probability < 60:
        risk_level = "متوسط"
        risk_color = "#F59E0B"
    else:
        risk_level = "مرتفع"
        risk_color = "#EF4444"
    
    result = {
        "prediction": prediction,
        "risk_percentage": round(probability, 2),
        "risk_level": risk_level,
        "risk_color": risk_color,
        "shap_values": shap_values,
        "top_factors": sorted(shap_values.items(), key=lambda x: abs(x[1]), reverse=True)[:5]
    }
    
    return result


def predict_batch(features_list: list) -> list:
    """التنبؤ لبيانات متعددة"""
    results = []
    for features in features_list:
        result = predict_single(features)
        if result:
            results.append(result)
    return results


# مثال على الاستخدام
if __name__ == "__main__":
    # بيانات اختبار
    test_features = {
        'Pregnancies': 2,
        'Glucose': 145,
        'BloodPressure': 85,
        'SkinThickness': 25,
        'Insulin': 120,
        'BMI': 28.5,
        'DiabetesPedigreeFunction': 0.7,
        'Age': 50
    }
    
    result = predict_single(test_features)
    
    if result:
        print("\n🔮 نتيجة التنبؤ:")
        print(f"   - نسبة الخطر: {result['risk_percentage']}%")
        print(f"   - مستوى الخطر: {result['risk_level']}")
        print(f"   - أهم العوامل المؤثرة:")
        for factor, value in result['top_factors']:
            print(f"     • {factor}: {value:.4f}")