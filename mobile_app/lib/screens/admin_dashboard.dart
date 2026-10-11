import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/screens/bus_management_screen.dart';
import 'package:mobile_app/screens/driver_management_screen.dart';
import 'package:mobile_app/screens/conductor_management_screen.dart';
import 'package:mobile_app/screens/passenger_management_screen.dart';
import 'package:mobile_app/screens/live_tracking_screen.dart';
import 'package:mobile_app/screens/complaint_management_screen.dart';
import 'package:mobile_app/screens/revenue_management_screen.dart';
import 'package:mobile_app/screens/ticket_management_screen.dart';
import 'package:mobile_app/screens/settings_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() =>
      _AdminDashboardState();
}

class _AdminDashboardState
    extends State<AdminDashboard> {

  bool loading = true;

  Map<String, dynamic> stats = {
    "buses": 0,
    "drivers": 0,
    "conductors": 0,
    "passengers": 0,
    "tickets": 0,
    "complaints": 0,
    "revenue": 0,
  };

  final String baseUrl =
      "http://10.131.101.232:5000";
  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/dashboard",
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          stats =
              jsonDecode(response.body);
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      debugPrint(
        "Dashboard Error: $e",
      );

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F6FB),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF6C3DF4),
        elevation: 0,
        title: const Text(
          "BusBuddy Admin",
          style: TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [

            const DrawerHeader(
              decoration: BoxDecoration(
                color:
                    Color(0xFF6C3DF4),
              ),
              child: Center(
                child: Text(
                  "BusBuddy Admin",
                  style: TextStyle(
                    color:
                        Colors.white,
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            ListTile(
              leading: const Icon(
                Icons.directions_bus,
              ),
              title: const Text(
                "Bus Management",
              ),
              onTap: () {

                Navigator.pop(
                    context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const BusManagementScreen(),
                  ),
                );
              },
            ),

                        ListTile(
              leading: const Icon(Icons.person),
              title: const Text(
                "Driver Management",
              ),
              onTap: () {

                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const DriverManagementScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.badge),
              title: const Text(
                "Conductor Management",
              ),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ConductorManagementScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.people),
              title: const Text(
                "Passenger Management",
              ),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const PassengerManagementScreen(),
                  ),
                );
              },
            ),

            ListTile(
                leading: const Icon(
                  Icons.confirmation_number,
                ),
                title: const Text(
                  "Ticket Management",
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const TicketManagementScreen(),
                    ),
                  );
                },
              ),

            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text(
                "Complaints",
              ),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ComplaintManagementScreen(),
                  ),
                );
              },
            ),

            ListTile(
                leading: const Icon(
                  Icons.location_on,
                ),
                title: const Text(
                  "Live Tracking",
                ),
                onTap: () {

                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const LiveTrackingScreen(),
                    ),
                  );

                },
              ),

            ListTile(
              leading: const Icon(
                Icons.analytics,
              ),
              title: const Text(
                "Revenue Analytics",
              ),
              onTap: () {

                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const RevenueManagementScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.settings,
              ),
              title: const Text(
                "Settings",
              ),
              onTap: () {

                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      body: RefreshIndicator(
        onRefresh:
            fetchDashboardData,
        child:
            SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [

              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets
                        .all(12),
                color:
                    const Color(
                  0xFF6C3DF4,
                ),
                child: Text(
                  "📍 Live Tracking Active | "
                  "👨‍✈️ Drivers: ${stats["drivers"]} | "
                  "🎫 Tickets: ${stats["tickets"]} | "
                  "👥 Passengers: ${stats["passengers"]} | "
                  "💰 Revenue: ₹${stats["revenue"]}",
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(
                  height: 15),

              Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                ),
                child:
                    GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  crossAxisSpacing:
                      12,
                  mainAxisSpacing:
                      12,
                  childAspectRatio:
                      1.1,
                  children: [

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const BusManagementScreen(),
                          ),
                        );
                      },
                      child:
                          dashboardCard(
                        "🚌",
                        "Total Buses",
                        stats["buses"]
                            .toString(),
                      ),
                    ),

                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DriverManagementScreen(),
                            ),
                          );
                        },
                        child: dashboardCard(
                          "👨‍✈️",
                          "Drivers",
                          stats["drivers"].toString(),
                        ),
                      ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ConductorManagementScreen(),
                          ),
                        );
                      },
                      child: dashboardCard(
                        "🎫",
                        "Conductors",
                        stats["conductors"].toString(),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PassengerManagementScreen(),
                          ),
                        );
                      },
                      child: dashboardCard(
                        "👥",
                        "Passengers",
                        stats["passengers"].toString(),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const TicketManagementScreen(),
                          ),
                        );
                      },
                      child: dashboardCard(
                        "🎟️",
                        "Tickets",
                        stats["tickets"].toString(),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ComplaintManagementScreen(),
                          ),
                        );
                      },
                      child: dashboardCard(
                        "⚠️",
                        "Complaints",
                        stats["complaints"].toString(),
                      ),
                    ),

                   GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const LiveTrackingScreen(),
                      ),
                    );
                  },
                  child: dashboardCard(
                    "📍",
                    "Live Tracking",
                    "Active",
                  ),
                  ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const RevenueManagementScreen(),
                          ),
                        );
                      },
                      child: dashboardCard(
                        "💰",
                        "Revenue",
                        "₹${stats["revenue"]}",
                      ),
                    ),
                  ],
                ),
              ),

              GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SettingsScreen(),
                      ),
                    );
                  },
                  child: dashboardCard(
                    "⚙️",
                    "Settings",
                    "Admin",
                  ),
                ),
              ],
          ),
        ),
      ),
    );
  }

  Widget dashboardCard(
    String emoji,
    String title,
    String value,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
                18),
        boxShadow: [
          BoxShadow(
            color:
                Colors.grey.shade300,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [

          Text(
            emoji,
            style:
                const TextStyle(
              fontSize: 36,
            ),
          ),

          const SizedBox(
              height: 10),

          Text(
            title,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
              height: 8),

          Text(
            value,
            style:
                const TextStyle(
              color:
                  Color(0xFF6C3DF4),
              fontWeight:
                  FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}