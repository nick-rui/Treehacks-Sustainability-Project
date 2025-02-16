from fastapi import FastAPI, File, UploadFile
from ultralytics import YOLO
import cv2
import numpy as np
from PIL import Image
import io
import random

# Initialize FastAPI app
app = FastAPI()

# Load YOLO model (assuming it's already trained and available in your notebook)
# model = YOLO("/home/ubuntu/model_training/Object Detection/code/runs/detect/train10/weights/best.pt")  # Update with correct model path
# model = YOLO("yolov8x.pt")
model = YOLO("/home/ubuntu/model_training/Object Detection/code/runs/detect/train11/weights/last.pt")  # Update with correct model path


annotations = None
names = ['Aluminium foil', 'Battery', 'Aluminium blister pack', 'Carded blister pack', 'Bottle', 'Bottle', 'Bottle', 'Plastic bottle cap', 'Metal bottle cap', 'Broken glass', 'Food Can', 'Aerosol', 'Drink can', 'Toilet tube', 'Other carton', 'Egg carton', 'Drink carton', 'Corrugated carton', 'Meal carton', 'Pizza box', 'Paper cup', 'Plastic cup', 'Foam cup', 'Glass cup', 'Plastic cup', 'Food waste', 'Glass jar', 'Plastic lid', 'Metal lid', 'Other plastic', 'Magazine paper', 'Tissues', 'Wrapping paper', 'Normal paper', 'Paper bag', 'Chip bag', 'Plastic film', 'Six pack rings', 'Plastic bag', 'Chip bag', 'Single-use carrier bag', 'Polypropylene bag', 'Chip bag', 'Spread tub', 'Tupperware', 'Disposable food container', 'Foam food container', 'Other plastic container', 'Plastic glooves', 'Plastic utensils', 'Pop tab', 'Rope & strings', 'Scrap metal', 'Shoe', 'Squeezable tube', 'Plastic straw', 'Paper straw', 'Styrofoam piece', 'Unlabeled litter', 'Cigarette']
# likelihood = [0.5, 0.3, 0.2, 0.3, 0.95, 0.95, 0.7, 0.8, 0.6, 0.4, 0.7, 0.5, 0.9, 0.4, 0.3, 0.6, 0.7, 0.4, 0.3, 0.9, 0.8, 0.85, 0.75, 0.4, 0.85, 1.0, 0.5, 0.6, 0.5, 0.4, 0.3, 0.7, 0.6, 0.85, 0.75, 0.95, 0.9, 0.2, 0.95, 0.9, 0.8, 0.7, 0.9, 0.5, 0.3, 0.8, 0.75, 0.5, 0.2, 0.6, 0.1, 0.2, 0.4, 0.2, 0.3, 0.5, 0.4, 0.6, 0.1, 0.9]
items_we_want = {'Aluminium foil','Aerosol', 'Cigarette', 'Plastic bottle', 'Chip bag', 'Plastic cup', 'Drink can', 'Drink carton', 'Egg carton', 'Foam cup', 'Food can', 'Food waste', 'Bottle', 'Normal paper', 'Paper cup', 'Pizza box', 'Plastic straw', 'Plastic utensils', 'Scrap metal', 'Squeezable tube'}
# likelihood = [1 if name in items_we_want else 0.2 for name in names]
recyclable = {
    'Aluminium foil', 'Aerosol', 'Bottle', 'Plastic cup', 'Drink can', 
    'Drink carton', 'Egg carton', 'Food can', 'Normal paper', 'Scrap metal'
}

not_recyclable = {
    'Cigarette', 'Chip bag', 'Foam cup', 'Paper cup', 'Pizza box', 
    'Plastic straw', 'Plastic utensils', 'Squeezable tube'
}

compostable = {'Food waste'}

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    global annotations

    # Read image file
    image_bytes = await file.read()
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    
    # Convert PIL image to NumPy array
    image_np = np.array(image)
    
    # Run YOLO inference
    results = model.predict(image_np)

    # Extract detections
    detections = []
    for result in results:
        for box in result.boxes:
            x1, y1, x2, y2 = box.xyxy[0].tolist()
            conf = float(box.conf[0])
            class_id = int(box.cls[0])
            class_name = names[class_id]

            if class_name in items_we_want:
                detections.append({
                    "object": class_name,
                    "confidence": conf,
                    "bbox": [x1, y1, x2, y2],
                    "class_name": "recyclable" if class_name in recyclable 
                        else "compostable" if class_name in compostable 
                        else "not recyclable"
                })
            # else:
            #     detections.append({
            #         "object": f'unknown ({class_name})',
            #         "confidence": conf,
            #         "bbox": [x1, y1, x2, y2]
            #     })

    annotations = detections
    detections.sort(key=lambda x: x["confidence"], reverse=True)

    return {"detections": detections}

@app.get("/latest")
async def latest():
    global annotations
    return {"detections": annotations}