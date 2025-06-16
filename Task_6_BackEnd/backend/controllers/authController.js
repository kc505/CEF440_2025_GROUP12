// Import necessary modules
const { admin, db: firestoreDb } = require('../config/firebase-config'); // Assuming you export services from your config
const { pool } = require('../config/db'); // Your relational DB connection pool

// 1. SIGNUP CONTROLLER
// Creates a user in Firebase Auth, then creates corresponding profiles in Firestore and the Relational DB.
exports.signup = async (req, res) => {
  const { email, password, firstName, lastName, role, department } = req.body;

  // --- Step 1: Input Validation ---
  if (!email || !password || !firstName || !lastName || !role) {
    return res.status(400).json({ message: 'Missing required fields: email, password, firstName, lastName, role.' });
  }

  try {
    // --- Step 2: Create user in Firebase Authentication ---
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      displayName: `${firstName} ${lastName}`,
    });

    const uid = userRecord.uid;

    // --- Step 3: Create user profile in Cloud Firestore ---
    // This is great for unstructured or semi-structured data.
    const userProfileRef = firestoreDb.collection('userProfiles').doc(uid);
    await userProfileRef.set({
      uid: uid,
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: role.toLowerCase(), // Store role consistently
      department: department || null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isActive: true,
    });
    
    // --- Step 4: Create user record in Relational Database ---
    // This is for your structured data and relationships.
    // NOTE: We do not store the password here. Firebase handles authentication.
    const relationalQuery = `
      INSERT INTO Users (userID, firstName, lastName, email, role, isActive) 
      VALUES ($1, $2, $3, $4, $5, TRUE) 
      RETURNING userID, email, role;
    `;
    const relationalValues = [uid, firstName, lastName, email, role.toUpperCase()];
    await pool.query(relationalQuery, relationalValues);

    // --- Step 5: (Optional) Create role-specific record in another table ---
    // if (role.toLowerCase() === 'student') {
    //   await pool.query('INSERT INTO Students (studentID, ...) VALUES ($1, ...)', [uid, ...]);
    // } else if (role.toLowerCase() === 'lecturer') {
    //   await pool.query('INSERT INTO Lecturers (facultyID, ...) VALUES ($1, ...)', [uid, ...]);
    // }

    // --- Step 6: Send Success Response ---
    // The client should now prompt the user to log in to get their ID token.
    res.status(201).json({
      message: 'User registered successfully. Please login.',
      uid: uid,
      email: userRecord.email,
    });

  } catch (error) {
    console.error('Error during signup:', error);
    // Handle specific Firebase errors
    if (error.code === 'auth/email-already-exists') {
      return res.status(409).json({ message: 'Email address is already in use.' }); // 409 Conflict is more specific
    }
    if (error.code === 'auth/weak-password') {
      return res.status(400).json({ message: 'Password is too weak. It must be at least 6 characters long.' });
    }
    // Generic server error
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
  // authMiddleware has already run and attached `req.user`
  const uid = req.user.uid;

  try {
    // Fetch data from your relational database, which holds the primary user record
    const { rows } = await pool.query(
      'SELECT userID, firstName, lastName, email, role, isActive FROM Users WHERE userID = $1', 
      [uid]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'User profile not found in database.' });
    }
    const userProfile = rows[0];

    // You can also fetch additional data from Firestore if needed
    // const firestoreDoc = await firestoreDb.collection('userProfiles').doc(uid).get();
    // const firestoreData = firestoreDoc.data();
    // const combinedProfile = { ...userProfile, ...firestoreData };

    res.status(200).json(userProfile);
    
  } catch (error) {
    console.error('Error fetching user profile (/auth/me):', error);
    res.status(500).json({ message: 'Failed to fetch user profile.' });
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