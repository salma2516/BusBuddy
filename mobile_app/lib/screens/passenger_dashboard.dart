// ==========================================
// PASSENGER DASHBOARD
// COMPLETE UPDATED + DEBUGGED FILE
// ==========================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show rootBundle;

import 'package:dropdown_search/dropdown_search.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart'
    as IO;

import 'package:csv/csv.dart';

import '../models/district_model.dart';
import '../models/stop_model.dart';
import '../models/setc_bus_model.dart';

class PassengerDashboard
    extends StatefulWidget {

  const PassengerDashboard({
    super.key,
  });

  @override
  State<PassengerDashboard>
      createState() =>
          _PassengerDashboardState();
}

class _PassengerDashboardState
    extends State<PassengerDashboard> {

  GoogleMapController? mapController;

  late IO.Socket socket;

  BitmapDescriptor? busIcon;

  // ==========================================
  // BUS TYPE
  // ==========================================

  String selectedBusType =
      "Local";

  // ==========================================
  // DISTRICTS
  // ==========================================

  List<DistrictModel> districts =
      [];

  DistrictModel?
      selectedDistrict;

  // ==========================================
  // STOPS
  // ==========================================

  List<StopModel> stops = [];

  StopModel? fromStop;

  StopModel? toStop;

  // ==========================================
  // AVAILABLE BUSES
  // ==========================================

  List<Map<String, dynamic>>
      availableBuses = [];

  // ==========================================
  // SETC BUSES
  // ==========================================

  List<SetcBusModel> setcBuses =
      [];

  // ==========================================
  // MARKERS
  // ==========================================

  final Map<String, Marker>
      markers = {};

  // ==========================================
  // POLYLINES
  // ==========================================

  Set<Polyline> polylines = {};

  // ==========================================
  // INITIAL MAP POSITION
  // ==========================================

  static const CameraPosition
      initialPosition =
      CameraPosition(

    target: LatLng(
      13.0827,
      80.2707,
    ),

    zoom: 11,
  );

  // ==========================================
  // INIT
  // ==========================================

  @override
  void initState() {

    super.initState();

    connectSocket();

    fetchDistricts();

    loadBusIcon();

    loadSetcBuses();
  }

  // ==========================================
  // LOAD BUS ICON
  // ==========================================

  Future<void> loadBusIcon()
      async {

    busIcon =
        await BitmapDescriptor.asset(

      const ImageConfiguration(
        size: Size(48, 48),
      ),

      "assets/images/bus.png",
    );
  }

  // ==========================================
  // LOAD SETC CSV
  // ==========================================

  Future<void> loadSetcBuses()
      async {

    try {

      final rawData =
          await rootBundle.loadString(
        "assets/data/setc_buses.csv",
      );

      List<List<dynamic>> csvTable =
          const CsvToListConverter(
        eol: "\n",
      ).convert(rawData);

      setcBuses.clear();

      for (
        int i = 1;
        i < csvTable.length;
        i++
      ) {

        final row = csvTable[i];

        if (row.length < 5) {
          continue;
        }

        setcBuses.add(

          SetcBusModel(

            from:
                row[0].toString(),

            to:
                row[1].toString(),

            routeNo:
                row[2].toString(),

            departure:
                row[3].toString(),

            type:
                row[4].toString(),
          ),
        );
      }

      setState(() {});

    } catch (e) {

      print(
        "❌ SETC CSV ERROR: $e",
      );
    }
  }

  // ==========================================
  // FETCH DISTRICTS
  // ==========================================

  Future<void> fetchDistricts()
      async {

    try {

      final response =
          await http.get(

        Uri.parse(
          "http://10.131.101.232:5000/api/districts",
        ),
      );

      final data =
          jsonDecode(response.body);

      if (data["success"]) {

        List<dynamic>
            districtData =
            data["data"];

        districts = districtData
            .map(
              (district) =>
                  DistrictModel
                      .fromJson(
                district,
              ),
            )
            .toList();

        setState(() {});
      }

    } catch (e) {

      print(
        "❌ DISTRICT ERROR: $e",
      );
    }
  }

  // ==========================================
  // FETCH STOPS
  // ==========================================

  Future<void> fetchStops(
    int districtId,
  ) async {

    try {

      final response =
          await http.get(

        Uri.parse(
          "http://10.131.101.232:5000/api/stops/$districtId",
        ),
      );

      final data =
          jsonDecode(response.body);

      if (data["success"]) {

        List<dynamic> stopData =
            data["stops"];

        stops = stopData
            .map(
              (stop) =>
                  StopModel.fromJson(
                stop,
              ),
            )
            .toList();

        setState(() {});
      }

    } catch (e) {

      print(
        "❌ STOP ERROR: $e",
      );
    }
  }

  // ==========================================
  // SOCKET
  // ==========================================

  void connectSocket() {

    socket = IO.io(

      "http://10.131.101.232:5000",

      IO.OptionBuilder()

          .setTransports([
            'websocket'
          ])

          .enableAutoConnect()

          .build(),
    );

    socket.onConnect((_) {

      print(
        "✅ SOCKET CONNECTED",
      );
    });

    socket.on(

      "receive-location",

      (data) {

        try {

          String busId =
              data["busId"]
                  .toString();

          double latitude =
              double.parse(

            data["latitude"]
                .toString(),
          );

          double longitude =
              double.parse(

            data["longitude"]
                .toString(),
          );

          LatLng busPosition =
              LatLng(

            latitude,
            longitude,
          );

          setState(() {

            markers[busId] =
                Marker(

              markerId:
                  MarkerId(
                busId,
              ),

              position:
                  busPosition,

              icon: busIcon ??
                  BitmapDescriptor
                      .defaultMarker,

              infoWindow:
                  InfoWindow(

                title:
                    "Bus $busId",

                snippet:
                    "Live Tracking",
              ),
            );
          });

        } catch (e) {

          print(
            "❌ SOCKET ERROR: $e",
          );
        }
      },
    );
  }

  // ==========================================
  // SEARCH BUSES
  // ==========================================

  void searchBuses() {

    if (fromStop == null ||
        toStop == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "Please Select Stops",
          ),
        ),
      );

      return;
    }

    LatLng fromPosition =
        LatLng(

      double.parse(
        fromStop!.latitude,
      ),

      double.parse(
        fromStop!.longitude,
      ),
    );

    LatLng toPosition =
        LatLng(

      double.parse(
        toStop!.latitude,
      ),

      double.parse(
        toStop!.longitude,
      ),
    );

    LatLng busLocation = LatLng(

      (fromPosition.latitude +
              toPosition.latitude) /
          2,

      (fromPosition.longitude +
              toPosition.longitude) /
          2,
    );

    markers.clear();

    // FROM

    markers["from"] = Marker(

      markerId:
          const MarkerId("from"),

      position: fromPosition,

      icon:
          BitmapDescriptor
              .defaultMarkerWithHue(

        BitmapDescriptor.hueGreen,
      ),

      infoWindow:
          InfoWindow(
        title: fromStop!.stopName,
      ),
    );

    // TO

    markers["to"] = Marker(

      markerId:
          const MarkerId("to"),

      position: toPosition,

      icon:
          BitmapDescriptor
              .defaultMarkerWithHue(

        BitmapDescriptor.hueRed,
      ),

      infoWindow:
          InfoWindow(
        title: toStop!.stopName,
      ),
    );

    // BUS

    markers["bus1"] = Marker(

      markerId:
          const MarkerId("bus1"),

      position: busLocation,

      icon: busIcon ??
          BitmapDescriptor
              .defaultMarker,

      infoWindow:
          const InfoWindow(

        title: "TN 21 N 1234",

        snippet: "Live Bus",
      ),
    );

    // ROUTE

    polylines = {

      Polyline(

        polylineId:
            const PolylineId(
          "route",
        ),

        color: Colors.blue,

        width: 6,

        points: [

          fromPosition,

          busLocation,

          toPosition,
        ],
      ),
    };

    // AVAILABLE BUSES

    availableBuses = [

      {

        "busNumber":
            "TN 21 N 1234",

        "status":
            "On Time",

        "eta":
            "15 mins away",

        "arrivalTime":
            "3:08 PM",

        "distance":
            "24.6 KM",

        "driverName":
            "Arun Kumar",

        "speed":
            "45 km/h",
      },

      {

        "busNumber":
            "TN 21 N 5678",

        "status":
            "Delayed by 5 mins",

        "eta":
            "22 mins away",

        "arrivalTime":
            "3:15 PM",

        "distance":
            "26 KM",

        "driverName":
            "Vignesh",

        "speed":
            "39 km/h",
      },
    ];

    setState(() {});

    // ==========================================
    // AUTO FIT MAP
    // ==========================================

    Future.delayed(

      const Duration(
        milliseconds: 500,
      ),

      () {

        mapController?.animateCamera(

          CameraUpdate.newLatLngBounds(

            LatLngBounds(

              southwest: LatLng(

                fromPosition.latitude <
                        toPosition.latitude
                    ? fromPosition.latitude
                    : toPosition.latitude,

                fromPosition.longitude <
                        toPosition.longitude
                    ? fromPosition.longitude
                    : toPosition.longitude,
              ),

              northeast: LatLng(

                fromPosition.latitude >
                        toPosition.latitude
                    ? fromPosition.latitude
                    : toPosition.latitude,

                fromPosition.longitude >
                        toPosition.longitude
                    ? fromPosition.longitude
                    : toPosition.longitude,
              ),
            ),

            100,
          ),
        );
      },
    );
  }

  @override
  void dispose() {

    socket.dispose();

    mapController?.dispose();

    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      appBar: AppBar(

        backgroundColor:
            Colors.deepPurple,

        title: const Text(
          "Passenger Dashboard",
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(12),

        child: Column(

          children: [

            // ==========================================
            // BUS TYPE
            // ==========================================

            Container(

              padding:
                  const EdgeInsets.all(15),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  const Text(

                    "Select Bus Type",

                    style: TextStyle(

                      fontSize: 18,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Row(

                    children: [

                      Expanded(

                        child:
                            RadioListTile(

                          title:
                              const Text(
                            "Local",
                          ),

                          value:
                              "Local",

                          groupValue:
                              selectedBusType,

                          onChanged:
                              (value) {

                            setState(() {

                              selectedBusType =
                                  value
                                      .toString();
                            });
                          },
                        ),
                      ),

                      Expanded(

                        child:
                            RadioListTile(

                          title:
                              const Text(
                            "SETC",
                          ),

                          value:
                              "SETC",

                          groupValue:
                              selectedBusType,

                          onChanged:
                              (value) {

                            setState(() {

                              selectedBusType =
                                  value
                                      .toString();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            // ==========================================
            // LOCAL BUS
            // ==========================================

            if (selectedBusType ==
                "Local")

              Expanded(

                child:
                    SingleChildScrollView(

                  child: Column(

                    children: [

                      DropdownSearch<
                          DistrictModel>(

                        items:
                            (f, cs) =>
                                districts,

                        selectedItem:
                            selectedDistrict,

                        compareFn:
                            (
                              item1,
                              item2,
                            ) =>
                                item1.id ==
                                item2.id,

                        itemAsString:
                            (
                              DistrictModel
                                  district,
                            ) {

                          return district
                              .districtName;
                        },

                        onChanged:
                            (
                              DistrictModel?
                                  district,
                            ) async {

                          setState(() {

                            selectedDistrict =
                                district;

                            fromStop =
                                null;

                            toStop =
                                null;

                            stops = [];
                          });

                          if (district !=
                              null) {

                            await fetchStops(
                              district.id,
                            );
                          }
                        },

                        popupProps:
                            const PopupProps
                                .menu(

                          showSearchBox:
                              true,
                        ),

                        decoratorProps:
                            const DropDownDecoratorProps(

                          decoration:
                              InputDecoration(

                            labelText:
                                "Select District",

                            border:
                                OutlineInputBorder(),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      DropdownSearch<
                          StopModel>(

                        enabled:
                            stops.isNotEmpty,

                        items:
                            (f, cs) =>
                                stops,

                        selectedItem:
                            fromStop,

                        compareFn:
                            (
                              item1,
                              item2,
                            ) =>
                                item1.id ==
                                item2.id,

                        itemAsString:
                            (
                              StopModel
                                  stop,
                            ) {

                          return stop
                              .stopName;
                        },

                        onChanged:
                            (
                              StopModel?
                                  stop,
                            ) {

                          setState(() {

                            fromStop =
                                stop;
                          });
                        },

                        popupProps:
                            const PopupProps
                                .menu(

                          showSearchBox:
                              true,
                        ),

                        decoratorProps:
                            const DropDownDecoratorProps(

                          decoration:
                              InputDecoration(

                            labelText:
                                "From Stop",

                            border:
                                OutlineInputBorder(),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      DropdownSearch<
                          StopModel>(

                        enabled:
                            stops.isNotEmpty,

                        items:
                            (f, cs) =>
                                stops,

                        selectedItem:
                            toStop,

                        compareFn:
                            (
                              item1,
                              item2,
                            ) =>
                                item1.id ==
                                item2.id,

                        itemAsString:
                            (
                              StopModel
                                  stop,
                            ) {

                          return stop
                              .stopName;
                        },

                        onChanged:
                            (
                              StopModel?
                                  stop,
                            ) {

                          setState(() {

                            toStop =
                                stop;
                          });
                        },

                        popupProps:
                            const PopupProps
                                .menu(

                          showSearchBox:
                              true,
                        ),

                        decoratorProps:
                            const DropDownDecoratorProps(

                          decoration:
                              InputDecoration(

                            labelText:
                                "To Stop",

                            border:
                                OutlineInputBorder(),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // SEARCH BUTTON

                      SizedBox(

                        width:
                            double.infinity,

                        child:
                            ElevatedButton.icon(

                          onPressed:
                              searchBuses,

                          icon: const Icon(
                            Icons.search,
                            color:
                                Colors.white,
                          ),

                          label:
                              const Text(

                            "Search Buses",

                            style:
                                TextStyle(
                              color: Colors
                                  .white,
                            ),
                          ),

                          style:
                              ElevatedButton.styleFrom(

                            backgroundColor:
                                Colors
                                    .deepPurple,

                            padding:
                                const EdgeInsets.symmetric(
                              vertical:
                                  16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // MAP

                      SizedBox(

                        height: 350,

                        child: GoogleMap(

                          initialCameraPosition:
                              initialPosition,

                          onMapCreated:
                              (
                                controller,
                              ) {

                            mapController =
                                controller;
                          },

                          markers:
                              Set<
                                  Marker>.of(
                            markers
                                .values,
                          ),

                          polylines:
                              polylines,

                          myLocationEnabled:
                              true,

                          myLocationButtonEnabled:
                              true,
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // AVAILABLE BUSES

                      if (availableBuses
                          .isNotEmpty)

                        const Align(

                          alignment:
                              Alignment
                                  .centerLeft,

                          child: Text(

                            "Available Buses",

                            style: TextStyle(

                              fontSize: 24,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                      const SizedBox(
                        height: 15,
                      ),

                      ListView.builder(

                        shrinkWrap: true,

                        physics:
                            const NeverScrollableScrollPhysics(),

                        itemCount:
                            availableBuses
                                .length,

                        itemBuilder:
                            (
                              context,
                              index,
                            ) {

                          final bus =
                              availableBuses[
                                  index];

                          return Card(

                            elevation: 5,

                            margin:
                                const EdgeInsets.only(
                              bottom: 15,
                            ),

                            child: Padding(

                              padding:
                                  const EdgeInsets.all(
                                15,
                              ),

                              child: Column(

                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  Text(

                                    bus[
                                        "busNumber"],

                                    style:
                                        const TextStyle(

                                      fontSize:
                                          22,

                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 10,
                                  ),

                                  Text(
                                    "Status: ${bus["status"]}",
                                  ),

                                  Text(
                                    "ETA: ${bus["eta"]}",
                                  ),

                                  Text(
                                    "Arrival: ${bus["arrivalTime"]}",
                                  ),

                                  Text(
                                    "Distance: ${bus["distance"]}",
                                  ),

                                  Text(
                                    "Driver: ${bus["driverName"]}",
                                  ),

                                  Text(
                                    "Speed: ${bus["speed"]}",
                                  ),

                                  const SizedBox(
                                    height: 15,
                                  ),

                                  SizedBox(

                                    width:
                                        double.infinity,

                                    child:
                                        ElevatedButton(

                                      onPressed:
                                          () {

                                        LatLng busLocation =
                                            LatLng(

                                          (double.parse(
                                                    fromStop!.latitude,
                                                  ) +
                                                  double.parse(
                                                    toStop!.latitude,
                                                  )) /
                                              2,

                                          (double.parse(
                                                    fromStop!.longitude,
                                                  ) +
                                                  double.parse(
                                                    toStop!.longitude,
                                                  )) /
                                              2,
                                        );

                                        mapController
                                            ?.animateCamera(

                                          CameraUpdate.newCameraPosition(

                                            CameraPosition(

                                              target:
                                                  busLocation,

                                              zoom:
                                                  15,
                                            ),
                                          ),
                                        );
                                      },

                                      style:
                                          ElevatedButton.styleFrom(

                                        backgroundColor:
                                            Colors.deepPurple,
                                      ),

                                      child:
                                          const Text(

                                        "Track Bus Live",

                                        style:
                                            TextStyle(
                                          color:
                                              Colors.white,
                                        ),
                                      ),
                                    ),
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

            // ==========================================
            // SETC
            // ==========================================

            if (selectedBusType ==
                "SETC")

              Expanded(

                child: ListView.builder(

                  itemCount:
                      setcBuses.length,

                  itemBuilder:
                      (
                        context,
                        index,
                      ) {

                    final bus =
                        setcBuses[index];

                    return Card(

                      elevation: 5,

                      margin:
                          const EdgeInsets.only(
                        bottom: 15,
                      ),

                      child: Padding(

                        padding:
                            const EdgeInsets.all(
                          15,
                        ),

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(

                              "${bus.from} ➜ ${bus.to}",

                              style:
                                  const TextStyle(

                                fontSize:
                                    18,

                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            Text(
                              "Route No: ${bus.routeNo}",
                            ),

                            Text(
                              "Departure: ${bus.departure}",
                            ),

                            Text(
                              "Bus Type: ${bus.type}",
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}