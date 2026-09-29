const express = require("express");
const cors = require("cors");
const OpenAI = require("openai");
const admin = require("firebase-admin");
require("dotenv").config();

const app = express();

app.use(cors());
app.use(express.json());

// ========================================
// Firebase Admin
// ========================================

let firebaseReady = false;

try {
  if (!process.env.FIREBASE_SERVICE_ACCOUNT) {
    throw new Error("FIREBASE_SERVICE_ACCOUNT is missing");
  }

  const serviceAccount = JSON.parse(
    process.env.FIREBASE_SERVICE_ACCOUNT
  );

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  firebaseReady = true;

  console.log("Firebase Admin initialized successfully");
} catch (error) {
  console.error(
    "Firebase Admin initialization failed:",
    error.message
  );
}

// ========================================
// OpenAI
// ========================================

if (!process.env.OPENAI_API_KEY) {
  console.error("OPENAI_API_KEY is missing");
}

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// ========================================
// Siraj AI Instructions
// ========================================

const SIRAJ_INSTRUCTIONS = `
أنت "سِراج"، مساعد عربي ذكي متخصص في الإرشاد الروحي الهادئ والآمن.

هويتك:
- تحدث بالعربية الطبيعية والواضحة.
- أسلوبك هادئ، راقٍ، مطمئن، ذكي وقريب من المستخدم.
- لا تكن آلياً أو جافاً.
- اجعل إجاباتك مفهومة ومباشرة.
- استخدم العناوين والنقاط عندما تساعد على تنظيم الإجابة.
- استخدم الرموز التعبيرية باعتدال.
- لا تطل الإجابة دون داعٍ.

مجالات سِراج:
- القرآن الكريم.
- الأذكار والأدعية.
- الرقية الشرعية الذاتية.
- الأسئلة الروحية.
- الخوف والقلق المرتبطان بالأمور الروحية.
- الحسد والعين والسحر من الجانب الديني والتوعوي.
- بناء روتين إيماني هادئ.
- التوعية من الدجالين والمستغلين.
- تقديم إرشادات عامة تساعد المستخدم على التعامل مع الخوف والقلق.

قواعد مهمة جداً:

1. السحر والعين والحسد:
لا تجزم أبداً بأن المستخدم مسحور أو مصاب بالعين أو الحسد.

لا تقل:
"أنت مسحور"
"فلان سحرك"
"الأعراض التي لديك تثبت السحر"
"هذا الشخص هو سبب ما يحدث لك".

بدلاً من ذلك استخدم عبارات مثل:
"لا يمكن الجزم بذلك من الأعراض وحدها."
"هناك أسباب متعددة يمكن أن تفسر ما تشعر به."
"يمكنك الالتزام بالأذكار والرقية الشرعية دون الدخول في الخوف أو الاتهامات."

2. لا تشجع على الخوف أو الشك.
إذا كان المستخدم خائفاً، ساعده على الهدوء وتنظيم أفكاره والعودة إلى خطوات عملية وآمنة.

3. الرقية الشرعية:
يمكنك شرح الرقية الشرعية الذاتية المشروعة.
يمكنك ذكر القرآن والأذكار والأدعية الصحيحة عندما تكون متأكداً منها.
لا تخترع آيات أو أحاديث أو أدعية وتنسبها إلى الدين.
لا تقدم طلاسم أو رموزاً مجهولة أو أعمالاً سحرية أو طقوساً مؤذية.

4. الصحة الجسدية والنفسية:
لا تنسب الأعراض الجسدية أو النفسية تلقائياً إلى السحر أو العين أو الحسد.
إذا ذكر المستخدم أعراضاً شديدة أو مستمرة أو مقلقة، شجعه على استشارة طبيب أو مختص مناسب.
المساعدة الروحية لا تستبدل العلاج الطبي أو النفسي.

5. الدجالون والمستغلون:
ساعد المستخدم على التعرف على علامات الاستغلال مثل:
- التخويف الشديد.
- طلب مبالغ مالية كبيرة مقابل "إزالة السحر".
- طلب صور شخصية أو معلومات حساسة بلا مبرر.
- طلب ممارسات غريبة أو مؤذية.
- الضغط على المستخدم للاستمرار بالدفع.
- الادعاء بمعرفة الغيب أو معرفة من قام بالسحر.
- مطالبته بترك العلاج الطبي.

لا تتهم شخصاً محدداً بالاحتيال دون دليل واضح.
استخدم لغة مثل:
"هذه علامة تستحق الحذر."

6. القرآن:
إذا طلب المستخدم آية أو حديثاً وأنت غير متأكد من النص، لا تخترع النص.
يمكنك أن تقول إنك غير متأكد من النص الحرفي.

7. الخصوصية:
لا تطلب من المستخدم معلومات شخصية غير ضرورية.

8. أسلوب الحوار:
اقرأ سياق المحادثة قبل الإجابة.
لا تجعل المستخدم يعيد معلومات سبق أن ذكرها.
إذا كان السؤال واضحاً، أجب مباشرة.
إذا كان يحتاج توضيحاً، اسأل سؤالاً واحداً أو سؤالين فقط.

9. الحالات الطارئة:
إذا ذكر المستخدم خطراً فورياً على نفسه أو شخص آخر أو حالة طبية طارئة، وجّهه بوضوح إلى خدمات الطوارئ أو المساعدة الطبية المحلية المناسبة.

10. الهدف الأساسي:
تقليل الخوف.
زيادة الوعي.
تقديم إرشاد ديني وروحي مسؤول.
منع الاستغلال والخرافة.
تشجيع المستخدم على اتخاذ خطوات عملية وآمنة.

أنت لا تشخّص حالات خارقة للطبيعة.
أنت لا تدّعي معرفة الغيب.
أنت لا تتهم الأشخاص.
أنت لا تستبدل الطبيب أو المختص النفسي.

اجعل المستخدم يشعر بأنه يتحدث مع مساعد محترم وهادئ يفهمه ويأخذ مخاوفه بجدية دون تضخيمها.
`;

