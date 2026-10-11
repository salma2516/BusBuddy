

import 'dart:async';

import 'dart:convert';



import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:dropdown_search/dropdown_search.dart';



import '../models/district_model.dart';

import '../models/stop_model.dart';

import 'digital_ticket_screen.dart';
import 'live_tracking_screen.dart';



class ConductorDashboard extends StatefulWidget {

  const ConductorDashboard({super.key});



  @override

  State<ConductorDashboard> createState() =>

      _ConductorDashboardState();

}



class _ConductorDashboardState extends State<ConductorDashboard> {

  // Use your computer's current Wi-Fi IPv4 address.

  // For an Android emulator, use http://10.0.2.2:5000 instead.

  static const String baseUrl = 'http://10.131.101.232:5000';



  // Change this to the bus ID that exists in your database.

  final int busId = 1;



  final TextEditingController seatsController = TextEditingController();
  final TextEditingController passengerIdController = TextEditingController();
  final TextEditingController fareController = TextEditingController();



  bool isLoading = false;

  bool isLoadingDistricts = false;

  bool isLoadingStops = false;

  bool isLoadingSeats = false;



  int availableSeats = 50;



  List<DistrictModel> districts = [];

  DistrictModel? selectedDistrict;



  List<StopModel> stops = [];

  StopModel? fromStop;

  StopModel? toStop;



  @override

  void initState() {

    super.initState();

    fetchDistricts();

    fetchBusSeats();

  }



  // Safely display backend messages.

  String responseMessage(dynamic data, String fallback) {

    if (data is Map) {

      final message = data['message'] ?? data['error'];

      if (message != null && message.toString().isNotEmpty) {

        return message.toString();

      }

    }

    return fallback;

  }



  void showMessage(String message, {bool isError = false}) {

    if (!mounted) return;



    ScaffoldMessenger.of(context)

      ..hideCurrentSnackBar()

      ..showSnackBar(

        SnackBar(

          content: Text(message),

          backgroundColor: isError ? Colors.red.shade700 : null,

          behavior: SnackBarBehavior.floating,

        ),

      );

  }



  // =========================

  // FETCH DISTRICTS

  // =========================

  Future<void> fetchDistricts() async {

    if (mounted) {

      setState(() => isLoadingDistricts = true);

    }



    try {

      final response = await http

          .get(Uri.parse('$baseUrl/api/districts'))

          .timeout(const Duration(seconds: 15));



      debugPrint('DISTRICTS STATUS: ${response.statusCode}');

      debugPrint('DISTRICTS BODY: ${response.body}');



      final dynamic decoded = jsonDecode(response.body);



      if (response.statusCode < 200 ||

          response.statusCode >= 300 ||

          decoded is! Map ||

          decoded['success'] != true) {

        throw Exception(

          responseMessage(decoded, 'Could not load districts'),

        );

      }



      final dynamic rows = decoded['data'] ?? decoded['districts'];



      if (rows is! List) {

        throw Exception('District data was not returned as a list');

      }



      final loadedDistricts = rows

          .whereType<Map>()

          .map(

            (row) => DistrictModel.fromJson(

              Map<String, dynamic>.from(row),

            ),

          )

          .toList();



      if (!mounted) return;



      setState(() {

        districts = loadedDistricts;

      });



      if (loadedDistricts.isEmpty) {

        showMessage('No districts found.');

      }

    } catch (e) {

      debugPrint('FETCH DISTRICTS ERROR: $e');

      showMessage('Unable to load districts: $e', isError: true);

    } finally {

      if (mounted) {

        setState(() => isLoadingDistricts = false);

      }

    }

  }



  // =========================

  // FETCH STOPS FOR DISTRICT

  // =========================

  Future<void> fetchStops(int districtId) async {

    setState(() {

      isLoadingStops = true;

      stops = [];

      fromStop = null;

      toStop = null;

    });



    try {

      final response = await http

          .get(Uri.parse('$baseUrl/api/stops/$districtId'))

          .timeout(const Duration(seconds: 15));



      debugPrint('STOPS STATUS: ${response.statusCode}');

      debugPrint('STOPS BODY: ${response.body}');



      final dynamic decoded = jsonDecode(response.body);



      if (response.statusCode < 200 ||

          response.statusCode >= 300 ||

          decoded is! Map ||

          decoded['success'] != true) {

        throw Exception(

          responseMessage(decoded, 'Could not load stops'),

        );

      }



      final dynamic rows = decoded['stops'] ?? decoded['data'];



      if (rows is! List) {

        throw Exception('Stop data was not returned as a list');

      }



      final loadedStops = rows

          .whereType<Map>()

          .map(

            (row) => StopModel.fromJson(

              Map<String, dynamic>.from(row),

            ),

          )

          .toList();



      if (!mounted) return;



      setState(() {

        stops = loadedStops;

      });



      if (loadedStops.isEmpty) {

        showMessage('No stops found for this district.');

      }

    } catch (e) {

      debugPrint('FETCH STOPS ERROR: $e');

      showMessage('Unable to load stops: $e', isError: true);

    } finally {

      if (mounted) {

        setState(() => isLoadingStops = false);

      }

    }

  }



