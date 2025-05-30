import React from 'react';
import { View, Text, StyleSheet, Image } from 'react-native';
import CourseStatusBadge from './CourseStatus'; 

const CourseProfile = ({ 
  CourseName, 
  CourseId, 
  department, 
  style,
  status,
  profileImage, 
  showDetails = true 
}) => {
  const defaultImage = '../splash-icon.png';

  return (
    <View style={[styles.container, style]}>
      <View style={styles.profileSection}>
        <View style={styles.imageContainer}>
          <Image
            source={{ uri: profileImage || defaultImage }}
            style={styles.profileImage}
            defaultSource={{ uri: defaultImage }}
          />
        </View>
        
        <View style={styles.infoContainer}>
          <View style={styles.nameIdContainer}>
            <Text style={styles.CourseId}> {CourseId || 'N/A'}</Text>
            <Text style={styles.CourseName}>{CourseName || 'Unknown User'}</Text>
          </View>
          <CourseStatusBadge status={status} /> 
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
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
  profileSection: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  imageContainer: {
    marginRight: 16,
  },
  profileImage: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: '#F2F2F7',
  },
  infoContainer: {
    flex: 1,
  },
  nameIdContainer: {
    marginBottom: 8,
  },
  CourseName: {
    fontSize: 18,
    fontWeight: '600',
    color: '#1C1C1E',
  },
  CourseId: {
    fontSize: 16,
    color: '#8E8E93',
    marginBottom: 4,
  },
  department: {
    fontSize: 16,
    color: '#007AFF',
    fontWeight: '500',
  },
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

export default CourseProfile;
