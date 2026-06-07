#!/usr/bin/env python3
"""Generate presentation-ready figures for the complaint pipeline and dataset overview."""

from __future__ import annotations

from pathlib import Path

import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
import pandas as pd
import seaborn as sns

sns.set_theme(style="whitegrid", context="talk")
plt.rcParams.update(
    {
        "figure.figsize": (14, 8),
        "font.family": "DejaVu Sans",
        "axes.titlesize": 18,
        "axes.labelsize": 13,
        "xtick.labelsize": 11,
        "ytick.labelsize": 11,
        "legend.fontsize": 11,
    }
)

SCRIPT_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = SCRIPT_DIR


def find_repo_root() -> Path:
    data_relative = Path("ML_Model_Training") / "data" / "complaints_full.csv"
    for candidate in [SCRIPT_DIR, *SCRIPT_DIR.parents]:
        if (candidate / data_relative).exists():
            return candidate
    raise FileNotFoundError(f"Could not locate {data_relative} from {SCRIPT_DIR}")


REPO_ROOT = find_repo_root()
DATA_PATH = REPO_ROOT / "ML_Model_Training" / "data" / "complaints_full.csv"

FLOW_COLORS = {
    "input": "#1f3c88",
    "process": "#2f855a",
    "feature": "#6b46c1",
    "model": "#c05621",
    "output": "#0f766e",
}

SUBCATEGORY_TRANSLATIONS = {
    "ডানো": "Dano",
    "ডিপ্লোমা (নিউজিল্যান্ড)": "Diploma (New Zealand)",
    "মশুর ডাল (ছোট দানা)": "Masoor Dal (Small Grain)",
    "আলু (মানভেদে)": "Potato (Variety)",
    "লবণ(প্যাঃ)আয়োডিনযুক্ত": "Iodized Salt (Pack)",
    "চাল (মাঝারী)পাইজাম/আটাশ": "Rice (Medium Grade)",
    "পিঁয়াজ (দেশী)": "Onion (Local)",
    "সয়াবিন তেল (বোতল)": "Soybean Oil (Bottle)",
    "ধনে": "Coriander",
    "হলুদ (দেশী)": "Turmeric (Local)",
}


def draw_box(ax, xy, width, height, text, color, text_color="white", fontsize=12, wrap=True):
    # slightly tighter padding and cleaner corners for presentation
    patch = FancyBboxPatch(
        xy,
        width,
        height,
        boxstyle="round,pad=0.02,rounding_size=0.02",
        linewidth=1.6,
        edgecolor=color,
        facecolor=color,
        alpha=0.98,
    )
    ax.add_patch(patch)
    x, y = xy
    ax.text(
        x + width / 2,
        y + height / 2,
        text,
        ha="center",
        va="center",
        color=text_color,
        fontsize=fontsize,
        fontweight="bold",
        wrap=wrap,
    )


def arrow(ax, start, end, color="#4a5568"):
    # use small shrink values so arrowheads sit neatly against box edges
    ax.add_patch(
        FancyArrowPatch(
            start,
            end,
            arrowstyle="-|>",
            mutation_scale=18,
            linewidth=2.0,
            color=color,
            shrinkA=6,
            shrinkB=6,
            connectionstyle="arc3,rad=0",
        )
    )


