import requests
import streamlit as st
import os
from dotenv import load_dotenv
from typing import Optional, Dict, Any

load_dotenv()

API_URL = os.getenv("API_URL", "http://localhost:8000")


class APIClient:
    def __init__(self):
        self.base_url = API_URL

    def check_health(self) -> bool:
        """فحص صحة الخادم"""
        try:
            response = requests.get(f"{self.base_url}/health", timeout=5)
            return response.status_code == 200
        except:
            return False

    def predict(self, data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """إرسال طلب تنبؤ"""
        try:
            response = requests.post(
                f"{self.base_url}/predict",
                json=data,
                timeout=30
            )
            if response.status_code == 200:
                return response.json()
            else:
                return None
        except Exception as e:
            print(f"Prediction error: {e}")
            return None

    def get_assistant_advice(
        self, 
        risk_percentage: float, 
        shap_values: Dict, 
        health_data: Dict, 
        question: Optional[str] = None
    ) -> Optional[Dict[str, Any]]:
        """طلب نصائح من المساعد الذكي"""
        try:
            response = requests.post(
                f"{self.base_url}/assistant",
                json={
                    "risk_percentage": risk_percentage,
                    "shap_values": shap_values,
                    "health_data": health_data,
                    "question": question
                },
                timeout=60
            )
            if response.status_code == 200:
                return response.json()
            return None
        except Exception as e:
            print(f"Assistant error: {e}")
            return None


# إنشاء نسخة واحدة من العميل
api_client = APIClient()