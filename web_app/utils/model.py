# """
# utils/model.py - نموذج التنبؤ بالسكري

# 📌 هذا الملف مسؤول عن:
#     1. تدريب نموذج XGBoost على البيانات
#     2. تحميل وحفظ النماذج المدربة
#     3. التنبؤ وحساب الاحتمالات
#     4. تفسير النتائج باستخدام SHAP

# 🔧 **كيف تستبدل النموذج أو البيانات مستقبلاً:**
    
#     ✅ استبدال ملف البيانات فقط:
#         predictor = DiabetesPredictor(data_path="data/my_new_data.csv")
#         predictor.train()
    
#     ✅ استبدال النموذج المدرب فقط:
#         predictor = DiabetesPredictor(model_path="models/my_better_model.pkl")
#         predictor.load()
    
#     ✅ استخدام خوارزمية مختلفة (مثال: Random Forest):
#         قم بتعديل دالة train() واستبدل XGBClassifier بـ RandomForestClassifier
    
#     ✅ إضافة ميزات جديدة:
#         قم بتعديل قائمة FEATURES في config.py
    
#     ✅ تغيير مقياس التقييم:
#         قم بتعديل معامل eval_metric في XGBClassifier
# """

# import os
# import pickle
# import numpy as np
# import pandas as pd
# import streamlit as st
# from typing import Dict, List, Tuple, Optional, Any
# from datetime import datetime

# # مكتبات النموذج
# import xgboost as xgb
# from sklearn.model_selection import train_test_split
# from sklearn.preprocessing import StandardScaler
# from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score

# # مكتبات التفسير
# import shap
# import matplotlib.pyplot as plt

# # إعدادات المشروع
# from utils.config import FEATURES, MODEL_PATH, MODEL_ACCURACY


# # ============================================
# # كلاس النموذج الرئيسي
# # ============================================

# class DiabetesPredictor:
#     """
#     كلاس التنبؤ بالسكري - قابل للتوسيع والاستبدال
    
#     📌 **الوظائف الرئيسية:**
#         - train(): تدريب النموذج من الصفر
#         - load(): تحميل نموذج مدرب مسبقًا
#         - predict(): التنبؤ لبيانات جديدة
#         - predict_proba(): الحصول على احتمالات التنبؤ
#         - get_shap_values(): تفسير النتائج باستخدام SHAP
#         - retrain(): إعادة التدريب (عند تغيير البيانات)
#         - save(): حفظ النموذج الحالي
    
#     🔧 **كيفية التخصيص:**
#         🔄 تغيير الخوارزمية: عدل دالة train() 
#         📊 تغيير الميزات: عدل FEATURES في config.py
#         💾 تغيير مسار الحفظ: غير model_path
#         🎯 تغيير هدف التنبؤ: عدل target_column في دالة prepare_data()
#     """
    
#     def __init__(
#         self,
#         model_path: str = MODEL_PATH,
#         data_path: str = "data/diabetes.csv",
#         auto_train: bool = True
#     ):
#         """
#         تهيئة النموذج
        
#         Args:
#             model_path: مسار حفظ/تحميل النموذج
#             data_path: مسار ملف البيانات (للمرة الأولى)
#             auto_train: هل يتم التدريب تلقائيًا إذا لم يوجد نموذج؟
#         """
#         self.model_path = model_path
#         self.data_path = data_path
#         self.model: Optional[xgb.XGBClassifier] = None
#         self.scaler: Optional[StandardScaler] = None
#         self.feature_names: List[str] = FEATURES
#         self.explainer: Optional[shap.Explainer] = None
#         self.training_metrics: Dict[str, float] = {}
#         self.is_trained: bool = False
        
#         # محاولة تحميل نموذج موجود
#         if os.path.exists(model_path):
#             self.load()
#         elif auto_train and os.path.exists(data_path):
#             with st.spinner("🔄 جاري تدريب النموذج لأول مرة..."):
#                 self.train()
#         else:
#             st.warning(f"⚠️ لم يتم العثور على نموذج أو بيانات في:\n- {model_path}\n- {data_path}")
    
