// components/StatusCard.js
import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import StatusBadge from './StatusBadge';

const StatusCard = ({ 
  status, 
  timestamp, 
  location, 
  style,
  showLocation = true 
}) => {
  const formatTimestamp = (timestamp) => {
    if (!timestamp) return 'N/A';
    const date = new Date(timestamp);
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  };

  return (
    <View style={[styles.card, style]}>
      <Text style={styles.title}>Attendance Details</Text>
      
      <View style={styles.detailsContainer}>
        <View style={styles.detailsColumn}>
          {/* Time Row */}
          <View style={styles.detailRow}>
            <Text style={styles.label}>Time:</Text>
            <Text style={styles.value}>{formatTimestamp(timestamp)}</Text>
          </View>
          
          {/* Location Row */}
          {showLocation && location && (
            <View style={styles.detailRow}>
              <Text style={styles.label}>Location:</Text>
              <Text style={styles.value}>{location}</Text>
            </View>
          )}
        </View>
        
        {/* Status Badge positioned on the right */}
        <View style={styles.statusContainer}>
          <StatusBadge status={status} />
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 16,
    marginVertical: 8,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  title: {
    fontSize: 18,
    fontWeight: '600',
    color: '#1C1C1E',
    marginBottom: 12,
  },
  detailsContainer: {
    flexDirection: 'row',
    alignItems: 'flex-start',
  },
  detailsColumn: {
    flex: 1,
  },
  statusContainer: {
    marginLeft: 16,
    alignSelf: 'center',
  },
  detailRow: {
    flexDirection: 'row',
    marginBottom: 8,
  },
  label: {
    fontSize: 16,
    color: '#8E8E93',
    fontWeight: '500',
    width: 80, 
  },
  value: {
    fontSize: 16,
    color: '#1C1C1E',
    fontWeight: '400',
    flex: 1,
  },
});

export default StatusCard;