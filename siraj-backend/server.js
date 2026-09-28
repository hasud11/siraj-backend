const express = require('express');
const cors = require('cors');
require('dotenv').config();

const OpenAI = require('openai');

const {
  initializeApp,
  applicationDefault,
} = require('firebase-admin/app');

const {
  getAuth,
} = require('firebase-admin/auth');

const {
  getFirestore,
  FieldValue,
} = require('firebase-admin/firestore');

// ============================================================
// Firebase Admin
// ============================================================

let firebaseReady = false;
let firebaseInitError = null;

try {
  initializeApp({
    credential: applicationDefault(),
  });

  firebaseReady = true;

  console.log(
    'Firebase Admin: READY',
  );
} catch (error) {
  firebaseInitError = error;

  console.error(
    'Firebase Admin initialization failed:',
    error.message,
  );
}

// ============================================================
// Express
// ============================================================

const app = express();

// ============================================================
// إعدادات الخادم
// ============================================================

const PORT =
  Number(process.env.PORT) || 3000;

const HOST =
  process.env.HOST || '0.0.0.0';

const OPENAI_MODEL =
  process.env.OPENAI_MODEL ||
  'gpt-5.6-luna';

const REQUEST_TIMEOUT =
  Number(
    process.env.OPENAI_TIMEOUT_MS,
  ) || 60000;

const MAX_RETRIES =
  Number(
    process.env.OPENAI_MAX_RETRIES,
  ) || 2;

// ============================================================
// نظام الحساب المجاني
// ============================================================

const FREE_QUESTION_LIMIT =
  Number(
    process.env.FREE_QUESTION_LIMIT,
  ) || 3;

// ============================================================
// سياق المحادثة
// ============================================================

const MAX_CONTEXT_MESSAGES = 20;

const MAX_CONTEXT_MESSAGE_LENGTH = 2500;

// ============================================================
// Middleware
// ============================================================

app.disable('x-powered-by');

app.use(
  cors({
    origin: true,

    methods: [
      'GET',
      'POST',
      'OPTIONS',
    ],

    allowedHeaders: [
      'Content-Type',
      'Authorization',
    ],
  }),
);

app.use(
  express.json({
    limit: '1mb',
  }),
);

// ============================================================
// OpenAI
// ============================================================

const apiKey =
  process.env.OPENAI_API_KEY?.trim();

const openai = apiKey
  ? new OpenAI({
      apiKey: apiKey,
      timeout: REQUEST_TIMEOUT,
      maxRetries: 0,
    })
  : null;

// ============================================================
// Firebase Services
// ============================================================

const firebaseAuth =
  firebaseReady
    ? getAuth()
    : null;

const db =
  firebaseReady
    ? getFirestore()
    : null;

// ============================================================
// شخصية سِراج
// ============================================================

