import 'package:flutter/material.dart';
import 'package:nyampah_app/theme/colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String selectedType = '(TPA) Tempat Pembuangan Akhir';
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Position? _currentPosition;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      setState(() {
        _currentPosition = position;
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: 'Lokasi Anda'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
        isLoading = false;
      });

      _searchNearbyFacilities();
    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _searchNearbyFacilities() async {
    if (_currentPosition == null) return;

    // Example facility locations - replace with real API data
    final facilities = [
      {
        'name': 'TPA Purwokerto',
        'lat': _currentPosition!.latitude + 0.01,
        'lng': _currentPosition!.longitude,
        'type': '(TPA) Tempat Pembuangan Akhir',
      },
      {
        'name': 'Bank Sampah Purwokerto',
        'lat': _currentPosition!.latitude,
        'lng': _currentPosition!.longitude + 0.01,
        'type': 'Bank Sampah',
      },
      // Add more sample facilities
    ];

    setState(() {
      _markers.clear();
      // Add current location marker
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(title: 'Lokasi Anda'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );

      // Add facility markers that match the selected type
      for (var facility in facilities) {
        if (facility['type'] == selectedType) {
          _markers.add(
            Marker(
              markerId: MarkerId(facility['name'] as String),
              position: LatLng(
                facility['lat'] as double,
                facility['lng'] as double,
              ),
              infoWindow: InfoWindow(
                title: facility['name'] as String,
                snippet: facility['type'] as String,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double paddingScale = size.width * 0.02;
    final double basePadding = paddingScale.clamp(16.0, 24.0);

    return Scaffold(
      extendBody: true,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        backgroundColor: backgroundColor,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Text(
            "Tempat Pengolahan",
            style: TextStyle(
              color: greenColor,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: size.width * 0.065,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: greenColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: basePadding * 1.5), // Add top padding here
          Padding(
            padding: EdgeInsets.fromLTRB(basePadding * 2, basePadding * 0.5, basePadding * 2, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Jenis Sampah',
                style: TextStyle(
                  color: greenColor,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * 0.04,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(basePadding * 2, basePadding * 0.5, basePadding * 2, basePadding * 2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: greenColor.withOpacity(0.5)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedType,
                  icon: const Icon(Icons.arrow_drop_down, color: greenColor),
                  style: const TextStyle(
                    color: greenColor,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                  items: [
                    '(TPA) Tempat Pembuangan Akhir',
                    '(TPST) Tempat Pemrosesan Sampah Terpadu',
                    'Bank Sampah',
                    'Pusat Daur Ulang',
                    'Tempat Pengolahan Sampah Organik',
                    'Insinerator',
                    'Material Recovery Facility (MRF)',
                    'Tempat Pengolahan Sampah B3',
                    'Pusat Pengomposan Komunal'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(fontSize: 14), // Added to ensure text fits
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedType = newValue;
                      });
                      _searchNearbyFacilities();
                    }
                  },
                ),
              ),
            ),
          ),
          // Add Google Maps
          Expanded(
            child: isLoading || _currentPosition == null
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    margin: EdgeInsets.all(basePadding),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: greenColor.withOpacity(0.5)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          zoom: 14,
                        ),
                        markers: _markers,
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: true,
                        mapToolbarEnabled: true,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}