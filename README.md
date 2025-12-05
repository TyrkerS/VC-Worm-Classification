# WORM CLASSIFICATION


## ⭐ Project Summary
This project implements a complete pipeline for **image-based classification of intestinal worms** using classical **computer vision and image processing techniques** in MATLAB.  
The goal is to segment worms from images, extract relevant morphological features (area, eccentricity, curvature…), and classify them into predefined categories using a dataset of real samples.

This project was developed as an academic exercise in Computer Vision, focused on applying concepts such as segmentation, thresholding, contour extraction, feature engineering, and simple machine learning classification.

### What this project teaches
By completing and studying this project, one develops skills in:

#### **Computer Vision**
- Image preprocessing (blurring, thresholding, denoising)  
- Mask generation and morphological operations  
- Contour extraction and region analysis  
- Segmentation pipelines for biological imaging  

#### **Image Processing Techniques**
- HSV / grayscale conversion  
- Thresholding and adaptive segmentation  
- Morphological filtering (closing, filling, erosion…)  
- Blob analysis with regionprops  

#### **Machine Learning (Basic)**
- Feature extraction  
- Using CSV-based labeled datasets  
- Decision-rule classification  

#### **MATLAB Programming**
- Modular scripts  
- Visual debugging  
- Reproducible experiments  
- Working with image batches and datasets  

---

## 🧩 Technologies & Tools Used
- **MATLAB / Octave** – main environment  
- **Image Processing Toolbox**  
- **regionprops** for extracting morphological descriptors  
- **CSV-based dataset** for classification (`WormDataA.csv`)  
- Custom segmentation logic implemented from scratch  

No external machine learning libraries are required.

---

## 📁 Project Structure

```
VC-Worm-Classification/
│
├── main.m                               → Main execution script
├── classificacio_cucs.m                 → Feature extraction + classification for all images
├── classificacio_cucs_visual_individual.m → Visual per-image analysis with plots
│
├── WormImages/                          → Input images for segmentation & classification
│
├── WormDataA.csv                        → Dataset with labeled worm samples (ground truth)
│
└── resultats/                           → Output folder for generated masks, figures, etc.
```

### Design Philosophy
- **Separation of responsibilities**
  - `main.m` → orchestrates the workflow  
  - `classificacio_cucs.m` → full classification pipeline  
  - `classificacio_cucs_visual_individual.m` → debug & detailed visualisation  

- **Dataset-driven evaluation**
  Classification compares extracted features from images with real labeled CSV data.

- **Transparent processing**
  All intermediate steps (mask, contour, segmented worm) are saved for debugging.

---

## 🔍 Project Details

### **1. Segmentation Pipeline**
Each worm image goes through:
1. Grayscale preprocessing  
2. Noise reduction  
3. Thresholding  
4. Morphological cleaning  
5. Largest-blob extraction  
6. Boundary / contour detection  
7. Regionprops-based feature computation  

The segmentation must isolate a **single worm**, removing noise and artifacts.

---

### **2. Feature Extraction**
Each worm is described by metrics including:
- Area  
- Eccentricity  
- Major/Minor axis ratio  
- Curvature estimation  
- Solidity  
- Perimeter  

These are computed using MATLAB’s `regionprops` and custom functions.

---

### **3. Classification System**
Using the CSV dataset (`WormDataA.csv`), the system:
1. Extracts the same features from labeled worms  
2. Computes class statistics or thresholds  
3. Classifies new worms by comparing their descriptors  

Classification is based on simple decision rules, making the logic easy to inspect and tune.

---

### **4. Visualization**
`classificacio_cucs_visual_individual.m` generates:
- Original image  
- Segmented mask  
- Contour overlay  
- Extracted features  
- Final predicted class  

Useful for debugging and presenting results.

---

## ▶️ How to Run the Project

### **1. Open MATLAB**
```matlab
cd PracticaVC
```

### **2. Run the full classification pipeline**
```matlab
main
```

This script runs the segmentation and classification for all images located in `WormImages/`, and saves results in `resultats/`.

### **3. Run per-image visual debugging**
```matlab
classificacio_cucs_visual_individual
```

Useful to inspect each detection step visually.

---

## ✔ Summary
This project implements a complete classical computer vision pipeline for worm segmentation and classification.  
It demonstrates practical image processing techniques, real-world feature engineering, dataset-driven classification, and MATLAB scripting — all in a clean and educational structure ideal for academic evaluation or portfolio showcasing.
