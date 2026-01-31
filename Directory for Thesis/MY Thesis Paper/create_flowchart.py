#!/usr/bin/env python3
"""
Generate System Flow Diagram for Thesis
Shows the complete flow from user complaint input to admin dashboard
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
import seaborn as sns

# Set up styling
plt.rcParams['figure.figsize'] = (14, 10)
plt.rcParams['font.size'] = 11
plt.rcParams['font.family'] = 'DejaVu Sans'

print("🎨 Generating system flow diagram...\n")

fig, ax = plt.subplots(figsize=(14, 12))
ax.set_xlim(0, 10)
ax.set_ylim(0, 14)
ax.axis('off')

# Define colors
color_input = '#4CAF50'
color_process = '#2196F3'
color_analysis = '#9C27B0'
color_output = '#FF9800'
color_storage = '#F44336'

def draw_box(ax, x, y, width, height, text, color, text_size=10):
    """Draw a rounded box with text"""
    box = FancyBboxPatch((x, y), width, height, 
                          boxstyle="round,pad=0.1", 
                          edgecolor='black', 
                          facecolor=color, 
                          linewidth=2.5,
                          alpha=0.8)
    ax.add_patch(box)
    ax.text(x + width/2, y + height/2, text, 
            ha='center', va='center', 
            fontsize=text_size, fontweight='bold',
            color='white' if color != color_input else 'black')

def draw_arrow(ax, x1, y1, x2, y2, label=''):
    """Draw an arrow between two points"""
    arrow = FancyArrowPatch((x1, y1), (x2, y2),
                           arrowstyle='->', 
                           mutation_scale=30, 
                           linewidth=2.5,
                           color='black')
    ax.add_patch(arrow)
    if label:
        mid_x, mid_y = (x1 + x2) / 2, (y1 + y2) / 2
        ax.text(mid_x + 0.3, mid_y, label, 
                fontsize=9, style='italic',
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

# Title
ax.text(5, 13.5, 'AI-Enhanced Complaint Management System Flow', 
        ha='center', fontsize=16, fontweight='bold')

# 1. User Input Layer
draw_box(ax, 3.5, 12, 3, 0.8, 'User Submits Complaint\n(Bengali/English)', color_input, 11)

# Arrow down
draw_arrow(ax, 5, 12, 5, 11.2)

# 2. Input Validation & Preprocessing
draw_box(ax, 1, 10.5, 3, 0.6, 'Input Validation', color_process, 10)
draw_box(ax, 6, 10.5, 3, 0.6, 'Text Preprocessing', color_process, 10)

draw_arrow(ax, 5, 11.2, 2.5, 11.1, 'Web/Mobile')
draw_arrow(ax, 5, 11.2, 7.5, 11.1, 'Interface')

# Arrow down from both
draw_arrow(ax, 2.5, 10.5, 2.5, 9.8)
draw_arrow(ax, 7.5, 10.5, 7.5, 9.8)

# 3. BanglaBERT Analysis Engine (Central)
draw_box(ax, 2.5, 8.5, 5, 1.2, 'BanglaBERT Analysis Engine\n(Core NLP Model)', color_analysis, 11)

draw_arrow(ax, 2.5, 9.8, 3.5, 9.7)
draw_arrow(ax, 7.5, 9.8, 6.5, 9.7)

# 4. Parallel Analysis Tasks
y_task = 7
task_height = 0.7
task_width = 2.2

draw_box(ax, 0.5, y_task, task_width, task_height, 'Sentiment\nAnalysis', color_analysis, 9)
draw_box(ax, 3.2, y_task, task_width, task_height, 'Priority\nDetection', color_analysis, 9)
draw_box(ax, 5.9, y_task, task_width, task_height, 'Category\nClassification', color_analysis, 9)

# Arrows from BanglaBERT to tasks
draw_arrow(ax, 3.5, 8.5, 1.6, 7.7, 'Multi-task')
draw_arrow(ax, 5, 8.5, 4.3, 7.7, 'Learning')
draw_arrow(ax, 6.5, 8.5, 7, 7.7)

# 5. Results Aggregation
draw_box(ax, 3, 5.8, 4, 0.8, 'Analysis Results Aggregation', color_process, 10)

# Arrows from tasks to aggregation
draw_arrow(ax, 1.6, 7, 4, 6.6)
draw_arrow(ax, 4.3, 7, 5, 6.6)
draw_arrow(ax, 7, 7, 6, 6.6)

# 6. Database Storage
draw_box(ax, 7.5, 5.8, 2, 0.8, 'Database\nStorage', color_storage, 10)

draw_arrow(ax, 7, 6.2, 7.5, 6.2, 'Save')

# 7. Routing Module
draw_box(ax, 3, 4.5, 4, 0.8, 'Automatic Department Routing', color_process, 10)

draw_arrow(ax, 5, 5.8, 5, 5.3)

# 8. Notification System
draw_box(ax, 1, 3.2, 3, 0.7, 'Officer Notification', color_output, 10)
draw_box(ax, 6, 3.2, 3, 0.7, 'User Notification', color_output, 10)

draw_arrow(ax, 4, 4.5, 2.5, 3.9, 'Alert')
draw_arrow(ax, 6, 4.5, 7.5, 3.9, 'Confirm')

# 9. Admin Dashboard
draw_box(ax, 2.5, 1.5, 5, 1.2, 'Admin Dashboard\n(Visualizations & Reports)', color_output, 11)

draw_arrow(ax, 2.5, 3.2, 3.5, 2.7)
draw_arrow(ax, 7.5, 3.2, 6.5, 2.7)
draw_arrow(ax, 8.5, 5.8, 8.5, 2.3, 'Query')
draw_arrow(ax, 8.5, 2.3, 7.5, 2.1)

# 10. Government Officers Access
draw_box(ax, 2.5, 0.3, 5, 0.7, 'Government Officers\n(Review & Take Action)', color_input, 10)

draw_arrow(ax, 5, 1.5, 5, 1)

# Add legend
legend_x = 0.2
legend_y = 0.3
ax.text(legend_x, legend_y + 0.6, 'Legend:', fontsize=10, fontweight='bold')

legend_items = [
    (color_input, 'User Interface/Input'),
    (color_process, 'Processing/Routing'),
    (color_analysis, 'AI Analysis'),
    (color_output, 'Output/Dashboard'),
    (color_storage, 'Data Storage')
]

for i, (color, label) in enumerate(legend_items):
    y_pos = legend_y - i * 0.15
    rect = mpatches.Rectangle((legend_x, y_pos - 0.08), 0.15, 0.08, 
                               facecolor=color, edgecolor='black', linewidth=1)
    ax.add_patch(rect)
    ax.text(legend_x + 0.2, y_pos - 0.04, label, fontsize=8, va='center')

# Add processing time annotation
ax.text(9.5, 13, 'Average\nProcessing\nTime:\n~150ms', 
        fontsize=9, ha='center',
        bbox=dict(boxstyle='round', facecolor='yellow', alpha=0.6))

plt.tight_layout()
plt.savefig('system_flow_diagram.png', dpi=300, bbox_inches='tight', facecolor='white')
plt.close()

print("✅ Saved: system_flow_diagram.png")
print("\n" + "="*60)
print("✅ System flow diagram generated successfully!")
print("📊 Shows complete flow from user input to admin dashboard")
print("🎨 Professional styling with color-coded components")
print("="*60)