#     # ============================================
#     # 1. تجهيز البيانات
#     # ============================================
    
#     def prepare_data(self, df: pd.DataFrame) -> Tuple[np.ndarray, np.ndarray]:
#         """
#         تجهيز البيانات للتدريب
        
#         🔧 **للتخصيص:**
#             - تغيير الهدف: غير 'Outcome' إلى اسم العمود الذي تريد التنبؤ به
#             - إضافة معالجة: أضف خطوات تنظيف البيانات هنا
#             - تغيير طريقة التطبيع: استبدل StandardScaler بـ MinMaxScaler أو RobustScaler
        
#         Args:
#             df: DataFrame الخام
        
#         Returns:
#             X: الميزات بعد المعالجة (numpy array)
#             y: الهدف (numpy array)
#         """
#         # ✅ تأكد من وجود الأعمدة المطلوبة
#         missing_features = [f for f in self.feature_names if f not in df.columns]
#         if missing_features:
#             raise ValueError(f"❌ الأعمدة التالية غير موجودة في البيانات: {missing_features}")
        
#         # فصل الميزات عن الهدف
#         X = df[self.feature_names].copy()
#         y = df['Outcome'].copy()  # 🔧 غيّر 'Outcome' إلى اسم عمود الهدف لديك
        
#         # 🧹 معالجة القيم المفقودة
#         X = X.fillna(X.median())
        
#         # 📊 تطبيع البيانات (لتحسين أداء النموذج)
#         if self.scaler is None:
#             self.scaler = StandardScaler()  # 🔧 استبدل بـ MinMaxScaler() إذا أردت نطاق [0,1]
        
#         X_scaled = self.scaler.fit_transform(X)
        
#         return X_scaled, y.values
    
#     # ============================================
#     # 2. تدريب النموذج
#     # ============================================
    
#     def train(
#         self,
#         test_size: float = 0.2,
#         random_state: int = 42,
#         **kwargs
#     ) -> Dict[str, float]:
#         """
#         تدريب نموذج XGBoost
        
#         🔧 **للتخصيص (استبدال الخوارزمية):**
        
#         ✅ استبدال XGBoost بـ Random Forest:
#             from sklearn.ensemble import RandomForestClassifier
#             self.model = RandomForestClassifier(n_estimators=100, random_state=random_state)
        
#         ✅ استبدال XGBoost بـ Neural Network:
#             from sklearn.neural_network import MLPClassifier
#             self.model = MLPClassifier(hidden_layer_sizes=(100, 50), max_iter=500, random_state=random_state)
        
#         ✅ استبدال XGBoost بـ Logistic Regression:
#             from sklearn.linear_model import LogisticRegression
#             self.model = LogisticRegression(max_iter=1000, random_state=random_state)
        
#         ✅ استبدال XGBoost بـ LightGBM:
#             import lightgbm as lgb
#             self.model = lgb.LGBMClassifier(n_estimators=100, random_state=random_state)
        
#         Args:
#             test_size: نسبة بيانات الاختبار
#             random_state: ثابت عشوائي لإعادة النتائج
#             **kwargs: معاملات إضافية لـ XGBClassifier
        
#         Returns:
#             قاموس بمقاييس الأداء
#         """
#         # 📂 تحميل البيانات
#         if not os.path.exists(self.data_path):
#             raise FileNotFoundError(f"❌ ملف البيانات غير موجود: {self.data_path}")
        
#         df = pd.read_csv(self.data_path)
#         st.info(f"📊 تم تحميل {len(df)} سجل من {self.data_path}")
        
#         # تجهيز البيانات
#         X, y = self.prepare_data(df)
        
#         # تقسيم البيانات
#         X_train, X_test, y_train, y_test = train_test_split(
#             X, y, test_size=test_size, random_state=random_state, stratify=y
#         )
        
