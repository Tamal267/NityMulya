"""Train and evaluate complaint severity classifiers.

This script is intentionally classical and CPU-friendly. It compares Bengali,
English, and Banglish text preprocessing, TF-IDF feature variants, backend
numeric/categorical feature fusion, class imbalance handling, and several
Scikit-Learn classifiers on the 500 complaint dataset.
"""

from __future__ import annotations

import json
import os
import re
import shutil
import unicodedata
import warnings
from pathlib import Path
from typing import Any

os.environ.setdefault("MPLCONFIGDIR", "/tmp/matplotlib")

import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from imblearn.over_sampling import SMOTE
from imblearn.pipeline import Pipeline as ImbPipeline
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.cluster import KMeans
from sklearn.compose import ColumnTransformer
from sklearn.decomposition import TruncatedSVD
from sklearn.ensemble import RandomForestClassifier, VotingClassifier
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix,
    f1_score,
    make_scorer,
    precision_score,
    recall_score,
)
from sklearn.model_selection import (
    RandomizedSearchCV,
    StratifiedKFold,
    cross_validate,
    train_test_split,
)
from sklearn.pipeline import FeatureUnion, Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.svm import LinearSVC

warnings.filterwarnings("ignore")

RANDOM_STATE = 42
BASE_DIR = Path(__file__).resolve().parents[1]
REPO_DIR = BASE_DIR.parent
RESULTS_DIR = BASE_DIR / "results"
DATA_PATH = BASE_DIR / "data" / "complaints_full.csv"
PAPER_FIGURES_DIR = REPO_DIR / "Directory for Thesis" / "Journal Paper" / "figures"

CLASS_MAPPING = {"weak": 0, "medium": 1, "high": 2}
TARGET_NAMES = ["weak", "medium", "high"]

BENGALI_STOPWORDS = {
    "আমি",
    "আমরা",
    "আপনি",
    "এ",
    "এই",
    "এক",
    "এটা",
    "এর",
    "ও",
    "করতে",
    "করছে",
    "করে",
    "করা",
    "কে",
    "কি",
    "কিন্তু",
    "ছিল",
    "থেকে",
    "তার",
    "তারা",
    "তাই",
    "তবে",
    "না",
    "নাই",
    "পর",
    "মধ্যে",
    "যদি",
    "যার",
    "যে",
    "যা",
    "জন্য",
    "সাথে",
    "হতে",
    "হয়",
    "হয়",
    "হলো",
}

MARKETPLACE_BANGLISH_MAP = {
    "alu": "আলু",
    "baje": "বাজে",
    "bashi": "বাসি",
    "beshi": "বেশি",
    "chal": "চাল",
    "chini": "চিনি",
    "chola": "ছোলা",
    "dam": "দাম",
    "dal": "ডাল",
    "dim": "ডিম",
    "dokan": "দোকান",
    "dokandar": "দোকানদার",
    "dudh": "দুধ",
    "expired": "মেয়াদোত্তীর্ণ",
    "fake": "নকল",
    "kharap": "খারাপ",
    "kom": "কম",
    "list": "লিস্ট",
    "lobon": "লবণ",
    "meyad": "মেয়াদ",
    "milk": "দুধ",
    "moida": "ময়দা",
    "morich": "মরিচ",
    "nosto": "নষ্ট",
    "oil": "তেল",
    "peyaj": "পেঁয়াজ",
    "ponno": "পণ্য",
    "price": "দাম",
    "product": "পণ্য",
    "receipt": "রসিদ",
    "rice": "চাল",
    "taka": "টাকা",
    "tel": "তেল",
}


def load_banglish_map() -> dict[str, str]:
    """Load the larger app dictionary when available, then add marketplace terms."""
    dictionary_path = REPO_DIR / "nlp_service" / "banglish_dictionary.json"
    loaded: dict[str, str] = {}
    if dictionary_path.exists():
        with dictionary_path.open("r", encoding="utf-8") as file_obj:
            raw = json.load(file_obj)
        loaded = {str(key).lower(): str(value) for key, value in raw.items()}

    loaded.update(MARKETPLACE_BANGLISH_MAP)
    return loaded


