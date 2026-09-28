const express = require("express");
const cors = require("cors");
require("dotenv").config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// الصفحة الرئيسية
app.get("/", (req, res) => {
  res.json({
    service: "Siraj AI",
    status: "running",
    message: "Siraj AI backend is running"
  });
});

// فحص حالة الخادم
app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    service: "siraj-backend",
    message: "Siraj AI backend is running"
  });
});

// Render يوفر PORT تلقائياً
const PORT = process.env.PORT || 10000;

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Siraj backend running on port ${PORT}`);
});