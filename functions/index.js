const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");
const crypto = require("crypto");
const OpenAI = require("openai");

const {
  initializeApp,
  cert,
} = require("firebase-admin/app");

const {
  getAuth,
} = require("firebase-admin/auth");

const {
  getFirestore,
} = require("firebase-admin/firestore");

const {
  getAppCheck,
} = require("firebase-admin/app-check");

require("dotenv").config();

const app = express();


// ======================================================
// Security Configuration
// ======================================================

const FREE_QUESTIONS_LIMIT = 3;

// مدة الحجز المؤقت للسؤال.
// إذا انقطع الخادم أثناء معالجة الطلب، يمكن تحرير الحجز
// تلقائيًا بعد انتهاء هذه المدة عند الطلب التالي.
const QUESTION_RESERVATION_TTL_MS =
  2 * 60 * 1000;

// الحد الأقصى للرسالة التي يسمح بها الخادم.
const MAX_MESSAGE_LENGTH = 4000;

// الحد الأقصى لكل عنصر في history.
const MAX_HISTORY_ITEM_LENGTH = 4000;

// App Check:
// false = وضع اختبار/تدقيق حاليًا.
// true  = App Check يصبح إلزاميًا.
const REQUIRE_APP_CHECK =
  process.env.REQUIRE_APP_CHECK === "true";

// Replay Protection:
// لا تفعله قبل تعديل Flutter لاستخدام limited-use tokens.
const APP_CHECK_REPLAY_PROTECTION =
  process.env.APP_CHECK_REPLAY_PROTECTION === "true";


// ======================================================
// Basic HTTP Security
// ======================================================

app.disable("x-powered-by");

app.use(
  helmet({
    contentSecurityPolicy: false,
  })
);

app.use(
  express.json({
    limit: "20kb",
  })
);


// ======================================================
// CORS
// ======================================================

// تطبيق Android لا يعتمد على CORS كوسيلة حماية.
// نتركه مفتوحًا حاليًا حتى لا نكسر أي اتصال موجود.

app.use(
  cors({
    origin: true,
    methods: ["GET", "POST", "OPTIONS"],
    allowedHeaders: [
      "Content-Type",
      "Authorization",
      "X-Firebase-AppCheck",
      "X-Request-ID",
    ],
  })
);


// ======================================================
// General Rate Limit
// ======================================================

const generalLimiter = rateLimit({
  windowMs: 60 * 1000,

  // عدد الطلبات العامة من نفس IP خلال دقيقة.
  max: 120,

  standardHeaders: true,
  legacyHeaders: false,

  message: {
    success: false,
    error: "RATE_LIMITED",
  },
});

app.use(generalLimiter);


// ======================================================
// AI Rate Limit
// ======================================================

const aiLimiter = rateLimit({
  windowMs: 60 * 1000,

  // حماية إضافية لـ /api/ai/chat.
  max: 12,

  standardHeaders: true,
  legacyHeaders: false,

  message: {
    success: false,
    error: "AI_RATE_LIMITED",
  },
});


// ======================================================
// Firebase Admin
// ======================================================

let firebaseReady = false;
let firebaseAuth = null;
let firestore = null;
let firebaseApp = null;
let appCheckClient = null;

try {
  if (!process.env.FIREBASE_SERVICE_ACCOUNT) {
    throw new Error(
      "FIREBASE_SERVICE_ACCOUNT is missing"
    );
  }

  const serviceAccount = JSON.parse(
    process.env.FIREBASE_SERVICE_ACCOUNT
  );

  firebaseApp = initializeApp({
    credential: cert(serviceAccount),
  });

  firebaseAuth = getAuth(firebaseApp);
  firestore = getFirestore(firebaseApp);

  try {
    appCheckClient = getAppCheck(firebaseApp);

    console.log(
      "Firebase App Check initialized"
    );
  } catch (appCheckError) {
    console.error(
      "Firebase App Check initialization failed:",
      appCheckError.message
    );
  }

  firebaseReady = true;

  console.log(
    "Firebase Admin initialized successfully"
  );
} catch (error) {
  console.error(
    "Firebase Admin initialization failed:",
    error.message
  );
}