BANGLISH_MAP = load_banglish_map()
PUNCTUATION_RE = re.compile(r"[^0-9A-Za-z_\s\u0980-\u09FF]+", flags=re.UNICODE)
LATIN_REPEAT_RE = re.compile(r"([A-Za-z])\1{2,}")
BENGALI_REPEAT_RE = re.compile(r"([\u0980-\u09FF])\1{2,}")


class ComplaintTextNormalizer(BaseEstimator, TransformerMixin):
    """Normalize Bengali, English, and Banglish complaint text."""

    def __init__(self, remove_bengali_stopwords: bool = False):
        self.remove_bengali_stopwords = remove_bengali_stopwords

    def fit(self, X: Any, y: Any = None) -> "ComplaintTextNormalizer":
        return self

    def transform(self, X: Any) -> list[str]:
        if isinstance(X, pd.DataFrame):
            values = X.iloc[:, 0]
        elif isinstance(X, pd.Series):
            values = X
        elif isinstance(X, np.ndarray) and X.ndim > 1:
            values = X[:, 0]
        else:
            values = X

        return [self._normalize(value) for value in values]

    def _normalize(self, value: Any) -> str:
        if pd.isna(value):
            text = ""
        else:
            text = str(value)

        text = unicodedata.normalize("NFKC", text)
        text = text.lower()
        text = LATIN_REPEAT_RE.sub(r"\1\1", text)
        text = BENGALI_REPEAT_RE.sub(r"\1\1", text)
        text = PUNCTUATION_RE.sub(" ", text)

        tokens: list[str] = []
        for token in text.split():
            normalized = BANGLISH_MAP.get(token, token)
            if self.remove_bengali_stopwords and normalized in BENGALI_STOPWORDS:
                continue
            tokens.append(normalized)

        return " ".join(tokens)


def build_classifier(model_key: str) -> Any:
    if model_key == "logistic_regression":
        return LogisticRegression(
            C=1.0,
            class_weight="balanced",
            max_iter=5000,
            random_state=RANDOM_STATE,
            solver="liblinear",
        )
    if model_key == "linear_svc":
        return LinearSVC(
            C=1.0,
            class_weight="balanced",
            dual="auto",
            max_iter=20000,
            random_state=RANDOM_STATE,
        )
    if model_key == "random_forest":
        return RandomForestClassifier(
            class_weight="balanced",
            max_depth=None,
            min_samples_split=2,
            n_estimators=200,
            n_jobs=1,
            random_state=RANDOM_STATE,
        )
    if model_key == "voting":
        return VotingClassifier(
            estimators=[
                ("lr", build_classifier("logistic_regression")),
                ("svm", build_classifier("linear_svc")),
                ("rf", build_classifier("random_forest")),
            ],
            voting="hard",
        )
    raise ValueError(f"Unknown model key: {model_key}")


def build_text_pipeline(
    tfidf_variant: str = "word_char",
    word_ngram_range: tuple[int, int] = (1, 2),
    char_ngram_range: tuple[int, int] = (3, 5),
    word_max_features: int = 1000,
    char_max_features: int = 1000,
    remove_bengali_stopwords: bool = False,
) -> Pipeline:
    tfidf_parts: list[tuple[str, TfidfVectorizer]] = []

    if tfidf_variant in {"word", "word_char"}:
        tfidf_parts.append(
            (
                "word",
                TfidfVectorizer(
                    analyzer="word",
                    max_features=word_max_features,
                    min_df=1,
                    ngram_range=word_ngram_range,
                    sublinear_tf=True,
                ),
            )
        )

    if tfidf_variant in {"char", "word_char"}:
        tfidf_parts.append(
            (
                "char",
                TfidfVectorizer(
                    analyzer="char_wb",
                    max_features=char_max_features,
                    min_df=1,
                    ngram_range=char_ngram_range,
                    sublinear_tf=True,
                ),
            )
        )

    if not tfidf_parts:
        raise ValueError(f"Unsupported TF-IDF variant: {tfidf_variant}")

    return Pipeline(
        steps=[
            ("normalize", ComplaintTextNormalizer(remove_bengali_stopwords)),
            ("tfidf", FeatureUnion(tfidf_parts)),
        ]
    )


