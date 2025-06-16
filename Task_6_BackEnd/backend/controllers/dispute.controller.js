const db = require('../config/firebase');

exports.fileDispute = async (req, res) => {
  try {
    const data = req.body;
    const doc = await db.collection('disputes').add({
      ...data,
      status: 'PENDING',
      submittedAt: new Date().toISOString()
    });
    res.status(201).json({ id: doc.id, ...data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getDisputesByStudent = async (req, res) => {
  try {
    const { studentId } = req.params;
    const snapshot = await db.collection('disputes')
      .where('studentId', '==', studentId)
      .get();
    const records = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.status(200).json(records);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.resolveDispute = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    await db.collection('disputes').doc(id).update({ status });
    res.status(200).json({ message: 'Dispute updated.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
