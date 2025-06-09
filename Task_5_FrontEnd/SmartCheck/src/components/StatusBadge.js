
import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

const StatusBadge = ({ status }) => {
  const getStatusStyle = () => {
    switch (status?.toLowerCase()) {
      case 'present':
      case 'checked in':
        return styles.presentStatus;
      case 'absent':
      case 'checked out':
        return styles.absentStatus;
      case 'late':
        return styles.lateStatus;
      default:
        return styles.defaultStatus;
    }
  };

  return (
    <View style={[styles.statusCircle, getStatusStyle()]}>
      <Text style={styles.statusInitial}>
        {status ? status.charAt(0).toUpperCase() : 'U'}
      </Text>
    </View>
  );
};

const styles = StyleSheet.create({
  statusCircle: {
    width: 32,
    height: 32,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
  },
  statusInitial: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: 'bold',
  },
  presentStatus: {
    backgroundColor: '#34C759',
  },
  absentStatus: {
    backgroundColor: '#FF3B30',
  },
  lateStatus: {
    backgroundColor: '#FF9500',
  },
  defaultStatus: {
    backgroundColor: '#8E8E93',
  },
});

export default StatusBadge;