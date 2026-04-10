# AI Complaint System - Machine Learning Pipeline

This repository contains the codebase to train, test, and evaluate a Machine Learning model for the AI Complaints classification dataset.

## 📂 Project Structure

```
ML_Model_Training/
├── data/
│   └── complaints_full.csv        # The full 500-instance dataset exported from postgres
├── notebooks/                     # For exploratory jupyter notebooks (if any)
├── results/                       # Plots and metrics files output
│   ├── classification_report.txt  # Model precision, recall, f1, support metrics
│   ├── confusion_matrix.png       # Generated heat map for the confusion matrix
│   ├── feature_importance.png     # Evaluation of feature relevance in RandomForest
│   └── kmeans_clusters_pca.png    # Exploratory PCA-KMeans Plot
├── src/
│   └── pipeline.py                # Main executable training pipeline
├── requirements.txt               # Dependencies
└── README.md                      # Instructions
```

## ⚙️ Model Pipeline Details

1. **Preprocessing**: Missing values are dropped, and textual features (`complaint_description`) are vectorized using a `TfidfVectorizer` utilizing a character WB-analyzer. This is highly effective at managing multi-lingual text contexts like Bangla + English + Banglish.
2. **KMeans Exploration**: Explores the distribution of textual data into 3 classes.
3. **Data Split**: The dataset is split into `80%` Training and `20%` Evaluation segments in a stratified manner.
4. **Data Balancing**: The `SMOTE-Tomek` algorithm is applied to fix class imbalance (Since `medium` complaints hold the majority weighting).
5. **K-Fold & Grid Search**: Using `StratifiedKFold` (5 folds), it fine tunes the `RandomForestClassifier` parameters.
6. **Validation Evaluation**: Validation output includes plotting charts (ROC, Confusion Matrix) and calculates extensive metrics: Accuracy, Precision, Recall, F1, Support, Macro-Average, and Weighted-Average.

## 🚀 How to Run

1. **Ensure setup**: Make sure you have python version `>= 3.9`. Set up a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

2. **Execute the Pipeline**:
   ```bash
   cd src
   python pipeline.py
   ```

Check the `results` folder immediately after completion to inspect the generated charts and the `classification_report.txt`.