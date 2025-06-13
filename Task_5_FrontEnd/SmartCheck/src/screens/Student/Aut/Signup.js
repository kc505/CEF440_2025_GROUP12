import React, { useState } from 'react';
import { View, Text, TextInput, StyleSheet, TouchableOpacity, Alert } from 'react-native';
import { Menu } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import Button from '../../../components/Button';

const Signup = () => {
  const navigation = useNavigation();

  const [role, setRole] = useState('Student');
  const [menuVisible, setMenuVisible] = useState(false);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSignup = async () => {
    if (!name || !email || !password) {
      Alert.alert('Validation Error', 'Please fill in all fields.');
      return;
    }

    try {
      const response = await fetch('http://192.168.0.101:5000/api/signup', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name, email, password, role }),
      });

      const data = await response.json();

      if (response.ok) {
        Alert.alert('Success', 'Signup successful!');
        navigation.navigate('Login');
      } else {
        Alert.alert('Error', data.message || 'Signup failed');
      }
    } catch (err) {
      console.error(err);
      Alert.alert('Network Error', 'Could not connect to server.');
    }
  };

  return (
    <View style={styles.container}>
      <Menu
        visible={menuVisible}
        onDismiss={() => setMenuVisible(false)}
        anchor={
          <TouchableOpacity style={styles.roleDropdown} onPress={() => setMenuVisible(true)}>
            <Text style={styles.roleText}>{role} ⌄</Text>
          </TouchableOpacity>
        }>
        <Menu.Item onPress={() => { setRole('Student'); setMenuVisible(false); }} title="Student" />
        <Menu.Item onPress={() => { setRole('Teacher'); setMenuVisible(false); }} title="Teacher" />
      </Menu>

      <Text style={styles.title}>Create an account</Text>
      <Text style={styles.subtitle}>Fill in the field below to get started</Text>

      <TextInput
        style={styles.input}
        placeholder="Name"
        value={name}
        onChangeText={setName}
      />
      <TextInput
        style={styles.input}
        placeholder="Email"
        value={email}
        onChangeText={setEmail}
        keyboardType="email-address"
      />
      <TextInput
        style={styles.input}
        placeholder="Password"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
      />

      <Button label="Signup" onPress={handleSignup} />

      <TouchableOpacity onPress={() => navigation.navigate('Login')}>
        <Text style={styles.signinText}>
          Already have an account? <Text style={{ color: '#007bff' }}>Sign in</Text>
        </Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    padding: 24,
    flex: 1,
    justifyContent: 'center',
    backgroundColor: '#fff',
  },
  roleDropdown: {
    borderWidth: 1,
    borderColor: '#ccc',
    padding: 12,
    borderRadius: 8,
    marginBottom: 20,
  },
  roleText: {
    fontSize: 16,
  },
  title: {
    fontSize: 26,
    fontWeight: 'bold',
    marginBottom: 6,
  },
  subtitle: {
    fontSize: 14,
    color: '#777',
    marginBottom: 24,
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    marginBottom: 16,
  },
  signinText: {
    marginTop: 20,
    textAlign: 'center',
    fontSize: 14,
  },
});

export default Signup;
