// Import necessary modules
const { admin, db: firestoreDb } = require('../config/firebase');
const { pool } = require('../config/db'); // Your relational DB connection pool

// --- Helper function to get a user's role from the relational DB ---
const _getUserRole = async (uid) => {
  const { rows } = await pool.query('SELECT role FROM Users WHERE userID = $1', [uid]);
  if (rows.length === 0) {
    return null; // User not found
  }
  return rows[0].role; // Returns role like 'ADMIN', 'STUDENT', etc.
};


// 1. GET USER BY ID
// Fetches a complete, combined user profile from the relational DB.
// Accessible by the user themselves or an admin.
exports.getUserById = async (req, res) => {
  const { uid: requestedUid } = req.params;
  const { uid: requesterUid } = req.user; // From authMiddleware

  try {
    // --- Authorization ---
    const requesterRole = await _getUserRole(requesterUid);
    if (requesterRole !== 'ADMIN' && requesterUid !== requestedUid) {
      return res.status(403).json({ message: 'Forbidden: You do not have permission to access this resource.' });
    }

    // --- Data Fetching ---
    // This single, comprehensive query gets all data from the relational DB.
    const query = `
      SELECT 
        u.userID, u.firstName, u.lastName, u.email, u.role, u.phoneNumber, u.profileImageURL, u.isActive,
        s.enrollmentNumber, s.program, s.yearOfStudy, s.semester,
        l.employeeNumber, l.designation, l.specialization,
        -- Use COALESCE to pick the first non-null department from specialized tables
        COALESCE(s.department, l.department) as department
      FROM Users u
      LEFT JOIN Students s ON u.userID = s.studentID
      LEFT JOIN Lecturers l ON u.userID = l.facultyID
      WHERE u.userID = $1;
    `;
    const { rows } = await pool.query(query, [requestedUid]);

    if (rows.length === 0) {
      return res.status(404).json({ message: 'User not found.' });
    }

    res.status(200).json(rows[0]);

  } catch (error) {
    console.error(`Error fetching user ${requestedUid}:`, error);
    res.status(500).json({ message: 'Failed to fetch user profile.' });
  }
};


// 2. UPDATE USER BY ID
// Updates user data in both the relational DB and Firestore.
// Users can update their own info; Admins can update anyone's.
exports.updateUser = async (req, res) => {
  const { uid: targetUid } = req.params;
  const { uid: requesterUid } = req.user;
  const { firstName, lastName, phoneNumber, profileImageURL, ...roleSpecificUpdates } = req.body;

  try {
    // --- Authorization ---
    const requesterRole = await _getUserRole(requesterUid);
    if (requesterRole !== 'ADMIN' && requesterUid !== targetUid) {
      return res.status(403).json({ message: 'Forbidden: You do not have permission to update this profile.' });
    }
    // Note: Add checks here if only admins can update certain fields like 'role' or 'email'.

    // --- Update Logic ---
    // We will build a dynamic query to only update fields that were provided.
    const updates = [];
    const values = [];
    let paramIndex = 1;

    // Add fields to update to the arrays
    if (firstName) { updates.push(`firstName = $${paramIndex++}`); values.push(firstName); }
    if (lastName) { updates.push(`lastName = $${paramIndex++}`); values.push(lastName); }
    if (phoneNumber) { updates.push(`phoneNumber = $${paramIndex++}`); values.push(phoneNumber); }
    if (profileImageURL) { updates.push(`profileImageURL = $${paramIndex++}`); values.push(profileImageURL); }

    if (updates.length > 0) {
      values.push(targetUid); // Add the UID for the WHERE clause
      const query = `UPDATE Users SET ${updates.join(', ')} WHERE userID = $${paramIndex} RETURNING *;`;
      await pool.query(query, values);
    }

    // You can add logic here to update the role-specific tables (Students, Lecturers)
    // if 'roleSpecificUpdates' contains relevant fields.

    // Also update Firestore if you use it as a cache or for real-time features
    const firestoreUpdates = { firstName, lastName, phoneNumber, profileImageURL };
    // Remove undefined properties before updating
    Object.keys(firestoreUpdates).forEach(key => firestoreUpdates[key] === undefined && delete firestoreUpdates[key]);
    if (Object.keys(firestoreUpdates).length > 0) {
      await firestoreDb.collection('userProfiles').doc(targetUid).update(firestoreUpdates);
    }
    
    // Fetch and return the newly updated profile
    const { rows } = await pool.query('SELECT * FROM Users WHERE userID = $1', [targetUid]);
    res.status(200).json({ message: 'User profile updated successfully.', user: rows[0] });

  } catch (error) {
    console.error(`Error updating user ${targetUid}:`, error);
    res.status(500).json({ message: 'Failed to update user profile.' });
  }
};


// 3. DELETE USER BY ID (Admin Only)
// Deletes user from Firebase Auth, Firestore, and the relational database.
exports.deleteUser = async (req, res) => {
  const { uid: targetUid } = req.params;
  const { uid: requesterUid } = req.user;

  try {
    // --- Authorization: Admin Only ---
    const requesterRole = await _getUserRole(requesterUid);
    if (requesterRole !== 'ADMIN') {
      return res.status(403).json({ message: 'Forbidden: Only admins can delete users.' });
    }

    // --- Deletion Logic ---
    // Start a transaction in your relational DB for safety
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      // 1. Delete from relational DB. ON DELETE CASCADE should handle related tables.
      await client.query('DELETE FROM Users WHERE userID = $1', [targetUid]);
      // 2. Delete from Firestore
      await firestoreDb.collection('userProfiles').doc(targetUid).delete();
      // 3. Delete from Firebase Authentication (do this last)
      await admin.auth().deleteUser(targetUid);

      await client.query('COMMIT');
      res.status(200).json({ message: `User ${targetUid} has been deleted successfully.` });

    } catch (err) {
      await client.query('ROLLBACK');
      throw err; // Re-throw to be caught by the outer catch block
    } finally {
      client.release();
    }
  } catch (error) {
    console.error(`Error deleting user ${targetUid}:`, error);
    if (error.code === 'auth/user-not-found') {
      return res.status(404).json({ message: 'User not found in Firebase Authentication.' });
    }
    res.status(500).json({ message: 'Failed to delete user.' });
  }
};


// 4. GET USERS BY ROLE (Admin Only Recommended)
// Fetches a list of users based on their role from the relational DB.
exports.getUsersByRole = async (req, res) => {
  const { role } = req.query;
  const { uid: requesterUid } = req.user;

  if (!role) {
    return res.status(400).json({ message: 'Role query parameter is required.' });
  }

  try {
    // --- Authorization: Recommended to be Admin-only ---
    const requesterRole = await _getUserRole(requesterUid);
    if (requesterRole !== 'ADMIN') {
      return res.status(403).json({ message: 'Forbidden: Access restricted to admins.' });
    }

    // --- Data Fetching ---
    const query = 'SELECT userID, firstName, lastName, email, role FROM Users WHERE role = $1;';
    const { rows } = await pool.query(query, [role.toUpperCase()]);

    res.status(200).json(rows);

  } catch (error) {
    console.error(`Error fetching users by role '${role}':`, error);
    res.status(500).json({ message: 'Failed to fetch users.' });
  }
};