def generate_pipeline_flow() -> None:
    fig, ax = plt.subplots(figsize=(16, 8))
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis("off")

    ax.text(
        0.5,
        0.94,
        "Complaint Severity Classification Pipeline",
        ha="center",
        va="center",
        fontsize=22,
        fontweight="bold",
        color="#1a202c",
    )
    ax.text(
        0.5,
        0.885,
        "Flow from raw complaint text to final severity prediction",
        ha="center",
        va="center",
        fontsize=12,
        color="#4a5568",
    )

    # top row boxes
    b1 = (0.04, 0.56, 0.16, 0.14)
    b2 = (0.24, 0.56, 0.18, 0.14)
    b3 = (0.46, 0.56, 0.16, 0.14)
    b4 = (0.66, 0.56, 0.18, 0.14)
    b5 = (0.87, 0.56, 0.09, 0.14)

    draw_box(ax, (b1[0], b1[1]), b1[2], b1[3], "Raw complaint\ndata", FLOW_COLORS["input"])
    draw_box(ax, (b2[0], b2[1]), b2[2], b2[3], "Text cleaning\nnormalization", FLOW_COLORS["process"])
    draw_box(ax, (b3[0], b3[1]), b3[2], b3[3], "TF-IDF\nfeatures", FLOW_COLORS["feature"])
    draw_box(ax, (b4[0], b4[1]), b4[2], b4[3], "Hybrid feature\nfusion", FLOW_COLORS["feature"])
    draw_box(ax, (b5[0], b5[1]), b5[2], b5[3], "Models", FLOW_COLORS["model"], fontsize=11)

    # draw connecting arrows aligned to box centers (no visible gaps)
    arrow(ax, (b1[0] + b1[2], b1[1] + b1[3] / 2), (b2[0], b2[1] + b2[3] / 2))
    arrow(ax, (b2[0] + b2[2], b2[1] + b2[3] / 2), (b3[0], b3[1] + b3[3] / 2))
    arrow(ax, (b3[0] + b3[2], b3[1] + b3[3] / 2), (b4[0], b4[1] + b4[3] / 2))
    arrow(ax, (b4[0] + b4[2], b4[1] + b4[3] / 2), (b5[0], b5[1] + b5[3] / 2))

    # bottom row boxes
    bb1 = (0.12, 0.26, 0.2, 0.14)
    bb2 = (0.38, 0.26, 0.18, 0.14)
    bb3 = (0.62, 0.26, 0.28, 0.14)
    bout = (0.34, 0.07, 0.34, 0.12)

    draw_box(ax, (bb1[0], bb1[1]), bb1[2], bb1[3], "Bengali + Banglish\nnormalization", FLOW_COLORS["process"], fontsize=11)
    draw_box(ax, (bb2[0], bb2[1]), bb2[2], bb2[3], "Category + numeric\nfeatures", FLOW_COLORS["feature"], fontsize=11)
    draw_box(ax, (bb3[0], bb3[1]), bb3[2], bb3[3], "Logistic Regression\nLinear SVC\nRandom Forest\nVoting Ensemble", FLOW_COLORS["model"], fontsize=10)
    draw_box(ax, (bout[0], bout[1]), bout[2], bout[3], "Predicted complaint severity\nweak  |  medium  |  high", FLOW_COLORS["output"], fontsize=12)

    # arrows from top row into bottom processing boxes
    arrow(ax, (b1[0] + b1[2] * 0.5, b1[1]), (bb1[0] + bb1[2] / 2, bb1[1] + bb1[3]))
    arrow(ax, (b3[0] + b3[2] * 0.5, b3[1]), (bb2[0] + bb2[2] / 2, bb2[1] + bb2[3]))
    arrow(ax, (b4[0] + b4[2] * 0.5, b4[1]), (bb3[0] + bb3[2] / 2, bb3[1] + bb3[3]))
    arrow(ax, (bb3[0] + bb3[2] / 2, bb3[1]), (bout[0] + bout[2] / 2, bout[1] + bout[3]))

    ax.text(
        0.5,
        0.46,
        "Core preprocessing and feature engineering steps",
        ha="center",
        va="center",
        fontsize=11,
        color="#718096",
    )

    plt.tight_layout()
    fig.savefig(OUTPUT_DIR / "pipeline_flow.png", dpi=300, bbox_inches="tight")
    plt.close(fig)


