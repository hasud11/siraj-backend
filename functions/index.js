const express = require("express");

const app = express();

app.use(express.json());

// اختبار أن الـ Backend يعمل
app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    service: "siraj-backend",
    message: "Siraj AI backend is running"
  });
});

// استقبال طلبات مستقبلية من تطبيق سِراج AI
app.get("/", (req, res) => {
  res.json({
    service: "Siraj AI",
    status: "running"
  });
});

// Render يوفر PORT تلقائياً
const PORT = process.env.PORT || 10000;

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Siraj backend running on port ${PORT}`);
});
