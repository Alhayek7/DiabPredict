
import os

# إنشاء مجلد utils
os.makedirs("/mnt/agents/output/utils", exist_ok=True)

config_py = """
إعدادات التطبيق - DiabPredict
"""

# ============================================
# معلومات التطبيق
# ============================================
APP_NAME = "DiabPredict"
APP_VERSION = "1.0.0"
APP_DESCRIPTION = "نظام ذكي للتنبؤ المبكر بخطر السكري"

PAGE_TITLE = "DiabPredict - نظام التنبؤ بالسكري"
PAGE_ICON = "🏥"
LAYOUT = "wide"

# ============================================
# الألوان (نظام التصميم)
# ============================================
COLORS = {
    "primary": "#004ac6",
    "on_primary": "#ffffff",
    "primary_container": "#2563eb",
    "on_primary_container": "#eeefff",
    "inverse_primary": "#b4c5ff",
    
    "secondary": "#712ae2",
    "on_secondary": "#ffffff",
    "secondary_container": "#8a4cfc",
    "on_secondary_container": "#fffbff",
    
    "tertiary": "#006242",
    "on_tertiary": "#ffffff",
    "tertiary_container": "#007d55",
    "on_tertiary_container": "#bdffdb",
    
    "error": "#ba1a1a",
    "on_error": "#ffffff",
    "error_container": "#ffdad6",
    "on_error_container": "#93000a",
    
    "background": "#f9f9ff",
    "on_background": "#111c2d",
    "surface": "#f9f9ff",
    "on_surface": "#111c2d",
    "on_surface_variant": "#434655",
    
    "surface_variant": "#d8e3fb",
    "surface_container_lowest": "#ffffff",
    "surface_container_low": "#f0f3ff",
    "surface_container": "#e7eeff",
    "surface_container_high": "#dee8ff",
    "surface_container_highest": "#d8e3fb",
    "surface_dim": "#cfdaf2",
    "surface_bright": "#f9f9ff",
    
    "outline": "#737686",
    "outline_variant": "#c3c6d7",
    "surface_tint": "#0053db",
    
    "primary_fixed": "#dbe1ff",
    "primary_fixed_dim": "#b4c5ff",
    "on_primary_fixed": "#00174b",
    "on_primary_fixed_variant": "#003ea8",
    
    "secondary_fixed": "#eaddff",
    "secondary_fixed_dim": "#d2bbff",
    "on_secondary_fixed": "#25005a",
    "on_secondary_fixed_variant": "#5a00c6",
    
    "tertiary_fixed": "#6ffbbe",
    "tertiary_fixed_dim": "#4edea3",
    "on_tertiary_fixed": "#002113",
    "on_tertiary_fixed_variant": "#005236",
    
    "inverse_surface": "#263143",
    "inverse_on_surface": "#ecf1ff",
}

# ============================================
# إعدادات الخطوط
# ============================================
FONT_FAMILY = "Cairo"
FONT_URL = "https://fonts.googleapis.com/css2?family=Cairo:wght@400;500;600;700&display=swap"

# ============================================
# مسارات الصفحات
# ============================================
PAGES = {
    "home": {"title": "الرئيسية", "icon": "🏠", "file": "01_🏠_الرئيسية"},
    "predict": {"title": "التنبؤ", "icon": "🔮", "file": "02_🔮_التنبؤ"},
    "assistant": {"title": "المساعد الذكي", "icon": "🤖", "file": "03_🤖_المساعد_الذكي"},
    "history": {"title": "السجل", "icon": "📊", "file": "04_📊_السجل"},
    "about": {"title": "عن النظام", "icon": "ℹ️", "file": "05_ℹ️_عن_النظام"},
}

# ============================================
# إعدادات النموذج
# ============================================
MODEL_PATH = "models/diabetes_model.pkl"
MODEL_ACCURACY = 0.94
FEATURES = [
    "Pregnancies",
    "Glucose", 
    "BloodPressure",
    "SkinThickness",
    "Insulin",
    "BMI",
    "DiabetesPedigreeFunction",
    "Age"
]

# ============================================
# مستويات الخطر
# ============================================
RISK_LEVELS = {
    "low": {"label": "منخفض", "color": "#007d55", "bg": "#bdffdb", "max": 40},
    "medium": {"label": "متوسط", "color": "#712ae2", "bg": "#eaddff", "max": 70},
    "high": {"label": "مرتفع", "color": "#ba1a1a", "bg": "#ffdad6", "max": 100},
}