const SIRAJ_INSTRUCTIONS = `
أنتِ "سِراج"، المساعدة الروحية الذكية داخل تطبيق "سِراج الروحي".

أنتِ لستِ محرك بحث، ولستِ أداة لجلب صفحات الإنترنت.
أجيبي المستخدم مباشرة اعتمادًا على معرفتك وتعليماتك وسياق
المحادثة.

لا تقولي للمستخدم إنك تبحثين في الإنترنت أو تجلبين معلومات
من مواقع خارجية.

============================================================
شخصية سِراج
============================================================

كوني:

- هادئة
- راقية
- مطمئنة
- ذكية
- متفهمة
- واضحة
- طبيعية
- دافئة في الحوار

خاطبي المستخدم باللغة العربية الطبيعية.

إذا كانت المستخدمة امرأة، استخدمي صيغة المؤنث عندما يكون ذلك
واضحًا من السياق.

يمكنك فهم اللهجات العربية، ومنها الخليجية والسعودية والسورية.

لا تتحدثي بطريقة آلية أو تقنية.

لا تقولي:
"كنموذج ذكاء اصطناعي..."

إلا إذا كان السؤال يتطلب توضيح طبيعتك.

قدمي نفسك دائمًا باسم "سِراج" عند الحاجة.

============================================================
مجالات سِراج
============================================================

يمكنك الإجابة عن:

1. القرآن الكريم
2. الأذكار
3. الأدعية
4. الرقية الشرعية
5. التحصين
6. السحر
7. العين
8. الحسد
9. الوساوس والمخاوف الروحية
10. الطمأنينة والسكينة
11. الأسئلة الدينية والروحية العامة
12. الشعوذة والدجل من الجانب التوعوي
13. كيفية بناء روتين روحي يومي
14. الأدعية المناسبة للمواقف المختلفة
15. شرح المفاهيم الروحية بصورة مبسطة

============================================================
السحر
============================================================

عند سؤال المستخدم عن السحر:

اشرحي الموضوع بهدوء وبدون تخويف.

لا تجزمي أن شخصًا مسحور اعتمادًا على أعراض عامة.

لا تقولي:

"أنتِ مسحورة."

"فلان سحركِ."

"هذه الأعراض تثبت وجود السحر."

استخدمي:

"لا يمكن الجزم بوجود السحر من هذه الأعراض وحدها."

"هناك أسباب متعددة قد تفسر ما تشعرين به."

"يمكنكِ الالتزام بالأذكار والرقية الشرعية دون الدخول في دائرة
الخوف والشك."

لا تحددي ساحرًا أو شخصًا مشتبهًا به.

لا تساعدي على الانتقام.

لا تقدمي طرقًا لصنع السحر.

لا تقدمي طلاسم.

لا تقدمي تعاويذ مجهولة.

لا تقدمي وصفات سحرية.

لا تشجعي على الذهاب إلى المشعوذين أو الدجالين.

============================================================
العين والحسد
============================================================

اشرحي المفهوم بصورة هادئة.

لا تجزمي أن أعراضًا جسدية أو نفسية تعني وجود عين أو حسد.

لا تتهمي شخصًا معينًا بالحسد.

إذا كان المستخدم خائفًا من شخص معين، ساعديه على تهدئة الخوف
وعدم بناء اتهامات على الظنون.

يمكنك توجيهه إلى الأذكار والرقية الشرعية والدعاء.

============================================================
الرقية الشرعية
============================================================

يمكنك شرح:

- معنى الرقية الشرعية
- كيفية التعامل معها بصورة مشروعة
- الآيات والأدعية المعروفة عندما تكونين متأكدة من النص
- آداب الرقية
- الفرق بين الرقية الشرعية والشعوذة

لا تقدمي:

- طلاسم
- رموزًا مجهولة
- تعاويذ
- أعمالًا سحرية
- طقوسًا مؤذية
- وصفات خطيرة

لا تقولي إن الرقية تضمن شفاء مرض معين.

الرقية لا تستبدل العلاج الطبي.

============================================================
الأذكار والتحصين
============================================================

ساعدي المستخدم في إنشاء روتين بسيط مثل:

- أذكار الصباح
- أذكار المساء
- أذكار النوم
- أذكار الاستيقاظ
- الدعاء
- الاستغفار
- الصلاة
- قراءة القرآن
- التحصين المشروع

عند نقل نص ديني حرفيًا، لا تختلقي النص.

إذا لم تكوني متأكدة من نص حديث أو دعاء، قولي بوضوح إنك
غير متأكدة بدل اختلاق نص.

لا تنسبي حديثًا إلى النبي ﷺ دون معرفة كافية.

============================================================
القرآن
============================================================

لا تختلقي آيات.

لا تغيري ألفاظ القرآن عند الادعاء بأنك تنقلين الآية حرفيًا.

إذا لم تكوني متأكدة من النص الحرفي، لا تدعي أنك تنقلينه
حرفيًا.

يمكنك شرح المعنى العام عندما تكونين متأكدة منه.

============================================================
الصحة النفسية والجسدية
============================================================

إذا ذكر المستخدم:

- أرقًا
- خوفًا
- قلقًا
- اكتئابًا
- ألمًا
- دوخة
- صداعًا
- أعراضًا جسدية
- أعراضًا نفسية

لا تفسريها تلقائيًا بالسحر أو العين أو الحسد.

وضحي أن للأعراض أسبابًا متعددة.

يمكن تقديم التوجيه الروحي كدعم، لكن لا تستبدلي الطبيب أو
المختص.

إذا كانت الأعراض شديدة أو مستمرة، شجعي المستخدم على طلب
المساعدة الطبية المناسبة.

============================================================
الشعوذة والدجل
============================================================

إذا سأل المستخدم عن:

- المشعوذين
- العرافين
- قراءة الكف
- الأبراج لمعرفة الغيب
- الطلاسم
- التعاويذ المجهولة
- الأحجبة
- وصفات فك السحر
- استحضار الأرواح
- أعمال لإيذاء شخص

قدمي إجابة توعوية.

لا تعطي تعليمات عملية لممارسة الشعوذة أو السحر.

لا تشجعي المستخدم على دفع المال لمن يدعي قدرته على معرفة
الغيب أو فك السحر بطرق مجهولة.

============================================================
المواقف العاطفية والخوف
============================================================

إذا كان المستخدم خائفًا:

ابدئي بتهدئته.

لا تزيدي الخوف.

لا تقولي:

"هناك شيء يراقبك."

"هناك شخص يريد إيذاءك."

"أنتِ في خطر بسبب السحر."

إلا إذا كنت تنقلين كلام المستخدم، وفي هذه الحالة وضحي أنه
مجرد اعتقاد أو خوف وليس حقيقة مثبتة.

استخدمي أسلوبًا مثل:

"أفهم لماذا قد يسبب لكِ هذا الأمر القلق."

"لنحاول النظر إليه بهدوء."

"لا نريد أن نبني نتيجة مؤكدة على مجرد أعراض أو شكوك."

============================================================
المحادثة
============================================================

استخدمي سياق المحادثة السابق.

إذا قالت المستخدمة:

"نعم"

"الأول"

"هذا"

"مثل ذلك"

فارجعي إلى السياق السابق عندما يكون المعنى واضحًا.

لا تطلبي منها إعادة المعلومات الموجودة بالفعل في المحادثة.

إذا كان السؤال غامضًا فعلًا، اسألي سؤالًا توضيحيًا بسيطًا.

============================================================
طريقة الإجابة
============================================================

لا تجعلي كل إجابة طويلة.

إذا كان السؤال بسيطًا، أجيبي باختصار.

إذا كان الموضوع يحتاج شرحًا، رتبيه بعناوين ونقاط.

استخدمي الرموز التعبيرية باعتدال.

لا تخوفي المستخدم.

لا تدعي امتلاك قدرات خارقة.

لا تدعي معرفة الغيب.

لا تدعي أنك تستطيعين اكتشاف السحر أو العين من الأعراض.

============================================================
هدف سِراج
============================================================

هدفك أن تكوني رفيقة روحية ذكية وهادئة.

ساعدي المستخدم على:

- فهم الموضوع
- تقليل الخوف
- معرفة ما هو مشروع وما هو خرافة
- بناء روتين روحي
- معرفة الأذكار والأدعية
- فهم الرقية الشرعية
- التعامل مع موضوع السحر والعين والحسد دون تهويل
- طلب المساعدة الطبية عند الحاجة

لا تجعلي الخوف من السحر أو العين محور حياة المستخدم.

============================================================
قاعدة مهمة جدًا
============================================================

عندما لا تعرفين معلومة:

لا تخترعيها.

قولي إنك غير متأكدة.

وعندما تكون المعلومة دينية دقيقة جدًا، ميزي بين المعرفة
العامة وبين النقل الحرفي للنصوص.

أنتِ سِراج.
دورك المساعدة والتوعية والطمأنينة، وليس التخويف أو التشخيص
أو ممارسة الشعوذة.
`;

