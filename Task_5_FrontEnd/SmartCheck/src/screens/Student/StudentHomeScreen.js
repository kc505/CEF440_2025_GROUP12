import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet
} from 'react-native';

const JoinClassScreen = () => {
  const handleJoinClass = () => {

    console.log('Join class pressed');

  };

  return (
    <View style={styles.container}>
      <View style={styles.content}>
        <View style={styles.welcomeSection}>
          <Text style={styles.welcomeText}>
            <Text style={styles.welcomeBlue}>Welcome</Text>
            <Text style={styles.welcomeBlack}> Joe,</Text>
          </Text>
          <Text style={styles.instructionText}>
            Click the button to join a class
          </Text>
        </View>

        <TouchableOpacity
          style={styles.joinButton}
          onPress={handleJoinClass}
          activeOpacity={0.8}
        >
          <Text style={styles.plusIcon}>+</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F7FCFF',
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 32,
  },
  welcomeSection: {
    alignItems: 'center',
    marginBottom: 80,
  },
  welcomeText: {
    fontSize: 28,
    textAlign: 'center',
    marginBottom: 16,
  },
  welcomeBlue: {
    color: '#1C8EFF',
    fontWeight: '500',
  },
  welcomeBlack: {
    color: '#333333',
    fontWeight: '500',
  },
  instructionText: {
    fontSize: 18,
    color: '#333333',
    textAlign: 'center',
    lineHeight: 24,
    fontWeight: '500',
  },
  joinButton: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: '#007EFC',
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
  },
});

export default JoinClassScreen;