def generate_dataset_overview() -> None:
    if not DATA_PATH.exists():
        raise FileNotFoundError(f"Dataset not found: {DATA_PATH}")

    df = pd.read_csv(DATA_PATH)
    df = df.dropna(
        subset=[
            "complaint_description",
            "subcategory_name",
            "validity",
            "priority",
            "complaint_score",
            "complaint_classification",
        ]
    ).copy()

    fig = plt.figure(figsize=(18, 11))
    # reorganize layout to include a small sample-data table
    grid = fig.add_gridspec(3, 2, height_ratios=[0.6, 0.45, 1.1], wspace=0.24, hspace=0.28)

    ax_kpi = fig.add_subplot(grid[0, :])
    ax_class = fig.add_subplot(grid[1, 0])
    ax_table = fig.add_subplot(grid[1, 1])
    ax_subcat = fig.add_subplot(grid[2, :])

    total = len(df)
    unique_customers = df["customer_id"].nunique() if "customer_id" in df.columns else 0
    unique_subcategories = df["subcategory_name"].nunique()
    avg_score = df["complaint_score"].mean()

    ax_kpi.axis("off")
    ax_kpi.text(
        0.0,
        1.02,
        "Complaint Dataset Overview",
        fontsize=22,
        fontweight="bold",
        color="#1a202c",
        transform=ax_kpi.transAxes,
    )
    ax_kpi.text(
        0.0,
        0.92,
        "A compact summary for presentation slides",
        fontsize=12,
        color="#4a5568",
        transform=ax_kpi.transAxes,
    )

    kpi_cards = [
        (0.00, 0.58, 0.42, 0.20, f"{total}", "complaints"),
        (0.48, 0.58, 0.42, 0.20, f"{unique_subcategories}", "subcategories"),
        (0.00, 0.28, 0.42, 0.20, f"{unique_customers}", "customers"),
        (0.48, 0.28, 0.42, 0.20, f"{avg_score:.2f}", "avg. score"),
    ]

    for x, y, w, h, value, label in kpi_cards:
        card = FancyBboxPatch(
            (x, y),
            w,
            h,
            boxstyle="round,pad=0.025,rounding_size=0.03",
            linewidth=1.5,
            edgecolor="#cbd5e0",
            facecolor="#f7fafc",
        )
        ax_kpi.add_patch(card)
        ax_kpi.text(
            x + w / 2,
            y + 0.12,
            value,
            ha="center",
            va="center",
            fontsize=24,
            fontweight="bold",
            color="#1f3c88",
        )
        ax_kpi.text(
            x + w / 2,
            y + 0.05,
            label,
            ha="center",
            va="center",
            fontsize=11,
            color="#4a5568",
        )

    class_counts = df["complaint_classification"].value_counts().reindex([
        "weak",
        "medium",
        "high",
    ])
    class_palette = ["#38a169", "#d69e2e", "#e53e3e"]
    sns.barplot(
        x=class_counts.index,
        y=class_counts.values,
        ax=ax_class,
        palette=class_palette,
        edgecolor="#2d3748",
    )
    ax_class.set_title("Complaint severity distribution", fontweight="bold", pad=12)
    ax_class.set_xlabel("Severity class")
    ax_class.set_ylabel("Count")
    for idx, value in enumerate(class_counts.values):
        ax_class.text(idx, value + max(class_counts.values) * 0.02, str(int(value)), ha="center", va="bottom", fontweight="bold")

    top_subcategories = df["subcategory_name"].value_counts().head(10).sort_values()
    top_subcategories.index = [
        SUBCATEGORY_TRANSLATIONS.get(name, name) for name in top_subcategories.index
    ]
    sns.barplot(
        x=top_subcategories.values,
        y=top_subcategories.index,
        ax=ax_subcat,
        palette=sns.color_palette("viridis", len(top_subcategories)),
        edgecolor="#2d3748",
    )
    ax_subcat.set_title("Top complaint subcategories", fontweight="bold", pad=12)
    ax_subcat.set_xlabel("Count")
    ax_subcat.set_ylabel("Subcategory")
    ax_subcat.grid(axis="x", alpha=0.25)

    # --- add a small sample table of complaint rows for presentation ---
    ax_table.axis("off")
    sample_cols = [c for c in ["complaint_description", "subcategory_name", "complaint_classification"] if c in df.columns]
    sample = df[sample_cols].head(6).copy()
    if "complaint_description" in sample.columns:
        sample["complaint_description"] = sample["complaint_description"].str.replace("\n", " ")
        sample["complaint_description"] = sample["complaint_description"].str.slice(0, 80).str.rstrip()

    table = ax_table.table(
        cellText=sample.values.tolist(),
        colLabels=[SUBCATEGORY_TRANSLATIONS.get(col, col).replace("_", " ") for col in sample.columns],
        cellLoc="left",
        colLoc="left",
        loc="center",
    )
    table.auto_set_font_size(False)
    table.set_fontsize(10)
    table.scale(1, 1.3)

    plt.tight_layout()
    fig.savefig(OUTPUT_DIR / "complaint_dataset_overview.png", dpi=300, bbox_inches="tight")
    plt.close(fig)


