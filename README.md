<div align="center">

# 🗑️ Neat Now — Smart Waste Detection

### 9-class garbage detection for Pakistani urban environments · Built with YOLO26

[![Python 3.9+](https://img.shields.io/badge/python-3.9+-3776ab?style=flat-square&logo=python&logoColor=white)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/license-MIT-22863a?style=flat-square)](LICENSE)
[![YOLO26](https://img.shields.io/badge/model-YOLO26_Fast-brightgreen?style=flat-square)](https://github.com/ultralytics/ultralytics)
[![Roboflow](https://img.shields.io/badge/dataset-roboflow-purple?style=flat-square)](https://roboflow.com)
[![Kaggle](https://img.shields.io/badge/train-kaggle_GPU-20beff?style=flat-square&logo=kaggle)](https://kaggle.com)
[![mAP](https://img.shields.io/badge/mAP@50-82%25_test-1d9e75?style=flat-square)]()

**82% mAP@50 (test) · 87.9% Precision · 94% Construction Waste AP · 22,031 images**

[Quick Start](#-quick-start) · [Results](#-results) · [Dataset](#-dataset) · [Training History](#-training-history) · [Inference](#-inference) · [Roadmap](#-roadmap)

</div>

---

## What is Neat Now?

Neat Now is a production-ready computer-vision system that detects and classifies **9 categories of waste** in real time from images and video. Built as a Final Year Project (FYP), it targets smart waste monitoring in Pakistani urban environments — enabling automated sorting, bin-level monitoring, and municipal reporting.

The project ran **10+ training iterations** starting from 63.6% mAP and reached **82% test mAP** through a strategy of systematic data collection and quality improvement — not architecture changes.

---

## 🏆 Highlights

| | |
|---|---|
| **82% test mAP@50** | Achieved and maintained across two consecutive model versions |
| **94% test AP — Construction Waste** | From 11.3% (v1) to 94% (Neat Now 3) — an +82.7pp breakthrough |
| **22,031 images · 48,777 annotations** | Dataset nearly doubled from v8 (12,627 → 22,031 images) |
| **87.9% Precision** | Highest precision achieved across all versions |
| **2,524 unique CW images** | Up from 295 in v6 — ×8.5 collection growth |

---

## 📊 Results

### Final model — Neat Now 3 (current best)

| Metric | Validation | Test |
|--------|-----------|------|
| **mAP@50** | **79.5%** | **82.0%** ✅ |
| Precision | 87.9% | — |
| Recall | 69.6% | — |
| F1 Score | 77.7% | — |

### Per-class AP@50

| Class | Val | Test | Gap | Status |
|-------|-----|------|-----|--------|
| Metal | 90% | 90% | 0pp | ✅ Perfect |
| Glass | 90% | 82% | -8pp | ✅ Narrowing (was -18pp) |
| Construction Waste | 89% | **94%** | +5pp | ✅ Star class |
| Paper | 85% | 87% | +2pp | ✅ Excellent |
| Animal Waste | 83% | 75% | -8pp | ✅ Strong |
| Organic | 81% | 83% | +2pp | ✅ Good |
| Garbage Bag | 78% | 81% | +3pp | ✅ Good |
| Plastic | 63% | 88% | +25pp | ⚠️ Val split bias — test is real score |
| waste | 57% | 58% | +1pp | ⚠️ Needs relabelling |

> **Note on Plastic (63% val):** The model is not broken — 88% test is excellent. The latest dataset reshuffle placed harder Plastic images disproportionately into the val split. Trust the test score.
>
> **Note on `waste` (57%):** Stuck across 6 model versions and 3 architectures. This is a labelling problem, not a model problem. Re-labelling ambiguous "waste" images to specific classes is the highest-leverage remaining action.

---

## 🏗️ Architecture

| Parameter | Value |
|-----------|-------|
| Model | YOLO26 Object Detection (Fast) |
| Input resolution | 640 × 640 px |
| Training epochs | 150–155 (full convergence) |
| Early-stop patience | 30 |
| Training platform | Roboflow Managed + Kaggle (P100 GPU) |
| Base weights | COCO pretrained → fine-tuned |

---

## 📁 Dataset

### Classes (9)

```
0: Animal Waste    1: Construction Waste    2: Garbage Bag
3: Glass           4: Metal                 5: Organic
6: Paper           7: Plastic               8: waste
```

### Neat Now 3 — Dataset Statistics

| Split | Images | Annotations | Avg boxes/img |
|-------|--------|-------------|---------------|
| Train | 19,512 | 44,251 | 2.27 |
| Valid | 1,254 | 2,470 | 1.97 |
| Test | 1,265 | 2,056 | 1.63 |
| **Total** | **22,031** | **48,777** | — |

### Class balance

| Class | Instances | Imbalance ratio |
|-------|-----------|-----------------|
| Plastic | 6,520 | 1.0× (balanced) |
| Metal | 6,244 | 1.0× |
| Garbage Bag | 5,881 | 1.1× |
| Glass | 5,880 | 1.1× |
| Organic | 5,552 | 1.2× |
| Animal Waste | 5,539 | 1.2× |
| waste | 5,017 | 1.3× |
| Paper | 4,852 | 1.3× |
| Construction Waste | 3,292 | **2.0×** ← minority |

> Max imbalance: **2.0×** (down from 2.5× in v8). Well within acceptable range. Target: <1.5× for CW.

### Key dataset facts

- All images resized to **640×640 px** by Roboflow (auto-orient + stretch applied)
- **Polygon → BBox conversion** applied — polygon labels automatically converted to axis-aligned bounding boxes
- Train/val box area CDF curves now nearly match — distribution shift resolved from earlier versions
- Annotation density median: 1 box/image (outliers: Plastic up to 170 boxes in dense pellet images)

---

## 📈 Training History

| Version | Date | Epochs | Val mAP | Test mAP | Key change |
|---------|------|--------|---------|----------|------------|
| v1 YOLOv8m | Mar 31 | 150 | 68.4% | 61.2% | Baseline — YOLOv8m |
| v3 YOLO26 | Mar 31 | ~50 | 71.8% | — | Switched to YOLO26, dataset relabelled |
| v4 YOLO26 | Apr 1 | ~50 | 72.0% | — | Checkpoint fine-tune |
| v6 YOLO26 | Apr 1 | ~15 | 75.2% | 77.0% | CW annotations restored + new CW images |
| v7 YOLO26 | Apr 2 | 155 | 77.8% | 78.0% | First full convergence |
| v8 YOLO26 | Apr 3 | 155 | 79.4% | 82.0% | New Glass + AW images; CW ×5 diversity |
| **Neat Now 3** | **Apr 4** | **~150** | **79.5%** | **82.0%** ✅ | **Dataset doubled; CW 2,524 unique images** |

### Construction Waste journey — the key story

```
v1 (YOLOv8m)     →  11.3%   ← polygon labels silently skipped by parser bug
v2 (poly fix)    →  42.0%   ← bug fixed; 1,664 hidden images recovered
v3 (relabel)     →  33.0%   ← 671 labels accidentally deleted during cleanup
v6               →  77.0%   ← annotations restored + first new CW images
v8               →  85% val / 90% test  ← 295 → 1,466 unique images (+397%)
Neat Now 3       →  89% val / 94% test  ← 295 → 2,524 unique images (+756%)
```

### Key lessons from 10+ iterations

1. **Data quality > model architecture** — switching from YOLOv8m to YOLO26 gave +3.4pp; fixing CW data gave +25pp over four versions
2. **Full convergence is essential** — runs cut at 15–50 epochs left 2–5pp mAP on the table every time
3. **Polygon labels must be converted** — a silent parser bug caused 1,664 images to appear unlabelled, costing ~30pp CW AP
4. **CW unique image count was the #1 variable** — 295 → 2,524 images drove CW from 11.3% → 94% AP

---

## 🗂️ Repository Structure

```
neat-now/
├── Notebooks/
│   ├── FYP_Coll...ipynb         # Training notebook (Kaggle-ready, auto-resume)
│   └── Neat_Now_EDA.ipynb       # EDA notebook (polygon-aware, full analysis)
├── EDA Data/                    # EDA outputs and plots
├── Model Output/                # Exported weights and metrics
├── .gitignore
├── LICENSE
└── README.md
```

---

## ⚙️ Inference

### Using Roboflow API

```python
from roboflow import Roboflow

rf = Roboflow(api_key="YOUR_API_KEY")
project = rf.workspace("fyp-loofa").project("asian-waste-detection-dihfa-m9t9o-hqccl-4ptpz")
model = project.version(8).model

result = model.predict("garbage_photo.jpg", confidence=40, overlap=30).json()
print(result["predictions"])
```

### Using Downloaded Weights (Ultralytics)

```python
from ultralytics import YOLO

model = YOLO("best.pt")   # download weights from Roboflow dashboard

results = model.predict(
    source="garbage_photo.jpg",
    conf=0.40,      # recommended (precision ~88%)
    iou=0.45,
    imgsz=640,
)
results[0].show()   # display with bounding boxes
```

### Batch inference on a folder

```python
results = model.predict(
    source="path/to/images/",
    conf=0.40,
    save=True,      # saves annotated images to runs/detect/
    save_txt=True,  # saves YOLO-format labels
)
```

### Recommended inference settings

| Setting | Value | Reason |
|---------|-------|--------|
| `conf` | 0.40 | Maximises F1; balances precision (87.9%) and recall (69.6%) |
| `iou` | 0.45 | Standard NMS threshold |
| `imgsz` | 640 | Matches training resolution |

---

## 🚀 Quick Start

### 1. Clone the repo

```bash
git clone https://github.com/Al-Qasim/neat-now.git
cd neat-now
```

### 2. Install dependencies

```bash
pip install ultralytics roboflow opencv-python-headless \
            pandas matplotlib seaborn scikit-learn scipy tqdm
```

### 3. Download the dataset

```python
from roboflow import Roboflow

rf = Roboflow(api_key="YOUR_API_KEY")
project = rf.workspace("fyp-loofa").project("asian-waste-detection-dihfa-m9t9o-hqccl-4ptpz")
dataset = project.version(3).download("yolov8")   # Neat Now 3 dataset version
```

### 4. Train from checkpoint (recommended)

```python
from ultralytics import YOLO

model = YOLO("best.pt")   # start from Neat Now 3 checkpoint
model.train(
    data="dataset/data.yaml",
    epochs=80,
    patience=20,
    imgsz=640,
    batch=16,
    save_period=10,   # checkpoint every 10 epochs — safety net
    project="runs",
    name="neat_now_4",
)
```

### 5. Train from scratch

```bash
yolo detect train \
  model=yolov8m.pt \
  data=dataset/data.yaml \
  epochs=150 \
  imgsz=640 \
  batch=16 \
  patience=30 \
  save_period=10
```

> **Kaggle tip:** Open `Notebooks/FYP_Coll...ipynb`, enable GPU (P100 recommended), and run all cells. The notebook handles dataset download, auto-resume from checkpoint, and saves metrics to CSV automatically.

### 6. Evaluate on test set

```bash
yolo detect val \
  model=best.pt \
  data=dataset/data.yaml \
  split=test
```

---

## 📦 Export for Deployment

```python
from ultralytics import YOLO

model = YOLO("best.pt")

model.export(format="onnx")         # Universal CPU/GPU
model.export(format="torchscript")  # Mobile / edge
model.export(format="engine")       # TensorRT — NVIDIA (fastest)
model.export(format="tflite")       # Android / Raspberry Pi
```

| Format | Use case | Speed gain |
|--------|----------|------------|
| `.pt` (PyTorch) | Development, fine-tuning | Baseline |
| ONNX | Cross-platform production | ~1.3× |
| TensorRT `.engine` | NVIDIA GPU deployment | ~3–5× |
| TFLite | Mobile / embedded | Varies |

---

## 🗂️ Dataset Format (YOLO)

```
dataset_root/
├── train/
│   ├── images/     ← JPEG / PNG (640×640)
│   └── labels/     ← YOLO .txt files (auto bbox + polygon → bbox)
├── valid/
│   ├── images/
│   └── labels/
├── test/
│   ├── images/
│   └── labels/
└── data.yaml       ← class names + split paths
```

**Label format:**
```
# Bounding box (5 values):
class_id  cx  cy  width  height

# Polygon / segmentation (1 + 2N values — auto-converted to bbox):
class_id  x1 y1  x2 y2  ...  xN yN
```

---

## ⚠️ Known Limitations

| Limitation | Detail | Fix |
|---|---|---|
| `waste` class (57–58%) | Semantically ambiguous catch-all — stuck across 6 versions | Re-label ambiguous images to specific classes |
| Plastic val/test gap (25pp) | Val split bias after dataset reshuffle — test (88%) is accurate | Stratified resplit across val and test |
| Glass val/test gap (8pp) | Partially fixed (was 18pp); outdoor Glass scenes still harder | Add 30–50 more outdoor Glass images |
| Animal Waste val/test gap (8pp) | Model learned val-set characteristics | More diverse outdoor AW images |
| Construction Waste imbalance (2.0×) | Still minority despite ×8.5 growth | Add ~1,000 more CW images → closes to 1.5× |

---

## 🗺️ Roadmap

- [x] Baseline training — YOLOv8m (v1, 68.4% val)
- [x] Architecture upgrade to YOLO26 Fast
- [x] Dataset relabelling and quality improvement
- [x] Polygon-aware label parser (recovered 1,664 hidden images)
- [x] Offline augmentation pipeline — Construction Waste ×4
- [x] CW from 295 → 2,524 unique images — 94% test AP
- [x] Dataset doubled — 22,031 images, 48,777 annotations
- [x] 82% test mAP achieved — **target hit** ✅
- [ ] Re-label `waste` class → +2–3pp mAP → 84–85%
- [ ] Stratified resplit — fix Plastic val/test gap
- [ ] Add 30–50 outdoor Glass images — close 8pp gap
- [ ] Train Neat Now 4 from NN3 checkpoint — target 85%
- [ ] Build Gradio / Streamlit inference demo
- [ ] Add real-time video inference pipeline
- [ ] Mobile export — TFLite for Android deployment

---

## 🔗 Roboflow Project

| | |
|---|---|
| Workspace | `fyp-loofa` |
| Project | `asian-waste-detection-dihfa-m9t9o-hqccl-4ptpz` |
| Current dataset | Neat Now 3 (Apr 2026, 22,031 images) |
| Best model | Neat Now 3 — YOLO26 Fast |

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 📋 Citation

```bibtex
@misc{neat-now-2026,
  title   = {Neat Now: 9-Class Urban Waste Detection using YOLO26},
  author  = {Muhammad Qasim Javed},
  year    = {2026},
  url     = {https://github.com/Al-Qasim/neat-now},
  note    = {YOLO26 Fast · 82\% mAP@50 · 9 classes · 22,031 images}
}
```

---

<div align="center">
<sub>Final Year Project · Muhammad Qasim Javed · UET Lahore · 2026</sub><br>
<sub>Last updated: April 4, 2026 · Model: Neat Now 3 · Dataset: v3 (22,031 images)</sub>
</div>
