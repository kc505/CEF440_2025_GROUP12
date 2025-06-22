const { db } = require('../config/firebase');

// ✅ Create a Course
exports.createCourse = async (req, res) => {
  try {
    const {
      courseCode,
      courseName,
      credits,
      geofence,         // { lat, lng }
      schedule,         // { dayOfWeek, time }
    } = req.body;

    const newCourse = {
      courseCode,
      courseName,
      credits,
      createdDate: new Date(),
      isActive: true,
      lecturerId: null,  // Lecturer assigned later
      geofence: geofence || null,
      schedule: schedule || null,
    };

    const docRef = await db.collection('courses').add(newCourse);
    res.status(201).json({ id: docRef.id, ...newCourse });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// ✅ Get All Courses
exports.getAllCourses = async (req, res) => {
  try {
    const snapshot = await db.collection('courses').get();
    const courses = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.status(200).json(courses);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// ✅ Get Single Course
exports.getCourseById = async (req, res) => {
  try {
    const doc = await db.collection('courses').doc(req.params.courseId).get();
    if (!doc.exists) return res.status(404).json({ message: 'Course not found' });
    res.status(200).json({ id: doc.id, ...doc.data() });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// ✅ Update Course (Partial updates supported)
exports.updateCourse = async (req, res) => {
  try {
    await db.collection('courses').doc(req.params.courseId).update(req.body);
    const updated = await db.collection('courses').doc(req.params.courseId).get();
    res.status(200).json({ id: updated.id, ...updated.data() });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// ✅ Delete Course
exports.deleteCourse = async (req, res) => {
  try {
    await db.collection('courses').doc(req.params.courseId).delete();
    res.status(200).json({ message: 'Course deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

//  Assign Lecturer to Course
exports.assignLecturer = async (req, res) => {
  const { lecturerId } = req.body;
  try {
    await db.collection('courses').doc(req.params.courseId).update({ lecturerId });
    res.status(200).json({ message: 'Lecturer assigned successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

