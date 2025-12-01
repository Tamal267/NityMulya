"""
Model Training Script for BanglaBERT Fine-tuning
For Priority Classification Task
"""

import torch
from transformers import (
    AutoTokenizer, 
    AutoModelForSequenceClassification,
    TrainingArguments,
    Trainer,
    DataCollatorWithPadding
)
from datasets import Dataset, DatasetDict
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_recall_fscore_support, confusion_matrix
import numpy as np

# Configuration
MODEL_NAME = "sagorsarker/bangla-bert-base"
MAX_LENGTH = 512
BATCH_SIZE = 8
LEARNING_RATE = 2e-5
EPOCHS = 10
OUTPUT_DIR = "./models/priority_classifier"

# Priority labels
PRIORITY_LABELS = {
    "Low": 0,
    "Medium": 1,
    "High": 2,
    "Urgent": 3
}

def load_data(csv_path: str):
    """Load labeled complaint data"""
    df = pd.read_csv(csv_path)
    
    # Required columns: complaint_text, priority_label
    assert 'complaint_text' in df.columns
    assert 'priority_label' in df.columns
    
    # Convert labels to numeric
    df['label'] = df['priority_label'].map(PRIORITY_LABELS)
    
    return df

def prepare_dataset(df: pd.DataFrame, test_size=0.2):
    """Split and prepare dataset"""
    train_df, test_df = train_test_split(
        df, 
        test_size=test_size, 
        stratify=df['label'],
        random_state=42
    )
    
    train_dataset = Dataset.from_pandas(train_df[['complaint_text', 'label']])
    test_dataset = Dataset.from_pandas(test_df[['complaint_text', 'label']])
    
    dataset_dict = DatasetDict({
        'train': train_dataset,
        'test': test_dataset
    })
    
    return dataset_dict

def tokenize_function(examples, tokenizer):
    """Tokenize texts"""
    return tokenizer(
        examples['complaint_text'],
        truncation=True,
        max_length=MAX_LENGTH,
        padding=True
    )

def compute_metrics(eval_pred):
    """Compute evaluation metrics"""
    predictions, labels = eval_pred
    predictions = np.argmax(predictions, axis=1)
    
    # Calculate metrics
    accuracy = accuracy_score(labels, predictions)
    precision, recall, f1, _ = precision_recall_fscore_support(
        labels, predictions, average='macro'
    )
    
    # Confusion matrix
    cm = confusion_matrix(labels, predictions)
    
    return {
        'accuracy': accuracy,
        'precision': precision,
        'recall': recall,
        'f1': f1,
        'confusion_matrix': cm.tolist()
    }

def train_priority_classifier(data_path: str):
    """Main training function"""
    print("🚀 Starting BanglaBERT fine-tuning for Priority Classification")
    
    # 1. Load tokenizer and model
    print(f"📥 Loading model: {MODEL_NAME}")
    tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
    model = AutoModelForSequenceClassification.from_pretrained(
        MODEL_NAME,
        num_labels=4  # Low, Medium, High, Urgent
    )
    
    # 2. Load and prepare data
    print(f"📊 Loading data from: {data_path}")
    df = load_data(data_path)
    print(f"   Total samples: {len(df)}")
    print(f"   Class distribution:\n{df['priority_label'].value_counts()}")
    
    dataset = prepare_dataset(df)
    
    # 3. Tokenize
    print("🔤 Tokenizing texts...")
    tokenized_dataset = dataset.map(
        lambda x: tokenize_function(x, tokenizer),
        batched=True
    )
    
    # 4. Data collator
    data_collator = DataCollatorWithPadding(tokenizer=tokenizer)
    
    # 5. Training arguments
    training_args = TrainingArguments(
        output_dir=OUTPUT_DIR,
        learning_rate=LEARNING_RATE,
        per_device_train_batch_size=BATCH_SIZE,
        per_device_eval_batch_size=BATCH_SIZE,
        num_train_epochs=EPOCHS,
        weight_decay=0.01,
        evaluation_strategy="epoch",
        save_strategy="epoch",
        load_best_model_at_end=True,
        metric_for_best_model="f1",
        push_to_hub=False,
        logging_dir='./logs',
        logging_steps=10,
    )
    
    # 6. Trainer
    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=tokenized_dataset["train"],
        eval_dataset=tokenized_dataset["test"],
        tokenizer=tokenizer,
        data_collator=data_collator,
        compute_metrics=compute_metrics,
    )
    
    # 7. Train
    print("🏋️ Training started...")
    trainer.train()
    
    # 8. Evaluate
    print("📈 Evaluating model...")
    metrics = trainer.evaluate()
    print("\n✅ Final Metrics:")
    print(f"   Accuracy: {metrics['eval_accuracy']:.4f}")
    print(f"   Precision: {metrics['eval_precision']:.4f}")
    print(f"   Recall: {metrics['eval_recall']:.4f}")
    print(f"   F1-Score: {metrics['eval_f1']:.4f}")
    
    # 9. Save model
    print(f"\n💾 Saving model to: {OUTPUT_DIR}")
    trainer.save_model(OUTPUT_DIR)
    tokenizer.save_pretrained(OUTPUT_DIR)
    
    print("\n🎉 Training complete!")
    return trainer, metrics

if __name__ == "__main__":
    # Path to your labeled data
    DATA_PATH = "../data/labeled_complaints_priority.csv"
    
    # Train
    trainer, metrics = train_priority_classifier(DATA_PATH)
    
    # Test predictions
    print("\n🧪 Testing predictions...")
    test_texts = [
        "আমার বাচ্চা এই পণ্য খেয়ে অসুস্থ হয়ে গেছে। জরুরি ভিত্তিতে ব্যবস্থা নিন।",  # Urgent
        "দোকানদার দাম বেশি নিয়েছে",  # Medium
        "পণ্যের গুণগত মান খারাপ",  # High
    ]
    
    tokenizer = AutoTokenizer.from_pretrained(OUTPUT_DIR)
    model = AutoModelForSequenceClassification.from_pretrained(OUTPUT_DIR)
    model.eval()
    
    label_names = {v: k for k, v in PRIORITY_LABELS.items()}
    
    for text in test_texts:
        inputs = tokenizer(text, return_tensors="pt", truncation=True, max_length=MAX_LENGTH)
        with torch.no_grad():
            outputs = model(**inputs)
        
        prediction = torch.argmax(outputs.logits, dim=1).item()
        confidence = torch.softmax(outputs.logits, dim=1)[0][prediction].item()
        
        print(f"\nText: {text}")
        print(f"Predicted: {label_names[prediction]} (confidence: {confidence:.3f})")
