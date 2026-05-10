
# 4. components/gauge.py - مؤشر الدائرة

gauge_code = """
مؤشر الدائرة (Gauge) - DiabPredict
يعرض نسبة الخطر بشكل بصري
"""

import streamlit as st
import plotly.graph_objects as go
from utils.theme import COLORS

def render_gauge(value: float, title: str = "نسبة الخطر"):
    """
    عرض مؤشر دائري للخطر
    
    Args:
        value: نسبة الخطر (0-100)
        title: عنوان المؤشر
    """
    
    # تحديد اللون بناءً على القيمة
    if value <= 30:
        color = COLORS["tertiary"]
        risk_text = "منخفض"
    elif value <= 70:
        color = "#f59e0b"  # برتقالي
        risk_text = "متوسط"
    else:
        color = COLORS["error"]
        risk_text = "مرتفع"
    
    fig = go.Figure(go.Indicator(
        mode="gauge+number+delta",
        value=value,
        number={
            'suffix': "%",
            'font': {'size': 48, 'color': COLORS["on_surface"], 'family': 'Arial'},
        },
        title={
            'text': f"<b>{title}</b><br><span style='color:{color};font-size:16px;'>{risk_text}</span>",
            'font': {'size': 20, 'color': COLORS["on_surface"]},
        },
        delta={'reference': 50, 'position': "bottom"},
        gauge={
            'axis': {
                'range': [0, 100],
                'tickwidth': 2,
                'tickcolor': COLORS["outline"],
                'tickfont': {'size': 12},
            },
            'bar': {
                'color': color,
                'thickness': 0.75,
            },
            'bgcolor': COLORS["surface_container"],
            'borderwidth': 0,
            'steps': [
                {'range': [0, 30], 'color': '#bdffdb'},
                {'range': [30, 70], 'color': '#fef3c7'},
                {'range': [70, 100], 'color': '#ffdad6'},
            ],
            'threshold': {
                'line': {'color': COLORS["on_surface"], 'width': 4},
                'thickness': 0.8,
                'value': value,
            }
        }
    ))
    
    fig.update_layout(
        height=300,
        margin=dict(l=20, r=20, t=50, b=20),
        paper_bgcolor='rgba(0,0,0,0)',
        plot_bgcolor='rgba(0,0,0,0)',
        font={'family': 'Arial'},
    )
    
    st.plotly_chart(fig, width='stretch', config={'displayModeBar': False})

def render_risk_bar(value: float):
    """
    عرض شريط أفقي للخطر
    
    Args:
        value: نسبة الخطر (0-100)
    """
    
    if value <= 30:
        color = COLORS["tertiary"]
        label = "منخفض"
    elif value <= 70:
        color = "#f59e0b"
        label = "متوسط"
    else:
        color = COLORS["error"]
        label = "مرتفع"
    
    st.markdown(f"""
    <div style="margin: 20px 0;">
        <div style="
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 8px;
        ">
            <span style="font-weight: 600; color: {COLORS['on_surface']};">مستوى الخطر</span>
            <span style="
                background-color: {color}20;
                color: {color};
                padding: 4px 16px;
                border-radius: 9999px;
                font-weight: 700;
                font-size: 14px;
            ">{label}</span>
        </div>
        <div style="
            height: 12px;
            background-color: {COLORS['surface_container']};
            border-radius: 6px;
            overflow: hidden;
        ">
            <div style="
                width: {value}%;
                height: 100%;
                background: linear-gradient(90deg, {color} 0%, {color}dd 100%);
                border-radius: 6px;
                transition: width 1s ease;
            "></div>
        </div>
        <div style="
            display: flex;
            justify-content: space-between;
            margin-top: 4px;
            font-size: 12px;
            color: {COLORS['outline']};
        ">
            <span>0%</span>
            <span>50%</span>
            <span>100%</span>
        </div>
    </div>
    """, unsafe_allow_html=True)
