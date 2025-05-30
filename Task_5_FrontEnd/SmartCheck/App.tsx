
import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  SafeAreaView,
  Alert,
  Dimensions,
  TouchableOpacity
} from 'react-native';

import Header from './components/Header.js';
import Footer from './components/Footer';
import AttendanceButton from './components/Button';
import StatusCard from './components/AttendanceDetails.js';
import CourseProfile from './components/Course';
import SquareCard from './components/squarecard';
import Input from './components/Input';
import Card from './components/card.js';

const App = () => {
  // State for active tab
  const [activeTab, setActiveTab] = useState('home');
  const [searchQuery, setSearchQuery] = useState('');
  
  // Calculate responsive card dimensions
  const screenWidth = Dimensions.get('window').width;
  const cardWidth = (screenWidth - 90) / 2;
  
  // Sample data and state management
  const [currentCourse, setCurrentCourse] = useState({
    CourseName: 'Human Computer Interface',
    CourseId: 'CEF400',
    department: 'Engineering',
    profileImage: null,
    status: 'InComing',
  });

  const [attendanceStatus, setAttendanceStatus] = useState({
    status: 'Present',
    timestamp: new Date().toISOString(),
    location: 'Office Building A',
  });

  const [locationStatus, setLocationStatus] = useState({
    isInGeofence: true,
    distance: 0,
    locationName: 'TechCorp Office',
  });

  const [attendanceHistory, setAttendanceHistory] = useState([
    {
      id: 1,
      date: '2024-01-15T09:00:00Z',
      status: 'Present',
    },
    {
      id: 2,
      date: '2024-01-14T09:15:00Z',
      status: 'Late',
    },
    {
      id: 3,
      date: '2024-01-13T08:45:00Z',
      status: 'Present',
    },
    {
      id: 4,
      date: '2024-01-12T09:30:00Z',
      status: 'Late',
    },
  ]);

  const [isProcessing, setIsProcessing] = useState(false);
  const [showCamera, setShowCamera] = useState(false);
  const [notificationCount, setNotificationCount] = useState(3);

  // Handlers
  const handleCheckIn = () => {
    if (!locationStatus.isInGeofence) {
      Alert.alert('Location Error', 'You must be within the office premises to check in.');
      return;
    }
    setShowCamera(true);
  };

  const handleCheckOut = () => {
    Alert.alert('Check Out', 'Are you sure you want to check out?', [
      { text: 'Cancel', style: 'cancel' },
      { 
        text: 'Confirm', 
        onPress: () => {
          setAttendanceStatus({
            status: 'Checked Out',
            timestamp: new Date().toISOString(),
            location: attendanceStatus.location,
          });
          Alert.alert('Success', 'You have been checked out successfully.');
        }
      },
    ]);
  };

  const handleFaceCapture = async (imageData) => {
    setIsProcessing(true);
    setTimeout(() => {
      setIsProcessing(false);
      setShowCamera(false);
      setAttendanceStatus({
        status: 'Present',
        timestamp: new Date().toISOString(),
        location: locationStatus.locationName,
      });
      const newRecord = {
        id: attendanceHistory.length + 1,
        date: new Date().toISOString(),
        status: 'Present',
      };
      setAttendanceHistory([newRecord, ...attendanceHistory]);
      Alert.alert('Success', 'Face recognized! Attendance recorded.');
    }, 3000);
  };

  const handleFaceDetected = (faces) => {
    console.log('Faces detected:', faces);
  };

  const handleNotificationPress = () => {
    Alert.alert('Notifications', `You have ${notificationCount} new notifications`);
    setNotificationCount(0);
  };

  const handleTabPress = (tabId) => {
    setActiveTab(tabId);
  };
    // Navigation handlers
  const navigateToCourseDetail = () => {
    Alert.alert('Navigation', 'Navigating to Course Detail');
  };

  const navigateToRecordAttendance = () => {
    Alert.alert('Navigation', 'Navigating to Record Attendance');
  };

  const navigateToViewAttendance = () => {
    Alert.alert('Navigation', 'Navigating to View Attendance');
  };
   const handleSearch = () => {
    Alert.alert('Search', `Searching for: ${searchQuery}`);
  };



  return (
    <SafeAreaView style={styles.container}>
      <Header 
        appName="SmartCheck" 
        onNotificationPress={handleNotificationPress}
        notificationCount={notificationCount}
      />
      
         <SafeAreaView>
      <View>
        <Text>  Hello World! </Text>
        <Text>  Welcome To Group12 Mobile-Based Attendance App</Text>
      </View>
    </SafeAreaView>

      <ScrollView style={styles.scrollView} showsVerticalScrollIndicator={false}>
       <Input
          label="Search Courses"
          placeholder="Enter course name or ID"
          value={searchQuery}
          onChangeText={setSearchQuery}
          onSubmitEditing={handleSearch}
          returnKeyType="search"
          style={styles.searchInput}
        />
        <View style={styles.cardsContainer}>
          <View style={styles.cardRow}>
            <SquareCard
              title="Quick Check-In"
              icon="checkin"
              onPress={handleCheckIn}
              style={[styles.squareCard, { width: cardWidth }]}
            />
            <SquareCard
              title="View History"
              icon="attendance"
              onPress={() => Alert.alert('History', 'Showing attendance history')}
              style={[styles.squareCard, { width: cardWidth }]}
            />
          </View>
          <View style={styles.cardRow}>
            <SquareCard
              title="Courses"
              icon="course"
              onPress={() => Alert.alert('Courses', 'View your courses')}
              style={[styles.squareCard, { width: cardWidth }]}
            />
            <SquareCard
              title="Reports"
              icon="report"
              onPress={() => Alert.alert('Reports', 'View your reports')}
              style={[styles.squareCard, { width: cardWidth }]}
            />
          </View>
        </View>

        <CourseProfile
          CourseName={currentCourse.CourseName}
          CourseId={currentCourse.CourseId}
          department={currentCourse.department}
          profileImage={currentCourse.profileImage}
          status={currentCourse.status}
        />

        {/* Course Navigation Cards with centered text */}
        <View style={styles.navigationCards}>
          <TouchableOpacity onPress={navigateToCourseDetail}>
            <Card style={styles.navCard}>
              <View style={styles.centeredContent}>
                <Text style={styles.navCardTitle}>Course Details</Text>
                <Text style={styles.navCardSubtitle}>View course information</Text>
              </View>
            </Card>
          </TouchableOpacity>

          <TouchableOpacity onPress={navigateToRecordAttendance}>
            <Card style={styles.navCard}>
              <View style={styles.centeredContent}>
                <Text style={styles.navCardTitle}>Record Attendance</Text>
                <Text style={styles.navCardSubtitle}>Take attendance for this course</Text>
              </View>
            </Card>
          </TouchableOpacity>

          <TouchableOpacity onPress={navigateToViewAttendance}>
            <Card style={styles.navCard}>
              <View style={styles.centeredContent}>
                <Text style={styles.navCardTitle}>View Attendance</Text>
                <Text style={styles.navCardSubtitle}>Check attendance records</Text>
              </View>
            </Card>
          </TouchableOpacity>
        </View>

        <StatusCard
          status={attendanceStatus.status}
          timestamp={attendanceStatus.timestamp}
          location={attendanceStatus.location}
        />

        <View style={styles.buttonContainer}>
          <AttendanceButton
            title="Check In"
            onPress={handleCheckIn}
            variant="primary"
            style={styles.actionButton}
          />
          <AttendanceButton
            title="Check Out"
            onPress={handleCheckOut}
            variant="danger"
            style={styles.actionButton}
          />
        </View>

      </ScrollView>
      
      <Footer 
        activeTab={activeTab}
        onTabPress={handleTabPress}
      />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F2F2F7',
  },
  scrollView: {
    flex: 1,
    padding: 16,
    marginBottom: 60,
  },
  searchInput: {
    marginBottom: 20,
  },
  centeredContent: {
    alignItems: 'center',
    justifyContent: 'center',
    textAlign: 'center',
  },
  navigationCards: {
    marginBottom: 20,
  },
  navCard: {
    marginBottom: 12,
    padding: 16,
  },
  navCardTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#3b82f6',
    marginBottom: 4,
    textAlign: 'center',
  },
  navCardSubtitle: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
  },
  cardsContainer: {
    marginBottom: 16,
  },
  cardRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  squareCard: {
    height: 150,
    borderRadius: 12,
    padding: 16,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
    backgroundColor: '#fff',
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginVertical: 16,
    gap: 12,
  },
  actionButton: {
    flex: 1,
  },
  historyContainer: {
    flex: 1,
    minHeight: 300,
    marginBottom: 20,
  },
});

export default App;