// ======================================================
// OpenAI
// ======================================================

if (!process.env.OPENAI_API_KEY) {
  console.error(
    "OPENAI_API_KEY is missing"
  );
}

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});


// ======================================================
// Siraj AI Instructions
// ======================================================

// ======================================================
// ضع هنا SIRAJ_INSTRUCTIONS الحالية كاملة كما أرسلتها.
// لا تغيّر محتواها.
// ======================================================

const SIRAJ_INSTRUCTIONS = `
ضع هنا تعليمات سِراج الحالية كاملة.

استخدم النص الموجود لديك حاليًا دون تغيير.
`;


// ======================================================
// Utility: Request ID
// ======================================================

function createRequestId() {
  return crypto.randomUUID();
}


// ======================================================
// Request ID Middleware
// ======================================================

app.use((req, res, next) => {
  const incomingRequestId =
    req.headers["x-request-id"];

  if (
    typeof incomingRequestId === "string" &&
    /^[a-zA-Z0-9_-]{8,100}$/.test(
      incomingRequestId
    )
  ) {
    req.requestId =
      incomingRequestId;
  } else {
    req.requestId =
      createRequestId();
  }

  res.setHeader(
    "X-Request-ID",
    req.requestId
  );

  next();
});


// ======================================================
// Firebase Authentication Middleware
// ======================================================

