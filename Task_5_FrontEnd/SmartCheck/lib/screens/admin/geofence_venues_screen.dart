import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../models/geofence_venue.dart';
import 'add_geofence_venue_screen.dart';

class GeofenceVenuesScreen extends StatefulWidget {
  const GeofenceVenuesScreen({Key? key}) : super(key: key);

  @override
  State<GeofenceVenuesScreen> createState() => _GeofenceVenuesScreenState();
}

class _GeofenceVenuesScreenState extends State<GeofenceVenuesScreen> {
  List<GeofenceVenue> _venues = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVenues();
  }

  Future<void> _loadVenues() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Implement API call to fetch geofence venues
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data for demonstration
      _venues = [
        GeofenceVenue(
          id: '1',
          name: 'Main Lecture Hall',
          description: 'Primary lecture hall for large classes',
          latitude: 6.5244,
          longitude: 3.3792,
          radius: 50.0,
          isActive: true,
        ),
        GeofenceVenue(
          id: '2',
          name: 'Computer Lab A',
          description: 'Computer laboratory for programming courses',
          latitude: 6.5245,
          longitude: 3.3793,
          radius: 30.0,
          isActive: true,
        ),
        GeofenceVenue(
          id: '3',
          name: 'Library Study Room',
          description: 'Quiet study room in the library',
          latitude: 6.5243,
          longitude: 3.3791,
          radius: 25.0,
          isActive: false,
        ),
      ];
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading venues: ${e.toString()}'),
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

  Future<void> _deleteVenue(String venueId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Venue'),
        content: const Text('Are you sure you want to delete this geofence venue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // TODO: Implement API call to delete venue
        await Future.delayed(const Duration(seconds: 1));
        
        setState(() {
          _venues.removeWhere((venue) => venue.id == venueId);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Venue deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting venue: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleVenueStatus(String venueId, bool isActive) async {
    try {
      // TODO: Implement API call to toggle venue status
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        final venueIndex = _venues.indexWhere((venue) => venue.id == venueId);
        if (venueIndex != -1) {
          _venues[venueIndex] = _venues[venueIndex].copyWith(isActive: isActive);
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Venue ${isActive ? 'activated' : 'deactivated'} successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating venue: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Geofence Venues'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVenues,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Manage geofence venues for attendance verification',
                          style: AppTheme.bodyStyle.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _venues.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No geofence venues found',
                                style: AppTheme.bodyStyle.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add your first venue to get started',
                                style: AppTheme.bodyStyle.copyWith(
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _venues.length,
                          itemBuilder: (context, index) {
                            final venue = _venues[index];
                            return _buildVenueCard(venue);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<GeofenceVenue>(
            context,
            MaterialPageRoute(
              builder: (context) => const AddGeofenceVenueScreen(),
            ),
          );
          
          if (result != null) {
            setState(() {
              _venues.add(result);
            });
          }
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add_location, color: Colors.white),
        label: const Text('Add Venue', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildVenueCard(GeofenceVenue venue) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: venue.isActive 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: venue.isActive ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venue.name,
                        style: AppTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (venue.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          venue.description,
                          style: AppTheme.bodyStyle.copyWith(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Switch(
                  value: venue.isActive,
                  onChanged: (value) => _toggleVenueStatus(venue.id, value),
                  activeColor: AppTheme.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.gps_fixed, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Coordinates: ${venue.latitude.toStringAsFixed(6)}, ${venue.longitude.toStringAsFixed(6)}',
                        style: AppTheme.bodyStyle.copyWith(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.radio_button_unchecked, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Radius: ${venue.radius.toInt()}m',
                        style: AppTheme.bodyStyle.copyWith(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // TODO: Navigate to edit venue screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit venue - Coming Soon')),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deleteVenue(venue.id),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
