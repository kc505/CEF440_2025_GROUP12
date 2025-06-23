const { admin, db } = require('../config/firebase');

// 1. GET USER PROFILE (Firestore)
exports.getUserById = async (req, res) => {
  const { uid } = req.params;
  try {
    const doc = await db.collection('userProfiles').doc(uid).get();
    if (!doc.exists) {
      return res.status(404).json({ message: 'User not found.' });
    }
    res.status(200).json({ id: doc.id, ...doc.data() });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// 2. UPDATE USER PROFILE
exports.updateUser = async (req, res) => {
  const { uid } = req.params;
  const updates = req.body;

  try {
    await db.collection('userProfiles').doc(uid).update(updates);
    const updatedDoc = await db.collection('userProfiles').doc(uid).get();
    res.status(200).json({ message: 'User updated successfully.', data: updatedDoc.data() });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// 3. DELETE USER PROFILE
exports.deleteUser = async (req, res) => {
  const { uid } = req.params;
  try {
    await db.collection('userProfiles').doc(uid).delete();
    await admin.auth().deleteUser(uid);
    res.status(200).json({ message: `User ${uid} deleted successfully.` });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// 4. GET USERS BY ROLE
exports.getUsersByRole = async (req, res) => {
  const { role } = req.query;
  try {
    const snapshot = await db.collection('userProfiles').where('role', '==', role).get();

    if (snapshot.empty) {
      return res.status(404).json({ message: `No users found with role '${role}'.` });
    }

    const users = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.status(200).json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// GET ALL USERS (Firestore)
exports.getAllUsers = async (req, res) => {
  try {
    const snapshot = await db.collection('userProfiles').get();

    const users = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    res.status(200).json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// ADMIN creates lecturer account (email + Firestore document)
exports.createLecturer = async (req, res) => {
  const {
    email,
    password,
    firstName,
    lastName,
    department,
    employeeNumber,
    phoneNumber,
    specialization,
    officeLocation,
  } = req.body;

  try {
    // 1️⃣ Create in Firebase Authentication
    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName: `${firstName} ${lastName}`,
    });

    const userID = userRecord.uid;

    // 2️⃣ Create Firestore user profile
    const users = {
      userID,
      email,
      firstName,
      lastName,
      department,
      employeeNumber: employeeNumber || '',
      phoneNumber: phoneNumber || '',
      specialization: specialization || '',
      officeLocation: officeLocation || '',
      role: 'lecturer',
      registrationDate: admin.firestore.FieldValue.serverTimestamp(),
      profileImageURL: '', // or add later
      program: '',
      admissionYear: '',
      matriculeNumber: '',
      username: email.split('@')[0], // or generate one differently
    };

    await db.collection('users').doc(userID).set(users);

    res.status(201).json({ message: 'Lecturer created successfully', userID, data: users });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getLecturerById = async (req, res) => {
  const { uid } = req.params;
  try {
    const doc = await db.collection('users').doc(uid).get();

    if (!doc.exists) {
      return res.status(404).json({ message: 'Lecturer not found.' });
    }

    const data = doc.data();

    // Check if the role is lecturer
    if (data.role !== 'lecturer') {
      return res.status(400).json({ message: 'User is not a lecturer.' });
    }

    res.status(200).json({ id: doc.id, ...data });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getAllLecturers = async (req, res) => {
  try {
    const snapshot = await db.collection('users').where('role', '==', 'lecturer').get();

    if (snapshot.empty) {
      return res.status(404).json({ message: 'No lecturers found.' });
    }

    const lecturers = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.status(200).json(lecturers);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Assign Lecturer to Course
exports.assignLecturer = async (req, res) => {
  const { lecturerId } = req.body;
  const { courseId } = req.params;

  try {
    await db.collection('courses').doc(courseId).update({ lecturerId });
    const updatedDoc = await db.collection('courses').doc(courseId).get();

    if (!updatedDoc.exists) {
      return res.status(404).json({ message: 'Course not found' });
    }

    res.status(200).json({ message: 'Lecturer assigned successfully', data: { id: updatedDoc.id, ...updatedDoc.data() } });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
