import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import Icon from 'react-native-vector-icons/Ionicons';

// Import your JavaScript screens
import SplashScreen from './src/screens/Aut/Splash';
import Signup from './src/screens/Aut/Signup.js';
import Login from './src/screens/Aut/Login.js';
import JoinClassScreen from './src/screens/Home/Home.js';
import MyCoursesScreen from './src/screens/Student/StudentCoursesScreen.js';
import GeofenceAttendancePage from './src/screens/Student/GeofenceScreen';
import AttendanceHistory from './src/screens/CheckIn/AttendanceHistory';
import FacialRecognitionScreen from './src/screens/CheckIn/FacialRecognition';
import AttendanceLoginScreen from './src/screens/CheckIn/AttendanceLogin';
import HomeScreen from './src/screens/Home/Home';
import Footer from './src/components/Footer.js';

const Stack = createNativeStackNavigator();
const Tab = createBottomTabNavigator();

// Stack Navigator for Course-related screens
const CourseStack = () => {
  return (
    <Stack.Navigator screenOptions={{ headerShown: true }}>
      <Stack.Screen
        name="MyCoursesMain"
        component={MyCoursesScreen}
        options={{ title: 'My Courses' }}
      />
      <Stack.Screen
        name="AttendanceHistory"
        component={AttendanceHistory}
        options={{ title: 'Attendance History' }}
      />
    </Stack.Navigator>
  );
};

// Main Tab Navigator with Footer
const MainTabNavigator = () => {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          let iconName: string;

          if (route.name === 'Home') {
            iconName = focused ? 'home' : 'home-outline';
          } else if (route.name === 'Dashboard') {
            iconName = focused ? 'grid' : 'grid-outline';
          } else if (route.name === 'Profile') {
            iconName = focused ? 'person' : 'person-outline';
          } else if (route.name === 'Dispute') {
            iconName = focused ? 'alert-circle' : 'alert-circle-outline';
          } else {
            iconName = 'help-outline';
          }

          return <Icon name={iconName} size={size} color={color} />;
        },
        tabBarActiveTintColor: '#007AFF',
        tabBarInactiveTintColor: '#666',
        tabBarStyle: {
          paddingVertical: 8,
          paddingBottom: 12,
          borderTopWidth: 1,
          borderTopColor: '#E5E5E5',
          shadowColor: '#000',
          shadowOffset: {
            width: 0,
            height: -2,
          },
          shadowOpacity: 0.1,
          shadowRadius: 4,
          elevation: 8,
          backgroundColor: '#fff',
        },
        tabBarLabelStyle: {
          fontSize: 12,
          fontWeight: '500',
          marginTop: 4,
        },
        headerShown: true,
      })}
    >
      <Tab.Screen
        name="Home"
        component={JoinClassScreen}
        options={{ title: 'Student Dashboard' }}
      />
      <Tab.Screen
        name="Dashboard"
        component={CourseStack}
        options={{ headerShown: false }}
      />
      <Tab.Screen
        name="Profile"
        component={HomeScreen}
        options={{ title: 'Home' }}
      />
      <Tab.Screen
        name="Dispute"
        component={AttendanceLoginScreen}
        options={{ title: 'Attendance Login' }}
      />
    </Tab.Navigator>
  );
};

// App Component 
const App = () => {
  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName="Splash"
        screenOptions={{ headerShown: false }}
      >
        {/* Auth Flow */}
        <Stack.Screen name="Splash" component={SplashScreen} />
        <Stack.Screen
          name="Login"
          component={Login}
          options={{
            headerShown: true,
            title: 'Login',
            headerBackTitle: 'Back',
          }}
        />
        <Stack.Screen
          name="Signup"
          component={Signup}
          options={{
            headerShown: true,
            title: 'Sign Up',
            headerBackTitle: 'Back',
          }}
        />

        {/* Student Dashboard Flow */}
        <Stack.Screen
          name="StudentHome"
          component={MainTabNavigator}
          options={{
            headerShown: false,
          }}
        />
        <Stack.Screen
          name="MyCourses"
          component={MyCoursesScreen}
          options={{
            headerShown: true,
            title: 'My Courses',
            headerBackTitle: 'Dashboard',
          }}
        />

        {/* Attendance Flow */}
        <Stack.Screen
          name="GeofenceAttendance"
          component={GeofenceAttendancePage}
          options={{
            headerShown: false,
            title: 'Location Verification',
          }}
        />
        <Stack.Screen
          name="FacialRecognition"
          component={FacialRecognitionScreen}
          options={{
            headerShown: true,
            title: 'Facial Recognition',
            headerBackTitle: 'Back',
          }}
        />
        <Stack.Screen
          name="AttendanceHistory"
          component={AttendanceHistory}
          options={{
            headerShown: true,
            title: 'Attendance History',
            headerBackTitle: 'Dashboard',
          }}
        />

        {/* Legacy/Admin Screens */}
        <Stack.Screen
          name="Home"
          component={HomeScreen}
          options={{
            headerShown: true,
            title: 'Home',
          }}
        />
        <Stack.Screen
          name="AttendanceLogin"
          component={AttendanceLoginScreen}
          options={{
            headerShown: true,
            title: 'Attendance Login',
          }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
};

export default App;
