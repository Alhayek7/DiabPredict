# utils/storage.py
import os
import pickle
import streamlit as st
from datetime import datetime

def get_storage_path():
    """الحصول على مسار ملف التخزين"""
    return os.path.join(os.path.dirname(__file__), '..', 'user_data.pkl')

def save_user_data():
    """حفظ جميع بيانات المستخدم في ملف محلي"""
    try:
        data_to_save = {
            'predictions_history': st.session_state.get('predictions_history', []),
            'last_risk': st.session_state.get('last_risk', None),
            'last_importance': st.session_state.get('last_importance', None),
            'last_features': st.session_state.get('last_features', None),
            'user_name': st.session_state.get('user_name', ''),
            'chat_history': st.session_state.get('chat_history', []),
            'last_prediction_date': st.session_state.get('last_prediction_date', datetime.now().strftime("%Y-%m-%d %H:%M:%S")),
            'app_version': st.session_state.get('app_version', '1.0.0'),
            'theme': st.session_state.get('theme', 'light'),
            'current_page': st.session_state.get('current_page', 'home'),
            'last_input_values': st.session_state.get('last_input_values', {
                'pregnancies': 0, 'glucose': 120, 'blood_pressure': 70,
                'skin_thickness': 20, 'insulin': 80, 'bmi': 25.0,
                'dpf': 0.5, 'age': 30
            }),
        }
        with open(get_storage_path(), 'wb') as f:
            pickle.dump(data_to_save, f)
        return True
    except Exception as e:
        print(f"خطأ في حفظ البيانات: {e}")
        return False

def load_user_data():
    """تحميل بيانات المستخدم من الملف المحلي"""
    try:
        storage_path = get_storage_path()
        if os.path.exists(storage_path):
            with open(storage_path, 'rb') as f:
                data = pickle.load(f)
            for key, value in data.items():
                if key not in st.session_state:
                    st.session_state[key] = value
            return True
    except Exception as e:
        print(f"خطأ في تحميل البيانات: {e}")
    return False

def clear_user_data():
    """مسح جميع بيانات المستخدم"""
    try:
        storage_path = get_storage_path()
        if os.path.exists(storage_path):
            os.remove(storage_path)
        keys_to_clear = ['predictions_history', 'last_risk', 'last_importance', 
                        'last_features', 'user_name', 'chat_history', 
                        'last_prediction_date', 'last_input_values']
        for key in keys_to_clear:
            if key in st.session_state:
                del st.session_state[key]
        return True
    except Exception as e:
        print(f"خطأ في مسح البيانات: {e}")
        return False