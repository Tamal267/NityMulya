#!/usr/bin/env python3
"""
Generate System Architecture Diagram
Shows the layered architecture with components and their interactions
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, Rectangle, FancyArrowPatch
import seaborn as sns

# Set up styling
plt.rcParams['figure.figsize'] = (14, 11)
plt.rcParams['font.size'] = 10
plt.rcParams['font.family'] = 'DejaVu Sans'

print("🎨 Generating system architecture diagram...\n")

fig, ax = plt.subplots(figsize=(14, 11))
ax.set_xlim(0, 14)
ax.set_ylim(0, 13)
ax.axis('off')

# Define colors for layers
color_presentation = '#4CAF50'
color_application = '#2196F3'
color_ai_layer = '#9C27B0'
color_data = '#F44336'
color_external = '#FF9800'

def draw_layer_box(ax, x, y, width, height, color, alpha=0.3):
    """Draw a layer background box"""
    box = Rectangle((x, y), width, height, 
                    facecolor=color, edgecolor='black', 
                    linewidth=2, alpha=alpha)
    ax.add_patch(box)

def draw_component(ax, x, y, width, height, text, color, text_size=9):
    """Draw a component box"""
    box = FancyBboxPatch((x, y), width, height, 
                          boxstyle="round,pad=0.05", 
                          edgecolor='black', 
                          facecolor=color, 
                          linewidth=1.5,
                          alpha=0.9)
    ax.add_patch(box)
    
    # Handle multi-line text
    lines = text.split('\n')
    if len(lines) > 1:
        y_offset = y + height/2 + 0.1 * (len(lines) - 1)
        for i, line in enumerate(lines):
            ax.text(x + width/2, y_offset - i*0.2, line,
                   ha='center', va='center', 
                   fontsize=text_size, fontweight='bold')
    else:
        ax.text(x + width/2, y + height/2, text, 
               ha='center', va='center', 
               fontsize=text_size, fontweight='bold')

def draw_arrow(ax, x1, y1, x2, y2, style='->', color='black', width=2):
    """Draw an arrow between components"""
    arrow = FancyArrowPatch((x1, y1), (x2, y2),
                           arrowstyle=style, 
                           mutation_scale=20, 
                           linewidth=width,
                           color=color)
    ax.add_patch(arrow)

# Title
ax.text(7, 12.5, 'System Architecture - Layered View', 
        ha='center', fontsize=16, fontweight='bold')

# ========== Layer 1: Presentation Layer ==========
layer1_y = 10.5
draw_layer_box(ax, 0.5, layer1_y, 13, 1.5, color_presentation)
ax.text(0.8, layer1_y + 1.3, 'Presentation Layer', 
        fontsize=11, fontweight='bold', style='italic')

# Components
draw_component(ax, 1, layer1_y + 0.2, 2.5, 0.8, 'Web Interface\n(React)', color_presentation)
draw_component(ax, 4, layer1_y + 0.2, 2.5, 0.8, 'Mobile App\n(Flutter)', color_presentation)
draw_component(ax, 7, layer1_y + 0.2, 2.5, 0.8, 'Admin Dashboard\n(React)', color_presentation)
draw_component(ax, 10, layer1_y + 0.2, 2.5, 0.8, 'REST API\nEndpoints', color_presentation)

# ========== Layer 2: Application Layer ==========
layer2_y = 8
draw_layer_box(ax, 0.5, layer2_y, 13, 2, color_application)
ax.text(0.8, layer2_y + 1.8, 'Application Layer', 
        fontsize=11, fontweight='bold', style='italic')

# Components
draw_component(ax, 1, layer2_y + 1.1, 2.2, 0.7, 'Input\nValidation', color_application)
draw_component(ax, 3.5, layer2_y + 1.1, 2.2, 0.7, 'Text\nPreprocessing', color_application)
draw_component(ax, 6, layer2_y + 1.1, 2.2, 0.7, 'Routing\nModule', color_application)
draw_component(ax, 8.5, layer2_y + 1.1, 2.2, 0.7, 'Notification\nService', color_application)
draw_component(ax, 11, layer2_y + 1.1, 2.2, 0.7, 'Report\nGenerator', color_application)

draw_component(ax, 2.2, layer2_y + 0.2, 2.5, 0.7, 'Authentication\n& Authorization', color_application)
draw_component(ax, 5.2, layer2_y + 0.2, 2.5, 0.7, 'Business Logic\nController', color_application)
draw_component(ax, 8.2, layer2_y + 0.2, 2.5, 0.7, 'Dashboard\nServices', color_application)

# ========== Layer 3: AI/NLP Layer ==========
layer3_y = 5.5
draw_layer_box(ax, 0.5, layer3_y, 13, 2, color_ai_layer)
ax.text(0.8, layer3_y + 1.8, 'AI/NLP Processing Layer', 
        fontsize=11, fontweight='bold', style='italic')

# Main component
draw_component(ax, 4.5, layer3_y + 1.05, 5, 0.8, 'BanglaBERT Model\n(110M Parameters)', 
               color_ai_layer, text_size=10)

# Sub-components
draw_component(ax, 1, layer3_y + 0.15, 2.3, 0.7, 'Sentiment\nAnalyzer', color_ai_layer)
draw_component(ax, 3.6, layer3_y + 0.15, 2.3, 0.7, 'Priority\nDetector', color_ai_layer)
draw_component(ax, 6.2, layer3_y + 0.15, 2.3, 0.7, 'Category\nClassifier', color_ai_layer)
draw_component(ax, 8.8, layer3_y + 0.15, 2.3, 0.7, 'Language\nDetector', color_ai_layer)
draw_component(ax, 11.4, layer3_y + 0.15, 2, 0.7, 'Validity\nChecker', color_ai_layer)

# ========== Layer 4: Data Layer ==========
layer4_y = 3.2
draw_layer_box(ax, 0.5, layer4_y, 13, 1.8, color_data)
ax.text(0.8, layer4_y + 1.6, 'Data Layer', 
        fontsize=11, fontweight='bold', style='italic')

# Components
draw_component(ax, 1.5, layer4_y + 0.8, 2.2, 0.7, 'PostgreSQL\nDatabase', color_data)
draw_component(ax, 4.2, layer4_y + 0.8, 2.2, 0.7, 'Complaints\nRepository', color_data)
draw_component(ax, 6.9, layer4_y + 0.8, 2.2, 0.7, 'Analysis\nResults Store', color_data)
draw_component(ax, 9.6, layer4_y + 0.8, 2.2, 0.7, 'User\nManagement', color_data)

draw_component(ax, 3, layer4_y + 0.05, 2.5, 0.6, 'Cache Layer\n(Redis)', color_data)
draw_component(ax, 6, layer4_y + 0.05, 2.5, 0.6, 'File Storage\n(Documents)', color_data)
draw_component(ax, 9, layer4_y + 0.05, 2.5, 0.6, 'Audit Logs', color_data)

# ========== Layer 5: External Services ==========
layer5_y = 1.2
draw_layer_box(ax, 0.5, layer5_y, 13, 1.5, color_external)
ax.text(0.8, layer5_y + 1.3, 'External Services & Infrastructure', 
        fontsize=11, fontweight='bold', style='italic')

# Components
draw_component(ax, 1.5, layer5_y + 0.2, 2, 0.8, 'Email\nService', color_external)
draw_component(ax, 3.9, layer5_y + 0.2, 2, 0.8, 'SMS\nGateway', color_external)
draw_component(ax, 6.3, layer5_y + 0.2, 2, 0.8, 'Cloud\nStorage', color_external)
draw_component(ax, 8.7, layer5_y + 0.2, 2, 0.8, 'Backup\nService', color_external)
draw_component(ax, 11.1, layer5_y + 0.2, 2, 0.8, 'Monitoring\n& Logging', color_external)

# ========== Draw Arrows Between Layers ==========

# Layer 1 to Layer 2
draw_arrow(ax, 2.25, layer1_y + 0.2, 2.1, layer2_y + 1.8, '<->', 'gray', 1.5)
draw_arrow(ax, 5.25, layer1_y + 0.2, 4.6, layer2_y + 1.8, '<->', 'gray', 1.5)
draw_arrow(ax, 8.25, layer1_y + 0.2, 7.1, layer2_y + 1.8, '<->', 'gray', 1.5)
draw_arrow(ax, 11.25, layer1_y + 0.2, 9.6, layer2_y + 1.8, '<->', 'gray', 1.5)

# Layer 2 to Layer 3
draw_arrow(ax, 3.5, layer2_y + 0.2, 5, layer3_y + 1.85, '->', 'gray', 1.5)
draw_arrow(ax, 7, layer3_y + 1.05, 7, layer2_y + 0.2, '->', 'gray', 1.5)

# Layer 3 to Layer 4
draw_arrow(ax, 5, layer3_y + 0.15, 5.1, layer4_y + 1.5, '<->', 'gray', 1.5)
draw_arrow(ax, 7.5, layer3_y + 0.15, 7.5, layer4_y + 1.5, '<->', 'gray', 1.5)

# Layer 4 to Layer 5
draw_arrow(ax, 4, layer4_y + 0.05, 3.5, layer5_y + 1, '<->', 'gray', 1.5)
draw_arrow(ax, 7.25, layer4_y + 0.05, 7.3, layer5_y + 1, '<->', 'gray', 1.5)

# Add legend
legend_x = 0.2
legend_y = 0.3
ax.text(legend_x, legend_y, 'Architecture Layers:', fontsize=9, fontweight='bold')

legend_items = [
    (color_presentation, 'Presentation'),
    (color_application, 'Application'),
    (color_ai_layer, 'AI/NLP'),
    (color_data, 'Data'),
    (color_external, 'External')
]

for i, (color, label) in enumerate(legend_items):
    x_pos = legend_x + (i * 2.3)
    rect = mpatches.Rectangle((x_pos, legend_y - 0.25), 0.3, 0.15, 
                               facecolor=color, edgecolor='black', linewidth=1, alpha=0.6)
    ax.add_patch(rect)
    ax.text(x_pos + 0.4, legend_y - 0.175, label, fontsize=8, va='center')

# Add annotation
ax.text(13.5, 12, 'Multi-tier\nArchitecture\n\nScalable &\nModular', 
        fontsize=8, ha='right',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.7))

plt.tight_layout()
plt.savefig('system_architecture.png', dpi=300, bbox_inches='tight', facecolor='white')
plt.close()

print("✅ Saved: system_architecture.png")
print("\n" + "="*60)
print("✅ System architecture diagram generated successfully!")
print("📊 Shows 5-layer architecture with all components")
print("🎨 Professional layered architecture visualization")
print("="*60)