// ============================================================
// أدوات مساعدة
// ============================================================

function getErrorDetails(error) {
  return {
    name:
      error?.name ||
      'UnknownError',

    message:
      error?.message ||
      'Unknown error',

    status:
      error?.status ??
      error?.statusCode ??
      null,

    code:
      error?.code ??
      error?.error?.code ??
      null,

    requestId:
      error?.request_id ??
      error?.requestID ??
      error?._request_id ??
      null,
  };
}

function logOpenAIError(
  prefix,
  error,
) {
  const details =
    getErrorDetails(error);

  console.error(
    '================================',
  );

  console.error(prefix);

  console.error(
    'Name:',
    details.name,
  );

  console.error(
    'Message:',
    details.message,
  );

  console.error(
    'Status:',
    details.status,
  );

  console.error(
    'Code:',
    details.code,
  );

  console.error(
    'Request ID:',
    details.requestId,
  );

  console.error(
    '================================',
  );
}

function isTemporaryError(
  error,
) {
  const status =
    error?.status ??
    error?.statusCode ??
    0;

  if (
    status === 408 ||
    status === 409 ||
    status === 429 ||
    status >= 500
  ) {
    return true;
  }

  const name =
    error?.name || '';

  return (
    name.includes('Timeout') ||
    name.includes('Connection') ||
    name.includes('APIConnection')
  );
}

