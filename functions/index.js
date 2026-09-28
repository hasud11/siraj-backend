/**
 * Firebase Cloud Functions for سِراج
 */

const {setGlobalOptions} = require("firebase-functions");

// تحديد الحد الأقصى للحاويات لتقليل التكلفة
setGlobalOptions({maxInstances: 10});
