import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GeolocScreen extends StatefulWidget {
  const GeolocScreen({super.key});

  @override
  State<GeolocScreen> createState() => _GeolocScreenState();
}

class _GeolocScreenState extends State<GeolocScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(48.8566, 2.3522),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission de localisation refusée')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Permission de localisation refusée de façon permanente')),
      );
      return;
    }

    _getCurrentLocation();
  }

  // Obtenir la position actuelle du téléphone
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service de localisation désactivé')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(_currentPosition!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte avec géolocalisation'),
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: _initialCameraPosition,
              myLocationEnabled: true,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              markers: _currentPosition != null
                  ? {
                      Marker(
                        markerId: const MarkerId('currentLocation'),
                        position: _currentPosition!,
                      )
                    }
                  : {},
            ),
    );
  }
}