function wait(ms) {
  return new Promise(
    (resolve) => {
      setTimeout(
        resolve,
        ms,
      );
    },
  );
}

// ============================================================
// تنظيف تاريخ المحادثة
// ============================================================

function normalizeConversationHistory(
  history,
) {
  if (!Array.isArray(history)) {
    return [];
  }

  const normalized = [];

  for (
    const item of history.slice(
      -MAX_CONTEXT_MESSAGES,
    )
  ) {
    if (
      !item ||
      typeof item !== 'object'
    ) {
      continue;
    }

    const role =
      item.role;

    const content =
      item.content;

    if (
      role !== 'user' &&
      role !== 'assistant'
    ) {
      continue;
    }

    if (
      typeof content !== 'string'
    ) {
      continue;
    }

    const cleanContent =
      content.trim();

    if (!cleanContent) {
      continue;
    }

    normalized.push({
      role: role,

      content:
        cleanContent.slice(
          0,
          MAX_CONTEXT_MESSAGE_LENGTH,
        ),
    });
  }

  return normalized;
}

// ============================================================
// استخراج Firebase Token
// ============================================================

function getBearerToken(req) {
  const header =
    req.headers.authorization;

  if (
    !header ||
    typeof header !== 'string'
  ) {
    return null;
  }

  if (
    !header.startsWith(
      'Bearer ',
    )
  ) {
    return null;
  }

  return header
    .substring(7)
    .trim();
}

// ============================================================
// التحقق من المستخدم
// ============================================================

async function authenticateUser(
  req,
  res,
) {
  if (!firebaseReady || !firebaseAuth) {
    res
      .status(503)
      .json({
        success: false,
        code:
          'FIREBASE_NOT_CONFIGURED',
        message:
          'Firebase Admin غير مهيأ على الخادم.',
      });

    return null;
  }

  const idToken =
    getBearerToken(req);

  if (!idToken) {
    res
      .status(401)
      .json({
        success: false,
        code:
          'AUTH_TOKEN_REQUIRED',
        message:
          'يجب تسجيل الدخول للوصول إلى سِراج.',
      });

    return null;
  }

  try {
    const decodedToken =
      await firebaseAuth.verifyIdToken(
        idToken,
        false,
      );

    return decodedToken;
  } catch (error) {
    console.error(
      'Firebase token verification failed:',
      error.message,
    );

    res
      .status(401)
      .json({
        success: false,
        code:
          'INVALID_AUTH_TOKEN',
        message:
          'جلسة تسجيل الدخول غير صالحة أو منتهية. يرجى تسجيل الدخول مرة أخرى.',
      });

    return null;
  }
}

// ============================================================
// الحصول على بيانات المستخدم
// ============================================================

async function getUserProfile(
  uid,
) {
  const userRef =
    db
      .collection('users')
      .doc(uid);

  const snapshot =
    await userRef.get();

  if (!snapshot.exists) {
    await userRef.set(
      {
        uid: uid,
        accountType: 'free',
        aiQuestionsUsed: 0,
        createdAt:
          FieldValue.serverTimestamp(),
      },
      {
        merge: true,
      },
    );

    return {
      uid: uid,
      accountType: 'free',
      aiQuestionsUsed: 0,
    };
  }

  const data =
    snapshot.data() || {};

  return {
    uid: uid,

    accountType:
      data.accountType ||
      'free',

    aiQuestionsUsed:
      Number(
        data.aiQuestionsUsed || 0,
      ),
  };
}

// ============================================================
// هل الحساب مدفوع؟
// ============================================================

function isPaidAccount(
  profile,
) {
  const type =
    String(
      profile.accountType ||
        'free',
    ).toLowerCase();

  return (
    type === 'premium' ||
    type === 'pro' ||
    type === 'paid' ||
    type === 'subscription' ||
    type === 'subscriber'
  );
}

// ============================================================
// حجز سؤال مجاني
// ============================================================

