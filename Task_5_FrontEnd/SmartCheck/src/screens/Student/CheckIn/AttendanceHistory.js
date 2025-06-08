// src/screens/CheckIn/AttendanceHistory.js

import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';

const attendanceData = {
  'Thursday 26 May 2025': [
    { time: '11:00', course: 'Human Computer Inter', code: 'CEF 472', status: 'P' },
    { time: '11:00', course: 'Human Computer Inter', code: 'CEF 472', status: 'A' },
    { time: '11:00', course: 'Human Computer Inter', code: 'CEF 472', status: 'P' },
  ],
  'Friday 29 May 2025': [
    { time: '11:00', course: 'Human Computer Inter', code: 'CEF 472', status: 'P' },
    { time: '11:00', course: 'Human Computer Inter', code: 'CEF 472', status: 'A' },
    { time: '11:00', course: 'Human Computer Inter', code: 'CEF 472', status: 'P' },
  ],
};

const AttendanceHistory = () => {
  const navigation = useNavigation();

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()}>
          <Ionicons name="arrow-back" size={24} color="#000" />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Attendance History</Text>
      </View>

      {/* Tabs */}
      <View style={styles.tabs}>
        <Text style={[styles.tab, styles.activeTab]}>Current Attendance</Text>
        <Text style={styles.tab}>Overall Attendance</Text>
      </View>

      {/* Attendance List */}
      <ScrollView>
        {Object.entries(attendanceData).map(([date, entries], index) => (
          <View key={index} style={styles.dateSection}>
            <Text style={styles.dateText}>{date}</Text>
            {entries.map((entry, idx) => (
              <View key={idx} style={styles.card}>
                <View>
                  <Text style={styles.time}>{entry.time}</Text>
                  <Text style={styles.course}>{entry.course}</Text>
                  <Text style={styles.code}>{entry.code}</Text>
                </View>
                <View
                  style={[
                    styles.statusCircle,
                    entry.status === 'P' ? styles.present : styles.absent,
                  ]}
                >
                  <Text style={styles.statusText}>{entry.status}</Text>
                </View>
              </View>
            ))}
          </View>
        ))}
      </ScrollView>

      {/* Bottom Tabs (Static UI for now) */}
      <View style={styles.bottomNav}>
        <Text style={styles.navItem}>Home</Text>
        <Text style={styles.navItem}>History</Text>
        <Text style={styles.navItem}>Profile</Text>
        <Text style={styles.navItem}>Logout</Text>
      </View>
    </View>
  );
};

export default AttendanceHistory;

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingTop: 50,
    backgroundColor: '#fff',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginLeft: 10,
  },
  tabs: {
    flexDirection: 'row',
    marginTop: 20,
    marginHorizontal: 20,
    borderBottomWidth: 1,
    borderColor: '#ddd',
  },
  tab: {
    marginRight: 20,
    paddingBottom: 10,
    color: '#777',
  },
  activeTab: {
    color: '#007bff',
    borderBottomWidth: 2,
    borderColor: '#007bff',
  },
  dateSection: {
    marginTop: 20,
    paddingHorizontal: 20,
  },
  dateText: {
    fontWeight: '600',
    marginBottom: 10,
  },
  card: {
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 12,
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 12,
    shadowColor: '#000',
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  time: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  course: {
    fontSize: 14,
    marginTop: 4,
  },
  code: {
    fontSize: 12,
    color: '#888',
  },
  statusCircle: {
    width: 32,
    height: 32,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
  },
  statusText: {
    color: '#fff',
    fontWeight: 'bold',
  },
  present: {
    backgroundColor: 'green',
  },
  absent: {
    backgroundColor: 'red',
  },
  bottomNav: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    paddingVertical: 12,
    borderTopWidth: 1,
    borderColor: '#eee',
    backgroundColor: '#f9f9f9',
  },
  navItem: {
    color: '#777',
    fontSize: 14,
  },
});