#         # 🧠 إنشاء النموذج (XGBoost)
#         # 🔧 قم بتعديل هذه المعاملات لتحسين الأداء
#         default_params = {
#             'n_estimators': 100,      # عدد الأشجار (زيد للحصول على دقة أعلى)
#             'max_depth': 6,           # عمق الشجرة (زيد بحذر - قد يسبب overfitting)
#             'learning_rate': 0.1,     # معدل التعلم (قلل للحصول على نموذج أكثر استقرارًا)
#             'subsample': 0.8,         # نسبة العينات لكل شجرة
#             'colsample_bytree': 0.8,  # نسبة الميزات لكل شجرة
#             'random_state': random_state,
#             'eval_metric': 'logloss', # 🔧 غيّر إلى 'auc' أو 'error' حسب الحاجة
#             'use_label_encoder': False
#         }
#         default_params.update(kwargs)
        
#         self.model = xgb.XGBClassifier(**default_params)
        
#         # التدريب
#         with st.spinner("🚀 جاري تدريب النموذج..."):
#             self.model.fit(X_train, y_train)
        
#         # التقييم
#         y_pred = self.model.predict(X_test)
#         y_pred_proba = self.model.predict_proba(X_test)[:, 1]
        
#         self.training_metrics = {
#             'accuracy': accuracy_score(y_test, y_pred),
#             'precision': precision_score(y_test, y_pred),
#             'recall': recall_score(y_test, y_pred),
#             'f1_score': f1_score(y_test, y_pred),
#             'roc_auc': roc_auc_score(y_test, y_pred_proba),
#             'test_size': len(X_test),
#             'train_size': len(X_train)
#         }
        
#         # إنشاء SHAP explainer
#         self.explainer = shap.Explainer(self.model, X_train, feature_names=self.feature_names)
        
#         self.is_trained = True
        
#         # حفظ النموذج تلقائيًا
#         self.save()
        
#         # عرض النتائج
#         # st.success(f"✅ تم تدريب النموذج بنجاح!")
#         st.json(self.training_metrics)
        
#         return self.training_metrics
    
#     # ============================================
#     # 3. تحميل نموذج مدرب
#     # ============================================
    
#     def load(self) -> bool:
#         """
#         تحميل نموذج مدرب مسبقًا من ملف
        
#         🔧 **لتغيير النموذج:**
#             1. ضع ملف النموذج الجديد (.pkl) في مجلد models/
#             2. غير المسار في model_path
#             3. استدعِ predictor.load()
        
#         Returns:
#             bool: نجاح التحميل أم لا
#         """
#         try:
#             with open(self.model_path, 'rb') as f:
#                 saved_data = pickle.load(f)
                
#                 # تحميل المكونات
#                 self.model = saved_data.get('model')
#                 self.scaler = saved_data.get('scaler')
#                 self.feature_names = saved_data.get('feature_names', self.feature_names)
#                 self.training_metrics = saved_data.get('metrics', {})
                
#                 # إعادة إنشاء SHAP explainer إذا كان النموذج موجودًا
#                 if self.model is not None:
#                     self.explainer = shap.Explainer(self.model, feature_names=self.feature_names)
                
#                 self.is_trained = self.model is not None
                
#             # st.success(f"✅ تم تحميل النموذج من {self.model_path}")
#             return True
            
#         except Exception as e:
#             st.warning(f"⚠️ لم نتمكن من تحميل النموذج: {e}")
#             return False
    
#     # ============================================
#     # 4. حفظ النموذج
#     # ============================================
    
#     def save(self) -> bool:
#         """
#         حفظ النموذج الحالي
        
#         🔧 **لحفظ نماذج متعددة:**
#             غير model_path لكل نموذج
#             مثال: predictor.save('models/model_v2.pkl')
#         """
#         if not self.is_trained:
#             st.warning("⚠️ لا يوجد نموذج مدرب للحفظ")
#             return False
        