async function reserveQuestion(
  uid,
) {
  const userRef =
    db
      .collection('users')
      .doc(uid);

  return await db.runTransaction(
    async (transaction) => {
      const snapshot =
        await transaction.get(
          userRef,
        );

      let data = {};

      if (snapshot.exists) {
        data =
          snapshot.data() || {};
      }

      const accountType =
        data.accountType ||
        'free';

      const paid =
        isPaidAccount({
          accountType:
            accountType,
        });

      const used =
        Number(
          data.aiQuestionsUsed ||
            0,
        );

      // --------------------------------------------------------
      // الحساب المدفوع
      // --------------------------------------------------------

      if (paid) {
        if (!snapshot.exists) {
          transaction.set(
            userRef,
            {
              uid: uid,
              accountType:
                accountType,
              aiQuestionsUsed:
                used,
              createdAt:
                FieldValue.serverTimestamp(),
            },
            {
              merge: true,
            },
          );
        }

        return {
          allowed: true,
          paid: true,
          used: used,
          remaining: null,
          accountType:
            accountType,
        };
      }

      // --------------------------------------------------------
      // الحساب المجاني
      // --------------------------------------------------------

      if (
        used >=
        FREE_QUESTION_LIMIT
      ) {
        return {
          allowed: false,
          paid: false,
          used: used,
          remaining: 0,
          accountType:
            'free',
        };
      }

      const newUsed =
        used + 1;

      const remaining =
        Math.max(
          FREE_QUESTION_LIMIT -
            newUsed,
          0,
        );

      transaction.set(
        userRef,
        {
          uid: uid,
          accountType: 'free',
          aiQuestionsUsed:
            newUsed,
        },
        {
          merge: true,
        },
      );

      return {
        allowed: true,
        paid: false,
        used: newUsed,
        remaining: remaining,
        accountType: 'free',
      };
    },
  );
}

// ============================================================
// إرجاع السؤال عند فشل OpenAI
// ============================================================

async function rollbackQuestion(
  uid,
) {
  try {
    const userRef =
      db
        .collection('users')
        .doc(uid);

    await db.runTransaction(
      async (transaction) => {
        const snapshot =
          await transaction.get(
            userRef,
          );

        if (!snapshot.exists) {
          return;
        }

        const data =
          snapshot.data() || {};

        const accountType =
          data.accountType ||
          'free';

        if (
          isPaidAccount({
            accountType:
              accountType,
          })
        ) {
          return;
        }

        const used =
          Number(
            data.aiQuestionsUsed ||
              0,
          );

        if (used <= 0) {
          return;
        }

        transaction.update(
          userRef,
          {
            aiQuestionsUsed:
              used - 1,
          },
        );
      },
    );

    console.log(
      'Free question rolled back for:',
      uid,
    );
  } catch (error) {
    console.error(
      'Failed to rollback free question:',
      error.message,
    );
  }
}

// ============================================================
// الصفحة الرئيسية
// ============================================================

app.get(
  '/',
  (req, res) => {
    return res.json({
      success: true,
      app: 'Siraj Spiritual',
      message:
        'Siraj Backend is running',
      version: '3.0.0',
      mode:
        'AI Spiritual Assistant',
      freeQuestionLimit:
        FREE_QUESTION_LIMIT,
      firebase:
        firebaseReady,
      aiConfigured:
        Boolean(apiKey),
    });
  },
);

// ============================================================
// Health Check
// ============================================================

app.get(
  '/api/health',
  (req, res) => {
    return res.json({
      success: true,

      backend: true,

      aiConfigured:
        Boolean(apiKey),

      firebaseConfigured:
        firebaseReady,

      model:
        OPENAI_MODEL,

      mode: 'AI_ONLY',

      externalContent: false,

      timeoutMs:
        REQUEST_TIMEOUT,

      maxRetries:
        MAX_RETRIES,

      contextMessages:
        MAX_CONTEXT_MESSAGES,

      freeQuestionLimit:
        FREE_QUESTION_LIMIT,

      serverTime:
        new Date().toISOString(),
    });
  },
);

// ============================================================
// معرفة استخدام المستخدم
// ============================================================

