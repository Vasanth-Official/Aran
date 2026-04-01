import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() => _currentPosition = position);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude), 15,
      ));
    }
  }

  void _addDangerZone() {
    if (_currentPosition == null) return;
    showDialog(
      context: context,
      builder: (ctx) {
        String description = '';
        return AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: const Text('Mark Danger Zone', style: TextStyle(color: Colors.white)),
          content: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: 'Describe the danger (e.g. unlit road)', hintStyle: TextStyle(color: Colors.grey)),
            onChanged: (val) => description = val,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
              onPressed: () {
                FirebaseFirestore.instance.collection('danger_zones').add({
                  'latitude': _currentPosition!.latitude,
                  'longitude': _currentPosition!.longitude,
                  'description': description,
                  'timestamp': FieldValue.serverTimestamp(),
                });
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Danger Map', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.surfaceDark,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('danger_zones').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _markers.clear();
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              _markers.add(
                Marker(
                  markerId: MarkerId(doc.id),
                  position: LatLng(data['latitude'], data['longitude']),
                  infoWindow: InfoWindow(title: 'Danger Zone', snippet: data['description']),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                ),
              );
            }
          }
          return _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  onMapCreated: (controller) => _mapController = controller,
                  markers: _markers,
                );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDangerZone,
        backgroundColor: AppColors.primaryRed,
        icon: const Icon(Icons.warning, color: Colors.white),
        label: const Text('Mark Danger', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
