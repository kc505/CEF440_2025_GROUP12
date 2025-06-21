const { admin, db: firestoreDb } = require('../config/firebaseAdmin');

exports.signup = async (req, res) => {
  const { email, password, firstName, lastName, role, department } = req.body;

  if (!email || !password || !firstName || !lastName || !role) {
    return res.status(400).json({ message: 'Missing required fields: email, password, firstName, lastName, role.' });
  }

  try {
    // Create user in Firebase Auth
    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName: `${firstName} ${lastName}`,
    });

    // Create user profile in Firestore
    await firestoreDb.collection('userProfiles').doc(userRecord.uid).set({
      uid: userRecord.uid,
      email,
      firstName,
      lastName,
      role: role.toLowerCase(),
      department: department || null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isActive: true,
    });

    res.status(201).json({
      message: 'User registered successfully. Please login using the client SDK.',
      uid: userRecord.uid,
      email: userRecord.email
    });

  } catch (error) {
    console.error('Signup error:', error);
    if (error.code === 'auth/email-already-exists') {
      return res.status(409).json({ message: 'Email already in use.' });
    }
    if (error.code === 'auth/weak-password') {
      return res.status(400).json({ message: 'Password too weak.' });
    }
    res.status(500).json({ message: 'Registration failed', error: error.message });
  }
};

// Client-side login handler
exports.login = async (req, res) => {
  res.status(200).json({
    message: "Please use Firebase client SDK for authentication."
  });
};

// Get current user profile
exports.getMe = async (req, res) => {
  try {
    const userDoc = await firestoreDb.collection('userProfiles').doc(req.user.uid).get();
    if (!userDoc.exists) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.status(200).json(userDoc.data());
  } catch (error) {
    console.error('Profile fetch error:', error);
    res.status(500).json({ message: 'Failed to fetch profile', error: error.message });
  }
};

// Logout endpoint
exports.logout = async (req, res) => {
  try {
    // Revoke all sessions (optional - only needed if you want to force client logout)
    await admin.auth().revokeRefreshTokens(req.user.uid);
    res.status(200).json({ message: 'All sessions terminated. Client should clear local credentials.' });
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({ message: 'Logout failed', error: error.message });
  }
};