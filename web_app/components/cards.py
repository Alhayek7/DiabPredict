
# 5. components/cards.py - البطاقات المختلفة

cards_code = """
البطاقات - DiabPredict
مكونات البطاقات المستخدمة في الواجهة
"""

import streamlit as st
from utils.theme import COLORS

def stat_card(title: str, value: str, subtitle: str = "", icon: str = "📊", color: str = None):
    """
    بطاقة إحصائية
    
    Args:
        title: عنوان البطاقة
        value: القيمة الرقمية
        subtitle: نص فرعي
        icon: أيقونة
        color: لون مخصص
    """
    
    if color is None:
        color = COLORS["primary"]
    
    st.markdown(f"""
    <div class="card" style="text-align: center;">
        <div style="
            width: 48px;
            height: 48px;
            background-color: {color}15;
            border-radius: 12px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 12px;
        ">
            <span style="font-size: 24px;">{icon}</span>
        </div>
        <h3 style="
            margin: 0 0 4px 0;
            font-size: 14px;
            color: {COLORS['outline']};
            font-weight: 500;
        ">{title}</h3>
        <p style="
            margin: 0;
            font-size: 32px;
            font-weight: 700;
            color: {COLORS['on_surface']};
            line-height: 1.2;
        ">{value}</p>
        {f'<p style="margin: 4px 0 0 0; font-size: 14px; color: {COLORS["outline"]};">{subtitle}</p>' if subtitle else ''}
    </div>
    """, unsafe_allow_html=True)

def feature_card(title: str, description: str, icon: str = "✨", color: str = None):
    """
    بطاقة ميزة
    
    Args:
        title: عنوان الميزة
        description: وصف الميزة
        icon: أيقونة
        color: لون مخصص
    """
    
    if color is None:
        color = COLORS["primary"]
    
    st.markdown(f"""
    <div class="card" style="
        display: flex;
        gap: 16px;
        align-items: flex-start;
        direction: rtl;
        text-align: right;
    ">
        <div style="
            width: 48px;
            height: 48px;
            min-width: 48px;
            background-color: {color}15;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        ">
            <span style="font-size: 24px;">{icon}</span>
        </div>
        <div>
            <h3 style="
                margin: 0 0 8px 0;
                font-size: 18px;
                font-weight: 600;
                color: {COLORS['on_surface']};
            ">{title}</h3>
            <p style="
                margin: 0;
                font-size: 14px;
                color: {COLORS['on_surface_variant']};
                line-height: 1.6;
            ">{description}</p>
        </div>
    </div>
    """, unsafe_allow_html=True)

def info_card(title: str, content: str, type: str = "info"):
    """
    بطاقة معلومات (تحذير/نجاح/معلومات)
    
    Args:
        title: العنوان
        content: المحتوى
        type: نوع البطاقة (info/warning/success/error)
    """
    
    colors_map = {
        "info": {"bg": "#EFF6FF", "border": "#3B82F6", "icon": "ℹ️"},
        "warning": {"bg": "#FFFBEB", "border": "#F59E0B", "icon": "⚠️"},
        "success": {"bg": "#ECFDF5", "border": "#10B981", "icon": "✅"},
        "error": {"bg": "#FEF2F2", "border": "#EF4444", "icon": "❌"},
    }
    
    style = colors_map.get(type, colors_map["info"])
    
    st.markdown(f"""
    <div style="
        background-color: {style['bg']};
        border-right: 4px solid {style['border']};
        border-radius: 12px;
        padding: 16px;
        margin: 16px 0;
        direction: rtl;
        text-align: right;
    ">
        <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 8px;">
            <span>{style['icon']}</span>
            <h4 style="margin: 0; font-size: 16px; font-weight: 600;">{title}</h4>
        </div>
        <p style="margin: 0; font-size: 14px; line-height: 1.6;">{content}</p>
    </div>
    """, unsafe_allow_html=True)
    

def team_member_card(name: str, role: str, color: str = None):
    """
    بطاقة عضو الفريق
    
    Args:
        name: الاسم
        role: الدور
        color: لون مخصص
    """
    
    if color is None:
        color = COLORS["primary"]
    
    st.markdown(f"""
    <div class="card" style="text-align: center;">
        <div style="
            width: 64px;
            height: 64px;
            background-color: {color}15;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 12px;
        ">
            <span style="font-size: 28px;">👤</span>
        </div>
        <h4 style="
            margin: 0 0 4px 0;
            font-size: 16px;
            font-weight: 600;
            color: {COLORS['on_surface']};
        ">{name}</h4>
        <p style="
            margin: 0;
            font-size: 14px;
            color: {COLORS['outline']};
        ">{role}</p>
    </div>
    """, unsafe_allow_html=True)
