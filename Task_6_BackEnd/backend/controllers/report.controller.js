const db = require('../config/firebase');

exports.attendanceSummary = async (req, res) => {
  try {
    const { courseId } = req.params;
    const snapshot = await db.collection('attendance')
      .where('courseId', '==', courseId)
      .get();

    const total = snapshot.size;
    const present = snapshot.docs.filter(doc => doc.data().attendanceStatus === 'PRESENT').length;

    res.status(200).json({
      courseId,
      totalRecords: total,
      presentCount: present,
      absentCount: total - present,
      attendanceRate: ((present / total) * 100).toFixed(2)
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.studentHistory = async (req, res) => {
  try {
    const { studentId } = req.params;
    const snapshot = await db.collection('attendance')
      .where('studentId', '==', studentId)
      .get();

    const history = snapshot.docs.map(doc => doc.data());
    res.status(200).json(history);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