def generate_classification_visuals() -> None:
    """Additional classification visuals: score distribution by class and class proportion pie."""
    if not DATA_PATH.exists():
        raise FileNotFoundError(f"Dataset not found: {DATA_PATH}")

    df = pd.read_csv(DATA_PATH)
    df = df.dropna(subset=["complaint_score", "complaint_classification"]).copy()

    # Violin / boxplot of complaint_score by class
    fig, ax = plt.subplots(figsize=(8, 5))
    sns.violinplot(
        x="complaint_classification",
        y="complaint_score",
        data=df,
        order=["weak", "medium", "high"],
        palette=["#38a169", "#d69e2e", "#e53e3e"],
        inner="quartile",
        ax=ax,
    )
    ax.set_title("Complaint score distribution by severity", fontweight="bold")
    ax.set_xlabel("Severity class")
    ax.set_ylabel("Complaint score")
    plt.tight_layout()
    fig.savefig(OUTPUT_DIR / "classification_score_distribution.png", dpi=300, bbox_inches="tight")
    plt.close(fig)

    # Pie chart of class proportions
    counts = df["complaint_classification"].value_counts().reindex(["weak", "medium", "high"]).fillna(0)
    fig, ax = plt.subplots(figsize=(6, 6))
    ax.pie(counts.values, labels=counts.index, autopct="%1.1f%%", colors=["#38a169", "#d69e2e", "#e53e3e"], startangle=90, wedgeprops={"edgecolor": "white"})
    ax.set_title("Class proportion (dataset)")
    plt.tight_layout()
    fig.savefig(OUTPUT_DIR / "class_proportion_pie.png", dpi=300, bbox_inches="tight")
    plt.close(fig)


def generate_model_flow_comparison() -> None:
    """Create a 2x2 panel showing simplified model pipelines and key properties."""
    # larger canvas and denser layout to maximize space for presentation
    fig, axes = plt.subplots(2, 2, figsize=(20, 12))
    axes = axes.flatten()

    model_specs = [
        (
            "Logistic Regression",
            ["class_weight=balanced", "solver=liblinear", "C=1.0"],
            FLOW_COLORS["model"],
        ),
        (
            "Linear SVC",
            ["class_weight=balanced", "dual=auto", "C=1.0"],
            FLOW_COLORS["model"],
        ),
        (
            "Random Forest",
            ["n_estimators=200", "class_weight=balanced", "max_depth=None"],
            FLOW_COLORS["model"],
        ),
        (
            "Voting Ensemble",
            ["LR + SVC + RF", "voting=hard"],
            FLOW_COLORS["feature"],
        ),
    ]

    for ax, (title, bullets, color) in zip(axes, model_specs):
        ax.set_xlim(0, 1)
        ax.set_ylim(0, 1)
        ax.axis("off")

        # draw sequence of boxes across the full width: Raw -> Normalize -> TF-IDF -> Features -> Model
        x0 = 0.03
        y = 0.56
        box_w = 0.18
        box_h = 0.18

        boxes = []
        # use single-line labels and disable wrapping for clarity
        labels = [
            "Raw complaint text",
            "Normalization (Bangla/Banglish)",
            "TF-IDF (word+char)",
            "Hybrid features",
            title,
        ]

        # positions across the top row
        for i, lbl in enumerate(labels):
            xi = x0 + i * (box_w + 0.03)
            # last box (model) uses the model color and larger font
            if i == len(labels) - 1:
                draw_box(ax, (xi, y), box_w, box_h, lbl, color, fontsize=14, wrap=False)
            else:
                draw_box(ax, (xi, y), box_w, box_h, lbl, FLOW_COLORS["process"], fontsize=13, wrap=False)
            boxes.append((xi, y, box_w, box_h))

        # output box centered below the model
        out_x = boxes[-1][0]
        draw_box(ax, (out_x, 0.12), 0.28, 0.14, "Predicted severity: weak | medium | high", FLOW_COLORS["output"], fontsize=12, wrap=False)

        # arrows across top (no wrap, endpoints snug to boxes)
        for i in range(len(boxes) - 1):
            start = (boxes[i][0] + boxes[i][2], boxes[i][1] + boxes[i][3] / 2)
            end = (boxes[i + 1][0], boxes[i + 1][1] + boxes[i + 1][3] / 2)
            arrow(ax, start, end)

        # arrow from model to output
        model_box = boxes[-1]
        arrow(ax, (model_box[0] + model_box[2] / 2, model_box[1]), (out_x + 0.14, 0.24))

        # side panel with bullet points (no wrap)
        bullet_text = "\n".join([f"• {b}" for b in bullets])
        ax.text(
            0.02,
            0.02,
            bullet_text,
            ha="left",
            va="bottom",
            fontsize=12,
            color="#2d3748",
            wrap=False,
        )

        ax.set_title(title, pad=10, fontweight="bold", fontsize=16)

    # maximize use of figure area
    fig.subplots_adjust(left=0.02, right=0.99, top=0.95, bottom=0.03, wspace=0.12, hspace=0.18)
    fig.savefig(OUTPUT_DIR / "model_pipeline_comparison.png", dpi=300, bbox_inches="tight")
    plt.close(fig)