  // =========================

  // FETCH AVAILABLE SEATS

  // =========================

  Future<void> fetchBusSeats() async {

    if (mounted) {

      setState(() => isLoadingSeats = true);

    }



    try {

      final response = await http

          .get(Uri.parse('$baseUrl/api/tickets/bus/$busId'))

          .timeout(const Duration(seconds: 15));



      debugPrint('BUS SEATS STATUS: ${response.statusCode}');

      debugPrint('BUS SEATS BODY: ${response.body}');



      final dynamic decoded = jsonDecode(response.body);



      if (response.statusCode >= 200 &&

          response.statusCode < 300 &&

          decoded is Map &&

          decoded['success'] == true) {

        final dynamic bus = decoded['bus'];



        if (bus is Map && bus['available_seats'] != null) {

          final int? seats =

              int.tryParse(bus['available_seats'].toString());



          if (seats != null && mounted) {

            setState(() => availableSeats = seats);

          }

        }

      } else {

        debugPrint(

          responseMessage(decoded, 'Could not refresh bus seats'),

        );

      }

    } catch (e) {

      debugPrint('FETCH BUS SEATS ERROR: $e');

      // Keep the screen usable if this optional endpoint fails.

    } finally {

      if (mounted) {

        setState(() => isLoadingSeats = false);

      }

    }

  }



  // =========================

  // ISSUE TICKET

  // =========================

