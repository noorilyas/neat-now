# 🗑️ Neat Now — YOLOv8 / YOLO26 FYP

> **9-class garbage detection model trained on Pakistani urban waste · 82% mAP@50 on test set**

A production-ready object detection system built as a Final Year Project (FYP) for classifying 9 categories of waste found in Asian/Pakistani urban environments. The project evolved through 8 training iterations, progressing from 63.6% to **82.0% mAP@50** through systematic dataset improvement and architecture upgrades.

---

## 📊 Final Model Performance — v8 (Best)

| Metric | Validation | Test |
|--------|-----------|------|
| **mAP@50** | **79.4%** | **82.0%** ✅ |
| Precision | 87.6% | — |
| Recall | 70.0% | — |
| F1 Score | 77.8% | — |

### Per-Class AP@50

| Class | Val | Test | Status |
|-------|-----|------|--------|
| Animal Waste | 83% | 74% | ✅ Strong |
| Construction Waste | 85% | 90% | ✅ Best class |
| Garbage Bag | 77% | 80% | ✅ Good |
| Glass | 89% | 81% | ✅ Good |
| Metal | 88% | 90% | ✅ Excellent |
| Organic | 79% | 80% | ✅ Good |
| Paper | 88% | 89% | ✅ Excellent |
| Plastic | 66% | 89% | ⚠️ Val/test gap |
| waste | 59% | 67% | ⚠️ Needs relabelling |

---

## 🏗️ Architecture

- **Model:** YOLO26 Object Detection (Fast) — Ultralytics latest
- **Input size:** 640×640 px
- **Training platform:** Roboflow (managed) + Kaggle (Notebooks)
- **Base weights:** COCO pretrained → fine-tuned on custom waste dataset
- **Training epochs:** 150–155 (full convergence)

---

## 📁 Dataset

### Classes (9)
`Animal Waste` · `Construction Waste` · `Garbage Bag` · `Glass` · `Metal` · `Organic` · `Paper` · `Plastic` · `waste`

### Dataset v8 Statistics

| Split | Images | Annotations | Avg boxes/img |
|-------|--------|-------------|---------------|
| Train | 9,964 | 22,846 | 2.29 |
| Valid | 1,327 | 2,602 | 1.96 |
| Test | 1,336 | 2,211 | 1.65 |
| **Total** | **12,627** | **27,659** | — |

### Class Imbalance (v8)
- Max ratio: **1.8×** (Construction Waste vs Plastic) — well within acceptable range
- All classes between 2,010–3,614 instances
- No class in "severe" (>5×) zone

### Key Dataset Facts
- All images resized to **640×640 px** by Roboflow
- **Polygon → BBox conversion** applied (polygon labels converted to axis-aligned bounding boxes)
- Construction Waste: grew from **295 unique images (v6) → 1,466 unique images (v8)** — the biggest quality improvement
- Label types: native bboxes + polygon-derived bboxes (automatically detected and handled)

---

## 📈 Training History

| Version | Date | Epochs | Val mAP | Test mAP | Key change |
|---------|------|--------|---------|----------|------------|
| v1 | Mar 31 | 150 | 68.4% | 61.2% | YOLOv8m baseline → switched to YOLO26 |
| v3 | Mar 31 | ~50 | 71.8% | — | Dataset re-labelled, early stop |
| v4 | Apr 1 | ~50 | 72.0% | — | Checkpoint fine-tune, still early stop |
| v6 | Apr 1 | ~15 | 75.2% | 77.0% | CW annotations restored + new CW images |
| v7 | Apr 2 | 155 | 77.8% | 78.0% | First full convergence |
| **v8** | **Apr 3** | **155** | **79.4%** | **82.0%** | **New Glass + Animal Waste images; CW ×5 diversity** |

### Key Lessons Learned
1. **Dataset quality > model architecture** — switching from YOLOv8m to YOLO26 gave +3.4pp; fixing Construction Waste data gave +9pp over two versions
2. **Full training convergence is essential** — runs stopped at 15–50 epochs left 2–5pp mAP on the table
3. **Polygon labels must be converted** — silent polygon skipping caused 1,664 images to appear unlabelled in early runs
4. **CW unique image count** was the single most impactful variable: 295 → 1,466 images drove CW from 11.3% → 90% AP

---

## 🔍 Notable Observations

### Construction Waste Journey
The most dramatic improvement in the project: AP went from **11.3% (v1) → 90% (v8 test)**.

Root causes of early poor performance:
- Polygon annotations silently skipped by original parser
- Only 295 unique source images (heavily augmented — model memorised artefacts)
- 72% of boxes were tiny (<1% image area)

Fixes applied:
- Polygon-aware label parser (converts to axis-aligned bbox)
- Added 1,171 new diverse CW images from real construction sites
- Restored 671 accidentally deleted annotations during re-labelling

### Persistent Challenges
- **"waste" class** (59–67%) — semantically ambiguous catch-all. No training fix possible; requires manual re-labelling to specific classes
- **Glass val/test gap** (8pp in v8, down from 18pp in v7) — studio Glass images in val vs real-world in test; partially fixed by adding outdoor Glass images

