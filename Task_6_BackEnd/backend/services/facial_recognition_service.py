from fastapi import FastAPI, UploadFile, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import face_recognition
import numpy as np
import io
from PIL import Image
import firebase_admin
from firebase_admin import credentials, firestore
import base64

# Initialize Firebase
cred = credentials.Certificate('Task_6_BackEnd/backend/firebaseServiceKey.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

app = FastAPI()

# Allow CORS for your frontend/backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # You can restrict this to your backend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Threshold for face matching
FACE_MATCH_THRESHOLD = 0.6
class RegisterRequest(BaseModel):
    studentId: str
    imageBase64: str


class VerifyRequest(BaseModel):
    studentId: str
    imageBase64: str

@app.get("/health")
def health_check():
    return {"status": "ok"}

@app.get("/")
def read_root():
    return {"message": "Facial Recognition Service is up and running!"}


@app.post("/register")
async def register_face(request: RegisterRequest):
    try:
        image_bytes = base64.b64decode(request.imageBase64.split(",")[1])
        image = face_recognition.load_image_file(io.BytesIO(image_bytes))
        encodings = face_recognition.face_encodings(image)

        if not encodings:
            raise HTTPException(status_code=400, detail="No face detected")

        encoding_list = encodings[0].tolist()

        db.collection("facialData").document(request.studentId).set({
            "facialEmbedding": encoding_list,
            "faceRegistered": True,
        }, merge=True)

        return {"success": True}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/verify")
async def verify_face(request: VerifyRequest):
    try:
        doc = db.collection("facialData").document(request.studentId).get()
        if not doc.exists:
            raise HTTPException(status_code=404, detail="User not found")

        data = doc.to_dict()
        if "facialEmbedding" not in data or not data.get("faceRegistered"):
            raise HTTPException(status_code=400, detail="Face not registered")

        # Convert provided image to encoding
        image_bytes = base64.b64decode(request.imageBase64.split(",")[1])
        image = face_recognition.load_image_file(io.BytesIO(image_bytes))
        encodings = face_recognition.face_encodings(image)

        if not encodings:
            raise HTTPException(status_code=400, detail="No face detected")

        # Calculate distance
        known_encoding = np.array(data["facialEmbedding"])
        distance = np.linalg.norm(encodings[0] - known_encoding)

        return {
            "match": distance < FACE_MATCH_THRESHOLD,
            "confidence": round(float(1 - min(distance, 1.0)), 2),
            "distance": round(float(distance), 4)
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

