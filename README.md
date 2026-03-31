# Smart Waste Detection — YOLOv8 / YOLO26

[![Python 3.9+](https://img.shields.io/badge/python-3.9+-blue.svg)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ultralytics](https://img.shields.io/badge/ultralytics-yolov8-brightgreen)](https://github.com/ultralytics/ultralytics)
[![Dataset: Roboflow](https://img.shields.io/badge/dataset-roboflow-purple)](https://roboflow.com)

> Real-time object detection for intelligent waste classification and management.  
> Fine-tuned YOLO26 (Fast) on a 9-class Asian waste dataset — achieving **72% mAP@0.5** in 50 epochs.

---

## Overview

This project delivers a production-ready waste detection system trained to identify and classify nine distinct waste categories from images and video. It is built as the computer-vision component of a Final Year Project (FYP) targeting smart city waste monitoring in Pakistan.

The training pipeline handles the full lifecycle: dataset download via Roboflow, exploratory data analysis, offline augmentation for minority classes, model training with early stopping, and comprehensive evaluation with per-class metrics.

Three model versions were trained iteratively:

| Version | Architecture | Epochs | mAP@0.5 | Precision | Recall |
|---------|-------------|--------|---------|-----------|--------|
| v1      | YOLOv8m     | 100    | 68.0%   | 72.0%     | 63.0%  |
| v2      | YOLO26 Fast | 150    | 68.4%   | 76.8%     | 61.3%  |
| v3/v4   | YOLO26 Fast | 50     | **72.0%** | **81.8%** | **63.2%** |

---

## Classes

| ID | Class              | Notes                                      |
|----|--------------------|--------------------------------------------|
| 0  | Animal Waste       |                                            |
| 1  | Construction Waste | Challenging — tiny boxes, sparse data      |
| 2  | Garbage Bag        |                                            |
| 3  | Glass              |                                            |
| 4  | Metal              |                                            |
| 5  | Organic            |                                            |
| 6  | Paper              |                                            |
| 7  | Plastic            |                                            |
| 8  | waste              | General/mixed refuse catch-all             |

---

## Dataset

- **Total images:** 11,523 (640 × 640 px, uniform)
- **Total annotations:** 27,275 bounding boxes
- **Split:** 79.6% train / 9.9% val / 10.6% test
- **Source:** Collected and annotated via [Roboflow](https://roboflow.com)
- **Imbalance:** Construction Waste is the minority class (2.5× imbalance ratio vs majority)

Offline augmentation was applied to Construction Waste images to address class imbalance:
- Horizontal flip, random 90° rotation, shift/scale/rotate (±30°), brightness/contrast jitter, Gaussian noise
- This tripled Construction Waste representation from ~295 unique images before augmentation

> **Note on Construction Waste:** AP@0.5 on the test set is 19% — significantly below other classes. This reflects the visual heterogeneity of the class (rubble, timber, pipes, concrete) and a limited diversity of source images rather than a model deficiency. It is flagged as a known limitation and prioritised for future data collection.

---

## Results

### Per-class AP@0.5 — final model (val / test)

| Class              | Val AP | Test AP | Gap    |
|--------------------|--------|---------|--------|
| Metal              | 88%    | 88%     | 0pp    |
| Glass              | 88%    | 72%     | -17pp  |
| Paper              | 88%    | 88%     | 0pp    |
| Garbage Bag        | 81%    | 79%     | -2pp   |
| Organic            | 76%    | 72%     | -4pp   |
| Plastic            | 73%    | 89%     | +18pp  |
| waste              | 62%    | 60%     | -2pp   |
| Animal Waste       | 61%    | 69%     | +8pp   |
| Construction Waste | 33%    | 19%     | -14pp  |
| **Overall**        | **72%**| **71%** | -1pp   |

---

## Model

| Parameter             | Value                    |
|-----------------------|--------------------------|
| Architecture          | YOLO26 Object Detection (Fast) |
| Input resolution      | 640 × 640                |
| Epochs                | 50                       |
| Early-stop patience   | 30                       |
| Optimizer             | SGD                      |
| Initial LR            | 0.01                     |
| Momentum              | 0.937                    |
| Weight decay          | 0.0005                   |
| Training hardware     | NVIDIA T4 (Kaggle)       |
| Training time         | ~4 hours                 |

Built-in augmentations used during training: mosaic, mixup, HSV jitter, horizontal flip, scale, and rotation.

---

## Project Structure

```
smart-waste-detection/
├── train.ipynb              # Main training notebook (Kaggle-ready)
├── augment_upload.ipynb     # Offline augmentation + Roboflow upload
├── eda.ipynb                # Exploratory data analysis
├── data/
│   └── data.yaml            # Dataset config for YOLO
├── weights/
│   └── best.pt              # Best checkpoint (download separately)
└── README.md
```

---

## Quick start

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/smart-waste-detection.git
cd smart-waste-detection
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
dataset = project.version(4).download("yolov8")
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
  name=waste_v4
```

> Training on Kaggle: open `train.ipynb`, enable GPU (T4), and run all cells. The notebook handles dataset download, training, and evaluation automatically.

### 5. Run inference

```python
from ultralytics import YOLO

model = YOLO("weights/best.pt")
results = model("path/to/image.jpg")
results[0].show()
```

### 6. Evaluate

```bash
yolo detect val \
  model=weights/best.pt \
  data=data/data.yaml \
  split=test
```

---

## Export for deployment

```python
from ultralytics import YOLO

model = YOLO("weights/best.pt")

model.export(format="onnx")        # ONNX (CPU/GPU universal)
model.export(format="torchscript") # TorchScript (mobile)
model.export(format="engine")      # TensorRT (NVIDIA GPU, fastest)
```

---

## Known limitations

| Limitation | Detail |
|---|---|
| Construction Waste detection | 19% test AP. Class is visually heterogeneous (rubble, timber, concrete, pipes). Requires more diverse training data. |
| Small object recall | 55.6% of Construction Waste boxes are under 1% image area. Training at `imgsz=1280` or using a P2 detection head is recommended. |
| Train/val distribution shift | KS test confirms val boxes are statistically larger than train boxes. Val AP may over-estimate real-world performance on small objects. |
| Scene domain coverage | Current data is predominantly urban residential. Construction site and industrial site coverage is limited. |

---

## Roadmap

- [ ] Collect 500+ new Construction Waste images from construction and demolition sites
- [ ] Train at `imgsz=1280` to improve small-object detection
- [ ] Evaluate a P2 detection head variant for tiny-box classes
- [ ] Re-shuffle train/val split to eliminate distribution shift
- [ ] Build a lightweight deployment demo (Gradio or Streamlit)
- [ ] Add video inference support

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Citation

If you use this work in your own research or project, please cite:

```bibtex
@misc{smartwaste2026,
  title  = {Smart Waste Detection using YOLOv8/YOLO26},
  author = {Your Name},
  year   = {2026},
  url    = {https://github.com/yourusername/smart-waste-detection}
}
```
