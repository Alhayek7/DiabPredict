"""
utils/theme.py - سمة التصميم والألوان مع دعم الوضع المظلم
"""

import streamlit as st
from typing import Literal

# ============================================
# ألوان الوضع الفاتح (Light Mode)
# ============================================
LIGHT_COLORS = {
    "primary": "#2563eb",
    "primary_container": "#3b82f6",
    "on_primary": "#ffffff",
    "on_primary_container": "#eff6ff",
    "secondary": "#0d9488",
    "secondary_container": "#14b8a68b5cf6",
    "on_secondary": "#ffffff",
    "on_secondary_container": "#f5f3ff",
    "tertiary": "#059669",
    "tertiary_container": "#10b981",
    "on_tertiary": "#ffffff",
    "on_tertiary_container": "#ecfdf5",
    "error": "#dc2626",
    "error_container": "#fef2f2",
    "on_error": "#ffffff",
    "on_error_container": "#991b1b",
    "background": "#f4f7fc",
    "on_background": "#1e293b",
    "surface": "#ffffff",
    "surface_dim": "#e2e8f0",
    "surface_bright": "#f8fafc",
    "surface_container_lowest": "#ffffff",
    "surface_container_low": "#f1f5f9",
    "surface_container": "#e2e8f0",
    "surface_container_high": "#cbd5e1",
    "surface_container_highest": "#94a3b8",
    "on_surface": "#0f172a",
    "on_surface_variant": "#475569",
    "outline": "#64748b",
    "outline_variant": "#cbd5e1",
    "surface_tint": "#2563eb",
    "inverse_surface": "#1e293b",
    "inverse_on_surface": "#f8fafc",
    "inverse_primary": "#60a5fa",
}

# ============================================
# ألوان الوضع المظلم (Dark Mode)
# ============================================
DARK_COLORS = {
    "primary": "#60a5fa",
    "primary_container": "#1e3a8a",
    "on_primary": "#0f172a",
    "on_primary_container": "#eff6ff",
    "secondary": "#a78bfa",
    "secondary_container": "#14b8a6",
    "on_secondary": "#0f172a",
    "on_secondary_container": "#14b8a6",
    "tertiary": "#34d399",
    "tertiary_container": "#064e3b",
    "on_tertiary": "#0f172a",
    "on_tertiary_container": "#ecfdf5",
    "error": "#f87171",
    "error_container": "#7f1d1d",
    "on_error": "#0f172a",
    "on_error_container": "#fef2f2",
    "background": "#0f172a",
    "on_background": "#f1f5f9",
    "surface": "#1e293b",
    "surface_dim": "#0f172a",
    "surface_bright": "#334155",
    "surface_container_lowest": "#0f172a",
    "surface_container_low": "#1e293b",
    "surface_container": "#334155",
    "surface_container_high": "#475569",
    "surface_container_highest": "#64748b",
    "on_surface": "#f8fafc",
    "on_surface_variant": "#cbd5e1",
    "outline": "#94a3b8",
    "outline_variant": "#475569",
    "surface_tint": "#60a5fa",
    "inverse_surface": "#f8fafc",
    "inverse_on_surface": "#0f172a",
    "inverse_primary": "#2563eb",
}

RISK_COLORS = {
    "low": {"bg": "#bdffdb", "text": "#006242", "label": "منخفض"},
    "medium": {"bg": "#eaddff", "text": "#712ae2", "label": "متوسط"},
    "high": {"bg": "#ffdad6", "text": "#ba1a1a", "label": "مرتفع"},
}

# ============================================
# إدارة الوضع المظلم
# ============================================

def get_theme() -> Literal["light", "dark"]:
    return st.session_state.get("theme", "light")

def toggle_theme():
    current = get_theme()
    st.session_state.theme = "dark" if current == "light" else "light"
    st.rerun()

def get_colors():
    return DARK_COLORS if get_theme() == "dark" else LIGHT_COLORS

COLORS = get_colors()

# ============================================
# CSS
# ============================================

