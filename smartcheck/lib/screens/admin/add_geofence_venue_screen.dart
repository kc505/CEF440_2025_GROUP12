import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../models/geofence_venue.dart';

class AddGeofenceVenueScreen extends StatefulWidget {
  const AddGeofenceVenueScreen({Key? key}) : super(key: key);

  @override
  State<AddGeofenceVenueScreen> createState() => _AddGeofenceVenueScreenState();
}

class _AddGeofenceVenueScreenState extends State<AddGeofenceVenueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _radiusController = TextEditingController(text: '50');
  
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(6.5244, 3.3792); // Default to Lagos
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  bool _isLoading = false;
  bool _isMapReady = false;
  bool _isLocationPermissionGranted = false;
  bool _hasMapError = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _radiusController.addListener(_updateMapMarkers);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _radiusController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      // Skip location services on web for now
      if (kIsWeb) {
        setState(() {
          _isLocationPermissionGranted = false;
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        setState(() {
          _isLocationPermissionGranted = true;
        });

        // Get current location
        try {
          _currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 10),
          );
          
          if (_currentPosition != null) {
            setState(() {
              _selectedLocation = LatLng(
                _currentPosition!.latitude, 
                _currentPosition!.longitude
              );
            });
            _updateMapMarkers();
            _animateToLocation(_selectedLocation);
          }
        } catch (e) {
          // If getting current location fails, use default location
          print('Error getting current location: $e');
        }
      } else {
        // Show dialog explaining why location permission is needed
        _showLocationPermissionDialog();
      }
    } catch (e) {
      print('Error initializing location: $e');
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'This app needs location permission to help you set geofence venues accurately. '
            'You can still manually select locations on the map.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initializeLocation();
              },
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );
  }

  void _updateMapMarkers() {
    final radius = double.tryParse(_radiusController.text) ?? 50.0;
    
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _selectedLocation,
          draggable: true,
          onDragEnd: (LatLng position) {
            setState(() {
              _selectedLocation = position;
            });
            _updateMapMarkers();
          },
          infoWindow: InfoWindow(
            title: 'Geofence Center',
            snippet: 'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}, '
                    'Lng: ${_selectedLocation.longitude.toStringAsFixed(6)}',
          ),
        ),
      };
      
      _circles = {
        Circle(
          circleId: const CircleId('geofence_radius'),
          center: _selectedLocation,
          radius: radius,
          fillColor: AppTheme.primaryColor.withOpacity(0.2),
          strokeColor: AppTheme.primaryColor,
          strokeWidth: 2,
        ),
      };
    });
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
    _updateMapMarkers();
  }

  void _onMapCreated(GoogleMapController controller) {
    try {
      _mapController = controller;
      setState(() {
        _isMapReady = true;
        _hasMapError = false;
      });
      _updateMapMarkers();
    } catch (e) {
      print('Error creating map: $e');
      setState(() {
        _hasMapError = true;
      });
    }
  }

  void _animateToLocation(LatLng location) {
    if (_mapController != null && _isMapReady) {
      try {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: location,
              zoom: 16.0,
            ),
          ),
        );
      } catch (e) {
        print('Error animating camera: $e');
      }
    }
  }

  void _getCurrentLocation() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services not available on web. Please select location manually.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_isLocationPermissionGranted) {
      _showLocationPermissionDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      LatLng newLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedLocation = newLocation;
        _currentPosition = position;
      });
      
      _updateMapMarkers();
      _animateToLocation(newLocation);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location updated to current position'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchLocation() {
    // TODO: Implement location search functionality
    // This could integrate with Google Places API for location search
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Location'),
        content: const Text('Location search feature will be implemented with Google Places API.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleSaveVenue() {
    _saveVenue();
  }

  Future<void> _saveVenue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Implement API call to save geofence venue
      await Future.delayed(const Duration(seconds: 2));
      
      final venue = GeofenceVenue(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
        radius: double.parse(_radiusController.text),
        isActive: true,
      );

      if (mounted) {
        Navigator.of(context).pop(venue);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geofence venue created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating venue: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildMapWidget() {
    if (_hasMapError) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.map_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Map not available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please configure Google Maps API key',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasMapError = false;
                  });
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _selectedLocation,
        zoom: 16,
      ),
      markers: _markers,
      circles: _circles,
      onTap: _onMapTap,
      myLocationEnabled: _isLocationPermissionGranted && !kIsWeb,
      myLocationButtonEnabled: false, // We have custom button
      mapToolbarEnabled: false,
      zoomControlsEnabled: true,
      compassEnabled: true,
      mapType: MapType.normal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Add Geofence Venue'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _searchLocation,
            tooltip: 'Search Location',
          ),
          if (!kIsWeb)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _getCurrentLocation,
              tooltip: 'Current Location',
            ),
        ],
      ),
      body: Column(
        children: [
          // Enhanced Map Section
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    _buildMapWidget(),
                    // Map overlay with instructions
                    if (!_hasMapError)
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Tap on map or drag marker to set venue location',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Loading indicator
                    if (_isLoading)
                      Container(
                        color: Colors.black.withOpacity(0.3),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Form Section
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Venue Details',
                      style: AppTheme.headingStyle.copyWith(
                        fontSize: 18,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    CustomTextField(
                      controller: _nameController,
                      label: 'Venue Name',
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter venue name';
                        }
                        if (value!.length < 3) {
                          return 'Venue name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    
                    CustomTextField(
                      controller: _radiusController,
                      label: 'Geofence Radius (meters)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter radius';
                        }
                        final radius = double.tryParse(value!);
                        if (radius == null || radius <= 0) {
                          return 'Please enter a valid radius';
                        }
                        if (radius < 10) {
                          return 'Radius must be at least 10 meters';
                        }
                        if (radius > 1000) {
                          return 'Radius cannot exceed 1000 meters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Enhanced Location Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.1),
                            AppTheme.primaryColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.gps_fixed,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Selected Location',
                                style: AppTheme.bodyStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Latitude',
                                      style: AppTheme.bodyStyle.copyWith(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      _selectedLocation.latitude.toStringAsFixed(6),
                                      style: AppTheme.bodyStyle.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Longitude',
                                      style: AppTheme.bodyStyle.copyWith(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      _selectedLocation.longitude.toStringAsFixed(6),
                                      style: AppTheme.bodyStyle.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Radius: ${_radiusController.text} meters',
                            style: AppTheme.bodyStyle.copyWith(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    CustomButton(
                      text: 'Create Venue',
                      onPressed: _handleSaveVenue,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