def build_feature_transformer(
    feature_set: str = "full",
    tfidf_variant: str = "word_char",
    word_ngram_range: tuple[int, int] = (1, 2),
    char_ngram_range: tuple[int, int] = (3, 5),
    word_max_features: int = 1000,
    char_max_features: int = 1000,
    remove_bengali_stopwords: bool = False,
) -> ColumnTransformer:
    transformers: list[tuple[str, Any, Any]] = [
        (
            "text",
            build_text_pipeline(
                tfidf_variant=tfidf_variant,
                word_ngram_range=word_ngram_range,
                char_ngram_range=char_ngram_range,
                word_max_features=word_max_features,
                char_max_features=char_max_features,
                remove_bengali_stopwords=remove_bengali_stopwords,
            ),
            "complaint_description",
        )
    ]

    if feature_set in {"text_category", "full"}:
        transformers.append(
            (
                "category",
                OneHotEncoder(handle_unknown="ignore", sparse_output=True),
                ["subcategory_name"],
            )
        )

    if feature_set in {"text_numeric", "full"}:
        transformers.append(
            ("numeric", StandardScaler(with_mean=False), ["validity", "priority"])
        )

    if feature_set not in {"text", "text_category", "text_numeric", "full"}:
        raise ValueError(f"Unsupported feature set: {feature_set}")

    return ColumnTransformer(transformers=transformers, sparse_threshold=0.3)


def build_pipeline(
    model_key: str,
    feature_set: str = "full",
    tfidf_variant: str = "word_char",
    word_ngram_range: tuple[int, int] = (1, 2),
    char_ngram_range: tuple[int, int] = (3, 5),
    word_max_features: int = 1000,
    char_max_features: int = 1000,
    remove_bengali_stopwords: bool = False,
    use_smote: bool = False,
) -> ImbPipeline:
    smote_step: Any = "passthrough"
    if use_smote:
        smote_step = SMOTE(k_neighbors=3, random_state=RANDOM_STATE)

    return ImbPipeline(
        steps=[
            (
                "features",
                build_feature_transformer(
                    feature_set=feature_set,
                    tfidf_variant=tfidf_variant,
                    word_ngram_range=word_ngram_range,
                    char_ngram_range=char_ngram_range,
                    word_max_features=word_max_features,
                    char_max_features=char_max_features,
                    remove_bengali_stopwords=remove_bengali_stopwords,
                ),
            ),
            ("smote", smote_step),
            ("classifier", build_classifier(model_key)),
        ]
    )


SCORING = {
    "accuracy": make_scorer(accuracy_score),
    "precision_weighted": make_scorer(
        precision_score, average="weighted", zero_division=0
    ),
    "recall_weighted": make_scorer(recall_score, average="weighted", zero_division=0),
    "f1_weighted": make_scorer(f1_score, average="weighted", zero_division=0),
}

MODEL_LABELS = {
    "logistic_regression": "Logistic Regression",
    "linear_svc": "Linear SVC",
    "random_forest": "Random Forest",
    "voting": "Voting Ensemble",
}

FEATURE_LABELS = {
    "text": "Text only",
    "text_category": "Text + product category",
    "text_numeric": "Text + numeric features",
    "full": "Full hybrid feature set",
}


def load_dataset() -> tuple[pd.DataFrame, pd.Series, pd.DataFrame]:
    df = pd.read_csv(DATA_PATH)
    required_columns = [
        "complaint_description",
        "complaint_classification",
        "subcategory_name",
        "validity",
        "priority",
    ]
    df = df.dropna(subset=required_columns).copy()
    df["target"] = df["complaint_classification"].map(CLASS_MAPPING)
    df = df.dropna(subset=["target"]).copy()
    df["target"] = df["target"].astype(int)

    X = df[["complaint_description", "subcategory_name", "validity", "priority"]]
    y = df["target"]
    return X, y, df


def summarize_cv_result(
    name: str,
    pipeline: ImbPipeline,
    X: pd.DataFrame,
    y: pd.Series,
    cv: StratifiedKFold,
    **extra: Any,
) -> dict[str, Any]:
    result = cross_validate(
        pipeline,
        X,
        y,
        cv=cv,
        n_jobs=-1,
        scoring=SCORING,
        return_train_score=False,
    )

    row: dict[str, Any] = {"experiment": name}
    row.update(extra)
    for metric in SCORING:
        values = result[f"test_{metric}"]
        row[f"mean_{metric}"] = float(np.mean(values))
        row[f"std_{metric}"] = float(np.std(values))
    return row


