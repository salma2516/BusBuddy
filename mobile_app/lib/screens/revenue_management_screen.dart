import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RevenueManagementScreen extends StatefulWidget {
  const RevenueManagementScreen({super.key});

  @override
  State<RevenueManagementScreen> createState() =>
      _RevenueManagementScreenState();
}

class _RevenueManagementScreenState
    extends State<RevenueManagementScreen> {

  final String baseUrl =
      "http://10.131.101.232:5000";

  List tickets = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  Future<void> fetchTickets() async {

    try {

      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/tickets",
        ),
      );

      if (response.statusCode == 200) {

        setState(() {

          tickets =
              jsonDecode(response.body);

          loading = false;

        });
      }

    } catch (e) {

      debugPrint(
        "Revenue Error: $e",
      );

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    double totalRevenue =
        tickets.fold(
      0,
      (sum, ticket) =>
          sum +
          double.tryParse(
                ticket["amount"]
                    .toString(),
              )!
                  .toDouble(),
    );

    int totalPassengers =
        tickets.fold(
      0,
      (sum, ticket) =>
          sum +
          int.parse(
            ticket["seats"]
                .toString(),
          ),
    );

    int totalTrips =
        tickets.length;

    return Scaffold(

      backgroundColor:
          const Color(0xFFF4F6FB),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF6C3DF4),
        title: const Text(
          "Revenue Analytics",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: loading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : SingleChildScrollView(

              padding:
                  const EdgeInsets.all(
                      15),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(
                    "💰 Revenue Analytics",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                      height: 15),

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
                        1.2,

                    children: [

                      revenueCard(
                        "💰",
                        "Total Revenue",
                        "₹${totalRevenue.toStringAsFixed(0)}",
                      ),

                      revenueCard(
                        "🎟️",
                        "Total Tickets",
                        tickets.length
                            .toString(),
                      ),

                      revenueCard(
                        "🚌",
                        "Total Trips",
                        totalTrips
                            .toString(),
                      ),

                      revenueCard(
                        "👥",
                        "Passengers",
                        totalPassengers
                            .toString(),
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 20),

                  const Text(
                    "Conductor Ticket Revenue Report",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                      height: 10),

                  ListView.builder(

                    shrinkWrap: true,

                    physics:
                        const NeverScrollableScrollPhysics(),

                    itemCount:
                        tickets.length,

                    itemBuilder:
                        (context,
                            index) {

                      final ticket =
                          tickets[index];

                      return Card(

                        margin:
                            const EdgeInsets.only(
                          bottom: 10,
                        ),

                        child: ListTile(

                          leading:
                              const Icon(
                            Icons
                                .confirmation_number,
                            color:
                                Color(
                                    0xFF6C3DF4),
                          ),

                          title: Text(
                            "Ticket #${ticket["id"]}",
                          ),

                          subtitle:
                              Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              Text(
                                "Passenger: ${ticket["passenger_id"]}",
                              ),

                              Text(
                                "Bus: ${ticket["bus_id"]}",
                              ),

                              Text(
                                "${ticket["from_stop"]} → ${ticket["to_stop"]}",
                              ),

                              Text(
                                "Seats: ${ticket["seats"]}",
                              ),
                            ],
                          ),

                          trailing:
                              Text(
                            "₹${ticket["amount"]}",
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  Colors.green,
                              fontSize:
                                  18,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget revenueCard(
    String emoji,
    String title,
    String value,
  ) {

    return Container(

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
                15),

        boxShadow: [

          BoxShadow(
            color: Colors.grey
                .shade300,

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
              fontSize: 35,
            ),
          ),

          const SizedBox(
              height: 8),

          Text(
            title,
            textAlign:
                TextAlign.center,
          ),

          const SizedBox(
              height: 8),

          Text(
            value,
            style:
                const TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
              color:
                  Color(
                      0xFF6C3DF4),
            ),
          ),
        ],
      ),
    );
  }
}
