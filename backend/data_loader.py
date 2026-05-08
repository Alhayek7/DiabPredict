import pandas as pd
import numpy as np
from sklearn.datasets import make_classification

def generate_diabetes_data(n_samples=100000):
    """
    إنشاء بيانات تجريبية تحاكي بيانات مرض السكري
    في الحقيقة، يفضل استخدام BRFSS أو PIMA dataset
    """
    np.random.seed(42)
    
    # العوامل المؤثرة في السكري
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
    
    # إنشاء الهدف بناءً على العلاقات المنطقية
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
    
    return df

if __name__ == "__main__":
    df = generate_diabetes_data(100000)
    print(f"Shape: {df.shape}")
    print(f"Diabetes rate: {df['diabetes'].mean():.2%}")
    df.to_csv("E:/Graduation_project/data/diabetes_dataset.csv", index=False)
    print("Dataset saved!")