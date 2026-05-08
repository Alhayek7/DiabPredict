import pandas as pd
import numpy as np
import joblib
import xgboost as xgb
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score
import shap
import warnings
warnings.filterwarnings('ignore')

print("📊 Generating sample data...")

# إنشاء بيانات تجريبية (نموذجية)
np.random.seed(42)
n_samples = 10000

# إنشاء البيانات
data = {
    'age': np.random.randint(18, 90, n_samples),
    'bmi': np.random.uniform(15, 45, n_samples),
    'hba1c': np.random.uniform(4, 12, n_samples),
    'glucose': np.random.uniform(70, 300, n_samples),
    'blood_pressure_systolic': np.random.uniform(90, 180, n_samples),
    'blood_pressure_diastolic': np.random.uniform(60, 120, n_samples),
    'cholesterol': np.random.uniform(120, 300, n_samples),
    'family_history': np.random.choice([0, 1], n_samples, p=[0.7, 0.3]),
    'smoking': np.random.choice([0, 1, 2], n_samples, p=[0.6, 0.3, 0.1]),
    'physical_activity': np.random.choice([0, 1, 2], n_samples, p=[0.4, 0.4, 0.2])
}

df = pd.DataFrame(data)

# إنشاء الهدف (diabetes) بناءً على علاقات منطقية
risk_score = (
    (df['hba1c'] > 6.5) * 3 +
    (df['glucose'] > 126) * 2 +
    (df['bmi'] > 30) * 1.5 +
    (df['age'] > 45) * 1 +
    (df['family_history'] == 1) * 1.5 +
    (df['smoking'] > 0) * 0.5 +
    (df['physical_activity'] == 0) * 0.5
)

df['diabetes'] = (risk_score > 3.5).astype(int)

print(f"✅ Dataset shape: {df.shape}")
print(f"✅ Diabetes rate: {df['diabetes'].mean():.2%}")

# فصل الميزات والهدف
feature_columns = ['age', 'bmi', 'hba1c', 'glucose', 'blood_pressure_systolic', 
                   'blood_pressure_diastolic', 'cholesterol', 'family_history', 
                   'smoking', 'physical_activity']

X = df[feature_columns]
y = df['diabetes']

# تقسيم البيانات
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

# تطبيع البيانات
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# حساب scale_pos_weight
scale_pos_weight = len(y_train[y_train==0]) / len(y_train[y_train==1])

print("\n🚀 Training XGBoost model...")

# تدريب النموذج
model = xgb.XGBClassifier(
    n_estimators=100,
    max_depth=5,
    learning_rate=0.1,
    subsample=0.8,
    colsample_bytree=0.8,
    scale_pos_weight=scale_pos_weight,
    random_state=42,
    eval_metric='logloss',
    use_label_encoder=False
)

model.fit(X_train_scaled, y_train)

# التقييم
y_pred = model.predict(X_test_scaled)
y_pred_proba = model.predict_proba(X_test_scaled)[:, 1]

print("\n📈 Model Performance:")
print(f"Accuracy:  {accuracy_score(y_test, y_pred):.4f}")
print(f"Precision: {precision_score(y_test, y_pred):.4f}")
print(f"Recall:    {recall_score(y_test, y_pred):.4f}")
print(f"F1-Score:  {f1_score(y_test, y_pred):.4f}")
print(f"AUC-ROC:   {roc_auc_score(y_test, y_pred_proba):.4f}")

# حساب SHAP values
print("\n🔮 Computing SHAP values...")
explainer = shap.TreeExplainer(model)
# نأخذ عينة صغيرة لحساب SHAP
shap_values = explainer.shap_values(X_test_scaled[:100])

# إنشاء مجلد models إذا لم يكن موجوداً
import os
os.makedirs("models", exist_ok=True)

# حفظ النماذج
print("\n💾 Saving models...")
joblib.dump(model, "models/xgb_model.pkl")
joblib.dump(scaler, "models/scaler.pkl")
joblib.dump(explainer, "models/shap_explainer.pkl")
joblib.dump(feature_columns, "models/feature_names.pkl")

print("\n✅ Models saved successfully!")
print("📁 Saved files in 'models/' folder:")
print("   - xgb_model.pkl")
print("   - scaler.pkl")
print("   - shap_explainer.pkl")
print("   - feature_names.pkl")

# عرض أهم الميزات
importance_dict = dict(zip(feature_columns, model.feature_importances_))
sorted_importance = sorted(importance_dict.items(), key=lambda x: x[1], reverse=True)
print("\n📊 Feature Importance:")
for feature, importance in sorted_importance:
    print(f"   {feature}: {importance:.4f}")