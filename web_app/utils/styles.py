"""
utils/styles.py - الأنماط والثيم
"""

import streamlit as st
from utils.theme import get_colors, get_theme


def get_css():
    """إرجاع CSS المخصص للتطبيق"""
    colors = get_colors()
    is_dark = get_theme() == "dark"
    
    return f"""
    <style>
        /* تنسيق عام */
        .stApp {{
            background-color: {colors['background']};
            font-family: 'Cairo', sans-serif;
        }}
        
        /* إخفاء العناصر الافتراضية */
        #MainMenu {{visibility: hidden;}}
        footer {{visibility: hidden;}}
        header {{visibility: hidden;}}
        
        /* تنسيق البطاقات */
        .stCard, div[data-testid="stVerticalBlock"] > div[style*="flex"] {{
            background-color: {colors['surface_container_lowest']};
            border-radius: 16px;
            padding: 20px;
            border: 1px solid {colors['outline_variant']};
            transition: all 0.3s ease;
        }}
        
        /* تنسيق الأزرار */
        .stButton > button {{
            border-radius: 30px !important;
            font-weight: 600 !important;
            transition: all 0.3s ease !important;
        }}
        
        .stButton > button:hover {{
            transform: translateY(-2px) !important;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15) !important;
        }}
        
        /* تنسيق الحقول */
        .stTextInput > div > div > input,
        .stNumberInput > div > div > input,
        .stSelectbox > div > div {{
            border-radius: 12px !important;
            border-color: {colors['outline_variant']} !important;
            background-color: {colors['surface_container_low']} !important;
            color: {colors['on_surface']} !important;
        }}
        
        /* تنسيق الشريط الجانبي */
        [data-testid="stSidebar"] {{
            background: linear-gradient(180deg, {colors['surface']} 0%, {colors['surface_container']} 100%);
            border-right: 1px solid {colors['outline_variant']};
        }}
        
        /* تنسيق الرسوم البيانية */
        .js-plotly-plot {{
            border-radius: 16px;
            background: {colors['surface_container_lowest']};
            padding: 10px;
        }}
        
        /* شريط التمرير */
        ::-webkit-scrollbar {{
            width: 8px;
            height: 8px;
        }}
        
        ::-webkit-scrollbar-track {{
            background: {colors['surface_container']};
            border-radius: 10px;
        }}
        
        ::-webkit-scrollbar-thumb {{
            background: {colors['primary']};
            border-radius: 10px;
        }}
        
        ::-webkit-scrollbar-thumb:hover {{
            background: {colors['primary_container']};
        }}
        
        /* أنيميشن للعناصر */
        @keyframes fadeInUp {{
            from {{
                opacity: 0;
                transform: translateY(30px);
            }}
            to {{
                opacity: 1;
                transform: translateY(0);
            }}
        }}
        
        .animate-fade-in {{
            animation: fadeInUp 0.5s ease forwards;
        }}
        
        /* تنسيق رسائل التنبيه */
        .stAlert {{
            border-radius: 12px !important;
            border-right: 4px solid !important;
        }}
        
        /* تنسيق الشارت */
        .stPlotlyChart {{
            border-radius: 16px !important;
            overflow: hidden !important;
        }}
    </style>
    """