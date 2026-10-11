
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'live_tracking_screen.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  static const String serverUrl = 'http://10.131.101.232:5000';

  late IO.Socket socket;
  Position? currentPosition;
  Timer? timer;

  bool isSharing = false;
  int selectedBusId = 1;

  @override
  void initState() {
    super.initState();
    connectSocket();
  }

  // SOCKET CONNECTION
  void connectSocket() {
    socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .build(),
    );

    socket.onConnect((_) {
      debugPrint('Socket connected');
    });

    socket.onDisconnect((_) {
      debugPrint('Socket disconnected');
    });

    socket.onConnectError((data) {
      debugPrint('Socket connection error: $data');
    });

    socket.connect();
  }

  // LOCATION PERMISSION
  Future<bool> requestPermission() async {
    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      showMessage('Please enable GPS on your device.');
      return false;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      showMessage('Location permission is required.');
      return false;
    }

    return true;
  }

  // START SHARING LOCATION
  Future<void> startSharing() async {
    if (isSharing) return;

    final allowed = await requestPermission();
    if (!allowed || !mounted) return;

    setState(() => isSharing = true);

    // Send the first location immediately.
    await sendLocation();

    timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => sendLocation(),
    );
  }

  Future<void> sendLocation() async {
    try {
      currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!socket.connected) {
        debugPrint('Socket is not connected; location not sent.');
        return;
      }

      socket.emit('bus-location-update', {
        'busId': selectedBusId,
        'latitude': currentPosition!.latitude,
        'longitude': currentPosition!.longitude,
        'speed': currentPosition!.speed,
      });

      debugPrint('Location sent for bus $selectedBusId');
    } catch (e) {
      debugPrint('Location update error: $e');
    }
  }

  // STOP SHARING
  void stopSharing() {
    timer?.cancel();
    timer = null;

    if (socket.connected) {
      socket.emit('driver-stopped', {
        'busId': selectedBusId,
      });
    }

    if (mounted) {
      setState(() => isSharing = false);
    }
  }

  // OPEN EXISTING BUS TRACKING SCREEN
  void openBusTracking() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LiveTrackingScreen(),
      ),
    );
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    timer?.cancel();

    if (socket.connected) {
      socket.emit('driver-stopped', {
        'busId': selectedBusId,
      });
    }

    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // DRIVER CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Colors.deepPurple,
                    Colors.purple,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BusBuddy Driver',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Bus ID: $selectedBusId',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSharing
                        ? 'Live Tracking Active'
                        : 'Tracking Stopped',
                    style: TextStyle(
                      color: isSharing
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                      fontSize: 16,
                    ),
                  ),
                  if (currentPosition != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Latitude: ${currentPosition!.latitude.toStringAsFixed(5)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Longitude: ${currentPosition!.longitude.toStringAsFixed(5)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 30),

            // LOCATION ICON
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.location_on,
                size: 100,
                color: isSharing ? Colors.green : Colors.red,
              ),
            ),

            const SizedBox(height: 30),

            // BUS SELECTION
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.deepPurple),
              ),
              child: DropdownButton<int>(
                value: selectedBusId,
                isExpanded: true,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Bus 1 - Express'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('Bus 2 - City Rider'),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Text('Bus 3 - Metro Link'),
                  ),
                ],
                onChanged: isSharing
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() => selectedBusId = value);
                      },
              ),
            ),

            const SizedBox(height: 25),

            // START / STOP LOCATION SHARING
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: isSharing ? stopSharing : startSharing,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isSharing ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: Icon(
                  isSharing ? Icons.stop : Icons.play_arrow,
                ),
                label: Text(
                  isSharing ? 'Stop Sharing' : 'Start Sharing',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // NEW BUS TRACKING BUTTON
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: openBusTracking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: const Icon(Icons.location_searching),
                label: const Text(
                  'Search & Track Bus',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Driver Instructions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('• Select your bus.'),
                    Text('• Enable GPS on your device.'),
                    Text('• Tap Start Sharing to send live location.'),
                    Text('• Tap Search & Track Bus to open tracking.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