// ========================================
// Firebase Authentication Middleware
// ========================================

async function verifyFirebaseToken(req, res, next) {
  try {
    if (!firebaseReady) {
      return res.status(500).json({
        success: false,
        error: "FIREBASE_NOT_CONFIGURED",
      });
    }

    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        success: false,
        error: "AUTH_REQUIRED",
      });
    }

    const idToken = authHeader.substring(7);

    const decodedToken = await admin
      .auth()
      .verifyIdToken(idToken);

    req.user = decodedToken;

    next();
  } catch (error) {
    console.error(
      "Firebase Auth Error:",
      error.message
    );

    return res.status(401).json({
      success: false,
      error: "INVALID_AUTH_TOKEN",
    });
  }
}

// ========================================
// Health Check
// ========================================

app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    service: "siraj-backend",
    firebase: firebaseReady
      ? "ready"
      : "not_ready",
    message: "Siraj AI backend is running",
  });
});

// ========================================
// Home
// ========================================

app.get("/", (req, res) => {
  res.json({
    service: "Siraj AI",
    status: "running",
    message: "Siraj AI backend is ready",
  });
});

// ========================================
// Siraj AI Chat API
// ========================================

app.post(
  "/api/ai/chat",
  verifyFirebaseToken,
  async (req, res) => {
    try {
      const { message, history } = req.body;

      // ----------------------------------------
      // Validate message
      // ----------------------------------------

      if (
        !message ||
        typeof message !== "string"
      ) {
        return res.status(400).json({
          success: false,
          error: "message is required",
        });
      }

      // ----------------------------------------
      // Clean conversation history
      // ----------------------------------------

      let conversationHistory = [];

      if (Array.isArray(history)) {
        conversationHistory = history
          .filter(
            (item) =>
              item &&
              typeof item === "object" &&
              typeof item.role === "string" &&
              typeof item.content === "string"
          )
          .filter(
            (item) =>
              item.role === "user" ||
              item.role === "assistant"
          )
          .slice(-12)
          .map((item) => ({
            role: item.role,
            content: item.content.slice(0, 4000),
          }));
      }

      // ----------------------------------------
      // Build AI input
      // ----------------------------------------

      const input = [
        {
          role: "system",
          content: SIRAJ_INSTRUCTIONS,
        },
        ...conversationHistory,
        {
          role: "user",
          content: message.trim().slice(0, 4000),
        },
      ];

      // ----------------------------------------
      // OpenAI
      // ----------------------------------------

      const response =
        await openai.responses.create({
          model: "gpt-5-mini",
          input,
        });

      const reply =
        response.output_text?.trim() ||
        "عذراً، لم أتمكن من إعداد إجابة الآن.";

      // ----------------------------------------
      // Response
      // ----------------------------------------

      return res.json({
        success: true,
        reply,
      });
    } catch (error) {
      console.error(
        "Siraj AI Error:",
        error
      );

      return res.status(500).json({
        success: false,
        error: "AI request failed",
      });
    }
  }
);

// ========================================
// Start Server
// ========================================

const PORT =
  process.env.PORT || 10000;

app.listen(
  PORT,
  "0.0.0.0",
  () => {
    console.log(
      `Siraj backend running on port ${PORT}`
    );
  }
);
