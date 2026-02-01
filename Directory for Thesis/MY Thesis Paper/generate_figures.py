#!/usr/bin/env python3
"""
Generate Thesis Paper Figures with Proper Styling
Based on accuracy analysis data with visible, properly formatted labels
"""

import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib
import numpy as np

# Set up styling for better visibility (inspired by analyze_accuracy.py)
sns.set_theme(style="whitegrid")
plt.rcParams['figure.figsize'] = (10, 8)
plt.rcParams['font.size'] = 12
plt.rcParams['axes.labelsize'] = 12
plt.rcParams['axes.titlesize'] = 14
plt.rcParams['xtick.labelsize'] = 11
plt.rcParams['ytick.labelsize'] = 11
plt.rcParams['legend.fontsize'] = 11

# For Bengali text support - try to use a font that supports Bengali
try:
    plt.rcParams['font.family'] = 'DejaVu Sans'
except:
    pass

print("🎨 Generating thesis paper figures with proper styling...\n")

# Data from accuracy_report.txt
# 1. Language Distribution (including Banglish/Mixed)
print("📊 Generating language distribution chart...")
langs = ['English', 'Bengali', 'Banglish']
lang_counts = [250, 76, 186]  # English, Bengali, Banglish/Mixed
colors = sns.color_palette("husl", len(langs))

plt.figure(figsize=(10, 6))
wedges, texts, autotexts = plt.pie(lang_counts, labels=langs, autopct='%1.1f%%', startangle=90, 
        colors=colors, textprops={'fontsize': 14, 'weight': 'bold'})

# Make percentage text more visible
for autotext in autotexts:
    autotext.set_color('white')
    autotext.set_fontweight('bold')
    autotext.set_fontsize(13)

plt.title('Language Distribution of Complaints\n(English, Bengali, and Banglish)', 
          fontsize=16, fontweight='bold', pad=20)
plt.savefig('language_distribution.png', dpi=300, bbox_inches='tight')
plt.close()
print("✅ Saved: language_distribution.png")

# 2. Priority Distribution
print("📊 Generating priority distribution chart...")
priorities = ['High', 'Medium']
priority_counts = [21, 424]
colors = ['#FF9800', '#FFC107']

plt.figure(figsize=(10, 6))
plt.pie(priority_counts, labels=priorities, autopct='%1.1f%%', startangle=90, 
        colors=colors, textprops={'fontsize': 14, 'weight': 'bold'})
plt.title('Priority Distribution of Complaints', fontsize=16, fontweight='bold', pad=20)
plt.savefig('priority_distribution.png', dpi=300, bbox_inches='tight')
plt.close()
print("✅ Saved: priority_distribution.png")

# 3. Sentiment Distribution
print("📊 Generating sentiment distribution chart...")
sentiments = ['Negative', 'Neutral']
sentiment_counts = [499, 13]
colors = ['#F44336', '#FF9800']

plt.figure(figsize=(10, 6))
plt.pie(sentiment_counts, labels=sentiments, autopct='%1.1f%%', startangle=90, 
        colors=colors, textprops={'fontsize': 14, 'weight': 'bold'})
plt.title('Sentiment Distribution of Complaints', fontsize=16, fontweight='bold', pad=20)
plt.savefig('sentiment_distribution.png', dpi=300, bbox_inches='tight')
plt.close()
print("✅ Saved: sentiment_distribution.png")

# 4. Top Categories (Bar Chart with English translations)
print("📊 Generating top categories chart...")
# Translate Bengali to English for better visibility in thesis
category_translations = {
    'অন্যান্য': 'Other',
    'স্বাস্থ্য সমস্যা': 'Health Issues',
    'গুণগত মান': 'Quality Issues',
    'মেয়াদোত্তীর্ণ': 'Expired Products',
    'ওজন/পরিমাণ': 'Weight/Quantity',
    'মূল্য সংক্রান্ত': 'Price Issues',
    'প্রতারণা': 'Fraud',
    'প্যাকেজিং': 'Packaging'
}

categories_bengali = ['অন্যান্য', 'স্বাস্থ্য সমস্যা', 'গুণগত মান', 'মেয়াদোত্তীর্ণ', 
                      'ওজন/পরিমাণ', 'মূল্য সংক্রান্ত', 'প্রতারণা', 'প্যাকেজিং']
categories_english = [category_translations[cat] for cat in categories_bengali]
cat_counts = [305, 87, 75, 20, 13, 8, 3, 1]

colors = sns.color_palette("viridis", len(categories_english))

plt.figure(figsize=(12, 8))
bars = plt.barh(categories_english, cat_counts, color=colors, edgecolor='black', linewidth=1.5)

# Add value labels on bars for better visibility
for i, (bar, count) in enumerate(zip(bars, cat_counts)):
    plt.text(count + 5, i, str(count), va='center', fontsize=11, fontweight='bold')

plt.xlabel('Number of Complaints', fontsize=14, fontweight='bold')
plt.ylabel('Category', fontsize=14, fontweight='bold')
plt.title('Top Complaint Categories', fontsize=16, fontweight='bold', pad=20)
plt.grid(True, alpha=0.3, axis='x')
plt.tight_layout()
plt.savefig('top_categories.png', dpi=300, bbox_inches='tight')
plt.close()
print("✅ Saved: top_categories.png")

print("\n" + "="*60)
print("✅ All figures generated successfully!")
print("📁 Files saved with high resolution (300 DPI)")
print("📊 Charts use visible fonts and professional styling")
print("="*60)
