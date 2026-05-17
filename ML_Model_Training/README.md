# AI Complaint System - Machine Learning Pipeline

This repository contains the codebase to train, test, and evaluate a Machine Learning model for the AI Complaints classification dataset.

## 📂 Project Structure

```
ML_Model_Training/
├── data/
│   └── complaints_full.csv        # The full 500-instance dataset exported from postgres
├── notebooks/                     # For exploratory jupyter notebooks (if any)
├── results/                       # Plots and metrics files output
│   ├── classification_report.txt      # Final hold-out metrics
│   ├── confusion_matrix.png           # Final hold-out confusion matrix
│   ├── model_comparison.csv           # 5-fold classifier and SMOTE comparison
│   ├── ablation_study.csv             # Text/category/numeric feature ablation
│   ├── cross_validation_results.csv   # Combined CV results table
│   ├── tfidf_variant_comparison.csv   # Word, character, and combined TF-IDF comparison
│   └── kmeans_clusters_pca.png        # Exploratory SVD/KMeans plot
├── src/
│   └── pipeline.py                # Main executable training pipeline
├── requirements.txt               # Dependencies
└── README.md                      # Instructions
```

## ⚙️ Model Pipeline Details

1. **Preprocessing**: Missing values are dropped. Bengali, English, and Banglish complaint text is normalized with Unicode normalization, lowercasing, punctuation cleanup, repeated character cleanup, a Banglish dictionary, and optional Bengali stopword removal.
2. **Feature extraction**: The pipeline compares word TF-IDF, character `char_wb` TF-IDF, and combined word-character TF-IDF. It also tests category one-hot encoding and scaled backend numeric features (`validity`, `priority`).
3. **Data split**: The dataset is split into `80%` training and `20%` hold-out evaluation segments in a stratified manner.
4. **Class imbalance**: Models use `class_weight='balanced'` where supported. SMOTE is tested inside an `imblearn` pipeline so oversampling occurs only on training folds.
5. **K-fold and tuning**: Using `StratifiedKFold` with 5 folds, the script compares Logistic Regression, Linear SVC, Random Forest, and a Voting ensemble. `RandomizedSearchCV` tunes TF-IDF and model hyperparameters.
6. **Evaluation**: Output includes classification report, confusion matrix, model comparison table, cross-validation table, imbalance comparison, ablation study, and SVD/KMeans plots.

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