---

## 🛠️ Notebooks

### Training Notebook (`training_notebook.ipynb`)
- Auto-downloads dataset from Roboflow (with caching)
- Handles CUDA compatibility for Kaggle P100/T4
- Auto-resume from last checkpoint on timeout
- Polygon-aware label ingestion
- Saves epoch metrics CSV + all artifacts

**Quick start:**
```python
# Cell 5 — set these before running
RESUME = False          # True to resume from checkpoint
RESUME_WEIGHTS = ""     # path to last.pt if resuming
CFG.model_name = "yolov8m.pt"   # or loaded checkpoint
CFG.epochs = 150
CFG.img_size = 640
```

### EDA Notebook (`garbage_eda_final.ipynb`)
Complete exploratory data analysis covering:
- Dataset structure & split sizes
- Class distribution + imbalance ratio
- Image statistics (resolution, aspect ratio, file size)
- Bounding-box statistics (size, position, density)
- Spatial heatmaps per class
- Co-occurrence matrix
- Train/val consistency (KS test)
- Problem class deep-dives
- Visual sample grids with GT boxes drawn
- Label quality checks (out-of-bounds, tiny/huge boxes, leakage detection)
- All plots auto-saved to `eda_plots/` and zipped for download

**Key feature:** Polygon-aware parser — handles both native bbox and polygon label formats seamlessly.

---

## ⚙️ Inference

### Using Roboflow API
```python
from roboflow import Roboflow

rf = Roboflow(api_key="YOUR_API_KEY")
project = rf.workspace("fyp-loofa").project("asian-waste-detection-dihfa-m9t9o-hqccl-4ptpz")
model = project.version(8).model

# Run inference on an image
result = model.predict("garbage_photo.jpg", confidence=40, overlap=30).json()
```

### Using Downloaded Weights (Ultralytics)
```python
from ultralytics import YOLO

model = YOLO("best.pt")   # download weights from Roboflow

# Inference
results = model.predict(
    source="garbage_photo.jpg",
    conf=0.40,       # recommended threshold (precision ~87%)
    iou=0.45,
    imgsz=640,
)
results[0].show()  # display with boxes
```

### Recommended Inference Settings
| Setting | Value | Reason |
|---------|-------|--------|
| `conf` | 0.40 | Maximises F1; balances precision (87.6%) and recall (70%) |
| `iou` | 0.45 | Standard NMS threshold |
| `imgsz` | 640 | Matches training resolution |

---

## 📦 Dependencies

```
ultralytics>=8.0.0
roboflow>=1.1.0
opencv-python-headless
numpy
pandas
matplotlib
seaborn
scikit-learn
scipy
tqdm
PyYAML
```

Install:
```bash
pip install ultralytics roboflow opencv-python-headless pandas matplotlib seaborn scikit-learn scipy tqdm
```

---

## 🗂️ Dataset Structure (YOLO format)

```
dataset_root/
├── train/
│   ├── images/     ← JPEG / PNG (640×640)
│   └── labels/     ← YOLO .txt (bbox + polygon formats)
├── valid/
│   ├── images/
│   └── labels/
├── test/
│   ├── images/
│   └── labels/
└── data.yaml       ← class names + split paths
```

### Label format
```
# Bounding box (5 values):
class_id  cx  cy  width  height

# Polygon / segmentation mask (1 + 2N values, N≥2):
class_id  x1 y1  x2 y2  ...  xN yN
# → automatically converted to enclosing bbox by EDA & training notebooks
```

---

## 🚀 Roboflow Project

- **Workspace:** `fyp-loofa`
- **Project:** `asian-waste-detection-dihfa-m9t9o-hqccl-4ptpz`
- **Current dataset version:** v8 (Apr 2026)
- **Current best model:** Asian Waste Detection 8

---

## 📋 What's Next (to reach 83–85%)

- [ ] Re-label remaining ambiguous `waste` images → specific classes
- [ ] Add 50 more outdoor real-world Glass images (closes remaining 8pp val/test gap)
- [ ] Investigate Plastic val score (66%) — check if v8 dataset reshuffle placed harder images in val
- [ ] Consider `img_size=832` for tiny-box classes (Construction Waste, Animal Waste) on Kaggle training

---

## 📄 Citation

```bibtex
@misc{asian-waste-detection-2026,
  title   = {Asian Waste Detection — 9-Class YOLO Garbage Classifier},
  author  = {FYP Team, fyp-loofa},
  year    = {2026},
  url     = {https://universe.roboflow.com/fyp-loofa/asian-waste-detection-dihfa-m9t9o-hqccl-4ptpz},
  note    = {YOLO26 Fast · 82\% mAP@50 · 9 classes · 12,627 images}
}
```

---

## 📸 Sample Predictions

The model runs in real-time on CPU and GPU. Recommended deployment: Roboflow Hosted API or Ultralytics `model.predict()` with `conf=0.40`.

---

*Last updated: April 2026 · Model v8 · Dataset v8*