async function verifyFirebaseToken(
  req,
  res,
  next
) {
  try {
    if (
      !firebaseReady ||
      !firebaseAuth
    ) {
      return res.status(500).json({
        success: false,
        error: "FIREBASE_NOT_CONFIGURED",
      });
    }

    const authHeader =
      req.headers.authorization;

    if (
      !authHeader ||
      !authHeader.startsWith(
        "Bearer "
      )
    ) {
      return res.status(401).json({
        success: false,
        error: "AUTH_REQUIRED",
      });
    }

    const idToken =
      authHeader
        .substring(7)
        .trim();

    if (!idToken) {
      return res.status(401).json({
        success: false,
        error: "AUTH_REQUIRED",
      });
    }

    const decodedToken =
      await firebaseAuth.verifyIdToken(
        idToken
      );

    // مهم جدًا:
    // UID الموثوق يأتي من Firebase Token.
    // لا نثق بأي UID يرسله Flutter في body.

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


// ======================================================
// Firebase App Check Middleware
// ======================================================

async function verifyFirebaseAppCheck(
  req,
  res,
  next
) {
  // وضع Audit في البداية:
  // يسمح للتطبيق الحالي بالعمل،
  // لكنه يسجل غياب App Check.

  const appCheckToken =
    req.headers["x-firebase-appcheck"];

  if (!appCheckToken) {
    if (REQUIRE_APP_CHECK) {
      return res.status(401).json({
        success: false,
        error: "APP_CHECK_REQUIRED",
      });
    }

    console.warn(
      `[APP_CHECK_AUDIT] Missing token | request=${req.requestId}`
    );

    return next();
  }

  if (
    !firebaseReady ||
    !appCheckClient
  ) {
    if (REQUIRE_APP_CHECK) {
      return res.status(500).json({
        success: false,
        error:
          "APP_CHECK_NOT_CONFIGURED",
      });
    }

    return next();
  }

  try {
    let claims;

    if (
      APP_CHECK_REPLAY_PROTECTION
    ) {
      claims =
        await appCheckClient.verifyToken(
          appCheckToken,
          {
            consume: true,
          }
        );

      if (
        claims &&
        claims.alreadyConsumed
      ) {
        return res.status(401).json({
          success: false,
          error:
            "APP_CHECK_TOKEN_REPLAYED",
        });
      }
    } else {
      claims =
        await appCheckClient.verifyToken(
          appCheckToken
        );
    }

    req.appCheck = claims;

    next();
  } catch (error) {
    console.warn(
      `[APP_CHECK_FAILED] request=${req.requestId}`
    );

    if (REQUIRE_APP_CHECK) {
      return res.status(401).json({
        success: false,
        error:
          "INVALID_APP_CHECK_TOKEN",
      });
    }

    next();
  }
}


// ======================================================
// Input Sanitization
// ======================================================

function cleanMessage(message) {
  if (
    typeof message !== "string"
  ) {
    return "";
  }

  return message
    .trim()
    .slice(0, MAX_MESSAGE_LENGTH);
}


function cleanHistory(history) {
  if (!Array.isArray(history)) {
    return [];
  }

  return history
    .filter(
      (item) =>
        item &&
        typeof item === "object" &&
        typeof item.role ===
          "string" &&
        typeof item.content ===
          "string"
    )
    .filter(
      (item) =>
        item.role === "user" ||
        item.role === "assistant"
    )
    .slice(-12)
    .map((item) => ({
      role: item.role,
      content:
        item.content
          .trim()
          .slice(
            0,
            MAX_HISTORY_ITEM_LENGTH
          ),
    }));
}


// ======================================================
// Question Reservation
// ======================================================
//
// بدل زيادة العداد مباشرة قبل OpenAI، نضع السؤال في
// pendingQuestions.
//
// هذا يمنع مشكلة:
// OpenAI يفشل -> المستخدم يخسر سؤالًا بدون إجابة.
//
// البنية:
// pendingQuestions: {
//   requestId: timestamp
// }
//
// used + pending < 3
// ======================================================

async function reserveQuestion(
  uid,
  requestId
) {
  if (!firestore) {
    throw new Error(
      "FIRESTORE_NOT_CONFIGURED"
    );
  }

  const userRef =
    firestore
      .collection("users")
      .doc(uid);

  return await firestore.runTransaction(
    async (transaction) => {
      const userSnapshot =
        await transaction.get(
          userRef
        );

      if (!userSnapshot.exists) {
        throw new Error(
          "USER_PROFILE_NOT_FOUND"
        );
      }

      const userData =
        userSnapshot.data() || {};

      const accountType =
        userData.accountType ||
        "free";

      // Premium لا يخضع لحد الأسئلة.
      if (
        accountType === "premium"
      ) {
        return {
          allowed: true,
          premium: true,
          reserved: false,
          questionsUsed: 0,
          questionsRemaining: null,
        };
      }

      const questionsUsed =
        Number(
          userData.freeQuestionsUsed ||
            0
        );

      let pendingQuestions =
        userData.pendingQuestions || {};

      if (
        typeof pendingQuestions !==
        "object"
      ) {
        pendingQuestions = {};
      }

      const now = Date.now();

      // تنظيف الحجوزات القديمة.
      const activePending = {};

      for (
        const [id, timestamp]
        of Object.entries(
          pendingQuestions
        )
      ) {
        if (
          typeof timestamp ===
            "number" &&
          now - timestamp <
            QUESTION_RESERVATION_TTL_MS
        ) {
          activePending[id] =
            timestamp;
        }
      }

      // منع إعادة استخدام نفس request ID.
      if (
        activePending[requestId]
      ) {
        return {
          allowed: false,
          premium: false,
          duplicate: true,
          questionsUsed,
          questionsRemaining:
            Math.max(
              FREE_QUESTIONS_LIMIT -
                questionsUsed -
                Object.keys(
                  activePending
                ).length,
              0
            ),
        };
      }

      const pendingCount =
        Object.keys(
          activePending
        ).length;

      const available =
        FREE_QUESTIONS_LIMIT -
        questionsUsed -
        pendingCount;

      if (available <= 0) {
        return {
          allowed: false,
          premium: false,
          duplicate: false,
          questionsUsed,
          questionsRemaining: 0,
        };
      }

      activePending[requestId] =
        now;

      transaction.update(
        userRef,
        {
          pendingQuestions:
            activePending,
        }
      );

      return {
        allowed: true,
        premium: false,
        reserved: true,
        questionsUsed,
        questionsRemaining:
          available - 1,
      };
    }
  );
}


// ======================================================
// Complete Question
// ======================================================

async function completeQuestion(
  uid,
  requestId,
  success
) {
  if (!firestore) {
    throw new Error(
      "FIRESTORE_NOT_CONFIGURED"
    );
  }

  const userRef =
    firestore
      .collection("users")
      .doc(uid);

  return await firestore.runTransaction(
    async (transaction) => {
      const userSnapshot =
        await transaction.get(
          userRef
        );

      if (!userSnapshot.exists) {
        throw new Error(
          "USER_PROFILE_NOT_FOUND"
        );
      }

      const userData =
        userSnapshot.data() || {};

      const accountType =
        userData.accountType ||
        "free";

      if (
        accountType === "premium"
      ) {
        return {
          premium: true,
        };
      }

      const questionsUsed =
        Number(
          userData.freeQuestionsUsed ||
            0
        );

      let pendingQuestions =
        userData.pendingQuestions || {};

      if (
        typeof pendingQuestions !==
        "object"
      ) {
        pendingQuestions = {};
      }

      // إزالة هذا الطلب فقط.
      delete pendingQuestions[
        requestId
      ];

      let newQuestionsUsed =
        questionsUsed;

      // السؤال يحسب فقط إذا نجحت عملية OpenAI.
      if (success) {
        newQuestionsUsed =
          questionsUsed + 1;
      }

      transaction.update(
        userRef,
        {
          freeQuestionsUsed:
            newQuestionsUsed,

          pendingQuestions:
            pendingQuestions,
        }
      );

      return {
        premium: false,
        questionsUsed:
          newQuestionsUsed,
        questionsRemaining:
          Math.max(
            FREE_QUESTIONS_LIMIT -
              newQuestionsUsed -
              Object.keys(
                pendingQuestions
              ).length,
            0
          ),
      };
    }
  );
}


// ======================================================
// Health Check
// ======================================================

app.get(
  "/health",
  (req, res) => {
    res.json({
      status: "ok",
      service:
        "siraj-backend",

      firebase:
        firebaseReady
          ? "ready"
          : "not_ready",

      firestore:
        firestore
          ? "ready"
          : "not_ready",

      appCheck:
        REQUIRE_APP_CHECK
          ? "required"
          : "audit",

      message:
        "Siraj AI backend is running",
    });
  }
);


// ======================================================
// Home
// ======================================================

app.get(
  "/",
  (req, res) => {
    res.json({
      service: "Siraj AI",
      status: "running",
      message:
        "Siraj AI backend is ready",
    });
  }
);


// ======================================================
// Usage API
// ======================================================

app.get(
  "/api/usage",

  verifyFirebaseToken,

  verifyFirebaseAppCheck,

  async (req, res) => {
    try {
      const uid =
        req.user.uid;

      const userRef =
        firestore
          .collection("users")
          .doc(uid);

      const userSnapshot =
        await userRef.get();

      if (!userSnapshot.exists) {
        return res.status(404).json({
          success: false,
          error:
            "USER_PROFILE_NOT_FOUND",
        });
      }

      const userData =
        userSnapshot.data() || {};

      const accountType =
        userData.accountType ||
        "free";

      const questionsUsed =
        Number(
          userData.freeQuestionsUsed ||
            0
        );

      if (
        accountType === "premium"
      ) {
        return res.json({
          success: true,
          accountType: "premium",
          questionsUsed: 0,
          questionsLimit: null,
          questionsRemaining:
            null,
        });
      }

      return res.json({
        success: true,

        accountType: "free",

        questionsUsed:
          questionsUsed,

        questionsLimit:
          FREE_QUESTIONS_LIMIT,

        questionsRemaining:
          Math.max(
            FREE_QUESTIONS_LIMIT -
              questionsUsed,
            0
          ),
      });
    } catch (error) {
      console.error(
        "Usage Error:",
        error.message
      );

      return res.status(500).json({
        success: false,
        error:
          "USAGE_REQUEST_FAILED",
      });
    }
  }
);


// ======================================================
// Siraj AI Chat API
// ======================================================

app.post(
  "/api/ai/chat",

  aiLimiter,

  verifyFirebaseToken,

  verifyFirebaseAppCheck,

  async (req, res) => {
    let questionReserved =
      false;

    const uid =
      req.user.uid;

    const requestId =
      req.requestId;

    try {
      const message =
        cleanMessage(
          req.body?.message
        );

      if (!message) {
        return res.status(400).json({
          success: false,
          error:
            "message is required",
        });
      }

      const conversationHistory =
        cleanHistory(
          req.body?.history
        );

      // ================================================
      // Reserve
      // ================================================

      const usage =
        await reserveQuestion(
          uid,
          requestId
        );

      if (
        usage.duplicate
      ) {
        return res.status(409).json({
          success: false,
          error:
            "DUPLICATE_REQUEST",
        });
      }

      if (!usage.allowed) {
        return res.status(402).json({
          success: false,
          error:
            "FREE_LIMIT_REACHED",

          usage: {
            accountType:
              "free",

            questionsUsed:
              usage.questionsUsed,

            questionsLimit:
              FREE_QUESTIONS_LIMIT,

            questionsRemaining:
              usage.questionsRemaining,
          },
        });
      }

      questionReserved =
        usage.reserved === true;

      // ================================================
      // Build OpenAI input
      // ================================================

      const input = [
        {
          role: "system",
          content:
            SIRAJ_INSTRUCTIONS,
        },

        ...conversationHistory,

        {
          role: "user",
          content: message,
        },
      ];

      // ================================================
      // OpenAI
      // ================================================

      const response =
        await openai.responses.create(
          {
            model: "gpt-5-mini",
            input: input,
          }
        );

      const reply =
        response.output_text
          ?.trim() ||
        "عذراً، لم أتمكن من إعداد إجابة الآن.";

      // ================================================
      // Consume question
      // ================================================

      if (questionReserved) {
        const completed =
          await completeQuestion(
            uid,
            requestId,
            true
          );

        questionReserved =
          false;

        return res.json({
          success: true,

          reply: reply,

          usage: {
            accountType:
              "free",

            questionsUsed:
              completed.questionsUsed,

            questionsLimit:
              FREE_QUESTIONS_LIMIT,

            questionsRemaining:
              completed.questionsRemaining,
          },
        });
      }

      // Premium
      return res.json({
        success: true,

        reply: reply,

        usage: {
          accountType:
            "premium",

          questionsUsed: 0,

          questionsLimit:
            null,

          questionsRemaining:
            null,
        },
      });
    } catch (error) {
      console.error(
        "Siraj AI Error:",
        {
          requestId:
            requestId,

          uid: uid,

          error:
            error.message,
        }
      );

      // ================================================
      // Release reservation on failure
      // ================================================

      if (questionReserved) {
        try {
          await completeQuestion(
            uid,
            requestId,
            false
          );
        } catch (releaseError) {
          console.error(
            "Question release failed:",
            releaseError.message
          );
        }
      }

      if (
        error.message ===
        "FIRESTORE_NOT_CONFIGURED"
      ) {
        return res.status(500).json({
          success: false,
          error:
            "FIRESTORE_NOT_CONFIGURED",
        });
      }

      if (
        error.message ===
        "USER_PROFILE_NOT_FOUND"
      ) {
        return res.status(404).json({
          success: false,
          error:
            "USER_PROFILE_NOT_FOUND",
        });
      }

      // أخطاء OpenAI
      if (
        error.status === 429
      ) {
        return res.status(503).json({
          success: false,
          error:
            "AI_TEMPORARILY_UNAVAILABLE",
        });
      }

      return res.status(500).json({
        success: false,
        error:
          "AI request failed",
      });
    }
  }
);


// ======================================================
// 404
// ======================================================

app.use(
  (req, res) => {
    return res.status(404).json({
      success: false,
      error: "NOT_FOUND",
    });
  }
);


// ======================================================
// Global Error Handler
// ======================================================

app.use(
  (error, req, res, next) => {
    console.error(
      "Unhandled Server Error:",
      error.message
    );

    return res.status(500).json({
      success: false,
      error:
        "INTERNAL_SERVER_ERROR",
    });
  }
);


// ======================================================
// Start Server
// ======================================================

const PORT =
  process.env.PORT || 10000;

app.listen(
  PORT,
  "0.0.0.0",
  () => {
    console.log(
      `Siraj backend running on port ${PORT}`
    );

    console.log(
      `App Check required: ${REQUIRE_APP_CHECK}`
    );

    console.log(
      `App Check replay protection: ${APP_CHECK_REPLAY_PROTECTION}`
    );
  }
);
