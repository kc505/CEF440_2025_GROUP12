import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Get current location with permissions
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return null;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      debugPrint('Current location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  // Check if student is within geofence
  static bool isWithinGeofence({
    required double studentLat,
    required double studentLng,
    required double sessionLat,
    required double sessionLng,
    required double radiusInMeters,
  }) {
    double distance = Geolocator.distanceBetween(
      studentLat,
      studentLng,
      sessionLat,
      sessionLng,
    );

    debugPrint('Distance from session location: ${distance.toStringAsFixed(2)}m');
    debugPrint('Geofence radius: ${radiusInMeters}m');
    
    return distance <= radiusInMeters;
  }

  // Get distance between two points
  static double getDistance({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  // Request location permissions
  static Future<bool> requestLocationPermission() async {
    try {
      PermissionStatus status = await Permission.location.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }

  // Check if location permissions are granted
  static Future<bool> hasLocationPermission() async {
    try {
      PermissionStatus status = await Permission.location.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('Error checking location permission: $e');
      return false;
    }
  }

  // Get location name from coordinates (reverse geocoding)
  static Future<String> getLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.name ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}';
      }
      return 'Unknown Location';
    } catch (e) {
      debugPrint('Error getting location name: $e');
      return 'Lat: ${latitude.toStringAsFixed(4)}, Lng: ${longitude.toStringAsFixed(4)}';
    }
  }
}