def save_table(df: pd.DataFrame, csv_name: str, tex_name: str) -> None:
    csv_path = RESULTS_DIR / csv_name
    tex_path = RESULTS_DIR / tex_name
    df.to_csv(csv_path, index=False)

    formatted = df.copy()
    for column in formatted.columns:
        if pd.api.types.is_float_dtype(formatted[column]):
            formatted[column] = formatted[column].map(lambda value: f"{value:.4f}")

    with tex_path.open("w", encoding="utf-8") as file_obj:
        file_obj.write(dataframe_to_latex(formatted))


def latex_escape(value: Any) -> str:
    text = str(value)
    replacements = {
        "\\": r"\textbackslash{}",
        "&": r"\&",
        "%": r"\%",
        "$": r"\$",
        "#": r"\#",
        "_": r"\_",
        "{": r"\{",
        "}": r"\}",
        "~": r"\textasciitilde{}",
        "^": r"\textasciicircum{}",
    }
    for original, replacement in replacements.items():
        text = text.replace(original, replacement)
    return text


def dataframe_to_latex(df: pd.DataFrame) -> str:
    column_spec = "l" * len(df.columns)
    lines = [rf"\begin{{tabular}}{{{column_spec}}}", r"\toprule"]
    lines.append(" & ".join(latex_escape(column) for column in df.columns) + r" \\")
    lines.append(r"\midrule")
    for _, row in df.iterrows():
        lines.append(" & ".join(latex_escape(value) for value in row.tolist()) + r" \\")
    lines.extend([r"\bottomrule", r"\end{tabular}", ""])
    return "\n".join(lines)


def compact_params(params: dict[str, Any]) -> dict[str, str]:
    compact: dict[str, str] = {}
    for key, value in params.items():
        if isinstance(value, tuple):
            compact[key] = str(value)
        elif isinstance(value, SMOTE):
            compact[key] = "SMOTE(k_neighbors=3)"
        else:
            compact[key] = str(value)
    return compact


def run_tfidf_variant_comparison(
    X: pd.DataFrame, y: pd.Series, cv: StratifiedKFold
) -> pd.DataFrame:
    variants = [
        ("Word unigram", "word", (1, 1), (3, 5)),
        ("Word unigram + bigram", "word", (1, 2), (3, 5)),
        ("Character wb 3-5", "char", (1, 2), (3, 5)),
        ("Word + character", "word_char", (1, 2), (3, 5)),
    ]

    rows = []
    for label, variant, word_range, char_range in variants:
        pipeline = build_pipeline(
            "linear_svc",
            tfidf_variant=variant,
            word_ngram_range=word_range,
            char_ngram_range=char_range,
            use_smote=False,
        )
        rows.append(
            summarize_cv_result(
                label,
                pipeline,
                X,
                y,
                cv,
                classifier="Linear SVC",
                tfidf_variant=variant,
                word_ngram_range=str(word_range),
                char_ngram_range=str(char_range),
                imbalance_handling="class_weight=balanced",
            )
        )

    df = pd.DataFrame(rows).sort_values("mean_f1_weighted", ascending=False)
    save_table(df, "tfidf_variant_comparison.csv", "tfidf_variant_comparison.tex")
    return df


def run_model_comparison(X: pd.DataFrame, y: pd.Series, cv: StratifiedKFold) -> pd.DataFrame:
    rows = []
    for model_key in [
        "logistic_regression",
        "linear_svc",
        "random_forest",
        "voting",
    ]:
        for use_smote in [False, True]:
            label = MODEL_LABELS[model_key]
            imbalance = "class_weight=balanced"
            if use_smote:
                imbalance = "class_weight=balanced + SMOTE"
            pipeline = build_pipeline(model_key, use_smote=use_smote)
            rows.append(
                summarize_cv_result(
                    f"{label} ({'SMOTE' if use_smote else 'no SMOTE'})",
                    pipeline,
                    X,
                    y,
                    cv,
                    classifier=label,
                    feature_set="Full hybrid feature set",
                    imbalance_handling=imbalance,
                )
            )

    df = pd.DataFrame(rows).sort_values("mean_f1_weighted", ascending=False)
    save_table(df, "model_comparison.csv", "model_comparison.tex")

    imbalance_df = df[
        [
            "classifier",
            "imbalance_handling",
            "mean_accuracy",
            "std_accuracy",
            "mean_precision_weighted",
            "mean_recall_weighted",
            "mean_f1_weighted",
            "std_f1_weighted",
        ]
    ].copy()
    save_table(imbalance_df, "imbalance_comparison.csv", "imbalance_comparison.tex")
    return df


