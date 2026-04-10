import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import warnings

from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.pipeline import FeatureUnion
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
from sklearn.ensemble import RandomForestClassifier
from imblearn.over_sampling import SMOTE

warnings.filterwarnings('ignore')

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RESULTS_DIR = os.path.join(BASE_DIR, 'results')
DATA_PATH = os.path.join(BASE_DIR, 'data', 'complaints_full.csv')
os.makedirs(RESULTS_DIR, exist_ok=True)

print("🚀 Initiating Machine Learning Pipeline using actual backend attributes...")
print("💡 Integrating subcategory table features to further empower model context...")

df = pd.read_csv(DATA_PATH)
df = df.dropna(subset=['complaint_description', 'complaint_classification', 'subcategory_name'])

class_mapping = {'weak': 0, 'medium': 1, 'high': 2}
target_names = ['weak (0)', 'medium (1)', 'high (2)']
df['target'] = df['complaint_classification'].map(class_mapping)

y = df['target'].values
# Adding subcategory_name to our feature dataset
X_df = df[['complaint_description', 'validity', 'priority', 'subcategory_name']]

print("[1/4] Combining Text NLP, Backend-Checked Numeric Features, and Subcategory Cats...")
X_train_df, X_test_df, y_train, y_test = train_test_split(
    X_df, y, test_size=0.20, random_state=42, stratify=y
)

feature_union = FeatureUnion([
    ('word', TfidfVectorizer(analyzer='word', ngram_range=(1, 2), max_features=1000)),
    ('char', TfidfVectorizer(analyzer='char_wb', ngram_range=(2, 4), max_features=1000))
])

preprocessor = ColumnTransformer(
    transformers=[
        ('text', feature_union, 'complaint_description'),
        ('numeric', StandardScaler(), ['validity', 'priority']),
        ('categorical', OneHotEncoder(handle_unknown='ignore'), ['subcategory_name'])
    ]
)

X_train = preprocessor.fit_transform(X_train_df)
X_test = preprocessor.transform(X_test_df)

print("[2/4] Balancing original dataset classes with SMOTE...")
smote = SMOTE(random_state=42, k_neighbors=3)
X_train_res, y_train_res = smote.fit_resample(X_train, y_train)

print("[3/4] Training Algorithm (Random Forest) securely...")
best_model = RandomForestClassifier(random_state=42, n_estimators=100, max_depth=10, class_weight='balanced')
best_model.fit(X_train_res, y_train_res)

print("[4/4] Evaluating and generating final results...")
y_pred = best_model.predict(X_test)
acc = accuracy_score(y_test, y_pred)
print(f"\n=> 🎯 SUBCATEGORY-SUPERCHARGED MODEL ACCURACY: {acc*100:.2f}%\n")

report = classification_report(y_test, y_pred, target_names=target_names)
print(report)

with open(os.path.join(RESULTS_DIR, 'classification_report.txt'), 'w') as f:
    f.write("Original Dataset Metrics - NLP + Backend Pricing variables + Subcategory contexts\n")
    f.write(f"Final Accuracy: {acc*100:.2f}%\n")
    f.write("="*50 + "\n")
    f.write(report)

cm = confusion_matrix(y_test, y_pred)
plt.figure()
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', xticklabels=target_names, yticklabels=target_names)
plt.ylabel('Actual Label')
plt.xlabel('Prediction')
plt.title(f'Confusion Matrix (Acc {acc*100:.1f}%)')
plt.tight_layout()
plt.savefig(os.path.join(RESULTS_DIR, 'confusion_matrix.png'))
plt.close()

print(f"✅ Success! Results written to {RESULTS_DIR}")