app.get(
  '/api/usage',
  async (req, res) => {
    try {
      const user =
        await authenticateUser(
          req,
          res,
        );

      if (!user) {
        return;
      }

      const profile =
        await getUserProfile(
          user.uid,
        );

      const paid =
        isPaidAccount(
          profile,
        );

      if (paid) {
        return res.json({
          success: true,
          uid: user.uid,
          accountType:
            profile.accountType,
          paid: true,
          used:
            profile.aiQuestionsUsed,
          remaining: null,
          limit: null,
          unlimited: true,
        });
      }

      const used =
        profile.aiQuestionsUsed;

      const remaining =
        Math.max(
          FREE_QUESTION_LIMIT -
            used,
          0,
        );

      return res.json({
        success: true,
        uid: user.uid,
        accountType: 'free',
        paid: false,
        used: used,
        remaining: remaining,
        limit:
          FREE_QUESTION_LIMIT,
        unlimited: false,
        subscriptionRequired:
          remaining <= 0,
      });
    } catch (error) {
      console.error(
        'USAGE ERROR:',
        error,
      );

      return res
        .status(500)
        .json({
          success: false,
          code:
            'USAGE_ERROR',
          message:
            'تعذر الحصول على معلومات الاستخدام.',
        });
    }
  },
);

// ============================================================
// اختبار الذكاء الاصطناعي
// ============================================================

app.get(
  '/api/health/ai',
  async (req, res) => {
    if (!openai) {
      return res
        .status(503)
        .json({
          success: false,
          ai: false,
          code:
            'AI_NOT_CONFIGURED',
          message:
            'OPENAI_API_KEY غير موجود.',
        });
    }

    try {
      const response =
        await openai.responses.create({
          model:
            OPENAI_MODEL,

          instructions:
            SIRAJ_INSTRUCTIONS,

          input:
            'قولي فقط: سِراج يعمل بشكل صحيح.',
        });

      const reply =
        response.output_text?.trim();

      return res.json({
        success: true,
        ai: true,
        model:
          OPENAI_MODEL,
        reply:
          reply || '',
        requestId:
          response._request_id ||
          null,
      });
    } catch (error) {
      logOpenAIError(
        'SIRAJ AI HEALTH CHECK ERROR',
        error,
      );

      const details =
        getErrorDetails(
          error,
        );

      return res
        .status(
          details.status ||
            500,
        )
        .json({
          success: false,
          ai: false,
          code:
            details.code ||
            'AI_CONNECTION_ERROR',
          message:
            'تعذر الاتصال بخدمة الذكاء الاصطناعي.',
          status:
            details.status,
          requestId:
            details.requestId,
        });
    }
  },
);

// ============================================================
// محادثة سِراج
// ============================================================

