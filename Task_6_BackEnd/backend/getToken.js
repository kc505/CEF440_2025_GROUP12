const { initializeApp } = require('firebase/app');
const { getAuth, signInWithEmailAndPassword } = require('firebase/auth');

// 🔑 Replace these with your Firebase project credentials from Project Settings → General
const firebaseConfig = {
  apiKey: "AIzaSyCj_42gu9A5P3LAAEptsR3lT6hyBDZlukM",
  authDomain: "smartcheck-51999.firebaseapp.com",
  projectId: "smartcheck-51999",
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);

async function loginAndGetToken(email, password) {
  try {
    const userCredential = await signInWithEmailAndPassword(auth, email, password);
    const token = await userCredential.user.getIdToken();
    console.log("✅ ID Token:", token);
  } catch (error) {
    console.error("❌ Error:", error.message);
  }
}

// 👉 Enter your Firebase email + password here (of a real Firebase Auth user!)
loginAndGetToken("student@example1.com", "securePass123");
