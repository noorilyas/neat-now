# 🗑️ NEAT NOW using YOLOv8

[![Python 3.9+](https://img.shields.io/badge/python-3.9+-blue.svg)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ultralytics](https://img.shields.io/badge/ultralytics-yolov8-brightgreen)](https://github.com/ultralytics/ultralytics)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

> **Real‑time object detection for intelligent waste management**  
> Fine‑tuned YOLOv8m on a 9‑class garbage dataset – ready for deployment.

---

## 📌 Overview

This project delivers a **production‑ready waste detection system** using **YOLOv8** (Ultralytics). The model is trained to detect and classify nine distinct waste categories from images, enabling automated waste sorting, monitoring, and reporting in smart cities or industrial settings.

Built as part of a **Final Year Project (FYP)**, it addresses real‑world challenges like **class imbalance**, **varying object scales**, and **real‑time inference**. The pipeline is fully automated, from dataset download to model export, and is optimized for Kaggle’s free GPU environment.

---

## 🎯 Key Features

- ✅ **Real‑time detection** – inference speed of 10–20 ms per image on GPU.
- ✅ **9‑class classification** – covers common waste types (plastic, glass, metal, organic, construction waste, etc.).
- ✅ **Robust training pipeline** – automatic dataset download (Roboflow), dataset validation, and EDA.
- ✅ **Handles class imbalance** – targeted augmentation for minority classes.
- ✅ **Comprehensive evaluation** – mAP@0.5, mAP@0.5:0.95, precision, recall, per‑class AP, confusion matrix.
- ✅ **Model export** – supports PyTorch (`best.pt`), ONNX, TensorRT, and TorchScript for flexible deployment.
- ✅ **Kaggle ready** – fully compatible with Kaggle’s GPU environment (“Save & Run All”).
- ✅ **Reproducible** – all parameters are centralised in a single config dataclass.

---

## 📊 Dataset

The dataset consists of **1,226 images** split into **train / valid / test**, with **9,404 annotations** across the following classes:

| ID | Class              |
|----|--------------------|
| 0  | Animal Waste       |
| 1  | Construction Waste |
| 2  | Garbage Bag        |
| 3  | Glass              |
| 4  | Metal              |
| 5  | Organic            |
| 6  | Paper              |
| 7  | Plastic            |
| 8  | waste              |

> ℹ️ The dataset was collected from multiple sources, annotated using **Roboflow**, and stored in **YOLOv8 format**.  
> **Construction Waste** is the smallest class (~300 unique images) – we applied offline augmentation (rotations, flips, brightness/contrast) to improve its representation.  
> **Glass** and **Garbage Bag** originally had polygon annotations; they were converted to bounding boxes for detection.

---

## 🧠 Model Architecture

We fine‑tuned **YOLOv8m** (medium variant), a state‑of‑the‑art single‑stage detector known for its speed‑accuracy trade‑off. Key architectural highlights:

- **CSPDarknet53 backbone** with spatial pyramid pooling.
- **Path aggregation network (PAN)** for multi‑scale feature fusion.
- **Anchor‑free detection head** with decoupled classification and regression.
- **Mosaic and MixUp** augmentations for robustness.

Hyperparameters (centralised in `TrainingConfig`):

| Parameter          | Value         |
|--------------------|---------------|
| Input size         | 640 × 640     |
| Batch size         | 32 (GPU‑specific) |
| Optimizer          | SGD           |
| Initial LR         | 0.01          |
| LR final           | 0.01          |
| Momentum           | 0.937         |
| Weight decay       | 0.0005        |
| Patience (early stop) | 30        |
| Augmentations      | mosaic, mixup, HSV, flip, scale, rotate, etc. |

Training was performed on a **NVIDIA T4 GPU** (Kaggle) with mixed precision.

---

## 🚀 Getting Started

### 1. Prerequisites

- Python 3.9 or higher
- CUDA‑capable GPU (recommended) – free T4 available on Kaggle
- Kaggle account (for GPU access and dataset hosting)

### 2. Clone the Repository

```bash
git clone https://https://github.com/noorilyas/neat-now/edit/AI-Qasim.git
cd AI-Qasim
