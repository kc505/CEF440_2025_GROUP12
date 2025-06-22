const express = require('express');
const router = express.Router();
const courseController = require('../controllers/course.controller');

router.post('/', courseController.createCourse);
router.get('/', courseController.getAllCourses);
router.get('/:courseId', courseController.getCourseById);
router.put('/:courseId', courseController.updateCourse);
router.delete('/:courseId', courseController.deleteCourse);

// Join course by code
router.post('/join', async (req, res) => {
  const { code } = req.body;
  const uid = req.user?.uid || req.headers['uid']; // Adjust based on how you're handling auth

  if (!code || !uid) {
    return res.status(400).json({ message: 'Course code and user ID are required.' });
  }

  try {
    // Check if the course with that code exists
    const courseSnapshot = await db.collection('courses')
      .where('code', '==', code)
      .limit(1)
      .get();

    if (courseSnapshot.empty) {
      return res.status(404).json({ message: 'Course not found with this code.' });
    }

    const courseDoc = courseSnapshot.docs[0];
    const courseId = courseDoc.id;

    // Add this course to student's enrolledCourses (assuming 'userProfiles' collection)
    const userRef = db.collection('users').doc(uid);
    await userRef.update({
      enrolledCourses: admin.firestore.FieldValue.arrayUnion(courseId),
    });

    res.status(200).json({ message: 'Course joined successfully', courseId });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to join course', error: error.message });
  }
});



// 👨‍🏫 Assign Lecturer
router.patch('/:courseId/assign-lecturer', courseController.assignLecturer);

module.exports = router;
