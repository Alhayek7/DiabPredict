from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime
from typing import Dict
import uvicorn

from schemas.prediction_schema import HealthData, PredictionResponse, AssistantRequest, AssistantResponse
from services.prediction_service import prediction_service
from services.gemini_service import gemini_service

# إنشاء تطبيق FastAPI
app = FastAPI(
    title="Diabetes Prediction API",
    description="نظام ذكي للتنبؤ المبكر بخطر مرض السكري",
    version="1.0.0"
)

# إعداد CORS للسماح بالاتصال من Flutter و Streamlit
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # في الإنتاج، حدد العناوين المحددة
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {
        "message": "Diabetes Prediction API",
        "status": "running",
        "version": "1.0.0"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.post("/predict", response_model=PredictionResponse)
async def predict(data: HealthData):
    """
    التنبؤ بخطر الإصابة بمرض السكري
    """
    try:
        # تحويل البيانات إلى قاموس
        data_dict = data.dict()
        
        # إجراء التنبؤ
        risk_percentage, probability, shap_values = prediction_service.predict(data_dict)
        
        # تحديد مستوى الخطر
        risk_level = prediction_service.get_risk_level(risk_percentage)
        
        # الحصول على التوصية
        recommendation = prediction_service.get_recommendation(risk_percentage, shap_values)
        
        # الحصول على أهم العوامل المؤثرة
        top_factors = prediction_service.get_top_factors(shap_values)
        
        return PredictionResponse(
            risk_percentage=round(risk_percentage, 2),
            risk_level=risk_level,
            probability=round(probability, 4),
            recommendation=recommendation,
            shap_values=shap_values,
            top_factors=top_factors,
            timestamp=datetime.now().isoformat()
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")

@app.post("/assistant", response_model=AssistantResponse)
async def get_assistant_response(request: AssistantRequest):
    """
    الحصول على نصائح من المساعد الذكي
    """
    try:
        health_data_dict = request.health_data.dict()
        
        response_data = gemini_service.get_health_advice(
            risk_percentage=request.risk_percentage,
            shap_values=request.shap_values,
            health_data=health_data_dict,
            user_question=request.question
        )
        
        return AssistantResponse(
            response=response_data["response"],
            suggestions=response_data["suggestions"]
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Assistant error: {str(e)}")

@app.post("/simulate")
async def simulate_scenario(data: HealthData, changes: Dict[str, float]):
    """
    محاكاة سيناريو "ماذا لو" - تغيير عامل معين وحساب الفرق
    """
    try:
        original_risk, _, original_shap = prediction_service.predict(data.dict())
        
        # تطبيق التغييرات
        modified_data = data.dict()
        for key, value in changes.items():
            if key in modified_data:
                modified_data[key] = modified_data[key] + value
        
        new_risk, _, new_shap = prediction_service.predict(modified_data)
        
        risk_change = new_risk - original_risk
        
        return {
            "original_risk": round(original_risk, 2),
            "new_risk": round(new_risk, 2),
            "risk_change": round(risk_change, 2),
            "improvement": risk_change < 0,
            "message": f"انخفضت نسبة الخطر بنسبة {abs(risk_change):.1f}%" if risk_change < 0 else f"ارتفعت نسبة الخطر بنسبة {risk_change:.1f}%"
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Simulation error: {str(e)}")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)