app.post(
  '/api/chat',
  async (req, res) => {
    const startedAt =
      Date.now();

    let authenticatedUser =
      null;

    let questionReserved =
      false;

    try {
      // --------------------------------------------------------
      // التحقق من المستخدم
      // --------------------------------------------------------

      authenticatedUser =
        await authenticateUser(
          req,
          res,
        );

      if (!authenticatedUser) {
        return;
      }

      // --------------------------------------------------------
      // البيانات
      // --------------------------------------------------------

      const {
        message,
        history,
      } = req.body || {};

      // --------------------------------------------------------
      // التحقق من الرسالة
      // --------------------------------------------------------

      if (
        !message ||
        typeof message !== 'string'
      ) {
        return res
          .status(400)
          .json({
            success: false,
            code:
              'INVALID_MESSAGE',
            message:
              'الرسالة مطلوبة.',
          });
      }

      const cleanMessage =
        message.trim();

      if (!cleanMessage) {
        return res
          .status(400)
          .json({
            success: false,
            code:
              'EMPTY_MESSAGE',
            message:
              'الرسالة لا يمكن أن تكون فارغة.',
          });
      }

      if (
        cleanMessage.length >
        MAX_CONTEXT_MESSAGE_LENGTH
      ) {
        return res
          .status(400)
          .json({
            success: false,
            code:
              'MESSAGE_TOO_LONG',
            message:
              'الرسالة طويلة جدًا.',
          });
      }

      if (!openai) {
        return res
          .status(503)
          .json({
            success: false,
            code:
              'AI_NOT_CONFIGURED',
            message:
              'خدمة الذكاء الاصطناعي غير مفعلة حاليًا.',
          });
      }

      if (!db) {
        return res
          .status(503)
          .json({
            success: false,
            code:
              'FIRESTORE_NOT_CONFIGURED',
            message:
              'قاعدة البيانات غير مهيأة على الخادم.',
          });
      }

      // --------------------------------------------------------
      // حجز السؤال
      // --------------------------------------------------------

      const usage =
        await reserveQuestion(
          authenticatedUser.uid,
        );

      // --------------------------------------------------------
      // انتهت المجانية
      // --------------------------------------------------------

      if (!usage.allowed) {
        console.log(
          'FREE LIMIT REACHED:',
          authenticatedUser.uid,
        );

        return res
          .status(402)
          .json({
            success: false,

            code:
              'FREE_LIMIT_REACHED',

            message:
              'لقد انتهت الأسئلة المجانية الثلاثة. اشتركي الآن لمواصلة استخدام سِراج.',

            accountType:
              'free',

            used:
              usage.used,

            remaining:
              0,

            limit:
              FREE_QUESTION_LIMIT,

            requiresSubscription:
              true,
          });
      }

      questionReserved = !usage.paid;

      // --------------------------------------------------------
      // تنظيف السياق
      // --------------------------------------------------------

      const conversationHistory =
        normalizeConversationHistory(
          history,
        );

      // --------------------------------------------------------
      // بناء المحادثة
      // --------------------------------------------------------

      const conversationInput = [
        ...conversationHistory,

        {
          role: 'user',
          content:
            cleanMessage,
        },
      ];

      console.log(
        '================================',
      );

      console.log(
        'SIRAJ CHAT REQUEST',
      );

      console.log(
        'UID:',
        authenticatedUser.uid,
      );

      console.log(
        'Account:',
        usage.accountType,
      );

      console.log(
        'Paid:',
        usage.paid,
      );

      console.log(
        'Used:',
        usage.used,
      );

      console.log(
        'Remaining:',
        usage.remaining,
      );

      console.log(
        'Context:',
        conversationHistory.length,
      );

      // --------------------------------------------------------
      // OpenAI
      // --------------------------------------------------------

      let response =
        null;

      let lastError =
        null;

      for (
        let attempt = 1;
        attempt <=
          MAX_RETRIES + 1;
        attempt++
      ) {
        try {
          console.log(
            `OpenAI request ${attempt}/${MAX_RETRIES + 1}`,
          );

          response =
            await openai.responses.create({
              model:
                OPENAI_MODEL,

              instructions:
                SIRAJ_INSTRUCTIONS,

              input:
                conversationInput,
            });

          break;
        } catch (error) {
          lastError =
            error;

          logOpenAIError(
            `SIRAJ REQUEST ERROR - ATTEMPT ${attempt}`,
            error,
          );

          if (
            !isTemporaryError(
              error,
            ) ||
            attempt >=
              MAX_RETRIES + 1
          ) {
            throw error;
          }

          const delay =
            Math.min(
              1000 *
                Math.pow(
                  2,
                  attempt - 1,
                ),
              8000,
            );

          await wait(
            delay,
          );
        }
      }

      if (!response) {
        throw (
          lastError ||
          new Error(
            'لم يصل رد من OpenAI.',
          )
        );
      }

      // --------------------------------------------------------
      // استخراج الرد
      // --------------------------------------------------------

      const reply =
        response.output_text?.trim();

      if (!reply) {
        throw new Error(
          'EMPTY_AI_RESPONSE',
        );
      }

      const duration =
        Date.now() -
        startedAt;

      console.log(
        'SIRAJ RESPONSE RECEIVED',
      );

      console.log(
        'Duration:',
        `${duration}ms`,
      );

      console.log(
        'Request ID:',
        response._request_id ||
          'N/A',
      );

      console.log(
        '================================',
      );

      // --------------------------------------------------------
      // الرد النهائي
      // --------------------------------------------------------

      return res.json({
        success: true,

        reply: reply,

        requestId:
          response._request_id ||
          null,

        contextUsed:
          conversationHistory.length,

        durationMs:
          duration,

        accountType:
          usage.accountType,

        paid:
          usage.paid,

        freeLimit:
          usage.paid
            ? null
            : FREE_QUESTION_LIMIT,

        questionsUsed:
          usage.paid
            ? null
            : usage.used,

        questionsRemaining:
          usage.paid
            ? null
            : usage.remaining,

        subscriptionRequired:
          usage.paid
            ? false
            : usage.remaining <= 0,
      });
    } catch (error) {
      // --------------------------------------------------------
      // إعادة السؤال في حال فشل OpenAI
      // --------------------------------------------------------

      if (
        questionReserved &&
        authenticatedUser
      ) {
        await rollbackQuestion(
          authenticatedUser.uid,
        );
      }

      // --------------------------------------------------------
      // تسجيل الخطأ
      // --------------------------------------------------------

      logOpenAIError(
        'SIRAJ CHAT FINAL ERROR',
        error,
      );

      const details =
        getErrorDetails(
          error,
        );

      let message =
        'حدث خطأ أثناء معالجة طلب سِراج.';

      if (
        details.status === 401
      ) {
        message =
          'مفتاح OpenAI غير صالح أو غير مصرح به.';
      } else if (
        details.status === 403
      ) {
        message =
          'ليس لديك صلاحية لاستخدام خدمة الذكاء الاصطناعي.';
      } else if (
        details.status === 404
      ) {
        message =
          'النموذج المطلوب غير متاح لهذا المفتاح.';
      } else if (
        details.status === 429
      ) {
        message =
          'تم الوصول إلى حد الاستخدام مؤقتًا. حاولي مرة أخرى.';
      } else if (
        details.status >= 500
      ) {
        message =
          'خدمة الذكاء الاصطناعي مشغولة مؤقتًا. حاولي مرة أخرى.';
      } else if (
        details.name?.includes(
          'Timeout',
        ) ||
        details.name?.includes(
          'Connection',
        )
      ) {
        message =
          'تعذر الاتصال بخدمة الذكاء الاصطناعي. حاولي مرة أخرى.';
      }

      return res
        .status(
          details.status &&
            details.status >= 400 &&
            details.status < 600
            ? details.status
            : 500,
        )
        .json({
          success: false,

          code:
            details.code ||
            'AI_ERROR',

          message:
            message,

          requestId:
            details.requestId ||
            null,
        });
    }
  },
);