def get_css():
    colors = get_colors()
    card_bg = colors["surface_container_lowest"]
    text_color = colors["on_surface"]
    
    return f"""
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Cairo:wght@400;500;600;700;800&display=swap');
        
        .stApp {{
            background-color: {colors["background"]};
            font-family: 'Cairo', sans-serif;
        }}
        
        #MainMenu {{visibility: hidden;}}
        footer {{visibility: hidden;}}
        header {{visibility: hidden;}}
        
        /* الشريط الجانبي - على اليمين */
        [data-testid="stSidebar"] {{
            background: linear-gradient(180deg, {colors["surface"]} 0%, {colors["surface_container"]} 100%);
            border-right: 1px solid {colors["outline_variant"]};
            direction: rtl;
            text-align: right;
        }}
        
        /* إخفاء التنقل التلقائي فقط */
        section[data-testid="stSidebar"] nav {{
            display: none;
        }}
        
        h1, h2, h3, h4, h5, h6 {{
            color: {text_color};
            font-family: 'Cairo', sans-serif;
        }}
        
        .card {{
            background-color: {card_bg};
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            border: 1px solid {colors["outline_variant"]};
            transition: all 0.3s ease;
        }}
        
        .card:hover {{
            transform: translateY(-4px);
            box-shadow: 0 12px 30px rgba(0,0,0,0.12);
        }}
        
        .stButton > button {{
            background: linear-gradient(135deg, {colors["primary"]} 0%, {colors["secondary"]} 100%);
            color: {colors["on_primary"]};
            border: none;
            border-radius: 40px;
            padding: 12px 32px;
            font-weight: 600;
            font-size: 16px;
            transition: all 0.3s ease;
            width: 100%;
            font-family: 'Cairo', sans-serif;
        }}
        
        .stButton > button:hover {{
            transform: translateY(-2px);
            box-shadow: 0 8px 25px {colors["primary"]}66;
        }}
        
        .stTextInput > div > div > input,
        .stNumberInput > div > div > input,
        .stSelectbox > div > div > select {{
            border-radius: 12px;
            border: 1px solid {colors["outline_variant"]};
            padding: 12px 16px;
            background-color: {colors["surface_container_low"]};
            color: {text_color};
            text-align: right;
            direction: rtl;
        }}
        
        .stTextInput label, .stNumberInput label, .stSelectbox label {{
            text-align: right;
            width: 100%;
            display: block;
            font-family: 'Cairo', sans-serif;
        }}
        
        .badge-low {{
            background-color: {RISK_COLORS['low']['bg']};
            color: {RISK_COLORS['low']['text']};
            display: inline-block;
            padding: 6px 16px;
            border-radius: 40px;
            font-size: 14px;
            font-weight: 600;
        }}
        
        .badge-medium {{
            background-color: {RISK_COLORS['medium']['bg']};
            color: {RISK_COLORS['medium']['text']};
            display: inline-block;
            padding: 6px 16px;
            border-radius: 40px;
            font-size: 14px;
            font-weight: 600;
        }}
        
        .badge-high {{
            background-color: {RISK_COLORS['high']['bg']};
            color: {RISK_COLORS['high']['text']};
            display: inline-block;
            padding: 6px 16px;
            border-radius: 40px;
            font-size: 14px;
            font-weight: 600;
            animation: pulse 2s infinite;
        }}
        
        @keyframes pulse {{
            0%, 100% {{ opacity: 1; }}
            50% {{ opacity: 0.85; }}
        }}
        
        .row-widget.stHorizontal {{
            direction: rtl;
        }}
        
        [data-testid="stSidebar"] .stMarkdown {{
            text-align: right;
        }}
    </style>
    """

def apply_theme():
    """تطبيق سمة التصميم المحسنة"""
    global COLORS
    COLORS.update(get_colors())
    colors = get_colors()
    
    css = f"""
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Cairo:wght@400;500;600;700&display=swap');
        
        * {{
            font-family: 'Cairo', sans-serif;
        }}
        
        /* تنسيق الشريط الجانبي */
        [data-testid="stSidebar"] {{
            background: linear-gradient(180deg, {colors['surface']} 0%, {colors['surface_container']} 100%);
            border-left: 1px solid {colors['outline_variant']};
        }}
        
        /* تنسيق البطاقات */
        .stCard, .element-container div[data-testid="stVerticalBlock"] > div {{
            background: {colors['surface_container_lowest']};
            border-radius: 16px;
            padding: 20px;
            border: 1px solid {colors['outline_variant']};
        }}
        
        /* تنسيق الأزرار */
        .stButton > button {{
            background: linear-gradient(135deg, {colors['primary']}, {colors['secondary']});
            color: white;
            border-radius: 30px;
            font-weight: 600;
            transition: all 0.3s ease;
        }}
        
        .stButton > button:hover {{
            transform: translateY(-2px);
            box-shadow: 0 5px 15px {colors['primary']}50;
        }}
        
        /* تنسيق الحقول */
        .stTextInput input, .stNumberInput input, .stSelectbox select {{
            border-radius: 12px !important;
            border-color: {colors['outline_variant']} !important;
        }}
        
        /* RTL */
        .stMarkdown, .stTextInput, .stNumberInput, .stSelectbox {{
            direction: rtl;
            text-align: right;
        }}
    </style>
    """
    st.markdown(css, unsafe_allow_html=True)

def get_risk_badge(risk_level: str) -> str:
    risk = RISK_COLORS.get(risk_level, RISK_COLORS["medium"])
    return f'<span class="badge-{risk_level}">{risk["label"]}</span>'