def tune_models(
    X_train: pd.DataFrame, y_train: pd.Series, cv: StratifiedKFold
) -> tuple[dict[str, RandomizedSearchCV], pd.DataFrame]:
    common_params: dict[str, list[Any]] = {
        "features__text__normalize__remove_bengali_stopwords": [False, True],
        "features__text__tfidf__word__ngram_range": [(1, 1), (1, 2)],
        "features__text__tfidf__word__max_features": [500, 1000, 2000],
        "features__text__tfidf__char__max_features": [500, 1000, 2000],
        "smote": ["passthrough", SMOTE(k_neighbors=3, random_state=RANDOM_STATE)],
    }

    model_spaces: dict[str, tuple[dict[str, list[Any]], int]] = {
        "logistic_regression": (
            {**common_params, "classifier__C": [0.1, 0.5, 1.0, 2.0, 5.0, 10.0]},
            36,
        ),
        "linear_svc": (
            {**common_params, "classifier__C": [0.1, 0.5, 1.0, 2.0, 5.0, 10.0]},
            36,
        ),
        "random_forest": (
            {
                **common_params,
                "classifier__max_depth": [None, 8, 12, 20],
                "classifier__min_samples_split": [2, 5, 10],
                "classifier__n_estimators": [100, 200, 300],
            },
            48,
        ),
    }

    searches: dict[str, RandomizedSearchCV] = {}
    rows = []
    for model_key, (param_space, n_iter) in model_spaces.items():
        print(f"Tuning {MODEL_LABELS[model_key]} with RandomizedSearchCV...")
        pipeline = build_pipeline(model_key, use_smote=False)
        search = RandomizedSearchCV(
            estimator=pipeline,
            param_distributions=param_space,
            n_iter=n_iter,
            scoring=SCORING["f1_weighted"],
            cv=cv,
            n_jobs=-1,
            random_state=RANDOM_STATE,
            refit=True,
            error_score="raise",
            verbose=0,
        )
        search.fit(X_train, y_train)
        searches[model_key] = search

        best_index = search.best_index_
        rows.append(
            {
                "classifier": MODEL_LABELS[model_key],
                "best_mean_f1_weighted": float(search.best_score_),
                "best_std_f1_weighted": float(
                    search.cv_results_["std_test_score"][best_index]
                ),
                "best_params": json.dumps(
                    compact_params(search.best_params_),
                    ensure_ascii=False,
                    sort_keys=True,
                ),
            }
        )

    tuning_df = pd.DataFrame(rows).sort_values(
        "best_mean_f1_weighted", ascending=False
    )
    save_table(tuning_df, "hyperparameter_tuning_results.csv", "hyperparameter_tuning_results.tex")
    return searches, tuning_df


def evaluate_tuned_models(
    searches: dict[str, RandomizedSearchCV],
    X: pd.DataFrame,
    y: pd.Series,
    cv: StratifiedKFold,
) -> pd.DataFrame:
    rows = []
    for model_key, search in searches.items():
        rows.append(
            summarize_cv_result(
                f"Tuned {MODEL_LABELS[model_key]}",
                search.best_estimator_,
                X,
                y,
                cv,
                classifier=f"Tuned {MODEL_LABELS[model_key]}",
                feature_set="Full hybrid feature set",
                imbalance_handling=(
                    "SMOTE"
                    if isinstance(search.best_estimator_.named_steps["smote"], SMOTE)
                    else "No SMOTE"
                ),
            )
        )

    df = pd.DataFrame(rows).sort_values("mean_f1_weighted", ascending=False)
    save_table(df, "tuned_cross_validation_results.csv", "tuned_cross_validation_results.tex")
    return df


