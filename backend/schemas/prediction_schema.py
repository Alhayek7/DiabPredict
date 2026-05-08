from pydantic import BaseModel, Field
from typing import Optional, List, Dict
from datetime import datetime

class HealthData(BaseModel):
    """البيانات الصحية المدخلة من المستخدم"""
    age: int = Field(..., ge=0, le=120, description="العمر بالسنوات")
    bmi: float = Field(..., ge=10, le=50, description="مؤشر كتلة الجسم")
    hba1c: float = Field(..., ge=4, le=15, description="نسبة السكر التراكمي HbA1c")
    glucose: float = Field(..., ge=50, le=400, description="نسبة السكر في الدم")
    blood_pressure_systolic: float = Field(..., ge=80, le=200, description="الضغط الانقباضي")
    blood_pressure_diastolic: float = Field(..., ge=50, le=130, description="الضغط الانبساطي")
    cholesterol: float = Field(..., ge=100, le=400, description="نسبة الكوليسترول")
    family_history: int = Field(..., ge=0, le=1, description="تاريخ عائلي (0=لا, 1=نعم)")
    smoking: int = Field(..., ge=0, le=2, description="التدخين (0=لا, 1=سابق, 2=حالي)")
    physical_activity: int = Field(..., ge=0, le=2, description="النشاط البدني (0=قليل, 1=متوسط, 2=كثير)")
    
    class Config:
        json_schema_extra = {
            "example": {
                "age": 45,
                "bmi": 28.5,
                "hba1c": 6.8,
                "glucose": 135,
                "blood_pressure_systolic": 125,
                "blood_pressure_diastolic": 85,
                "cholesterol": 220,
                "family_history": 1,
                "smoking": 1,
                "physical_activity": 1
            }
        }

# ✅ أضف هذا الكلاس الجديد
class TopFactor(BaseModel):
    """عامل مؤثر في التنبؤ"""
    name: str = Field(..., description="اسم العامل")
    impact: str = Field(..., description="نوع التأثير: يزيد الخطر / يقلل الخطر")
    level: str = Field(..., description="قوة التأثير: قوي / متوسط / ضعيف")
    strength: str = Field(..., description="قيمة التأثير (كنص)")

class PredictionResponse(BaseModel):
    """استجابة التنبؤ"""
    risk_percentage: float = Field(..., description="نسبة الخطر (%)")
    risk_level: str = Field(..., description="مستوى الخطر: منخفض/متوسط/مرتفع")
    probability: float = Field(..., description="احتمالية الإصابة")
    recommendation: str = Field(..., description="توصية مختصرة")
    shap_values: Dict[str, float] = Field(..., description="قيم SHAP لكل عامل")
    top_factors: List[TopFactor] = Field(..., description="أهم العوامل المؤثرة")  # ✅ تم التعديل
    timestamp: str = Field(..., description="وقت التنبؤ")

class AssistantRequest(BaseModel):
    """طلب للمساعد الذكي"""
    risk_percentage: float
    shap_values: Dict[str, float]
    health_data: HealthData
    question: Optional[str] = None

class AssistantResponse(BaseModel):
    """استجابة المساعد الذكي"""
    response: str
    suggestions: List[str]