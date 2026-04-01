<div align="center">

<img src="https://img.shields.io/badge/Neat_Now-Smart_Waste_Detection-22c55e?style=for-the-badge&logo=leaf&logoColor=white" alt="Neat Now"/>

# 🗑️ Neat Now — Smart Waste Detection

**Real-time, 9-class waste classification powered by YOLO26**  
*A Final Year Project (FYP) targeting intelligent waste monitoring in Pakistani urban environments*

[![Python 3.9+](https://img.shields.io/badge/Python-3.9+-3776AB?style=flat-square&logo=python&logoColor=white)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-F59E0B?style=flat-square)](https://opensource.org/licenses/MIT)
[![Ultralytics YOLO26](https://img.shields.io/badge/Ultralytics-YOLO26-00B4D8?style=flat-square)](https://github.com/ultralytics/ultralytics)
[![Dataset: Roboflow](https://img.shields.io/badge/Dataset-Roboflow_v6-7C3AED?style=flat-square)](https://roboflow.com)
[![Trained on Kaggle](https://img.shields.io/badge/Trained_on-Kaggle_T4-20BEFF?style=flat-square&logo=kaggle)](https://kaggle.com)

</div>

---

## 📊 Model Performance at a Glance

| Metric | v1 YOLOv8m | v2 YOLO26 150ep | v3/v4 YOLO26 50ep | **v6 YOLO26 (Latest)** |
|:---|:---:|:---:|:---:|:---:|
| **mAP@0.5 (val)** | 68.0% | 68.4% | 72.0% | **75.2%** |
| **mAP@0.5 (test)** | — | — | 71.0% | **77.0%** |
| **Precision** | 72.0% | 76.8% | 81.8% | **80.0%** |
| **Recall** | 63.0% | 61.3% | 63.2% | **68.8%** |

> ✅ **v6 achieves the best test mAP to date (77%)** — up +6pp from v3/v4. Construction Waste AP jumped from 19% → **84%** on the test set.

---

## 🏗️ Project Overview

Neat Now is a computer-vision pipeline that detects and classifies **nine waste categories** from images and live video. It is built as the CV backbone for a smart-city waste monitoring system targeting urban residential areas in Pakistan.

The pipeline covers the full ML lifecycle:

```
Roboflow Dataset Download
        ↓
Exploratory Data Analysis (EDA)
        ↓
Offline Augmentation (minority class balancing)
        ↓
YOLO26 Fine-tuning with Early Stopping
        ↓
Per-class Evaluation + Val/Test Gap Analysis
        ↓
Export (ONNX / TorchScript / TensorRT)
```

---

## 🗂️ Waste Classes

| ID | Class | Test AP (v6) | Notes |
|:--|:--|:--:|:--|
| 0 | Animal Waste | 69% | Good generalisation — +13pp test vs val |
| 1 | Construction Waste | **84%** | Massive recovery from v3/v4's 19% |
| 2 | Garbage Bag | 80% | Stable across splits |
| 3 | Glass | 70% | Val 88% → Test 70% gap in older models; resolved in v6 |
| 4 | Metal | 85% | Consistently top performer |
| 5 | Organic | 67% | Lowest performer — visual ambiguity with waste class |
| 6 | Paper | 86% | Best performer |
| 7 | Plastic | 86% | Best performer — positive generalisation |
| 8 | waste | 61% | Catch-all class; class ambiguity limits ceiling |

---

## 📦 Dataset

| Property | Value |
|:--|:--|
| **Total images** | 12,690 (640 × 640 px, uniform) |
| **Total annotations** | 27,944 bounding boxes |
| **Train split** | 10,014 images / 23,013 annotations (79.6%) |
| **Val split** | 1,338 images / 2,359 annotations (9.9%) |
| **Test split** | 1,338 images / 2,267 annotations (10.6%) |
| **Avg boxes/image** | 2.51 train · 2.07 val · 1.86 test |
| **Source** | [Roboflow](https://roboflow.com) — collected & annotated |
| **Imbalance** | Construction Waste: 1.9× minority CW |

### Class Imbalance & Augmentation

Construction Waste is the dataset's minority class at 1.9 × imbalance ratio. Offline augmentation was applied to triple its representation before upload:

- Horizontal flip, random 90° rotation
- Shift / scale / rotate (±30°)
- Brightness & contrast jitter
- Gaussian noise injection

### Known Dataset Issues

| Issue | Impact | Fix (Roadmap) |
|:--|:--|:--|
| Val boxes statistically larger than train (KS test confirmed) | Val mAP may over-estimate real-world small-object performance | Re-shuffle train/val split |
| Construction Waste covers only 295 unique source images | Limits model diversity despite augmentation | Collect 500+ new site images |
| Predominantly urban-residential scenes | Poor generalisation to industrial/construction contexts | Expand domain coverage |
| "waste" catch-all class is visually ambiguous | AP ceiling ~61% regardless of training | Refine or split the class |

---

## 🧠 Model Architecture

| Parameter | Value |
|:--|:--|
| Architecture | YOLO26 Object Detection (Fast) |
| Input resolution | 640 × 640 |
| Epochs | 50 |
| Early-stop patience | 30 |
| Optimizer | SGD |
| Initial LR | 0.01 |
| Momentum | 0.937 |
| Weight decay | 0.0005 |
| Hardware | NVIDIA T4 (Kaggle) |
| Training time | ~4 hours |

**Built-in augmentations:** mosaic, mixup, HSV jitter, horizontal flip, scale, rotation.

---

## 🚀 Quick Start

### 1. Clone

```bash
git clone https://github.com/yourusername/neat-now-waste-detection.git
cd neat-now-waste-detection
```

### 2. Install dependencies

```bash
pip install ultralytics roboflow albumentations opencv-python-headless
```

### 3. Download the dataset

```python
from roboflow import Roboflow

rf = Roboflow(api_key="YOUR_API_KEY")
project = rf.workspace("fyp-gojku").project("asian-waste-detection-dihfa-m9t9o-hqccl")
dataset = project.version(6).download("yolov8")  # use latest version
```

### 4. Train

```bash
yolo detect train \
  model=yolo26-fast.pt \
  data=data/data.yaml \
  epochs=50 \
  imgsz=640 \
  batch=32 \
  patience=30 \
  project=runs/train \
  name=waste_v6
```

> **Kaggle users:** Open `train.ipynb`, enable T4 GPU, and run all cells. Dataset download, training, and evaluation are handled automatically.

### 5. Inference

```python
from ultralytics import YOLO

model = YOLO("weights/best.pt")

# Single image
results = model("path/to/image.jpg")
results[0].show()

# Video stream
results = model("path/to/video.mp4", stream=True)
for r in results:
    r.show()
```

### 6. Evaluate on test set

```bash
yolo detect val \
  model=weights/best.pt \
  data=data/data.yaml \
  split=test
```

---

## 📈 Per-class Results — v6 Final Model

| Class | Val AP | Test AP | Trend |
|:--|:--:|:--:|:--|
| Paper | 86% | 86% | ✅ Stable top performer |
| Plastic | 71% | 86% | 📈 Strong positive generalisation |
| Metal | 85% | 85% | ✅ Consistent |
| Garbage Bag | 81% | 80% | ✅ Stable |
| Construction Waste | 77% | **84%** | 🚀 Massive v6 improvement |
| Glass | 88% | 70% | ⚠️ Watch val/test gap |
| Animal Waste | 56% | 69% | 📈 Good generalisation |
| Organic | 71% | 67% | ➡️ Moderate, limited by visual ambiguity |
| waste | 62% | 61% | ⚠️ Class ambiguity is the ceiling |
| **Overall** | **75%** | **77%** | ✅ **Best model to date** |

---

## 📤 Export for Deployment

```python
from ultralytics import YOLO

model = YOLO("weights/best.pt")

model.export(format="onnx")         # Universal CPU/GPU
model.export(format="torchscript")  # Mobile deployment
model.export(format="engine")       # TensorRT — fastest on NVIDIA GPUs
```

---

## 🗂️ Project Structure

```
neat-now/
├── train.ipynb              # Main training notebook (Kaggle-ready)
├── augment_upload.ipynb     # Offline augmentation + Roboflow re-upload
├── eda.ipynb                # Exploratory data analysis
├── data/
│   └── data.yaml            # YOLO dataset config
├── weights/
│   └── best.pt              # Best checkpoint (download separately)
├── runs/                    # Training outputs (auto-generated)
└── README.md
```

---

## ⚠️ Known Limitations

| Limitation | Detail |
|:--|:--|
| `waste` class ceiling | Visual ambiguity with organic/paper limits AP to ~61% regardless of scale |
| Small object recall | Many Construction Waste boxes are under 1% image area; training at `imgsz=1280` or a P2 head would help |
| Scene domain gap | Data is predominantly urban-residential; poor coverage of industrial/construction sites |
| Train/val size distribution shift | Confirmed by KS test — val boxes are statistically larger than train boxes |

---

## 🗺️ Roadmap to 80%+ mAP

- [ ] **Re-shuffle train/val split** to eliminate bounding-box size distribution shift
- [ ] **Collect 500+ new Construction Waste images** from demolition and active construction sites
- [ ] **Train at `imgsz=1280`** to recover small-object recall
- [ ] **Evaluate P2 detection head** for tiny-box classes (Construction Waste)
- [ ] **Apply SAHI (Slicing Aided Hyper Inference)** at test time for dense small-object scenes
- [ ] **Refine `waste` class** — split into sub-categories or merge with nearest semantic class
- [ ] **Build deployment demo** (Gradio / Streamlit)
- [ ] **Add real-time video inference** with tracking (ByteTrack)

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).

---

## 📖 Citation

```bibtex
@misc{neatnow2026,
  title  = {Neat Now: Smart Waste Detection using YOLO26},
  author = {Qasim Javed},
  year   = {2026},
  url    = {https://github.com/jqasim522/neat-now}
}
```

---

<div align="center">

Made with ☕ and too many training runs by **Qasim Javed**  
*Lahore, Pakistan · FYP 2026*

</div>
