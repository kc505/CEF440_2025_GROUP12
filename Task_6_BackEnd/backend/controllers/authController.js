const { admin, db: firestoreDb } = require('../config/firebaseAdmin');

exports.signup = async (req, res) => {
  const { email, password, firstName, lastName, role, department } = req.body;

  if (!email || !password || !firstName || !lastName || !role) {
    return res.status(400).json({ message: 'Missing required fields: email, password, firstName, lastName, role.' });
  }

  try {
    // Firebase Authentication
    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName: `${firstName} ${lastName}`,
    });

    const uid = userRecord.uid;

    // Firestore Profile
    await firestoreDb.collection('userProfiles').doc(uid).set({
      uid,
      email,
      firstName,
      lastName,
      role: role.toLowerCase(),
      department: department || null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isActive: true,
    });

    res.status(201).json({
      message: 'User registered successfully. Please login.',
      uid,
      email: userRecord.email,
    });

  } catch (error) {
    console.error('Error during signup:', error);
    if (error.code === 'auth/email-already-exists') {
      return res.status(409).json({ message: 'Email already in use.' });
    }
    if (error.code === 'auth/weak-password') {
      return res.status(400).json({ message: 'Password too weak.' });
    }
    res.status(500).json({ message: 'Failed to register user.', error: error.message });
  }
};


// 2. LOGIN CONTROLLER --- A NOTE ON BEST PRACTICE
// In a typical Firebase flow, a backend `/login` route is NOT needed.
// The standard flow is:
// 1. Client uses Firebase Client SDK to call `signInWithEmailAndPassword()`.
// 2. Firebase sends an ID Token directly to the client.
// 3. Client stores this token and includes it in the `Authorization: Bearer <token>` header for all future requests.
// 4. Client can immediately call a protected route like `/auth/me` to get the user's profile.
//
// Therefore, the `/auth/login` endpoint can often be removed. The code below is kept for reference if you have a specific need for it.

exports.login = async (req, res) => {
    return res.status(200).json({ 
        message: "Login is handled client-side with Firebase SDK. Use the obtained ID token to access protected routes like /auth/me." 
    });
};


// 3. GET USER PROFILE CONTROLLER (Protected Route)
// This is the correct way to get user data after the client has logged in.
exports.getMe = async (req, res) => {
  const uid = req.user.uid; // from auth middleware

  try {
    // Fetch user profile from Firestore
    const userDoc = await firestoreDb.collection('userProfiles').doc(uid).get();

    if (!userDoc.exists) {
      return res.status(404).json({ message: 'User profile not found.' });
    }

    const userProfile = userDoc.data();

    res.status(200).json(userProfile);

  } catch (error) {
    console.error('Error fetching user profile (/auth/me):', error);
    res.status(500).json({ message: 'Failed to fetch user profile.', error: error.message });
  }
};


// 4. LOGOUT CONTROLLER
// Logout is primarily a client-side action (deleting the stored ID token).
// This backend endpoint provides a "hard logout" by revoking all refresh tokens,
// forcing the user to log in again on all devices.
exports.logout = async (req, res) => {
  // authMiddleware should protect this route to get the user's UID
  const uid = req.user.uid;

  try {
    await admin.auth().revokeRefreshTokens(uid);
    res.status(200).json({ message: 'User refresh tokens have been revoked. Client should clear local token and log out.' });
  } catch (error) {
    console.error('Error revoking refresh tokens:', error);
    res.status(500).json({ message: 'Failed to revoke refresh tokens.' });
  }
};