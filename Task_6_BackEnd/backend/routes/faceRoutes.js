const express = require("express");
const multer = require("multer");
const { registerFace, verifyFace } = require("../controllers/faceController");

const router = express.Router();

const upload = multer({ storage: multer.memoryStorage() });

router.post("/register", upload.single("image"), registerFace);
router.post("/verify", upload.single("image"), verifyFace);

module.exports = router;
