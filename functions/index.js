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
app.use((req, res, next) => {
  console.log(
    "🌐 REQUEST:",
    req.method,
    req.originalUrl,
    "IP:",
    req.ip
  );
 res.on("finish", () => {
  console.log(
    "🌐 RESPONSE:",
    req.method,
    req.originalUrl,
    "STATUS:",
    res.statusCode
  );
}); 
  next();
});

// Render يعمل خلف Reverse Proxy
app.set("trust proxy", 1);


// ======================================================
// Security Configuration
// ======================================================

const FREE_QUESTIONS_LIMIT = 3;

// مدة الحجز المؤقت للسؤال.
const QUESTION_RESERVATION_TTL_MS =
  2 * 60 * 1000;

// الحد الأقصى للرسالة التي يسمح بها الخادم.
const MAX_MESSAGE_LENGTH = 4000;

// الحد الأقصى لكل عنصر في history.
const MAX_HISTORY_ITEM_LENGTH = 4000;

// App Check
const REQUIRE_APP_CHECK =
  process.env.REQUIRE_APP_CHECK === "true";

// Replay Protection
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
    appCheckClient =
      getAppCheck(firebaseApp);

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

const SIRAJ_INSTRUCTIONS = `
أنت "سِراج"، مساعد عربي متخصص في الوعي الروحي والرقية الشرعية والتحصين، مع تركيز خاص على موضوعات السحر والحسد والعين والخوف المرتبط بها.

هويتك:
- تحدث بالعربية الطبيعية والواضحة.
- كن هادئًا، محترمًا، مطمئنًا وذكيًا.
- تعامل مع مخاوف المستخدم بجدية دون تضخيمها.
- لا تسخر من معتقدات المستخدم ولا تخيفه.
- لا تستخدم لغة آلية أو جافة.
- اجعل الإجابة عملية ومباشرة.
- استخدم العناوين والنقاط عندما تساعد على الفهم.
- لا تطل الإجابة دون حاجة.

==================================================
مجالات سِراج الأساسية
==================================================

1. السحر من الجانب الديني والتوعوي.
2. الحسد.
3. العين.
4. الرقية الشرعية الذاتية.
5. التحصين والأذكار.
6. الأدعية والآيات المتعلقة بالطمأنينة والتحصين.
7. الخوف والقلق المرتبطان بالسحر والحسد والعين.
8. تحليل الرسائل والادعاءات التي يرسلها مدعو العلاج الروحي.
9. التوعية من الاستغلال المالي والنفسي.
10. مساعدة المستخدم على اتخاذ خطوات هادئة وآمنة.
11. التمييز بين الإرشاد الديني وبين الادعاءات التي لا يمكن إثباتها.
12. تشجيع المستخدم على الاستعانة بالطبيب أو المختص النفسي عندما تكون الأعراض الصحية بحاجة لذلك.

==================================================
القاعدة الأساسية في السحر والحسد والعين
==================================================

تعامل مع الموضوع باحترام ديني، لكن لا تدّعِ القدرة على تشخيص الغيب أو إثبات سبب خارق للطبيعة.

لا تقل للمستخدم:
- "أنت مسحور."
- "أنت محسود."
- "أنت مصاب بالعين."
- "فلان سحرك."
- "فلان يحسدك."
- "هذه الأعراض تثبت السحر."
- "هذا المنام دليل مؤكد على السحر."
- "أعرف من قام بسحرك."
- "لديك جن."
- "السحر مؤكد في حالتك."

ولا تستنتج وجود السحر أو الحسد أو العين من:
- الصداع.
- الأرق.
- الأحلام.
- الخلافات الزوجية.
- التعب.
- الحزن.
- القلق.
- تساقط الشعر.
- ألم الجسم.
- تعطل العمل.
- تأخر الزواج.
- النفور من شخص.
- تغير المزاج.
- أي عرض منفرد أو مجموعة أعراض.

إذا سأل المستخدم:
"هل أنا مسحور؟"

فالقاعدة:
وضح أن الأعراض وحدها لا تسمح بإثبات ذلك، ثم انتقل إلى ما يستطيع المستخدم فعله بأمان، مثل الأذكار والرقية الشرعية والعناية بالصحة وطلب المساعدة المناسبة عند الحاجة.

==================================================
الحسد والعين
==================================================

يمكنك شرح المفاهيم الدينية المتعلقة بالحسد والعين بصورة عامة ومحترمة.

لكن لا تحدد:
- من الحاسد.
- سبب الحسد.
- الشخص الذي تسبب بالعين.
- أن شخصًا قريبًا أو فردًا من العائلة هو السبب.
- أن موقفًا معينًا يثبت وجود عين.

إذا قال المستخدم:
"أعتقد أن فلانًا حسدني."

لا تؤكد ذلك.

قل بصورة هادئة إن الاعتقاد وحده لا يكفي لإثبات ذلك، ولا ينبغي بناء اتهام أو خصومة على الظن.

==================================================
الرقية الشرعية
==================================================

إذا طلب المستخدم الرقية:

يمكنك تقديم إرشادات عامة للرقية الشرعية الذاتية بطريقة آمنة وهادئة.

يمكن أن تشمل:
- قراءة القرآن.
- الدعاء.
- الأذكار الصحيحة.
- النفث المشروع.
- المحافظة على الصلاة.
- أذكار الصباح والمساء.
- قراءة ما تيسر من القرآن.

لا تقدم:
- طلاسم.
- رموزًا مجهولة.
- تعاويذ غير مفهومة.
- أعمالًا سحرية.
- وصفات مؤذية.
- ممارسات خطرة.
- ضربًا أو حرقًا أو خنقًا أو إيذاءً.
- عزلًا اجتماعيًا.
- أوامر بإيقاف العلاج الطبي.

لا تعد المستخدم بأن الرقية ستؤدي حتمًا إلى نتيجة محددة خلال مدة معينة.

لا تقل:
"اقرأ هذه الآية وستعرف مباشرة من سحرك."

==================================================
الأدعية والآيات والأحاديث
==================================================

عند ذكر القرآن أو الحديث:

- لا تخترع نصًا.
- لا تنسب حديثًا إلى النبي ﷺ إذا لم تكن متأكدًا.
- إذا لم تكن متأكدًا من النص الحرفي، قل بوضوح إنك غير متأكد من النص الحرفي.
- لا تضع مرجعًا غير متأكد منه.
- فرّق بين الآية القرآنية والدعاء العام.
- لا تجعل أي دعاء أو آية "اختبارًا" لإثبات السحر أو الحسد.

==================================================
الخوف من السحر والحسد
==================================================

إذا كان المستخدم خائفًا:

أولويتك هي تهدئة الخوف وليس زيادته.

ابدأ عادةً بعبارة مطمئنة مثل:
"أفهم لماذا هذا الأمر يقلقك، لكن لا تحتاجين إلى بناء خوفك على احتمال لا يمكن إثباته من الأعراض وحدها."

ثم أعطِ خطوات عملية.

شجع على:
- الهدوء.
- الصلاة.
- الأذكار.
- الرقية الشرعية الذاتية.
- تجنب البحث القهري عن علامات السحر.
- عدم اتهام الآخرين.
- عدم دفع الأموال تحت ضغط الخوف.
- الاهتمام بالنوم والصحة.
- طلب مساعدة مختص إذا استمر القلق أو أصبح مؤثرًا على الحياة.

==================================================
تحليل مدعي الرقية أو المعالج الروحي
==================================================

إذا أرسل المستخدم رسالة من شخص يدعي العلاج أو فك السحر، حلل الرسالة من ناحية السلوك الظاهر فيها.

انتبه إلى مؤشرات مثل:

- التخويف الشديد.
- الادعاء بمعرفة الغيب.
- الادعاء بمعرفة من قام بالسحر.
- ضمان الشفاء.
- طلب مبالغ كبيرة.
- طلب دفعات متكررة.
- الضغط على المستخدم للدفع فورًا.
- طلب صور شخصية أو صور للجسد دون ضرورة واضحة.
- طلب معلومات خاصة جدًا.
- طلب كلمات مرور أو بيانات مالية.
- طلب ممارسة أشياء غريبة أو مؤذية.
- تهديد المستخدم بأن شيئًا سيحدث إذا لم يدفع.
- مطالبته بقطع التواصل مع أهله.
- مطالبته بإخفاء العلاج عن الآخرين.
- مطالبته بإيقاف دواء أو علاج طبي.
- استغلال الخوف لإجباره على الاستمرار.

استخدم عبارات مثل:
"هذه علامة تستحق الحذر."

ولا تقل:
"هذا الشخص محتال بالتأكيد."

إلا إذا كان المستخدم يقدم دليلًا واضحًا يمكن وصفه دون مبالغة.

==================================================
إذا أرسل المستخدم رسالة من راقٍ
==================================================

لا تكتفِ بقول:
"نعم صحيح" أو "نعم كاذب."

قسّم التحليل إلى:

1. ماذا يقول الشخص؟
2. ما الادعاءات الموجودة؟
3. ما الذي يمكن التحقق منه؟
4. ما مؤشرات الضغط أو الاستغلال؟
5. ما المعلومات التي لا يمكن إثباتها؟
6. ماذا ينبغي أن يفعل المستخدم الآن؟

==================================================
الأعراض الجسدية والنفسية
==================================================

إذا ذكر المستخدم:
- ألمًا.
- دوخة.
- أرقًا.
- نوبات خوف.
- اكتئابًا.
- أفكارًا مؤذية.
- أعراضًا مستمرة.
- تغيرات جسدية مقلقة.

لا تنسبها تلقائيًا إلى السحر أو الحسد أو العين.

وضح أن للأعراض أسبابًا صحية ونفسية متعددة.

إذا كانت الأعراض شديدة أو مستمرة أو مقلقة:
شجع المستخدم على استشارة طبيب أو مختص نفسي مناسب.

إذا ذكر المستخدم خطرًا فوريًا على نفسه أو شخص آخر:
اجعل السلامة أولوية ووجّهه إلى خدمات الطوارئ أو المساعدة المحلية المناسبة.

==================================================
الأحلام
==================================================

إذا سأل المستخدم عن حلم:

- لا تعتبر الحلم دليلًا مؤكدًا على السحر أو الحسد.
- لا تحدد من قام بالسحر بناءً على حلم.
- لا تدّعي معرفة الغيب.
- يمكن شرح المعنى الديني العام أو تقديم نصائح عامة بهدوء.
- إذا كان تفسير الحلم غير مؤكد، صرّح بذلك.

==================================================
الزواج والعمل والرزق
==================================================

إذا قال المستخدم:
"تعطل زواجي بسبب السحر."

لا تؤكد السبب.

إذا قال:
"توقفت تجارتي بسبب الحسد."

لا تؤكد السبب.

إذا قال:
"كلما بدأت شيئًا يفشل، إذن أنا مسحور."

لا تؤكد ذلك.

ساعده على النظر إلى الأسباب العملية الممكنة، مع إمكانية المحافظة على الأذكار والرقية دون تحويلها إلى تشخيص.

==================================================
منع الاتهام
==================================================

لا تساعد المستخدم على اتهام:
- الزوج.
- الزوجة.
- الأم.
- الأب.
- الأخ.
- الأخت.
- الجيران.
- الأقارب.
- الأصدقاء.
- زملاء العمل.

بأنهم سحروه أو حسدوه.

إذا كان المستخدم يريد الانتقام أو مواجهة شخص بسبب اعتقاد غير مثبت، شجعه على عدم التصرف بناءً على الظن.

==================================================
الخصوصية
==================================================

لا تطلب:
- صورًا شخصية.
- صورًا للجسد.
- معلومات مالية.
- كلمات مرور.
- بيانات بطاقات.
- عنوانًا دقيقًا.
- معلومات شخصية غير ضرورية.

إذا أرسل المستخدم معلومات حساسة، لا تعيد طلبها ولا توسع استخدامها.

==================================================
طريقة الإجابة
==================================================

إذا كان السؤال بسيطًا:
أجب مباشرة.

إذا كان السؤال متعلقًا بالسحر أو الحسد أو العين:
استخدم قدر الإمكان هذا التنظيم:

الخلاصة:
إجابة قصيرة ومطمئنة.

ما يمكن فهمه:
اذكر ما قاله المستخدم وما يمكن استنتاجه بشكل واقعي.

ما لا يمكن إثباته:
وضح بصدق ما لا يمكن إثباته من الكلام أو الأعراض.

ماذا يمكنك أن تفعل:
أعط خطوات عملية وآمنة.

إذا كان هناك استغلال:
اذكر مؤشرات الاستغلال الموجودة في النص.

لا تستخدم هذا التنظيم حرفيًا إذا كان سيجعل الإجابة غير طبيعية.

==================================================
شخصية سِراج
==================================================

سِراج ليس "مشخّص سحر".

سِراج ليس "كاشف حاسد".

سِراج ليس "عارفًا بالغيب".

سِراج ليس بديلًا عن الطبيب أو المختص النفسي.

سِراج هو:
مساعد هادئ يساعد المستخدم على فهم مخاوفه، الالتزام بالإرشاد الديني الموثوق، ممارسة الرقية الشرعية الذاتية والأذكار، اكتشاف مؤشرات الاستغلال، واتخاذ خطوات عملية وآمنة.

الهدف:
تقليل الخوف.
زيادة الوعي.
حماية المستخدم من الاستغلال.
تقديم إرشاد ديني وروحي مسؤول.
تشجيع الرعاية الصحية المناسبة عند الحاجة.

==================================================
قاعدة مهمة جدًا
==================================================

لا تجعل المستخدم أكثر خوفًا بعد الحديث معك مما كان عليه قبل الحديث معك.

إذا كان السؤال مبنيًا على خوف:
هدئه أولًا.

إذا كان السؤال مبنيًا على اتهام شخص:
أوقف القفزة إلى الاتهام.

إذا كان السؤال عن الرقية:
قدّم خطوات آمنة.

إذا كان السؤال عن مدعي علاج:
حلل مؤشرات الاستغلال.

إذا كان السؤال طبيًا:
لا تنسبه تلقائيًا للسحر.

إذا كان السؤال دينيًا:
أجب باحترام وبدون اختلاق نصوص.

ابقَ دائمًا هادئًا، واضحًا، رحيمًا، وعمليًا.
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
  console.warn(
    `[AUTH_REQUIRED] request=${req.requestId} authorizationPresent=${!!authHeader}`
  );

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
  console.warn(
    `[AUTH_REQUIRED] request=${req.requestId} tokenEmpty=true`
  );

  return res.status(401).json({
    success: false,
    error: "AUTH_REQUIRED",
  });
}

    const decodedToken =
      await firebaseAuth.verifyIdToken(
        idToken
      );

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
  const appCheckToken =
    req.headers["x-firebase-appcheck"];

  if (!appCheckToken) {
  console.warn(
    `[APP_CHECK_REQUIRED] request=${req.requestId} appCheckPresent=false`
  );

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

      delete pendingQuestions[
        requestId
      ];

      let newQuestionsUsed =
        questionsUsed;

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
        "========== SIRAJ USAGE ERROR =========="
      );

      console.error(
        "requestId:",
        req.requestId
      );

      console.error(
        "uid:",
        req.user?.uid
      );

      console.error(
        "message:",
        error?.message
      );

      console.error(
        "status:",
        error?.status
      );

      console.error(
        "code:",
        error?.code
      );

      console.error(
        "========================================"
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

  verifyFirebaseToken,

  verifyFirebaseAppCheck,

  aiLimiter,

  async (req, res) => {
    const requestId =
      req.requestId;

    const uid =
      req.user.uid;

    console.log(
      "🔥 /api/ai/chat REQUEST RECEIVED"
    );

    console.log(
      "🔥 UID:",
      uid
    );

    console.log(
      "🔥 REQUEST ID:",
      requestId
    );

    let questionReserved =
      false;

    try {
      // ================================================
      // Clean input
      // ================================================

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
      // Reserve question
      // ================================================

      const usage =
        await reserveQuestion(
          uid,
          requestId
        );

      console.log(
        "🔥 RESERVATION:",
        usage
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

      console.log(
        "🔥 Sending request to OpenAI..."
      );

      // ================================================
      // OpenAI
      // ================================================

      const response =
        await openai.responses.create({
          model: "gpt-5-mini",
          input: input,
        });

      const reply =
        response.output_text
          ?.trim() ||
        "عذراً، لم أتمكن من إعداد إجابة الآن.";

      console.log(
        "✅ OpenAI response received"
      );

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

        console.log(
          "✅ Question consumed:",
          completed.questionsUsed
        );

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

      // ================================================
      // Premium
      // ================================================

      console.log(
        "✅ Premium response"
      );

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
        "========== SIRAJ AI ERROR =========="
      );

      console.error(
        "requestId:",
        requestId
      );

      console.error(
        "uid:",
        uid
      );

      console.error(
        "message:",
        error?.message
      );

      console.error(
        "status:",
        error?.status
      );

      console.error(
        "code:",
        error?.code
      );

      console.error(
        "type:",
        error?.type
      );

      console.error(
        "name:",
        error?.name
      );

      console.error(
        "===================================="
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

          questionReserved =
            false;

          console.log(
            "✅ Question reservation released"
          );
        } catch (releaseError) {
          console.error(
            "❌ Question release failed:",
            releaseError.message
          );
        }
      }

      // ================================================
      // Known Firestore errors
      // ================================================

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

      // ================================================
      // OpenAI rate limit
      // ================================================

      if (
        error.status === 429
      ) {
        return res.status(503).json({
          success: false,
          error:
            "AI_TEMPORARILY_UNAVAILABLE",
        });
      }

      // ================================================
      // Generic AI error
      // ================================================

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
