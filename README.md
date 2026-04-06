<div align="center">

# 🗑️ Neat Now — Smart Waste Detection

### 9-class garbage detection for Pakistani urban environments · Built with YOLO26 & YOLOv8m

[![Python 3.9+](https://img.shields.io/badge/python-3.9+-3776ab?style=flat-square&logo=python&logoColor=white)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/license-MIT-22863a?style=flat-square)](LICENSE)
[![YOLO26](https://img.shields.io/badge/model-YOLO26_Fast-brightgreen?style=flat-square)](https://github.com/ultralytics/ultralytics)
[![YOLOv8m](https://img.shields.io/badge/model-YOLOv8m-blue?style=flat-square)](https://github.com/ultralytics/ultralytics)
[![RF3](https://img.shields.io/badge/model-Roboflow_3.0_Accurate-8b5cf6?style=flat-square)](https://roboflow.com)
[![Roboflow](https://img.shields.io/badge/dataset-roboflow-purple?style=flat-square)](https://roboflow.com)
[![Kaggle](https://img.shields.io/badge/train-kaggle_GPU-20beff?style=flat-square&logo=kaggle)](https://kaggle.com)
[![mAP](https://img.shields.io/badge/mAP@50-82.5%25_val-1d9e75?style=flat-square)]()

**82.5% mAP@50 · 88.6% Precision · 94% Construction Waste AP · 22,031 images · 3 architectures**

[Quick Start](#-quick-start) · [Results](#-results) · [Dataset](#-dataset) · [Training History](#-training-history) · [Inference](#-inference) · [Roadmap](#-roadmap)

</div>

---

## What is Neat Now?

Neat Now is a production-ready computer-vision system that detects and classifies **9 categories of waste** in real time from images and video. Built as a Final Year Project (FYP) at UET Lahore, it targets smart waste monitoring in Pakistani urban environments — enabling automated sorting, bin-level monitoring, and municipal reporting.

The project ran **12+ training iterations** starting from 63.6% mAP and reached **82.5% mAP@50** through systematic data collection and quality improvement — not architecture changes. Three parallel model tracks were developed and compared: **YOLO26 Fast** (Roboflow managed), **YOLOv8m** (Kaggle P100), and **Roboflow 3.0 Object Detection (Accurate)** — all converging at 76–82.5% mAP, confirming results generalise across architectures.

---

## 🏆 Highlights

| | |
|---|---|
| **82.5% val mAP@50** | Maintained across three architectures (YOLO26, YOLOv8m, RF3.0 Accurate) |
| **94% test AP — Construction Waste** | From 11.3% (v1) to 94% (Neat Now 3) — an +82.7pp breakthrough |
| **22,031 images · 48,777 annotations** | Dataset nearly doubled from v8 (12,627 → 22,031 images) |
| **88.6% Precision** | Best precision achieved — YOLOv8m Kaggle experiment |
| **1 Kaggle session** | Full 90-epoch YOLOv8m training in 9.4 hours — down from 3 sessions previously |
| **2,524 unique CW images** | Up from 295 in v6 — ×8.5 collection growth |
| **53% optimal confidence** | RF3.0 Accurate model — F1-maximising threshold (test set) |

---

## 📊 Results

### Architecture comparison — all models on same dataset (Apr 2026)

| Model | Architecture | Val mAP@50 | Test mAP@50 | Precision | Recall | F1 | Optimal conf |
|-------|-------------|------------|-------------|-----------|--------|----|--------------|
| **YOLOv8m (Kaggle)** | YOLOv8m | **82.5%** | — | **88.6%** | 72.9% | — | 0.40 |
| Neat Now 4 | YOLO26 Fast | 81.7% | — | 88.4% | 72.2% | 79.5% | 0.40 |
| Neat Now 3 | YOLO26 Fast | 79.5% | **82.0%** ✅ | 87.9% | 69.6% | 77.7% | 0.40 |
| **Neat Now 1** | **RF3.0 Accurate** | **81.5%** | **76.0%** | **87.1%** | **75.2%** | **80.2%** | **0.53** |

> **Key insight:** RF3.0 Accurate achieves highest recall (75.2%) among all models but lower test mAP than YOLO26. YOLO26 Fast generalises better to the test split. YOLOv8m achieves highest val mAP and precision overall.

---

### Neat Now 1 — Roboflow 3.0 Object Detection (Accurate)

| Metric | Validation | Test (Industry Standard) |
|--------|------------|--------------------------|
| **mAP@50** | **81.5%** | **76.0%** |
| **mAP@50:95** | — | 62.8% |
| **mAP@75** | — | 67.0% |
| Precision | 87.0% | 87.1% |
| Recall | 72.1% | 75.2% |
| F1 | 78.9% | 80.2% |
| Optimal confidence | — | **53%** |

#### mAP breakdown by object size (Test Set)

| Size | mAP@50:95 | mAP@50 | mAP@75 |
|------|-----------|--------|--------|
| All sizes | 62.8% | 76.0% | 67.0% |
| Small (< 1,024 px²) | 12.2% | 17.2% | 14.1% |
| Medium (1,024–9,216 px²) | 24.4% | 35.9% | 31.9% |
| Large (≥ 9,216 px²) | 65.7% | 78.9% | 69.5% |

> **Small object detection (17.2% mAP@50)** is the weakest area — consistent with EDA showing many tiny (<1% area) annotations. SAHI tiling workflow recommended for small object inference in production.

#### Model improvement recommendations (Roboflow, @ conf=53%, test set)
- `waste` class: **106 objects missed** — highest false negative count of all classes
- `Plastic` confused with `Glass`: 4 misclassifications — label quality review recommended
- Recommended fixes: re-label ambiguous `waste` images; add varied Plastic/Glass examples

---

### Neat Now 4 — YOLO26 Fast (current Roboflow best)

| Metric | Validation |
|--------|------------|
| **mAP@50** | **81.7%** |
| Precision | 88.4% |
| Recall | 72.2% |
| F1 Score | 79.5% |

### Kaggle experiment — YOLOv8m (Apr 4–5, 2026)

| Metric | Validation |
|--------|------------|
| **mAP@50** | **82.5%** |
| **mAP@50:0.95** | **65.3%** |
| Precision | 88.6% |
| Recall | 72.9% |
| Epochs | 90 (early stop at patience=30) |
| Training time | 9.4 hrs — **1 session** |

> **Note on both models:** The YOLO26 Roboflow track and YOLOv8m Kaggle track both reach 82%+ mAP independently, confirming the result generalises across architectures and is driven by dataset quality.

### Previous model — Neat Now 3 (YOLO26, Roboflow)

| Metric | Validation | Test |
|--------|------------|------|
| **mAP@50** | **79.5%** | **82.0%** ✅ |
| Precision | 87.9% | — |
| Recall | 69.6% | — |
| F1 Score | 77.7% | — |

---

### Per-class AP@50 — YOLOv8m Kaggle (Val)

| Class | AP@50 | Confusion (recall) | Status |
|-------|-------|--------------------|--------|
| Plastic | ~95% | 0.78 | ✅ Star performer |
| Paper | ~90% | 0.82 | ✅ Excellent |
| Construction Waste | ~90% | 0.83 | ✅ Recovered class |
| Glass | ~89% | 0.85 | ✅ Best recall |
| Metal | ~87% | 0.82 | ✅ Strong |
| Animal Waste | ~85% | 0.82 | ✅ Good |
| Organic | ~82% | 0.75 | ✅ Good |
| Garbage Bag | ~81% | 0.76 | ✅ Acceptable |
| waste | ~58% | 0.53 | ⚠️ Labelling issue |

### Per-class AP@50 — Neat Now 3 (Val / Test)

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

> **Note on `waste` (57–58%):** Stuck across 6 model versions and 3 architectures. Confirmed labelling problem — the class contains semantically ambiguous mixed scenes. 47% of `waste` objects are missed as background. Re-labelling ambiguous images to specific classes (Organic, Garbage Bag, etc.) is the highest-leverage remaining action — estimated +2–3pp overall mAP.
>
> **Note on Plastic (63% val, 88% test):** The model is not broken. The dataset reshuffle placed harder Plastic images disproportionately into the val split. The 88% test score is accurate.

---

## 🏗️ Architecture

Three models are maintained across three architectures:

| Parameter | YOLO26 Fast (Roboflow) | YOLOv8m (Kaggle) | RF3.0 Accurate (Roboflow) |
|-----------|------------------------|------------------|---------------------------|
| Model | YOLO26 Object Detection (Fast) | YOLOv8m | Roboflow 3.0 Object Detection (Accurate) |
| Input resolution | 640 × 640 px | 640 × 640 px | 640 × 640 px |
| Training epochs | 150–155 | 90 (early stop) | ~150 |
| Early-stop patience | 30 | 30 | 30 |
| Batch size | Managed | 32 | Managed |
| AMP | Yes | Yes (FP16) | Yes |
| Cache | — | RAM | — |
| Platform | Roboflow Managed | Kaggle P100 GPU | Roboflow Managed |
| Base weights | COCO pretrained | COCO pretrained | COCO pretrained |
| Best val mAP | 81.7% | 82.5% | 81.5% |
| Best test mAP | 82.0% | — | 76.0% |
| Optimal conf | 0.40 | 0.40 | **0.53** |

---

## 📁 Dataset

### Classes (9)

```
0: Animal Waste    1: Construction Waste    2: Garbage Bag
3: Glass           4: Metal                 5: Organic
6: Paper           7: Plastic               8: waste
```

### Neat Now 3 — Dataset Statistics (Roboflow, 22,031 images)

| Split | Images | Annotations | Avg boxes/img |
|-------|--------|-------------|---------------|
| Train | 19,512 | 44,251 | 2.27 |
| Valid | 1,254 | 2,470 | 1.97 |
| Test | 1,265 | 2,056 | 1.63 |
| **Total** | **22,031** | **48,777** | — |

### Class balance (Neat Now 3)

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
- Class co-occurrence is very low — nearly all classes appear independently, minimising multi-label confusion

---

## 📈 Training History

| Version | Date | Epochs | Architecture | Val mAP | Test mAP | Key change |
|---------|------|--------|-------------|---------|----------|------------|
| v1 YOLOv8m | Mar 31 | 150 | YOLOv8m | 68.4% | 61.2% | Baseline |
| v3 YOLO26 | Mar 31 | ~50 | YOLO26 Fast | 71.8% | — | Switched to YOLO26; dataset relabelled |
| v4 YOLO26 | Apr 1 | ~50 | YOLO26 Fast | 72.0% | — | Checkpoint fine-tune |
| v6 YOLO26 | Apr 1 | ~15 | YOLO26 Fast | 75.2% | 77.0% | CW annotations restored + new CW images |
| v7 YOLO26 | Apr 2 | 155 | YOLO26 Fast | 77.8% | 78.0% | First full convergence |
| v8 YOLO26 | Apr 3 | 155 | YOLO26 Fast | 79.4% | 82.0% | New Glass + AW images; CW ×5 diversity |
| **Neat Now 3** | **Apr 4** | **~150** | **YOLO26 Fast** | **79.5%** | **82.0%** ✅ | **Dataset doubled; CW 2,524 unique images** |
| **Neat Now 4** | **Apr 5** | **~150** | **YOLO26 Fast** | **81.7%** | — | **+2.2pp val; precision 88.4%; recall 72.2%** |
| **YOLOv8m (Kaggle)** | **Apr 5** | **90** | **YOLOv8m** | **82.5%** | — | **batch=32+cache=ram; 1 session; mAP50-95=65.3%** |
| **Neat Now 1** | **Apr 6** | **~150** | **RF3.0 Accurate** | **81.5%** | **76.0%** | **New architecture; recall 75.2%; conf=53%; small obj 17.2%** |

### Construction Waste journey — the key story

```
v1 (YOLOv8m)       →  11.3%   ← polygon labels silently skipped by parser bug
v2 (poly fix)      →  42.0%   ← bug fixed; 1,664 hidden images recovered
v3 (relabel)       →  33.0%   ← 671 labels accidentally deleted during cleanup
v6                 →  77.0%   ← annotations restored + first new CW images
v8                 →  85% val / 90% test  ← 295 → 1,466 unique images (+397%)
Neat Now 3         →  89% val / 94% test  ← 295 → 2,524 unique images (+756%)
YOLOv8m (Kaggle)   →  ~90% val            ← confirmed cross-architecture
```

### Key lessons from 13+ iterations

1. **Data quality > model architecture** — switching from YOLOv8m to YOLO26 gave +3.4pp; fixing CW data gave +25pp over four versions
2. **Full convergence is essential** — runs cut at 15–50 epochs left 2–5pp mAP on the table every time
3. **Polygon labels must be converted** — a silent parser bug caused 1,664 images to appear unlabelled, costing ~30pp CW AP
4. **CW unique image count was the #1 variable** — 295 → 2,524 images drove CW from 11.3% → 94% AP
5. **Batch size + cache matters for speed** — batch=16→32 + cache=ram cut epoch time from ~14 min to ~7 min, enabling 1-session training on Kaggle P100
6. **Architecture trade-off confirmed** — RF3.0 Accurate = highest recall (75.2%), YOLO26 Fast = best test generalisation (82% test), YOLOv8m = highest val mAP (82.5%)
7. **Small objects are a hard problem** — RF3.0 Accurate mAP@50 for small objects is only 17.2%; SAHI tiling needed for production use

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
model = project.version(4).model   # Neat Now 4 — current best

result = model.predict("garbage_photo.jpg", confidence=40, overlap=30).json()
print(result["predictions"])
```

### Using Downloaded Weights (Ultralytics)

```python
from ultralytics import YOLO

model = YOLO("best.pt")   # download weights from Roboflow dashboard
results = model.predict(
    source="garbage_photo.jpg",
    conf=0.40,      # recommended (maximises F1 — precision ~88%, recall ~72%)
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
| `conf` | 0.40 | Maximises F1; balances precision (~88%) and recall (~72%) |
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
dataset = project.version(4).download("yolov8")   # Neat Now 4 dataset
```

### 4. Train from checkpoint (recommended)

```python
from ultralytics import YOLO

model = YOLO("best.pt")   # start from Neat Now 4 checkpoint
model.train(
    data="dataset/data.yaml",
    epochs=80,
    patience=20,
    imgsz=640,
    batch=32,         # P100 / A100 — use 16 for smaller GPUs
    cache="ram",      # significant speed-up; requires ~13GB RAM
    amp=True,
    save_period=10,
    project="runs",
    name="neat_now_5",
)
```

### 5. Train from scratch (Kaggle-optimised)

```python
from ultralytics import YOLO

model = YOLO("yolov8m.pt")
model.train(
    data="dataset/data.yaml",
    epochs=100,
    patience=30,
    imgsz=640,
    batch=32,
    cache="ram",
    amp=True,
    cos_lr=True,
    save_period=10,
    project="runs",
    name="neat_now_yolov8m",
)
```

> **Kaggle tip:** Open `Notebooks/FYP_Coll...ipynb`, enable GPU (P100 recommended), and run all cells. The notebook handles dataset download, auto-resume from checkpoint, budget warnings, and saves metrics to CSV automatically. With `batch=32` + `cache=ram`, 100 epochs complete in a single ~9-hour session.

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
model.export(format="onnx")         # Universal CPU/GPU — 98.8 MB
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

> ONNX export confirmed working: `98.8 MB`, ONNX Runtime smoke test passed.

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
| `waste` class (57–58%) | Semantically ambiguous catch-all — stuck across 6 versions and 3 architectures; 47% missed as background; 106 FN in RF3.0 test | Re-label ambiguous images to specific classes |
| Small object detection (17.2% mAP@50) | RF3.0 Accurate test: small objects (<1,024 px²) heavily underdetected | SAHI tiling workflow for inference; larger model |
| Plastic ↔ Glass confusion | RF3.0: Plastic detected as Glass 4 times — transparent material similarity | Review and add varied Plastic/Glass examples |
| Plastic val/test gap (25pp, NN3) | Val split bias after dataset reshuffle — test (88%) is accurate | Stratified resplit across val and test |
| Glass val/test gap (8pp) | Partially fixed (was 18pp); outdoor Glass scenes still harder | Add 30–50 more outdoor Glass images |
| Animal Waste val/test gap (8pp) | Model learned val-set characteristics | More diverse outdoor AW images |
| Construction Waste imbalance (2.0×) | Still minority despite ×8.5 growth | Add ~1,000 more CW images → closes to 1.5× |
| Center-bias in dataset | Majority of annotations are centre-framed | Collect edge-framed images |

---

## 🗺️ Roadmap

- [x] Baseline training — YOLOv8m (v1, 68.4% val)
- [x] Architecture upgrade to YOLO26 Fast
- [x] Dataset relabelling and quality improvement
- [x] Polygon-aware label parser (recovered 1,664 hidden images)
- [x] Offline augmentation pipeline — Construction Waste ×4
- [x] CW from 295 → 2,524 unique images — 94% test AP
- [x] Dataset doubled — 22,031 images, 48,777 annotations
- [x] 82% mAP achieved — **target hit** ✅
- [x] Neat Now 4 — 81.7% val, 88.4% precision, +2.2pp over NN3
- [x] YOLOv8m Kaggle experiment — 82.5% val, 65.3% mAP50-95, 1 session, ONNX 98.8 MB
- [x] Neat Now 1 (RF3.0 Accurate) — 81.5% val, 76.0% test, 75.2% recall, optimal conf=53%
- [x] Cross-architecture validation — YOLO26, YOLOv8m, RF3.0 all converge at 76–82.5%
- [ ] Re-label `waste` class → +2–3pp mAP → 84–85%
- [ ] Stratified resplit — fix Plastic val/test gap
- [ ] Add 30–50 outdoor Glass images — close 8pp gap
- [ ] Train Neat Now 5 from NN4 checkpoint — target 85%
- [ ] SAHI tiling inference pipeline — fix small object detection (17.2% → target 40%+)
- [ ] Build Gradio / Streamlit inference demo
- [ ] Add real-time video inference pipeline
- [ ] Mobile export — TFLite for Android deployment
- [ ] TensorRT export — 3–5× inference speedup on NVIDIA GPU

---

## 🔗 Roboflow Project

| | |
|---|---|
| Workspace | `fyp-loofa` |
| Project | `asian-waste-detection-dihfa-m9t9o-hqccl-4ptpz` |
| Current dataset | Neat Now 3 (Apr 2026, 22,031 images) |
| Best YOLO26 model | Neat Now 4 — 81.7% val mAP |
| Best RF3.0 model | Neat Now 1 — 81.5% val / 76.0% test mAP, recall 75.2% |
| Best overall (val) | YOLOv8m Kaggle — 82.5% val mAP |

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 📋 Citation

```bibtex
@misc{neat-now-2026,
  title   = {Neat Now: 9-Class Urban Waste Detection using YOLO26, YOLOv8m, and Roboflow 3.0},
  author  = {Muhammad Qasim Javed},
  year    = {2026},
  url     = {https://github.com/Al-Qasim/neat-now},
  note    = {YOLO26 Fast + YOLOv8m + RF3.0 Accurate · 82.5\% mAP@50 · 9 classes · 22,031 images}
}
```

---

<div align="center">
<sub>Final Year Project · Muhammad Qasim Javed · UET Lahore · 2026</sub><br>
<sub>Last updated: April 6, 2026 · Models: Neat Now 4 (81.7% val) · YOLOv8m Kaggle (82.5% val) · Neat Now 1 RF3.0 (81.5% val / 76.0% test) · Dataset: Neat Now 3 (22,031 images)</sub>
</div>
