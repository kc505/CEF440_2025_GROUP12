import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Alert,
  ActivityIndicator,
  Dimensions,
  StatusBar,
  Platform,
} from 'react-native';
import MapView, { Marker, Circle } from 'react-native-maps';
import Geolocation from '@react-native-community/geolocation';
import Icon from 'react-native-vector-icons/MaterialIcons';

const { width, height } = Dimensions.get('window');

const GeofenceAttendancePage = ({ navigation, route }) => {
  const [userLocation, setUserLocation] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [locationVerified, setLocationVerified] = useState(null);
  const [isCheckingLocation, setIsCheckingLocation] = useState(false);

  // Office location (you can make this dynamic from props/API)
  const officeLocation = {
    latitude: route?.params?.officeLatitude || 4.1536,
    longitude: route?.params?.officeLongitude || 9.2667,
    address: route?.params?.officeAddress || "University of Buea, Buea, Southwest Region, Cameroon",
  };

  const geofenceRadius = route?.params?.radius || 100; // meters

  useEffect(() => {
    getCurrentLocation();
  }, []);

  const getCurrentLocation = () => {
    setIsLoading(true);

    Geolocation.getCurrentPosition(
      (position) => {
        const { latitude, longitude } = position.coords;
        setUserLocation({ latitude, longitude });
        checkGeofence(latitude, longitude);
        setIsLoading(false);
      },
      (error) => {
        console.log('Location error:', error);
        setIsLoading(false);
        setLocationVerified(false);
        Alert.alert(
          'Location Error',
          'Unable to get your current location. Please check your GPS settings and try again.',
          [{ text: 'OK' }]
        );
      },
      {
        enableHighAccuracy: true,
        timeout: 15000,
        maximumAge: 10000,
      }
    );
  };

  const calculateDistance = (lat1, lon1, lat2, lon2) => {
    const R = 6371e3; // Earth's radius in meters
    const φ1 = (lat1 * Math.PI) / 180;
    const φ2 = (lat2 * Math.PI) / 180;
    const Δφ = ((lat2 - lat1) * Math.PI) / 180;
    const Δλ = ((lon2 - lon1) * Math.PI) / 180;

    const a =
      Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
      Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c; // Distance in meters
  };

  const checkGeofence = (userLat, userLon) => {
    const distance = calculateDistance(
      userLat,
      userLon,
      officeLocation.latitude,
      officeLocation.longitude
    );

    setLocationVerified(distance <= geofenceRadius);
  };

  const handleCheckIn = async () => {
    if (!userLocation) {
      Alert.alert('Error', 'Location not available. Please try again.');
      return;
    }

    setIsCheckingLocation(true);

    // Simulate API call delay
    setTimeout(() => {
      setIsCheckingLocation(false);

      if (locationVerified) {
        // Successful check-in
        Alert.alert(
          'Check-in Successful!',
          'Your attendance has been recorded successfully.',
          [
            {
              text: 'OK',
              onPress: () => navigation.goBack(),
            },
          ]
        );
      } else {
        // Failed check-in
        Alert.alert(
          'Check-in Failed',
          'You are not within the allowed location range. Please move closer to the office location.',
          [{ text: 'OK' }]
        );
      }
    }, 2000);
  };

  const refreshLocation = () => {
    getCurrentLocation();
  };

  if (isLoading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#4CAF50" />
        <Text style={styles.loadingText}>Getting your location...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor="#fff" />

      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Icon name="arrow-back" size={24} color="#333" />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Location Verification</Text>
      </View>

      {/* Status Indicator */}
      <View style={styles.statusContainer}>
        <View style={[
          styles.statusIcon,
          { backgroundColor: locationVerified ? '#4CAF50' : '#FF5722' }
        ]}>
          <Icon
            name={locationVerified ? "check" : "close"}
            size={32}
            color="white"
          />
        </View>
        <Text style={[
          styles.statusText,
          { color: locationVerified ? '#4CAF50' : '#FF5722' }
        ]}>
          {locationVerified ? 'Location Verified' : 'Location Not Verified'}
        </Text>
        {!locationVerified && (
          <Text style={styles.statusSubtext}>
            You are outside the allowed area
          </Text>
        )}
      </View>

      {/* Map */}
      <View style={styles.mapContainer}>
        {userLocation && (
          <MapView
            style={styles.map}
            initialRegion={{
              latitude: officeLocation.latitude,
              longitude: officeLocation.longitude,
              latitudeDelta: 0.005,
              longitudeDelta: 0.005,
            }}
            showsUserLocation={true}
            showsMyLocationButton={false}
          >
            {/* Office Location Marker */}
            <Marker
              coordinate={officeLocation}
              title="Office Location"
              description={officeLocation.address}
              pinColor="#FF5722"
            />

            {/* Geofence Circle */}
            <Circle
              center={officeLocation}
              radius={geofenceRadius}
              strokeColor="rgba(76, 175, 80, 0.5)"
              fillColor="rgba(76, 175, 80, 0.2)"
              strokeWidth={2}
            />

            {/* User Location Marker */}
            <Marker
              coordinate={userLocation}
              title="Your Location"
              pinColor="#2196F3"
            />
          </MapView>
        )}
      </View>

      {/* Location Info */}
      <View style={styles.infoContainer}>
        <View style={styles.infoRow}>
          <Icon name="location-on" size={20} color="#666" />
          <Text style={styles.infoText}>{officeLocation.address}</Text>
        </View>
        <View style={styles.infoRow}>
          <Icon name="radio-button-unchecked" size={20} color="#666" />
          <Text style={styles.infoText}>
            Allowed range: {geofenceRadius} meters
          </Text>
        </View>
      </View>

      {/* Action Buttons */}
      <View style={styles.buttonContainer}>
        <TouchableOpacity
          style={styles.refreshButton}
          onPress={refreshLocation}
          disabled={isCheckingLocation}
        >
          <Icon name="refresh" size={20} color="#2196F3" />
          <Text style={styles.refreshButtonText}>Refresh Location</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[
            styles.checkInButton,
            {
              backgroundColor: locationVerified ? '#4CAF50' : '#FF5722',
              opacity: isCheckingLocation ? 0.7 : 1
            }
          ]}
          onPress={handleCheckIn}
          disabled={isCheckingLocation}
        >
          {isCheckingLocation ? (
            <ActivityIndicator size="small" color="white" />
          ) : (
            <>
              <Icon name="access-time" size={20} color="white" />
              <Text style={styles.checkInButtonText}>
                {locationVerified ? 'Check In' : 'Check In (Out of Range)'}
              </Text>
            </>
          )}
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f5f5f5',
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
    color: '#666',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'white',
    paddingHorizontal: 16,
    paddingVertical: 12,
    paddingTop: Platform.OS === 'ios' ? 44 : 12,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  backButton: {
    padding: 8,
    marginRight: 8,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#333',
  },
  statusContainer: {
    alignItems: 'center',
    backgroundColor: 'white',
    paddingVertical: 24,
    marginBottom: 16,
  },
  statusIcon: {
    width: 64,
    height: 64,
    borderRadius: 32,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  statusText: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 4,
  },
  statusSubtext: {
    fontSize: 14,
    color: '#666',
  },
  mapContainer: {
    height: height * 0.4,
    margin: 16,
    borderRadius: 12,
    overflow: 'hidden',
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 4,
  },
  map: {
    flex: 1,
  },
  infoContainer: {
    backgroundColor: 'white',
    margin: 16,
    padding: 16,
    borderRadius: 12,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.15,
    shadowRadius: 2,
  },
  infoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  infoText: {
    marginLeft: 12,
    fontSize: 14,
    color: '#333',
    flex: 1,
  },
  buttonContainer: {
    padding: 16,
    paddingBottom: Platform.OS === 'ios' ? 32 : 16,
  },
  refreshButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'white',
    paddingVertical: 12,
    borderRadius: 8,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: '#2196F3',
  },
  refreshButtonText: {
    marginLeft: 8,
    fontSize: 16,
    color: '#2196F3',
    fontWeight: '500',
  },
  checkInButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 16,
    borderRadius: 8,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 4,
  },
  checkInButtonText: {
    marginLeft: 8,
    fontSize: 16,
    color: 'white',
    fontWeight: '600',
  },
});

export default GeofenceAttendancePage;