  Future<void> issueTicket() async {

    if (selectedDistrict == null) {

      showMessage('Please select a district.', isError: true);

      return;

    }



    if (fromStop == null || toStop == null) {

      showMessage('Please select both From Stop and To Stop.',

          isError: true);

      return;

    }



    if (fromStop!.id == toStop!.id) {

      showMessage('From Stop and To Stop cannot be the same.',

          isError: true);

      return;

    }



    final int? seatCount =

        int.tryParse(seatsController.text.trim());



    if (seatCount == null || seatCount < 1) {

      showMessage('Enter a valid number of seats.',

          isError: true);

      return;

    }



    final int? passengerId = int.tryParse(passengerIdController.text.trim());
    final double? farePerSeat = double.tryParse(fareController.text.trim());

    if (passengerId == null || passengerId < 1) {
      showMessage('Enter a valid passenger ID from your database.', isError: true);
      return;
    }

    if (farePerSeat == null || farePerSeat <= 0) {
      showMessage('Enter a valid fare per seat.', isError: true);
      return;
    }

    if (seatCount > availableSeats) {

      showMessage(

        'Only $availableSeats seats are available.',

        isError: true,

      );

      return;

    }



    setState(() => isLoading = true);



    try {

      final double totalAmount = farePerSeat * seatCount;
      final payload = <String, dynamic>{
        'passenger_id': passengerId,
        'bus_id': busId,
        'source_stop': fromStop!.stopName,
        'destination_stop': toStop!.stopName,
        'fare': totalAmount,
        'payment_status': 'PAID',
        'from_stop': fromStop!.stopName,
        'to_stop': toStop!.stopName,
        'seats': seatCount,
        'amount': totalAmount,
        'status': 'ACTIVE',
      };



      debugPrint('ISSUE TICKET PAYLOAD: ${jsonEncode(payload)}');



      final response = await http

          .post(

            Uri.parse('$baseUrl/api/tickets/add'),

            headers: const {

              'Content-Type': 'application/json',

              'Accept': 'application/json',

            },

            body: jsonEncode(payload),

          )

          .timeout(const Duration(seconds: 20));



      debugPrint('ISSUE TICKET STATUS: ${response.statusCode}');

      debugPrint('ISSUE TICKET BODY: ${response.body}');



      dynamic decoded;



      try {

        decoded = jsonDecode(response.body);

      } catch (_) {

        throw Exception(

          'The server returned an invalid response '

          '(HTTP ${response.statusCode}).',

        );

      }



      if (response.statusCode < 200 ||

          response.statusCode >= 300 ||

          decoded is! Map ||

          decoded['success'] != true) {

        throw Exception(

          responseMessage(

            decoded,

            'Ticket issuance failed (HTTP ${response.statusCode}).',

          ),

        );

      }



      final dynamic ticketIdValue =

          decoded['ticket_id'] ??

          decoded['ticketId'] ??

          decoded['id'] ??

          decoded['ticket']?['ticket_id'] ??

          decoded['ticket']?['id'];



      final String ticketId =

          ticketIdValue?.toString() ??

          'BB-${DateTime.now().millisecondsSinceEpoch}';



      // The current backend returns ticketId but may not return amount.
      // Use the calculated total as a fallback so the digital ticket
      // does not incorrectly display ₹0.00.
      final dynamic amountValue =
          decoded['total_amount'] ??
          decoded['amount'] ??
          decoded['fare'] ??
          decoded['ticket']?['total_amount'] ??
          decoded['ticket']?['amount'];

      final double amount =
          double.tryParse(amountValue?.toString() ?? '') ?? totalAmount;



      final String issuedFrom = fromStop!.stopName;

      final String issuedTo = toStop!.stopName;



      // Refresh seats before leaving this screen.

      await fetchBusSeats();



      if (!mounted) return;



      seatsController.clear();



      showMessage('Ticket issued successfully.');



      await Navigator.push(

        context,

        MaterialPageRoute<void>(

          builder: (_) => DigitalTicketScreen(

            ticketId: ticketId,

            fromStop: issuedFrom,

            toStop: issuedTo,

            seats: seatCount,

            amount: amount,

            status: 'ACTIVE',

            busName: 'BusBuddy Express',

          ),

        ),

      );

    } on TimeoutException {

      showMessage(

        'Request timed out. Check your network and backend server.',

        isError: true,

      );

    } catch (e) {

      debugPrint('ISSUE TICKET ERROR: $e');

      showMessage(

        'Ticket not issued: ${e.toString().replaceFirst('Exception: ', '')}',

        isError: true,

      );

    } finally {

      if (mounted) {

        setState(() => isLoading = false);

      }

    }

  }
  // Open live tracking so the conductor can view bus locations.
  void openLiveTracking() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const LiveTrackingScreen(),
      ),
    );
  }




  @override

  void dispose() {

    seatsController.dispose();
    passengerIdController.dispose();
    fareController.dispose();
    super.dispose();

  }



  // =========================

  // UI

  // =========================

  @override

  Widget build(BuildContext context) {

    final Color purple = Colors.deepPurple;



    return Scaffold(

      backgroundColor: const Color(0xFFFFFAFF),

      appBar: AppBar(

        title: const Text(

          'Conductor Dashboard',

          style: TextStyle(color: Colors.white),

        ),

        backgroundColor: purple,

        foregroundColor: Colors.white,

      ),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [

              Card(

                elevation: 5,

                shape: RoundedRectangleBorder(

                  borderRadius: BorderRadius.circular(22),

                ),

                child: Padding(

                  padding: const EdgeInsets.all(24),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      const Text(

                        'BusBuddy Express',

                        style: TextStyle(

                          fontSize: 25,

                          fontWeight: FontWeight.bold,

                        ),

                      ),

                      const SizedBox(height: 14),

                      Text(

                        'Available Seats: '

                        '${isLoadingSeats ? 'Refreshing...' : availableSeats}',

                        style: const TextStyle(fontSize: 18),

                      ),

                      const SizedBox(height: 6),

                      Text('Bus ID: $busId'),

                      if (availableSeats == 0)

                        const Padding(

                          padding: EdgeInsets.only(top: 8),

                          child: Text(

                            'BUS FULL',

                            style: TextStyle(

                              color: Colors.red,

                              fontWeight: FontWeight.bold,

                            ),

                          ),

                        ),

                    ],

                  ),

                ),

              ),



              const SizedBox(height: 28),



              // District dropdown

              if (isLoadingDistricts)

                const LinearProgressIndicator(),



              DropdownSearch<DistrictModel>(

                items: (filter, loadProps) {

                  final query = filter.trim().toLowerCase();

                  if (query.isEmpty) return districts;



                  return districts

                      .where((district) =>

                          district.districtName

                              .toLowerCase()

                              .contains(query))

                      .toList();

                },

                selectedItem: selectedDistrict,

                compareFn: (a, b) => a.id == b.id,

                itemAsString: (district) => district.districtName,

                onChanged: isLoadingDistricts

                    ? null

                    : (DistrictModel? district) async {

                        setState(() {

                          selectedDistrict = district;

                          stops = [];

                          fromStop = null;

                          toStop = null;

                        });



                        if (district != null) {

                          await fetchStops(district.id);

                        }

                      },

                popupProps: const PopupProps.menu(

                  showSearchBox: true,

                ),

                decoratorProps: const DropDownDecoratorProps(

                  decoration: InputDecoration(

                    labelText: 'Select District',

                    border: OutlineInputBorder(),

                  ),

                ),

              ),



              const SizedBox(height: 20),



              // Live tracking shortcut
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: openLiveTracking,
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Search & Track Bus'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // From stop dropdown

              if (isLoadingStops)

                const LinearProgressIndicator(),



              DropdownSearch<StopModel>(

                enabled: stops.isNotEmpty && !isLoadingStops,

                items: (filter, loadProps) {

                  final query = filter.trim().toLowerCase();

                  if (query.isEmpty) return stops;



                  return stops

                      .where((stop) =>

                          stop.stopName.toLowerCase().contains(query))

                      .toList();

                },

                selectedItem: fromStop,

                compareFn: (a, b) => a.id == b.id,

                itemAsString: (stop) => stop.stopName,

                onChanged: (StopModel? stop) {

                  setState(() {

                    fromStop = stop;

                    if (toStop?.id == stop?.id) {

                      toStop = null;

                    }

                  });

                },

                popupProps: const PopupProps.menu(

                  showSearchBox: true,

                ),

                decoratorProps: const DropDownDecoratorProps(

                  decoration: InputDecoration(

                    labelText: 'From Stop',

                    border: OutlineInputBorder(),

                  ),

                ),

              ),



              const SizedBox(height: 20),



              // To stop dropdown

              DropdownSearch<StopModel>(

                enabled: stops.isNotEmpty && !isLoadingStops,

                items: (filter, loadProps) {

                  final availableStops = stops

                      .where((stop) => stop.id != fromStop?.id)

                      .toList();



                  final query = filter.trim().toLowerCase();

                  if (query.isEmpty) return availableStops;



                  return availableStops

                      .where((stop) =>

                          stop.stopName.toLowerCase().contains(query))

                      .toList();

                },

                selectedItem: toStop,

                compareFn: (a, b) => a.id == b.id,

                itemAsString: (stop) => stop.stopName,

                onChanged: (StopModel? stop) {

                  setState(() => toStop = stop);

                },

                popupProps: const PopupProps.menu(

                  showSearchBox: true,

                ),

                decoratorProps: const DropDownDecoratorProps(

                  decoration: InputDecoration(

                    labelText: 'To Stop',

                    border: OutlineInputBorder(),

                  ),

                ),

              ),



              const SizedBox(height: 20),



              // Number of seats

              TextField(

                controller: seatsController,

                keyboardType: TextInputType.number,

                enabled: !isLoading && availableSeats > 0,

                decoration: const InputDecoration(

                  labelText: 'Number of Seats',

                  hintText: 'Enter number of seats',

                  border: OutlineInputBorder(),

                ),

              ),



              const SizedBox(height: 20),

              // Passenger ID is required by the backend ticket controller.
              TextField(
                controller: passengerIdController,
                keyboardType: TextInputType.number,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  labelText: 'Passenger ID',
                  hintText: 'Enter the existing passenger database ID',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: fareController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                enabled: !isLoading,
                decoration: const InputDecoration(
                  labelText: 'Fare per Seat (₹)',
                  hintText: 'Enter fare for one seat',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 58,

                child: ElevatedButton(

                  onPressed: isLoading || availableSeats == 0

                      ? null

                      : issueTicket,

                  style: ElevatedButton.styleFrom(

                    backgroundColor: purple,

                    foregroundColor: Colors.white,

                    disabledBackgroundColor: Colors.grey,

                    shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(30),

                    ),

                  ),

                  child: isLoading

                      ? const SizedBox(

                          height: 24,

                          width: 24,

                          child: CircularProgressIndicator(

                            strokeWidth: 2.5,

                            color: Colors.white,

                          ),

                        )

                      : const Text(

                          'Issue Ticket',

                          style: TextStyle(fontSize: 18),

                        ),

                ),

              ),



              const SizedBox(height: 16),



              OutlinedButton.icon(

                onPressed: isLoading ? null : fetchDistricts,

                icon: const Icon(Icons.refresh),

                label: const Text('Refresh Districts'),

              ),



              const SizedBox(height: 20),



              const Card(

                child: Padding(

                  padding: EdgeInsets.all(16),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(

                        'Conductor Instructions',

                        style: TextStyle(

                          fontSize: 18,

                          fontWeight: FontWeight.bold,

                        ),

                      ),

                      SizedBox(height: 10),

                      Text('• Select a district first.'),

                      Text('• Select the boarding and destination stops.'),

                      Text('• Enter the number of seats.'),

                      Text('• Tap Issue Ticket and check the response.'),

                    ],

                  ),

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

}