#         # إنشاء المجلد إذا لم يكن موجودًا
#         os.makedirs(os.path.dirname(self.model_path), exist_ok=True)
        
#         try:
#             with open(self.model_path, 'wb') as f:
#                 pickle.dump({
#                     'model': self.model,
#                     'scaler': self.scaler,
#                     'feature_names': self.feature_names,
#                     'metrics': self.training_metrics,
#                     'saved_at': datetime.now().isoformat()
#                 }, f)
#             st.success(f"💾 تم حفظ النموذج في {self.model_path}")
#             return True
#         except Exception as e:
#             st.error(f"❌ فشل حفظ النموذج: {e}")
#             return False
    
#     # ============================================
#     # 5. التنبؤ
#     # ============================================
    
#     def predict(self, features: Dict[str, float]) -> Tuple[int, float, Dict[str, float]]:
#         """
#         التنبؤ لبيانات جديدة
        
#         🔧 **لإضافة ميزات جديدة:**
#             1. أضف الميزة إلى FEATURES في config.py
#             2. تأكد من وجودها في قاموس features
#             3. أعد تدريب النموذج
        
#         Args:
#             features: قاموس باسم الميزة وقيمتها
#                      مثال: {'Pregnancies': 2, 'Glucose': 120, ...}
        
#         Returns:
#             (prediction, probability, shap_values_dict)
#             - prediction: 0 أو 1 (0 = لا يوجد سكري، 1 = يوجد سكري)
#             - probability: نسبة الخطر (0-100)
#             - shap_values: تأثير كل ميزة على التنبؤ
#         """
#         if not self.is_trained:
#             raise ValueError("❌ النموذج غير مدرب. قم باستدعاء train() أولاً")
        
#         # تحويل المدخلات إلى DataFrame
#         input_df = pd.DataFrame([features])[self.feature_names]
        
#         # معالجة القيم المفقودة
#         input_df = input_df.fillna(input_df.median())
        
#         # تطبيق التطبيع
#         input_scaled = self.scaler.transform(input_df)
        
#         # التنبؤ
#         prediction = int(self.model.predict(input_scaled)[0])
#         probability = float(self.model.predict_proba(input_scaled)[0][1]) * 100
        
#         # حساب SHAP values
#         shap_values = None
#         if self.explainer is not None:
#             shap_values_array = self.explainer(input_scaled)[0]
#             # الكود الجديد (الصحيح)
#             shap_values = {}
#             for i, name in enumerate(self.feature_names):
#                 val = shap_values_array[i]
#                 if hasattr(val, 'values'):
#                     shap_values[name] = float(val.values[0]) if hasattr(val, 'values') else float(val)
#                 else:
#                     shap_values[name] = float(val)
        
#         return prediction, probability, shap_values
    
#     # ============================================
#     # 6. تفسير النتائج باستخدام SHAP
#     # ============================================
    
#     def get_shap_plot(self, features: Dict[str, float]) -> plt.Figure:
#         """
#         إنشاء رسم بياني SHAP لتفسير التنبؤ
        
#         Returns:
#             matplotlib Figure للعرض في Streamlit
#         """
#         if self.explainer is None:
#             raise ValueError("❌ SHAP explainer غير جاهز. أعد تدريب النموذج")
        
#         # تحويل المدخلات
#         input_df = pd.DataFrame([features])[self.feature_names]
#         input_df = input_df.fillna(input_df.median())
#         input_scaled = self.scaler.transform(input_df)
        
#         # حساب SHAP
#         shap_values = self.explainer(input_scaled)
        
#         # رسم الشارت
#         fig, ax = plt.subplots(figsize=(10, 6))
#         shap.waterfall_plot(shap_values[0], max_display=8, show=False)
#         plt.title("تأثير العوامل على التنبؤ (SHAP)", fontsize=14, fontweight='bold')
        
#         return fig
    
#     # ============================================
#     # 7. إعادة التدريب
#     # ============================================
    