def generate_model_flow_alternative() -> None:
    """Stacked vertical panels (one per model) that use the full width and large fonts.

    This layout is intended for presentation slides where each model's flow is shown
    in a single horizontal row, stacked vertically, with large labels and no wrapping.
    """
    model_specs = [
        ("Logistic Regression", ["class_weight=balanced", "solver=liblinear", "C=1.0"], FLOW_COLORS["model"]),
        ("Linear SVC", ["class_weight=balanced", "dual=auto", "C=1.0"], FLOW_COLORS["model"]),
        ("Random Forest", ["n_estimators=200", "class_weight=balanced", "max_depth=None"], FLOW_COLORS["model"]),
        ("Voting Ensemble", ["LR + SVC + RF", "voting=hard"], FLOW_COLORS["feature"]),
    ]

    n = len(model_specs)
    fig, axes = plt.subplots(n, 1, figsize=(20, 4.5 * n))
    if n == 1:
        axes = [axes]

    for ax, (title, bullets, color) in zip(axes, model_specs):
        ax.set_xlim(0, 1)
        ax.set_ylim(0, 1)
        ax.axis("off")

        # horizontal flow across most of the width
        left = 0.02
        top_y = 0.52
        box_w = 0.18
        box_h = 0.28
        gap = 0.03

        labels = [
            "Raw complaint text",
            "Normalization (Bangla/Banglish)",
            "TF-IDF (word+char)",
            "Hybrid features",
            title,
        ]

        boxes = []
        for i, lbl in enumerate(labels):
            xi = left + i * (box_w + gap)
            box_color = color if i == len(labels) - 1 else FLOW_COLORS["process"]
            # larger fonts, no wrap
            draw_box(ax, (xi, top_y), box_w, box_h, lbl, box_color, fontsize=18, wrap=False)
            boxes.append((xi, top_y, box_w, box_h))

        # output box to the right of the model box
        out_x = boxes[-1][0] + boxes[-1][2] + 0.04
        draw_box(ax, (out_x, top_y + 0.03), 0.17, 0.22, "Predicted severity\nweak | medium | high", FLOW_COLORS["output"], fontsize=14, wrap=False)

        # arrows
        for i in range(len(boxes) - 1):
            start = (boxes[i][0] + boxes[i][2], boxes[i][1] + boxes[i][3] / 2)
            end = (boxes[i + 1][0], boxes[i + 1][1] + boxes[i + 1][3] / 2)
            arrow(ax, start, end, color="#2d3748")

        # arrow from model to output
        model_box = boxes[-1]
        arrow(ax, (model_box[0] + model_box[2], model_box[1] + model_box[3] / 2), (out_x, top_y + 0.14), color="#2d3748")

        # bullets on the right side below output box
        bullet_text = "\n".join([f"• {b}" for b in bullets])
        ax.text(out_x + 0.02, 0.08, bullet_text, ha="left", va="bottom", fontsize=14, wrap=False)

        ax.set_title(title, pad=6, fontweight="bold", fontsize=20)

    fig.subplots_adjust(left=0.02, right=0.98, top=0.96, bottom=0.04, hspace=0.36)
    fig.savefig(OUTPUT_DIR / "model_pipeline_comparison_alt.png", dpi=300, bbox_inches="tight")
    plt.close(fig)