def build_pipeline_from_best_params(
    model_key: str, best_params: dict[str, Any], feature_set: str
) -> ImbPipeline:
    use_smote = isinstance(best_params.get("smote"), SMOTE)
    word_ngram_range = best_params.get(
        "features__text__tfidf__word__ngram_range", (1, 2)
    )
    word_max_features = best_params.get("features__text__tfidf__word__max_features", 1000)
    char_max_features = best_params.get("features__text__tfidf__char__max_features", 1000)
    remove_stopwords = best_params.get(
        "features__text__normalize__remove_bengali_stopwords", False
    )

    classifier_params = {
        key.replace("classifier__", ""): value
        for key, value in best_params.items()
        if key.startswith("classifier__")
    }

    pipeline = build_pipeline(
        model_key,
        feature_set=feature_set,
        word_ngram_range=word_ngram_range,
        word_max_features=word_max_features,
        char_max_features=char_max_features,
        remove_bengali_stopwords=remove_stopwords,
        use_smote=use_smote,
    )
    pipeline.named_steps["classifier"].set_params(**classifier_params)
    return pipeline


def run_ablation_study(
    best_model_key: str,
    best_params: dict[str, Any],
    X: pd.DataFrame,
    y: pd.Series,
    cv: StratifiedKFold,
) -> pd.DataFrame:
    use_smote = isinstance(best_params.get("smote"), SMOTE)

    rows = []
    for feature_set in ["text", "text_category", "text_numeric", "full"]:
        pipeline = build_pipeline_from_best_params(
            best_model_key, best_params, feature_set
        )
        rows.append(
            summarize_cv_result(
                FEATURE_LABELS[feature_set],
                pipeline,
                X,
                y,
                cv,
                classifier=MODEL_LABELS[best_model_key],
                feature_set=FEATURE_LABELS[feature_set],
                imbalance_handling="SMOTE" if use_smote else "No SMOTE",
            )
        )

    df = pd.DataFrame(rows).sort_values("mean_f1_weighted", ascending=False)
    save_table(df, "ablation_study.csv", "ablation_study.tex")
    return df


def plot_test_distribution(y_test: pd.Series) -> None:
    counts = pd.Series(y_test).value_counts().sort_index()
    labels = [TARGET_NAMES[index] for index in counts.index]

    plt.figure(figsize=(6, 4))
    sns.barplot(x=labels, y=counts.values, palette="viridis")
    plt.xlabel("Complaint class")
    plt.ylabel("Number of complaints")
    plt.title("Hold-out Test Set Distribution")
    plt.tight_layout()
    plt.savefig(RESULTS_DIR / "test_set_distribution.png", dpi=220)
    plt.close()


def plot_confusion_matrix(cm: np.ndarray, accuracy: float) -> None:
    plt.figure(figsize=(6, 5))
    sns.heatmap(
        cm,
        annot=True,
        cmap="Blues",
        fmt="d",
        xticklabels=TARGET_NAMES,
        yticklabels=TARGET_NAMES,
    )
    plt.ylabel("Actual label")
    plt.xlabel("Predicted label")
    plt.title(f"Confusion Matrix (Accuracy {accuracy * 100:.1f}%)")
    plt.tight_layout()
    plt.savefig(RESULTS_DIR / "confusion_matrix.png", dpi=220)
    plt.close()


def plot_feature_space(final_model: ImbPipeline, X: pd.DataFrame, y: pd.Series) -> None:
    feature_matrix = final_model.named_steps["features"].transform(X)
    svd = TruncatedSVD(n_components=2, random_state=RANDOM_STATE)
    components = svd.fit_transform(feature_matrix)

    plot_df = pd.DataFrame(
        {
            "component_1": components[:, 0],
            "component_2": components[:, 1],
            "class": [TARGET_NAMES[index] for index in y],
        }
    )

    plt.figure(figsize=(7, 5))
    sns.scatterplot(
        data=plot_df,
        x="component_1",
        y="component_2",
        hue="class",
        palette="Set2",
        s=45,
        alpha=0.85,
    )
    plt.title("SVD Projection of Hybrid Complaint Features")
    plt.tight_layout()
    plt.savefig(RESULTS_DIR / "nlp_pca_clusters.png", dpi=220)
    plt.close()

    clusters = KMeans(n_clusters=3, n_init=20, random_state=RANDOM_STATE).fit_predict(
        feature_matrix
    )
    cluster_df = plot_df.copy()
    cluster_df["cluster"] = [f"Cluster {value}" for value in clusters]

    plt.figure(figsize=(7, 5))
    sns.scatterplot(
        data=cluster_df,
        x="component_1",
        y="component_2",
        hue="cluster",
        palette="Set1",
        s=45,
        alpha=0.85,
    )
    plt.title("K-Means Clusters on Hybrid Feature Space")
    plt.tight_layout()
    plt.savefig(RESULTS_DIR / "kmeans_clusters_pca.png", dpi=220)
    plt.close()