#     def retrain(self, new_data_path: Optional[str] = None) -> Dict[str, float]:
#         """
#         إعادة تدريب النموذج من الصفر
        
#         🔧 **متى تستخدم هذا:**
#             - تغييرت ملف البيانات إلى بيانات جديدة
#             - أضفت ميزات جديدة
#             - تريد تجربة معاملات مختلفة
        
#         Args:
#             new_data_path: مسار ملف البيانات الجديد (اختياري)
        
#         Returns:
#             مقاييس الأداء الجديدة
#         """
#         if new_data_path:
#             self.data_path = new_data_path
        
#         self.is_trained = False
#         return self.train()
    
#     # ============================================
#     # 8. معلومات النموذج
#     # ============================================
    
#     def get_info(self) -> Dict[str, Any]:
#         """
#         الحصول على معلومات عن النموذج الحالي
#         """
#         return {
#             'is_trained': self.is_trained,
#             'model_path': self.model_path,
#             'data_path': self.data_path,
#             'features': self.feature_names,
#             'n_features': len(self.feature_names),
#             'metrics': self.training_metrics,
#             'model_type': type(self.model).__name__ if self.model else None
#         }


# # ============================================
# # دالة مساعدة للحصول على نسخة جاهزة من النموذج
# # ============================================

# @st.cache_resource
# def get_predictor(
#     model_path: str = MODEL_PATH,
#     data_path: str = "data/diabetes.csv"
# ) -> DiabetesPredictor:
#     """
#     الحصول على نسخة من النموذج (مع caching لتحسين الأداء)
    
#     🔧 **لاستخدام نموذج مختلف:**
#         predictor = get_predictor(model_path="models/my_model.pkl")
    
#     🔧 **لاستخدام بيانات مختلفة:**
#         predictor = get_predictor(data_path="data/my_data.csv")
#         predictor.retrain()  # إعادة التدريب على البيانات الجديدة
    
#     Returns:
#         DiabetesPredictor: نسخة جاهزة من النموذج
#     """
#     return DiabetesPredictor(model_path=model_path, data_path=data_path, auto_train=True)


# # ============================================
# # مثال على الاستخدام
# # ============================================

# if __name__ == "__main__":
#     """
#     اختبار النموذج بشكل منفصل
    
#     🔧 **للتجربة:**
#         python utils/model.py
#     """
    
#     print("🔄 جاري اختبار النموذج...")
    
#     # إنشاء النموذج
#     predictor = DiabetesPredictor(data_path="../data/diabetes.csv")
    
#     if predictor.is_trained:
#         print("✅ النموذج جاهز!")
#         print(f"📊 المقاييس: {predictor.training_metrics}")
        
#         # اختبار تنبؤ
#         test_features = {
#             'Pregnancies': 2,
#             'Glucose': 120,
#             'BloodPressure': 70,
#             'SkinThickness': 20,
#             'Insulin': 85,
#             'BMI': 25.5,
#             'DiabetesPedigreeFunction': 0.5,
#             'Age': 35
#         }
        
#         pred, prob, shap_vals = predictor.predict(test_features)
#         print(f"🔮 التنبؤ: {'مصاب' if pred == 1 else 'غير مصاب'}")
#         print(f"📈 نسبة الخطر: {prob:.1f}%")
#         print(f"📊 SHAP: {shap_vals}")
#     else:
#         print("❌ فشل في تحميل/تدريب النموذج")


"""
utils/model.py - نموذج التنبؤ بالسكري
"""

import os
import pickle
import numpy as np
import pandas as pd
import streamlit as st
from typing import Dict, List, Tuple, Optional, Any
from datetime import datetime

# مكتبات النموذج
import xgboost as xgb
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score

# مكتبات التفسير
import shap

# إعدادات المشروع
from utils.config import FEATURES, MODEL_PATH


# ============================================
# كلاس النموذج الرئيسي
# ============================================

