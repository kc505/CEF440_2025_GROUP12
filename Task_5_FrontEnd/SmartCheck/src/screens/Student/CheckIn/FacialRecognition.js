import React, { useRef } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Alert,
  SafeAreaView,
} from 'react-native';
import { RNCamera } from 'react-native-camera';
import Header from '../../components/Header';

const FacialRecognition = () => {
  const cameraRef = useRef(null);

  const captureFace = async () => {
    if (cameraRef.current) {
      const options = { quality: 0.5, base64: true };
      const data = await cameraRef.current.takePictureAsync(options);
      Alert.alert('Face Captured', 'Sending for verification...');
      // TODO: Send image to backend for facial recognition
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <Header appName="SmartCheck" notificationCount={0} />

      <Text style={styles.instruction}>Align your face within the frame</Text>

      <RNCamera
        ref={cameraRef}
        style={styles.camera}
        type={RNCamera.Constants.Type.front}
        captureAudio={false}
      >
        <View style={styles.frameBox} />
      </RNCamera>

      <TouchableOpacity style={styles.button} onPress={captureFace}>
        <Text style={styles.buttonText}>Capture Face</Text>
      </TouchableOpacity>
    </SafeAreaView>
  );
};

export default FacialRecognition;

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#000' },
  instruction: {
    color: '#fff',
    textAlign: 'center',
    padding: 10,
    fontSize: 16,
  },
  camera: {
    flex: 1,
    margin: 16,
    borderRadius: 16,
    overflow: 'hidden',
    alignItems: 'center',
    justifyContent: 'center',
  },
  frameBox: {
    borderWidth: 3,
    borderColor: 'red',
    width: 200,
    height: 250,
    borderRadius: 10,
  },
  button: {
    backgroundColor: '#007bff',
    padding: 14,
    margin: 16,
    borderRadius: 10,
    alignItems: 'center',
  },
  buttonText: {
    color: '#fff',
    fontWeight: 'bold',
  },
});