// ============================================================
// 404
// ============================================================

app.use(
  (req, res) => {
    return res
      .status(404)
      .json({
        success: false,
        code:
          'NOT_FOUND',
        message:
          'المسار المطلوب غير موجود.',
      });
  },
);

// ============================================================
// خطأ عام
// ============================================================

app.use(
  (
    error,
    req,
    res,
    next,
  ) => {
    console.error(
      'EXPRESS ERROR:',
      error,
    );

    if (res.headersSent) {
      return next(
        error,
      );
    }

    return res
      .status(500)
      .json({
        success: false,
        code:
          'SERVER_ERROR',
        message:
          'حدث خطأ داخلي في خادم سِراج.',
      });
  },
);

// ============================================================
// تشغيل الخادم
// ============================================================

const server =
  app.listen(
    PORT,
    HOST,
    () => {
      console.log(
        '================================',
      );

      console.log(
        'SIRAJ BACKEND STARTED',
      );

      console.log(
        `Host: ${HOST}`,
      );

      console.log(
        `Port: ${PORT}`,
      );

      console.log(
        `Local: http://localhost:${PORT}`,
      );

      console.log(
        `AI configured: ${
          apiKey
            ? 'YES'
            : 'NO'
        }`,
      );

      console.log(
        `Firebase configured: ${
          firebaseReady
            ? 'YES'
            : 'NO'
        }`,
      );

      console.log(
        `AI model: ${OPENAI_MODEL}`,
      );

      console.log(
        'Mode: AI ONLY',
      );

      console.log(
        'External content: DISABLED',
      );

      console.log(
        `OpenAI timeout: ${REQUEST_TIMEOUT}ms`,
      );

      console.log(
        `OpenAI retries: ${MAX_RETRIES}`,
      );

      console.log(
        `Context messages: ${MAX_CONTEXT_MESSAGES}`,
      );

      console.log(
        `Free question limit: ${FREE_QUESTION_LIMIT}`,
      );

      console.log(
        '================================',
      );
    },
  );

// ============================================================
// أخطاء الخادم
// ============================================================

server.on(
  'error',
  (error) => {
    console.error(
      '================================',
    );

    console.error(
      'SERVER ERROR',
    );

    console.error(
      error,
    );

    console.error(
      '================================',
    );
  },
);

process.on(
  'uncaughtException',
  (error) => {
    console.error(
      '================================',
    );

    console.error(
      'UNCAUGHT EXCEPTION',
    );

    console.error(
      error,
    );

    console.error(
      '================================',
    );
  },
);

process.on(
  'unhandledRejection',
  (error) => {
    console.error(
      '================================',
    );

    console.error(
      'UNHANDLED REJECTION',
    );

    console.error(
      error,
    );

    console.error(
      '================================',
    );
  },
);