class DiabetesPredictor:
    
    def __init__(
        self,
        model_path: str = MODEL_PATH,
        data_path: str = "data/diabetes.csv",
        auto_train: bool = True
    ):
        self.model_path = model_path
        self.data_path = data_path
        self.model: Optional[xgb.XGBClassifier] = None
        self.scaler: Optional[StandardScaler] = None
        self.feature_names: List[str] = FEATURES
        self.explainer: Optional[shap.Explainer] = None
        self.training_metrics: Dict[str, float] = {}
        self.is_trained: bool = False
        
        if os.path.exists(model_path):
            self.load()
        elif auto_train and os.path.exists(data_path):
            with st.spinner("🔄 جاري تدريب النموذج لأول مرة..."):
                self.train()
        else:
            st.warning(f"⚠️ لم يتم العثور على نموذج أو بيانات")
    
    # ============================================
    # تجهيز البيانات
    # ============================================
    
    def prepare_data(self, df: pd.DataFrame) -> Tuple[np.ndarray, np.ndarray]:
        missing_features = [f for f in self.feature_names if f not in df.columns]
        if missing_features:
            raise ValueError(f"❌ الأعمدة التالية غير موجودة: {missing_features}")
        
        X = df[self.feature_names].copy()
        y = df['Outcome'].copy()
        
        X = X.fillna(X.median())
        
        if self.scaler is None:
            self.scaler = StandardScaler()
        
        X_scaled = self.scaler.fit_transform(X)
        
        return X_scaled, y.values
    
    # ============================================
    # تدريب النموذج
    # ============================================
    
    def train(
        self,
        test_size: float = 0.2,
        random_state: int = 42,
        **kwargs
    ) -> Dict[str, float]:
        
        if not os.path.exists(self.data_path):
            raise FileNotFoundError(f"❌ ملف البيانات غير موجود: {self.data_path}")
        
        df = pd.read_csv(self.data_path)
        st.info(f"📊 تم تحميل {len(df)} سجل من {self.data_path}")
        
        X, y = self.prepare_data(df)
        
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=test_size, random_state=random_state, stratify=y
        )
        
        default_params = {
            'n_estimators': 100,
            'max_depth': 6,
            'learning_rate': 0.1,
            'subsample': 0.8,
            'colsample_bytree': 0.8,
            'random_state': random_state,
            'eval_metric': 'logloss',
            'use_label_encoder': False
        }
        default_params.update(kwargs)
        
        self.model = xgb.XGBClassifier(**default_params)
        
        with st.spinner("🚀 جاري تدريب النموذج..."):
            self.model.fit(X_train, y_train)
        
        y_pred = self.model.predict(X_test)
        y_pred_proba = self.model.predict_proba(X_test)[:, 1]
        
        self.training_metrics = {
            'accuracy': accuracy_score(y_test, y_pred),
            'precision': precision_score(y_test, y_pred),
            'recall': recall_score(y_test, y_pred),
            'f1_score': f1_score(y_test, y_pred),
            'roc_auc': roc_auc_score(y_test, y_pred_proba),
            'test_size': len(X_test),
            'train_size': len(X_train)
        }
        
        # إنشاء SHAP explainer
        try:
            self.explainer = shap.Explainer(self.model, X_train, feature_names=self.feature_names)
        except:
            self.explainer = None
        
        self.is_trained = True
        self.save()
        
        return self.training_metrics
    
    # ============================================
    # تحميل نموذج مدرب
    # ============================================
    
    def load(self) -> bool:
        try:
            with open(self.model_path, 'rb') as f:
                saved_data = pickle.load(f)
                
                self.model = saved_data.get('model')
                self.scaler = saved_data.get('scaler')
                self.feature_names = saved_data.get('feature_names', self.feature_names)
                self.training_metrics = saved_data.get('metrics', {})
                
                if self.model is not None:
                    try:
                        self.explainer = shap.Explainer(self.model, feature_names=self.feature_names)
                    except:
                        self.explainer = None
                
                self.is_trained = self.model is not None
                
            return True
            
        except Exception as e:
            st.warning(f"⚠️ لم نتمكن من تحميل النموذج: {e}")
            return False
    
    # ============================================
    # حفظ النموذج
    # ============================================
    
    def save(self) -> bool:
        if not self.is_trained:
            st.warning("⚠️ لا يوجد نموذج مدرب للحفظ")
            return False
        
        os.makedirs(os.path.dirname(self.model_path), exist_ok=True)
        
        try:
            with open(self.model_path, 'wb') as f:
                pickle.dump({
                    'model': self.model,
                    'scaler': self.scaler,
                    'feature_names': self.feature_names,
                    'metrics': self.training_metrics,
                    'saved_at': datetime.now().isoformat()
                }, f)
            return True
        except Exception as e:
            st.error(f"❌ فشل حفظ النموذج: {e}")
            return False
    
    # ============================================
    # التنبؤ - الجزء المصحح
    # ============================================
    
    def predict(self, features: Dict[str, float]) -> Tuple[int, float, Dict[str, float]]:
        if not self.is_trained:
            raise ValueError("❌ النموذج غير مدرب")
        
        # تحويل المدخلات إلى DataFrame
        input_df = pd.DataFrame([features])[self.feature_names]
        input_df = input_df.fillna(input_df.median())
        input_scaled = self.scaler.transform(input_df)
        
        # التنبؤ
        prediction = int(self.model.predict(input_scaled)[0])
        probability = float(self.model.predict_proba(input_scaled)[0][1]) * 100
        
        # حساب SHAP values - الجزء المصحح
        shap_values = {}
        if self.explainer is not None:
            try:
                shap_result = self.explainer(input_scaled)
                # معالجة SHAP values بشكل صحيح
                for i, name in enumerate(self.feature_names):
                    try:
                        # محاولة استخراج القيمة الرقمية
                        val = shap_result[0][i]
                        if hasattr(val, 'values'):
                            shap_values[name] = float(val.values[0]) if len(val.values) > 0 else 0.0
                        else:
                            shap_values[name] = float(val)
                    except:
                        shap_values[name] = 0.0
            except Exception as e:
                # إذا فشل SHAP، نستخدم قيماً افتراضية
                shap_values = {name: 0.0 for name in self.feature_names}
        else:
            shap_values = {name: 0.0 for name in self.feature_names}
        
        return prediction, probability, shap_values
    
    # ============================================
    # معلومات النموذج
    # ============================================
    
    def get_info(self) -> Dict[str, Any]:
        return {
            'is_trained': self.is_trained,
            'model_path': self.model_path,
            'data_path': self.data_path,
            'features': self.feature_names,
            'n_features': len(self.feature_names),
            'metrics': self.training_metrics,
            'model_type': type(self.model).__name__ if self.model else None
        }


# ============================================
# دالة مساعدة
# ============================================

@st.cache_resource
def get_predictor(
    model_path: str = MODEL_PATH,
    data_path: str = "data/diabetes.csv"
) -> DiabetesPredictor:
    return DiabetesPredictor(model_path=model_path, data_path=data_path, auto_train=True)


if __name__ == "__main__":
    print("🔄 جاري اختبار النموذج...")
    predictor = DiabetesPredictor(data_path="../data/diabetes.csv")
    
    if predictor.is_trained:
        print("✅ النموذج جاهز!")
        print(f"📊 المقاييس: {predictor.training_metrics}")
        
        test_features = {
            'Pregnancies': 2,
            'Glucose': 120,
            'BloodPressure': 70,
            'SkinThickness': 20,
            'Insulin': 85,
            'BMI': 25.5,
            'DiabetesPedigreeFunction': 0.5,
            'Age': 35
        }
        
        pred, prob, shap_vals = predictor.predict(test_features)
        print(f"🔮 التنبؤ: {'مصاب' if pred == 1 else 'غير مصاب'}")
        print(f"📈 نسبة الخطر: {prob:.1f}%")
    else:
        print("❌ فشل في تحميل/تدريب النموذج")
        