const express = require("express");
const cors = require("cors");
require("dotenv").config();

const app = express();

app.use(cors());
app.use(express.json());

// ===============================
// Health Check
// ===============================
app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    service: "siraj-backend",
    message: "Siraj AI backend is running"
  });
});

// ===============================
// Home
// ===============================
app.get("/", (req, res) => {
  res.json({
    service: "Siraj AI",
    status: "running"
  });
});

// ===============================
// AI Chat - اختبار أولي
// ===============================
app.post("/api/ai/chat", async (req, res) => {
  try {
    const { message } = req.body;

    if (!message || typeof message !== "string") {
      return res.status(400).json({
        success: false,
        error: "message is required"
      });
    }

    res.json({
      success: true,
      message: message,
      reply: "وصلت رسالتك إلى Siraj AI Backend بنجاح."
    });

  } catch (error) {
    console.error("AI Chat Error:", error);

    res.status(500).json({
      success: false,
      error: "Internal server error"
    });
  }
});

// ===============================
// Server
// ===============================
const PORT = process.env.PORT || 10000;

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Siraj backend running on port ${PORT}`);
});