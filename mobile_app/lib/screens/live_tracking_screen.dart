import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final String baseUrl = 'http://10.131.101.232:5000';
  final TextEditingController searchController = TextEditingController();

  bool loading = true;
  String? errorMessage;

  List<dynamic> locations = [];
  List<dynamic> filteredLocations = [];
  dynamic selectedBus;

  GoogleMapController? mapController;
  Timer? refreshTimer;

  static const LatLng defaultLocation = LatLng(12.9716, 77.5946);

  @override
  void initState() {
    super.initState();
    fetchLocations();

    refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchLocations();
    });
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    mapController?.dispose();
    searchController.dispose();
    super.dispose();
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  LatLng? _positionFor(dynamic bus) {
    if (bus is! Map) return null;
    final latitude = _toDouble(bus['latitude']);
    final longitude = _toDouble(bus['longitude']);
    if (latitude == null || longitude == null) return null;
    if (latitude < -90 || latitude > 90 ||
        longitude < -180 || longitude > 180) {
      return null;
    }
    return LatLng(latitude, longitude);
  }

  String _busId(dynamic bus) => (bus is Map ? bus['bus_id'] : null).toString();

  Future<void> fetchLocations() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/location'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        if (!mounted) return;
        setState(() {
          loading = false;
          errorMessage =
              'Could not load bus locations (HTTP ${response.statusCode}).';
        });
        return;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const FormatException(
          'The location API response is not a list.',
        );
      }

      if (!mounted) return;

      final newLocations = decoded.whereType<Map>().toList();

      setState(() {
        locations = newLocations;
        final query = searchController.text.trim().toLowerCase();
        filteredLocations = _filterLocations(query);
        errorMessage = null;
        loading = false;

        if (selectedBus != null) {
          final selectedId = _busId(selectedBus);
          final matches = locations.where((bus) => _busId(bus) == selectedId);
          selectedBus = matches.isNotEmpty ? matches.first : null;
        }
      });
    } catch (e) {
      debugPrint('Location Error: $e');
      if (!mounted) return;
      setState(() {
        loading = false;
        errorMessage = 'Unable to connect to the location server.';
      });
    }
  }

  List<dynamic> _filterLocations(String query) {
    if (query.isEmpty) return List<dynamic>.from(locations);

    return locations.where((bus) {
      final id = (bus['bus_id'] ?? '').toString().toLowerCase();
      final name = (bus['bus_name'] ?? '').toString().toLowerCase();
      final number = (bus['bus_number'] ?? '').toString().toLowerCase();
      return id.contains(query) ||
          name.contains(query) ||
          number.contains(query);
    }).toList();
  }

  void searchBus(String value) {
    setState(() {
      filteredLocations = _filterLocations(value.trim().toLowerCase());
    });
  }

  Future<void> selectBus(dynamic bus, {bool zoom = true}) async {
    final position = _positionFor(bus);
    setState(() {
      selectedBus = bus;
    });

    if (zoom && position != null && mapController != null) {
      try {
        await mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: position, zoom: 16),
          ),
        );
      } catch (e) {
        debugPrint('Could not move map to selected bus: $e');
      }
    }
  }

  Set<Marker> buildMarkers() {
    final markers = <Marker>{};

    for (final bus in filteredLocations) {
      final position = _positionFor(bus);
      if (position == null) continue;

      final id = _busId(bus);
      final isSelected =
          selectedBus != null && _busId(selectedBus) == id;

      markers.add(
        Marker(
          markerId: MarkerId(id),
          position: position,
          icon: isSelected
              ? BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure,
                )
              : BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
          infoWindow: InfoWindow(
            title: (bus['bus_name'] ?? 'Bus $id').toString(),
            snippet:
                'Bus No: ${bus['bus_number'] ?? 'N/A'} | Speed: ${bus['speed'] ?? 0} km/h',
          ),
          onTap: () => selectBus(bus),
        ),
      );
    }

    return markers;
  }

  Widget statCard(String title, String value) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C3DF4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget selectedBusDetails() {
    final bus = selectedBus;
    if (bus == null) return const SizedBox.shrink();

    final position = _positionFor(bus);
    final speed = _toDouble(bus['speed']) ?? 0;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(top: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.directions_bus,
                  color: Color(0xFF6C3DF4),
                  size: 30,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    (bus['bus_name'] ?? 'Selected Bus').toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Show this bus on map',
                  onPressed: () => selectBus(bus),
                  icon: const Icon(Icons.my_location),
                ),
              ],
            ),
            Text('Bus ID: ${bus['bus_id'] ?? 'N/A'}'),
            Text('Bus No: ${bus['bus_number'] ?? 'N/A'}'),
            Text('Speed: ${speed.toStringAsFixed(2)} km/h'),
            const SizedBox(height: 6),
            if (position != null)
              Text(
                'Latitude: ${position.latitude.toStringAsFixed(6)}\n'
                'Longitude: ${position.longitude.toStringAsFixed(6)}',
                style: const TextStyle(color: Colors.black54),
              )
            else
              const Text(
                'This bus has not shared a valid GPS location yet.',
                style: TextStyle(color: Colors.deepOrange),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final running = locations.where((bus) {
      return (_toDouble(bus['speed']) ?? 0) > 0;
    }).length;

    final stopped = locations.length - running;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C3DF4),
        foregroundColor: Colors.white,
        title: const Text('Live Tracking'),
        actions: [
          IconButton(
            tooltip: 'Refresh locations',
            onPressed: fetchLocations,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchLocations,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (errorMessage != null) ...[
                      Card(
                        color: Colors.orange.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber,
                                  color: Colors.deepOrange),
                              const SizedBox(width: 8),
                              Expanded(child: Text(errorMessage!)),
                              TextButton(
                                onPressed: fetchLocations,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      children: [
                        statCard('Total', locations.length.toString()),
                        const SizedBox(width: 8),
                        statCard('Running', running.toString()),
                        const SizedBox(width: 8),
                        statCard('Stopped', stopped.toString()),
                      ],
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: searchController,
                      onChanged: searchBus,
                      decoration: InputDecoration(
                        hintText: 'Search bus name or bus number',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchController.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  searchController.clear();
                                  searchBus('');
                                },
                                icon: const Icon(Icons.clear),
                              ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 350,
                      child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                          target: _positionFor(selectedBus) ??
                              (locations.isNotEmpty
                                  ? _positionFor(locations.first) ??
                                      defaultLocation
                                  : defaultLocation),
                          zoom: selectedBus == null ? 5 : 16,
                        ),
                        markers: buildMarkers(),
                        zoomControlsEnabled: true,
                        myLocationButtonEnabled: false,
                        onMapCreated: (controller) {
                          mapController = controller;
                          final position = _positionFor(selectedBus);
                          if (position != null) {
                            controller.animateCamera(
                              CameraUpdate.newLatLngZoom(position, 16),
                            );
                          }
                        },
                      ),
                    ),
                    selectedBusDetails(),
                    const SizedBox(height: 14),
                    if (filteredLocations.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No buses found. Check the search or refresh locations.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredLocations.length,
                        itemBuilder: (context, index) {
                          final bus = filteredLocations[index];
                          final id = _busId(bus);
                          final isSelected = selectedBus != null &&
                              _busId(selectedBus) == id;
                          final position = _positionFor(bus);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            color: isSelected
                                ? const Color(0xFFEDE5FF)
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF6C3DF4)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: ListTile(
                              onTap: () => selectBus(bus),
                              leading: const Icon(
                                Icons.directions_bus,
                                color: Color(0xFF6C3DF4),
                              ),
                              title: Text(
                                (bus['bus_name'] ?? 'Bus $id').toString(),
                              ),
                              subtitle: Text(
                                'Bus No: ${bus['bus_number'] ?? 'N/A'}\n'
                                'Speed: ${(_toDouble(bus['speed']) ?? 0).toStringAsFixed(2)} km/h'
                                '${position == null ? '\nGPS location unavailable' : ''}',
                              ),
                              isThreeLine: true,
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('ID $id'),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF6C3DF4),
                                      size: 18,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
