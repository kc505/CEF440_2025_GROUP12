import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  Image,
  TouchableOpacity,
  SafeAreaView,
} from 'react-native';
import Header from '../../components/Header';

const AttendanceLogin = ({ navigation }) => {
  return (
    <SafeAreaView style={styles.container}>
      <Header appName="SmartCheck" notificationCount={0} />

      <Text style={styles.title}>Perform Facial Recognition</Text>

      <Image
        source={require('../../assets/face-scan.png')} // Add your image here
        style={styles.image}
      />

      <Text style={styles.subtitle}>Scan to Verify Identity</Text>

      <View style={styles.instructions}>
        <Text>✅ Ensure proper lighting</Text>
        <Text>✅ Center your face in the frame</Text>
        <Text>✅ Remove any face coverings</Text>
      </View>

      <TouchableOpacity
        style={styles.button}
        onPress={() => navigation.navigate('FacialRecognition')}
      >
        <Text style={styles.buttonText}>Scan Face</Text>
      </TouchableOpacity>
    </SafeAreaView>
  );
};

export default AttendanceLogin;

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#007bff',
    padding: 16,
  },
  title: {
    color: '#fff',
    fontSize: 22,
    fontWeight: 'bold',
    marginVertical: 20,
    textAlign: 'center',
  },
  image: {
    width: 130,
    height: 130,
    alignSelf: 'center',
    marginVertical: 20,
  },
  subtitle: {
    color: '#fff',
    fontSize: 16,
    textAlign: 'center',
  },
  instructions: {
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 10,
    marginTop: 20,
  },
  button: {
    backgroundColor: '#fff',
    marginTop: 30,
    padding: 16,
    borderRadius: 10,
    alignItems: 'center',
  },
  buttonText: {
    color: '#007bff',
    fontWeight: 'bold',
    fontSize: 16,
  },
});