def copy_figures_to_paper() -> None:
    PAPER_FIGURES_DIR.mkdir(parents=True, exist_ok=True)
    for filename in [
        "test_set_distribution.png",
        "confusion_matrix.png",
        "nlp_pca_clusters.png",
        "kmeans_clusters_pca.png",
    ]:
        source = RESULTS_DIR / filename
        if source.exists():
            shutil.copy2(source, PAPER_FIGURES_DIR / filename)


def write_final_report(
    final_model_name: str,
    final_model: ImbPipeline,
    y_test: pd.Series,
    y_pred: np.ndarray,
    holdout_metrics: dict[str, float],
    cm: np.ndarray,
) -> None:
    report_text = classification_report(
        y_test,
        y_pred,
        labels=[0, 1, 2],
        target_names=TARGET_NAMES,
        digits=4,
        zero_division=0,
    )
    report_dict = classification_report(
        y_test,
        y_pred,
        labels=[0, 1, 2],
        target_names=TARGET_NAMES,
        digits=4,
        zero_division=0,
        output_dict=True,
    )

    pd.DataFrame(report_dict).transpose().to_csv(
        RESULTS_DIR / "classification_report.csv"
    )
    pd.DataFrame(cm, index=TARGET_NAMES, columns=TARGET_NAMES).to_csv(
        RESULTS_DIR / "confusion_matrix.csv"
    )

    with (RESULTS_DIR / "classification_report.txt").open(
        "w", encoding="utf-8"
    ) as file_obj:
        file_obj.write("AI Enhanced Complaint Management System\n")
        file_obj.write("Final hold-out evaluation on 20% stratified test split\n")
        file_obj.write("=" * 72 + "\n")
        file_obj.write(f"Dataset: {DATA_PATH.name}\n")
        file_obj.write("Rows: 500 complaints\n")
        file_obj.write(f"Final model: {final_model_name}\n")
        file_obj.write(f"Pipeline: {final_model}\n\n")
        file_obj.write("Hold-out metrics\n")
        for key, value in holdout_metrics.items():
            file_obj.write(f"{key}: {value:.4f}\n")
        file_obj.write("\nClassification report\n")
        file_obj.write(report_text)
        file_obj.write("\nConfusion matrix rows=true, columns=predicted\n")
        file_obj.write(pd.DataFrame(cm, index=TARGET_NAMES, columns=TARGET_NAMES).to_string())
        file_obj.write("\n")


def write_experiment_summary(
    final_model_name: str,
    holdout_metrics: dict[str, float],
    model_comparison: pd.DataFrame,
    ablation: pd.DataFrame,
    tuning: pd.DataFrame,
) -> None:
    best_cv = model_comparison.iloc[0]
    best_ablation = ablation.iloc[0]
    best_tuning = tuning.iloc[0]

    with (RESULTS_DIR / "experiment_summary.md").open("w", encoding="utf-8") as file_obj:
        file_obj.write("# Complaint Classification Experiment Summary\n\n")
        file_obj.write(f"- Final selected model: {final_model_name}\n")
        file_obj.write(
            f"- Hold-out accuracy: {holdout_metrics['accuracy']:.4f}, "
            f"weighted F1: {holdout_metrics['weighted_f1']:.4f}\n"
        )
        file_obj.write(
            f"- Best default 5-fold CV row: {best_cv['experiment']} "
            f"(weighted F1 {best_cv['mean_f1_weighted']:.4f} +/- "
            f"{best_cv['std_f1_weighted']:.4f})\n"
        )
        file_obj.write(
            f"- Best tuned training-CV family: {best_tuning['classifier']} "
            f"(weighted F1 {best_tuning['best_mean_f1_weighted']:.4f})\n"
        )
        file_obj.write(
            f"- Best ablation feature set: {best_ablation['feature_set']} "
            f"(weighted F1 {best_ablation['mean_f1_weighted']:.4f})\n"
        )


