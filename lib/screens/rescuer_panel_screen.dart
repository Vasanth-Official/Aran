import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils/constants.dart';

class RescuerPanelScreen extends StatefulWidget {
  final String victimId;

  const RescuerPanelScreen({super.key, required this.victimId});

  @override
  State<RescuerPanelScreen> createState() => _RescuerPanelScreenState();
}

class _RescuerPanelScreenState extends State<RescuerPanelScreen> {
  GoogleMapController? _mapController;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  LatLng? _victimLocation;
  String _status = 'UNKNOWN';
  bool _isRemoteSirenActive = false;

  @override
  void initState() {
    super.initState();
    _listenToVictim();
  }

  void _listenToVictim() {
    _dbRef.child('alerts').child(widget.victimId).onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null && mounted) {
        setState(() {
          _victimLocation = LatLng(data['latitude'], data['longitude']);
          _status = data['status'];
          _isRemoteSirenActive = data['remote_siren'] == true;
        });

        if (_victimLocation != null) {
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(_victimLocation!, 17),
          );
        }
      }
    });
  }

  void _toggleRemoteSiren() {
    _dbRef.child('alerts').child(widget.victimId).update({
      'remote_siren': !_isRemoteSirenActive,
    });
  }

  void _markResolved() {
    _dbRef.child('alerts').child(widget.victimId).update({
      'status': 'RESOLVED',
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Active Rescue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          _victimLocation == null
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryRed))
              : GoogleMap(
                  myLocationEnabled: true,
                  compassEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target: _victimLocation!,
                    zoom: 17,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _mapController?.setMapStyle(
                        '[{"elementType":"geometry","stylers":[{"color":"#242f3e"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#746855"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#242f3e"}]},{"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#263c3f"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#6b9a76"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#38414e"}]},{"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#212a37"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#9ca5b3"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#746855"}]},{"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#1f2835"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#f3d19c"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#17263c"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#515c6d"}]},{"featureType":"water","elementType":"labels.text.stroke","stylers":[{"color":"#17263c"}]}]');
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('victim'),
                      position: _victimLocation!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                      infoWindow: const InfoWindow(title: 'Victim Location'),
                    )
                  },
                ),
          
          // Control Panel Overlay
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, spreadRadius: 5),
                ],
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _status == 'ACTIVE' ? AppColors.primaryRed.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _status == 'ACTIVE' ? Icons.warning_amber_rounded : Icons.check_circle,
                            color: _status == 'ACTIVE' ? AppColors.primaryRed : Colors.green,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Status: $_status', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              const Text('Live Tracking Active', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isRemoteSirenActive ? Colors.redAccent : AppColors.surfaceDark,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: _isRemoteSirenActive ? Colors.transparent : Colors.white.withOpacity(0.2)),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _toggleRemoteSiren,
                            icon: Icon(_isRemoteSirenActive ? Icons.notifications_active : Icons.notifications_off),
                            label: Text(_isRemoteSirenActive ? 'Siren ON' : 'Remote Siren', style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _markResolved,
                            icon: const Icon(Icons.check),
                            label: const Text('Mark Safe', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    )
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