def generate_single_model_slides() -> None:
    """Generate one full-slide image per model with large, clear flow and bullets below."""
    model_specs = [
        ("logistic_regression", "Logistic Regression", ["class_weight=balanced", "solver=liblinear", "C=1.0"], FLOW_COLORS["model"]),
        ("linear_svc", "Linear SVC", ["class_weight=balanced", "dual=auto", "C=1.0"], FLOW_COLORS["model"]),
        ("random_forest", "Random Forest", ["n_estimators=200", "class_weight=balanced", "max_depth=None"], FLOW_COLORS["model"]),
        ("voting", "Voting Ensemble", ["LR + SVC + RF", "voting=hard"], FLOW_COLORS["feature"]),
    ]

    for key, title, bullets, color in model_specs:
        fig, ax = plt.subplots(figsize=(20, 6))
        ax.set_xlim(0, 1)
        ax.set_ylim(0, 1)
        ax.axis("off")


        # flow boxes: compute dynamic widths so all boxes fit on the slide
        left = 0.03
        right = 0.03
        top_y = 0.45
        gap = 0.03
        labels = [
            "Raw complaint text",
            "Normalization (Bangla/Banglish)",
            "TF-IDF (word + char)",
            "Hybrid features",
            title,
        ]

        n_boxes = len(labels)
        available = 1.0 - left - right - (n_boxes - 1) * gap
        box_w = max(0.10, available / n_boxes)
        box_h = 0.26

        boxes = []
        for i, lbl in enumerate(labels):
            xi = left + i * (box_w + gap)
            box_color = color if i == len(labels) - 1 else FLOW_COLORS["process"]
            draw_box(ax, (xi, top_y), box_w, box_h, lbl, box_color, fontsize=18, wrap=False)
            boxes.append((xi, top_y, box_w, box_h))

        # arrows between boxes with larger arrowheads
        for i in range(len(boxes) - 1):
            start = (boxes[i][0] + boxes[i][2], boxes[i][1] + boxes[i][3] / 2)
            end = (boxes[i + 1][0], boxes[i + 1][1] + boxes[i + 1][3] / 2)
            ax.add_patch(FancyArrowPatch(start, end, arrowstyle='->', mutation_scale=28, linewidth=3.0, color='#2d3748', shrinkA=6, shrinkB=6))

        # bullets stacked below flow (one per line)
        bullet_lines = "\n".join(bullets)
        ax.text(0.5, 0.12, bullet_lines, ha="center", va="center", fontsize=14, color="#2d3748")

        ax.set_title(title, fontsize=26, fontweight="bold", pad=18)
        fig.savefig(OUTPUT_DIR / f"model_{key}_slide.png", dpi=300, bbox_inches="tight")
        plt.close(fig)


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    generate_pipeline_flow()
    generate_dataset_overview()
    generate_classification_visuals()
    generate_model_flow_comparison()
    generate_model_flow_alternative()
    generate_single_model_slides()
    print(f"Saved pipeline_flow.png, complaint_dataset_overview.png, classification_score_distribution.png, class_proportion_pie.png, and model_pipeline_comparison.png in {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
