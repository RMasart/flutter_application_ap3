import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class GeolocScreen extends StatefulWidget {
  const GeolocScreen({super.key});

  @override
  State<GeolocScreen> createState() => _GeolocScreenState();
}

class _GeolocScreenState extends State<GeolocScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(48.8566, 2.3522), // Paris par défaut
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  // Demander la permission d'accéder à la géolocalisation
  Future<void> _checkLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission de localisation refusée')),
      );
    }
  }

  // Obtenir la position actuelle du téléphone
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service de localisation désactivé')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission de localisation refusée')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Permission de localisation refusée de façon permanente')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
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
        title: Text('Carte avec géolocalisation'),
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: _initialCameraPosition,
              myLocationEnabled: true,
              onMapCreated: (controller) {
                _mapController = controller;
                _getCurrentLocation();
              },
              markers: _currentPosition != null
                  ? {
                      Marker(
                        markerId: MarkerId('currentLocation'),
                        position: _currentPosition!,
                      )
                    }
                  : {},
            ),
    );
  }
}
