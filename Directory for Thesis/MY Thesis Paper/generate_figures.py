import matplotlib.pyplot as plt

# Data from accuracy_report.txt
# 1. Language Distribution
langs = ['English', 'Bengali']
lang_counts = [436, 76]
plt.figure(figsize=(5,5))
plt.pie(lang_counts, labels=langs, autopct='%1.1f%%', startangle=90, colors=['#4e79a7','#f28e2b'])
plt.title('Language Distribution of Complaints')
plt.savefig('language_distribution.png')
plt.close()

# 2. Priority Distribution
priorities = ['High', 'Medium']
priority_counts = [21, 424]
plt.figure(figsize=(5,5))
plt.pie(priority_counts, labels=priorities, autopct='%1.1f%%', startangle=90, colors=['#e15759','#76b7b2'])
plt.title('Priority Distribution of Complaints')
plt.savefig('priority_distribution.png')
plt.close()

# 3. Sentiment Distribution
sentiments = ['Negative', 'Neutral']
sentiment_counts = [499, 13]
plt.figure(figsize=(5,5))
plt.pie(sentiment_counts, labels=sentiments, autopct='%1.1f%%', startangle=90, colors=['#59a14f','#edc948'])
plt.title('Sentiment Distribution of Complaints')
plt.savefig('sentiment_distribution.png')
plt.close()

# 4. Top Categories (Bar Chart)
categories = ['অন্যান্য', 'স্বাস্থ্য সমস্যা', 'গুণগত মান', 'মেয়াদোত্তীর্ণ', 'ওজন/পরিমাণ', 'মূল্য সংক্রান্ত', 'প্রতারণা', 'প্যাকেজিং']
cat_counts = [305, 87, 75, 20, 13, 8, 3, 1]
plt.figure(figsize=(8,5))
plt.barh(categories, cat_counts, color='#4e79a7')
plt.xlabel('Number of Complaints')
plt.title('Top Complaint Categories')
plt.tight_layout()
plt.savefig('top_categories.png')
plt.close()

print('All figures generated!')
