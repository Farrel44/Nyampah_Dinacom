import 'package:flutter/material.dart';
import 'package:nyampah_app/theme/colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
      if (permission == LocationPermission.denied || !mounted) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      if (!mounted) return;

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
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _searchNearbyFacilities() async {
    if (_currentPosition == null || !mounted) return;

    setState(() {
      isLoading = true;
    });

    const String apiKey = 'AIzaSyCxjdt6ro3m_2Z4TASj6sbPk8GUWQcVKtI';
    
    // Use the selectedType directly as the search keyword
    String searchKeyword = selectedType
        .replaceAll('(TPA)', '')
        .replaceAll('(TPST)', '')
        .replaceAll('(MRF)', '')
        .replaceAll('(B3)', '')
        .trim();

    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${_currentPosition!.latitude},${_currentPosition!.longitude}'
        '&radius=5000'
        '&keyword=${Uri.encodeComponent(searchKeyword)}'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (!mounted) return;

        // Parsing data lokasi dari API
        setState(() {
          _markers.clear();

          // Tambahkan marker untuk lokasi pengguna
          _markers.add(
            Marker(
              markerId: const MarkerId('current_location'),
              position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              infoWindow: const InfoWindow(title: 'Lokasi Anda'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            ),
          );

          // Tambahkan marker untuk setiap fasilitas yang ditemukan
          for (var place in data['results']) {
            _markers.add(
              Marker(
                markerId: MarkerId(place['place_id']),
                position: LatLng(
                  place['geometry']['location']['lat'],
                  place['geometry']['location']['lng'],
                ),
                infoWindow: InfoWindow(
                  title: place['name'],
                  snippet: place['vicinity'],
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              ),
            );
          }
        });
      } else {
        debugPrint('Failed to fetch nearby facilities: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error searching facilities: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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