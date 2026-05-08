import joblib
import numpy as np
import pandas as pd
from typing import Dict, List, Tuple, Optional
import os
import warnings
warnings.filterwarnings('ignore')

class PredictionService:
    def __init__(self):
        self.model = None
        self.scaler = None
        self.explainer = None
        self.feature_names = None
        self.is_loaded = False
        self.load_models()
    
    def _get_model_path(self, filename: str) -> str:
        """الحصول على المسار الصحيح للنماذج (مسارات نسبية)"""
        current_dir = os.path.dirname(os.path.abspath(__file__))
        models_dir = os.path.join(current_dir, "..", "models")
        return os.path.join(models_dir, filename)
    
    def _check_file_exists(self, filepath: str) -> bool:
        """التحقق من وجود ملف"""
        return os.path.exists(filepath)
    
    def load_models(self):
        """تحميل النماذج المدربة مع التحقق من وجودها"""
        
        # تعريف النماذج المطلوبة
        models = {
            "model": "xgb_model.pkl",
            "scaler": "scaler.pkl",
            "explainer": "shap_explainer.pkl",
            "features": "feature_names.pkl"
        }
        
        try:
            # التحقق من وجود جميع الملفات أولاً
            missing_files = []
            for name, filename in models.items():
                path = self._get_model_path(filename)
                if not self._check_file_exists(path):
                    missing_files.append(filename)
            
            if missing_files:
                print(f"⚠️ الملفات التالية غير موجودة: {missing_files}")
                print("📌 سيتم استخدام النموذج الاحتياطي...")
                self._load_backup_model()
                return
            
            # تحميل النموذج الرئيسي
            self.model = joblib.load(self._get_model_path(models["model"]))
            self.scaler = joblib.load(self._get_model_path(models["scaler"]))
            self.feature_names = joblib.load(self._get_model_path(models["features"]))
            
            # تحميل SHAP Explainer (مع تجنب الأخطاء)
            try:
                self.explainer = joblib.load(self._get_model_path(models["explainer"]))
                print("✅ SHAP Explainer loaded successfully!")
            except Exception as e:
                print(f"⚠️ Could not load SHAP explainer: {e}")
                self.explainer = None
            
            self.is_loaded = True
            print("✅ Models loaded successfully!")
            
        except Exception as e:
            print(f"❌ Error loading models: {e}")
            self._load_backup_model()
    
    def _load_backup_model(self):
        """نموذج احتياطي بسيط في حالة فشل تحميل النموذج الرئيسي"""
        print("🔄 Loading backup simple model...")
        
        # استخدام نموذج بسيط يعتمد على قواعد (Rule-based)
        self.is_loaded = False
        self.use_backup = True
        
        # تعريف أسماء الميزات الأساسية
        self.feature_names = [
            'age', 'bmi', 'hba1c', 'glucose', 'blood_pressure_systolic',
            'blood_pressure_diastolic', 'cholesterol', 'family_history', 
            'smoking', 'physical_activity'
        ]
        
        print("✅ Backup model ready (Rule-based)")
    
    def _predict_backup(self, data: Dict) -> Tuple[float, float, Dict]:
        """نموذج احتياطي للتنبؤ"""
        risk_score = 0.0
        
        # قواعد بسيطة للتنبؤ
        if data.get('age', 0) > 50:
            risk_score += 0.2
        if data.get('bmi', 0) > 30:
            risk_score += 0.2
        if data.get('hba1c', 0) > 6.5:
            risk_score += 0.3
        if data.get('glucose', 0) > 140:
            risk_score += 0.2
        if data.get('family_history', 0) == 1:
            risk_score += 0.1
        
        probability = min(risk_score, 0.95)
        risk_percentage = probability * 100
        
        # SHAP values مبسطة
        shap_dict = {feature: 0.0 for feature in self.feature_names}
        
        return risk_percentage, probability, shap_dict
    
    def predict(self, data: Dict) -> Tuple[float, float, Dict]:
        """
        إجراء التنبؤ
        Returns:
            risk_percentage: نسبة الخطر (%)
            probability: احتمالية الإصابة
            shap_values: قيم SHAP لكل عامل
        """
        # استخدام النموذج الاحتياطي إذا فشل التحميل
        if not self.is_loaded:
            return self._predict_backup(data)
        
        try:
            # تحويل البيانات إلى DataFrame
            df = pd.DataFrame([data])[self.feature_names]
            
            # معالجة القيم المفقودة
            df = df.fillna(df.mean())
            
            # تطبيع البيانات
            scaled_data = self.scaler.transform(df)
            
            # التنبؤ
            probability = self.model.predict_proba(scaled_data)[0][1]
            risk_percentage = probability * 100
            
            # حساب SHAP values (إذا كان متاحاً)
            shap_dict = {}
            if self.explainer is not None:
                try:
                    shap_values = self.explainer.shap_values(scaled_data)
                    for i, feature in enumerate(self.feature_names):
                        shap_dict[feature] = float(shap_values[0][i])
                except Exception as e:
                    print(f"⚠️ SHAP calculation failed: {e}")
                    shap_dict = {feature: 0.0 for feature in self.feature_names}
            else:
                shap_dict = {feature: 0.0 for feature in self.feature_names}
            
            return risk_percentage, probability, shap_dict
            
        except Exception as e:
            print(f"❌ Prediction error: {e}")
            # الرجوع إلى النموذج الاحتياطي في حالة الخطأ
            return self._predict_backup(data)
    
    def get_risk_level(self, risk_percentage: float) -> str:
        """تحديد مستوى الخطر"""
        if risk_percentage < 30:
            return "منخفض"
        elif risk_percentage < 60:
            return "متوسط"
        else:
            return "مرتفع"
    
    def get_recommendation(self, risk_percentage: float, shap_values: Dict) -> str:
        """توليد توصية مختصرة بناءً على النتائج"""
        if risk_percentage < 30:
            return "✅ مستوى الخطر منخفض. حافظ على نمط حياتك الصحي وأجرِ فحوصات دورية كل 6 أشهر."
        
        elif risk_percentage < 60:
            # تحديد العامل الأكثر تأثيراً
            if shap_values:
                top_factor = max(shap_values.items(), key=lambda x: abs(x[1]) if x[1] is not None else 0)
                factor_ar = self._translate_feature(top_factor[0])
                return f"⚠️ مستوى الخطر متوسط. العامل الأكثر تأثيراً هو {factor_ar}. ننصح باستشارة الطبيب وتحسين هذا العامل."
            else:
                return "⚠️ مستوى الخطر متوسط. ننصح باستشارة الطبيب وإجراء فحوصات منتظمة."
        else:
            return "🔴 مستوى الخطر مرتفع. يُرجى مراجعة الطبيب فوراً وإجراء فحوصات شاملة لمرض السكري."
    
    def _translate_feature(self, feature_name: str) -> str:
        """ترجمة أسماء العوامل إلى العربية"""
        names_ar = {
            'age': 'العمر',
            'bmi': 'مؤشر كتلة الجسم',
            'hba1c': 'السكر التراكمي HbA1c',
            'glucose': 'سكر الدم',
            'blood_pressure_systolic': 'الضغط الانقباضي',
            'blood_pressure_diastolic': 'الضغط الانبساطي',
            'cholesterol': 'الكوليسترول',
            'family_history': 'التاريخ العائلي',
            'smoking': 'التدخين',
            'physical_activity': 'النشاط البدني'
        }
        return names_ar.get(feature_name, feature_name)
    
    def get_top_factors(self, shap_values: Dict) -> List[Dict]:
        """استخراج أهم 3 عوامل مؤثرة"""
        if not shap_values:
            return []
        
        # تصفية القيم None أو NaN
        valid_factors = {k: v for k, v in shap_values.items() if v is not None and not np.isnan(v)}
        
        if not valid_factors:
            return []
        
        sorted_factors = sorted(valid_factors.items(), key=lambda x: abs(x[1]), reverse=True)[:3]
        
        top_factors = []
        for factor, value in sorted_factors:
            impact = "يزيد الخطر" if value > 0 else "يقلل الخطر"
            strength = abs(value)
            
            if strength > 0.5:
                level = "قوي جداً"
            elif strength > 0.3:
                level = "قوي"
            elif strength > 0.15:
                level = "متوسط"
            else:
                level = "ضعيف"
            
            top_factors.append({
                "name": self._translate_feature(factor),
                "impact": impact,
                "strength": f"{strength:.3f}",
                "level": level
            })
        
        return top_factors

# إنشاء نسخة واحدة من الخدمة (Singleton)
prediction_service = PredictionService()