def select_final_model(
    searches: dict[str, RandomizedSearchCV], tuning_df: pd.DataFrame
) -> tuple[str, str, ImbPipeline]:
    best_classifier_label = tuning_df.iloc[0]["classifier"]
    inverse_labels = {value: key for key, value in MODEL_LABELS.items()}
    best_model_key = inverse_labels[best_classifier_label]
    final_model_name = f"Tuned {best_classifier_label}"
    final_model = searches[best_model_key].best_estimator_
    return best_model_key, final_model_name, final_model


def main() -> None:
    RESULTS_DIR.mkdir(parents=True, exist_ok=True)

    print("Loading 500-complaint dataset...")
    X, y, df = load_dataset()
    print("Class distribution:")
    print(df["complaint_classification"].value_counts().to_string())

    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=0.20,
        random_state=RANDOM_STATE,
        stratify=y,
    )
    cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=RANDOM_STATE)

    print("\nComparing TF-IDF feature extraction variants...")
    tfidf_comparison = run_tfidf_variant_comparison(X, y, cv)
    print(tfidf_comparison[["experiment", "mean_accuracy", "mean_f1_weighted"]].to_string(index=False))

    print("\nComparing classifiers and imbalance strategies...")
    model_comparison = run_model_comparison(X, y, cv)
    print(model_comparison[["experiment", "mean_accuracy", "mean_f1_weighted", "std_f1_weighted"]].to_string(index=False))

    print("\nRunning hyperparameter tuning on the training split only...")
    searches, tuning_df = tune_models(X_train, y_train, cv)
    print(tuning_df[["classifier", "best_mean_f1_weighted", "best_std_f1_weighted"]].to_string(index=False))

    print("\nCross-validating tuned model families on the full dataset...")
    tuned_cv = evaluate_tuned_models(searches, X, y, cv)
    cross_validation_results = pd.concat([model_comparison, tuned_cv], ignore_index=True)
    cross_validation_results = cross_validation_results.sort_values(
        "mean_f1_weighted", ascending=False
    )
    save_table(cross_validation_results, "cross_validation_results.csv", "cross_validation_results.tex")

    best_model_key, base_final_model_name, _ = select_final_model(searches, tuning_df)

    print(f"\nRunning ablation study with {base_final_model_name}...")
    ablation = run_ablation_study(
        best_model_key,
        searches[best_model_key].best_params_,
        X,
        y,
        cv,
    )
    print(ablation[["feature_set", "mean_accuracy", "mean_f1_weighted"]].to_string(index=False))

    feature_label_to_key = {value: key for key, value in FEATURE_LABELS.items()}
    final_feature_label = ablation.iloc[0]["feature_set"]
    final_feature_key = feature_label_to_key[final_feature_label]
    final_model_name = f"{base_final_model_name} ({final_feature_label})"
    final_model = build_pipeline_from_best_params(
        best_model_key, searches[best_model_key].best_params_, final_feature_key
    )

    print(f"\nFitting {final_model_name} and evaluating the hold-out test split...")
    final_model.fit(X_train, y_train)
    y_pred = final_model.predict(X_test)

    holdout_metrics = {
        "accuracy": accuracy_score(y_test, y_pred),
        "weighted_precision": precision_score(
            y_test, y_pred, average="weighted", zero_division=0
        ),
        "weighted_recall": recall_score(
            y_test, y_pred, average="weighted", zero_division=0
        ),
        "weighted_f1": f1_score(y_test, y_pred, average="weighted", zero_division=0),
    }
    cm = confusion_matrix(y_test, y_pred, labels=[0, 1, 2])

    plot_test_distribution(y_test)
    plot_confusion_matrix(cm, holdout_metrics["accuracy"])
    plot_feature_space(final_model, X, y)
    write_final_report(final_model_name, final_model, y_test, y_pred, holdout_metrics, cm)
    write_experiment_summary(
        final_model_name, holdout_metrics, model_comparison, ablation, tuning_df
    )
    copy_figures_to_paper()

    print("\nFinal hold-out metrics:")
    for key, value in holdout_metrics.items():
        print(f"{key}: {value:.4f}")
    print("\nClassification report:")
    print(
        classification_report(
            y_test,
            y_pred,
            labels=[0, 1, 2],
            target_names=TARGET_NAMES,
            digits=4,
            zero_division=0,
        )
    )
    print(f"Results written to {RESULTS_DIR}")


if __name__ == "__main__":
    main()
