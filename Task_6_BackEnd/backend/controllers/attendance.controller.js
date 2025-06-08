const db = require('../config/firebase');

exports.markAttendance = async (req, res) => {
  try {
    const data = req.body;
    const doc = await db.collection('attendance').add(data);
    res.status(201).json({ id: doc.id, ...data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getAttendanceByStudent = async (req, res) => {
  try {
    const { studentId } = req.params;
    const snapshot = await db.collection('attendance')
      .where('studentId', '==', studentId)
      .get();

    const records = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.status(200).json(records);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getAttendanceBySession = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const snapshot = await db.collection('attendance')
      .where('sessionId', '==', sessionId)
      .get();

    const records = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.status(200).json(records);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
