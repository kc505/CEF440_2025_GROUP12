import React from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StyleSheet
} from 'react-native';
import CourseProfile from '../../../components/Course';
//import Img from '../../assets/splash.png'

const MyCoursesScreen = () => {
  const courses = [
    {
      id: 1,
      CourseName: 'Human Computer Interface',
      CourseId: 'CEF400',
      department: 'Engineering',
      profileImage: null,
      status: 'Incoming',
    },
    {
      id: 2,
      CourseName: 'Feedback Systems Laboratory',
      CourseId: 'EEF470',
      department: 'Engineering',
      profileImage: null,
      status: 'Active',
    },
    {
      id: 3,
      CourseName: 'Internet Programming',
      CourseId: 'CEF440',
      department: 'Engineering',
      profileImage: null,
      status: 'Incoming',
    },
    {
      id: 4,
      CourseName: 'Human Computer Interface',
      CourseId: 'CEF400',
      department: 'Engineering',
      profileImage: null,
      status: 'Cancelled',
    },
  ];

  const handleAddCourse = () => {
    console.log('Add course pressed');
    // Add your course addition logic here
  };

  return (
    <View style={styles.container}>
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.titleContainer}>
          <Text style={styles.title}>My Courses</Text>
        </View>

        <View style={styles.coursesList}>
          {courses.map((course) => (
            <CourseProfile
              key={course.id}
              CourseName={course.CourseName}
              CourseId={course.CourseId}
              department={course.department}
              profileImage={course.profileImage}
              status={course.status}
            />
          ))}
        </View>

        <TouchableOpacity
          style={styles.addButton}
          onPress={handleAddCourse}
          activeOpacity={0.8}
        >
          <Text style={styles.plusIcon}>+</Text>
        </TouchableOpacity>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F7FCFF',
  },
  titleContainer: {
    paddingHorizontal: 24,
    paddingTop: 20,
    paddingBottom: 16,
  },
  title: {
    fontSize: 32,
    fontWeight: '600',
    color: '#000000',
    textAlign: 'center',
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingBottom: 100,
  },
  coursesList: {
    paddingHorizontal: 24,
    gap: 16,
  },
  addButton: {
    position: 'absolute',
    bottom: 30,
    right: 30,
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: '#1C8EFF',
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#4A90E2',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  plusIcon: {
    fontSize: 32,
    color: '#FFFFFF',
    fontWeight: '500',
    textAlign: 'center',
    marginTop: -2,
  },
});

export default MyCoursesScreen;