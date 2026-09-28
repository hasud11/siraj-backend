const express = require("express");
const cors = require("cors");
const OpenAI = require("openai");
require("dotenv").config();

const app = express();

app.use(cors());
app.use(express.json());

// OpenAI
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// اختبار أن الـ Backend يعمل
app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    service: "siraj-backend",
    message: "Siraj AI backend is running",
  });
});

// الصفحة الرئيسية
app.get("/", (req, res) => {
  res.json({
    service: "Siraj AI",
    status: "running",
    message: "Siraj AI backend is ready",
  });
});

// ================================
// Siraj AI Chat API
// ================================
app.post("/api/ai/chat", async (req, res) => {
  try {
    const { message } = req.body;

    if (!message || typeof message !== "string") {
      return res.status(400).json({
        success: false,
        error: "message is required",
      });
    }

    const response = await openai.responses.create({
      model: "gpt-5-mini",
      input: [
        {
          role: "system",
          content:
            "أنت سِراج AI، مساعد ذكي عربي. أجب بوضوح واختصار وبأسلوب احترافي ومفيد.",
        },
        {
          role: "user",
          content: message,
        },
      ],
    });

    res.json({
      success: true,
      reply: response.output_text,
    });
  } catch (error) {
    console.error("Siraj AI Error:", error);

    res.status(500).json({
      success: false,
      error: "AI request failed",
    });
  }
});

// Render يوفر PORT تلقائياً
const PORT = process.env.PORT || 10000;

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Siraj backend running on port ${PORT}`);
});