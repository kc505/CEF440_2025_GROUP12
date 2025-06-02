import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

// Import your JavaScript screens
import HomeScreen from './src/screens/Home/Home'; 
import AttendanceLoginScreen from './src/screens/CheckIn/AttendanceLogin'; 
import FacialRecognitionScreen from './src/screens/CheckIn/FacialRecognition'; 
import Signup from './src/screens/Aut/Signup.js';
import Login from './src/screens/Aut/Login.js';
import AttendanceHistory from './src/screens/CheckIn/AttendanceHistory';

const Stack = createNativeStackNavigator();

const App = () => {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="Signup" screenOptions={{ headerShown: false }}>
        <Stack.Screen name="Signup" component={Signup} />
        <Stack.Screen name="Login" component={Login} />
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="AttendanceLogin" component={AttendanceLoginScreen} />
        <Stack.Screen name="FacialRecognition" component={FacialRecognitionScreen} />
        <Stack.Screen name="AttendanceHistory" component={AttendanceHistory} />
      </Stack.Navigator>
    </NavigationContainer>
  );
};

export default App;
