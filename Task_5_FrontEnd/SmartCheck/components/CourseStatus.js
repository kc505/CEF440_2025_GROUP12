
import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

const CourseStatusBadge = ({ status }) => {
  const getStatusStyle = () => {
    switch (status?.toLowerCase()) {
      case 'Ongoing':
      case 'checked in':
        return styles.ongoingStatus;
      case 'absent':
      case 'Incoming':
        return styles.incomingStatus;
      case 'Cancelled':
        return styles.cancelledStatus;
      default:
        return styles.defaultStatus;
    }
  };

  return (
    <View style={[styles.statusBadge, getStatusStyle()]}>
      <Text style={styles.statusText}>{status || 'Unknown'}</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  statusBadge: {
    alignSelf: 'flex-start',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 60,
    marginTop: 4,
  },
  statusText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: '600',
  },
  incomingStatus: {
    backgroundColor: '#34C759',
  },
  ongoingStatus: {
    backgroundColor: '#FF3B30',
  },
  cancelledStatus: {
    backgroundColor: '#FF9500',
  },
  defaultStatus: {
    backgroundColor: '#8E8E93',
  },
});

export default CourseStatusBadge;
