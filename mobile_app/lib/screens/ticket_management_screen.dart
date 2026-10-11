import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TicketManagementScreen extends StatefulWidget {
  const TicketManagementScreen({super.key});

  @override
  State<TicketManagementScreen> createState() =>
      _TicketManagementScreenState();
}

class _TicketManagementScreenState
    extends State<TicketManagementScreen> {

  final String baseUrl =
      "http://10.131.101.232:5000";

  List tickets = [];
  List filteredTickets = [];

  bool loading = true;

  int? editId;

  final passengerController =
      TextEditingController();

  final busController =
      TextEditingController();

  final fromController =
      TextEditingController();

  final toController =
      TextEditingController();

  final seatsController =
      TextEditingController();

  final amountController =
      TextEditingController();

  final searchController =
      TextEditingController();

  String paymentStatus = "PAID";

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

          filteredTickets =
              tickets;

          loading = false;

        });
      }

    } catch (e) {

      debugPrint(
        "Ticket Error: $e",
      );

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> addTicket() async {

    try {

      await http.post(
        Uri.parse(
          "$baseUrl/api/tickets/add",
        ),
        headers: {
          "Content-Type":
              "application/json",
        },
        body: jsonEncode({

          "passenger_id":
              passengerController.text,

          "bus_id":
              busController.text,

          "from_stop":
              fromController.text,

          "to_stop":
              toController.text,

          "source_stop":
              fromController.text,

          "destination_stop":
              toController.text,

          "seats":
              seatsController.text,

          "amount":
              amountController.text,

          "fare":
              amountController.text,

          "payment_status":
              paymentStatus,

          "status":
              "ACTIVE",

        }),
      );

      clearFields();
      fetchTickets();

    } catch (e) {

      debugPrint(e.toString());
    }
  }

  Future<void> updateTicket() async {

    try {

      await http.put(
        Uri.parse(
          "$baseUrl/api/tickets/update/$editId",
        ),
        headers: {
          "Content-Type":
              "application/json",
        },
        body: jsonEncode({

          "passenger_id":
              passengerController.text,

          "bus_id":
              busController.text,

          "from_stop":
              fromController.text,

          "to_stop":
              toController.text,

          "source_stop":
              fromController.text,

          "destination_stop":
              toController.text,

          "seats":
              seatsController.text,

          "amount":
              amountController.text,

          "fare":
              amountController.text,

          "payment_status":
              paymentStatus,

          "status":
              "ACTIVE",

        }),
      );

      clearFields();
      fetchTickets();

    } catch (e) {

      debugPrint(e.toString());
    }
  }

  Future<void> deleteTicket(
      int id) async {

    try {

      await http.delete(
        Uri.parse(
          "$baseUrl/api/tickets/delete/$id",
        ),
      );

      fetchTickets();

    } catch (e) {

      debugPrint(e.toString());
    }
  }

  void editTicket(
      Map ticket) {

    setState(() {

      editId =
          ticket["id"];

      passengerController.text =
          ticket["passenger_id"]
              .toString();

      busController.text =
          ticket["bus_id"]
              .toString();

      fromController.text =
          ticket["from_stop"] ?? "";

      toController.text =
          ticket["to_stop"] ?? "";

      seatsController.text =
          ticket["seats"]
              .toString();

      amountController.text =
          ticket["amount"]
              .toString();

      paymentStatus =
          ticket["payment_status"] ??
              "PAID";
    });
  }

  void searchTicket(
      String value) {

    setState(() {

      filteredTickets =
          tickets.where((ticket) {

        return ticket[
                "passenger_id"]
            .toString()
            .contains(value);

      }).toList();

    });
  }

  void clearFields() {

    passengerController.clear();
    busController.clear();
    fromController.clear();
    toController.clear();
    seatsController.clear();
    amountController.clear();

    paymentStatus = "PAID";

    editId = null;
  }

  @override
  Widget build(BuildContext context) {

    int activeTickets =
        tickets.where(
      (t) =>
          t["status"] ==
          "ACTIVE",
    ).length;

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

    return Scaffold(

      backgroundColor:
          const Color(0xFFF4F6FB),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF6C3DF4),
        title: const Text(
          "Ticket Management",
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

                children: [

                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets
                              .all(15),

                      child: Column(
                        children: [

                          TextField(
                            controller:
                                passengerController,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  "Passenger ID",
                            ),
                          ),

                          TextField(
                            controller:
                                busController,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  "Bus ID",
                            ),
                          ),

                          TextField(
                            controller:
                                fromController,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  "From Stop",
                            ),
                          ),

                          TextField(
                            controller:
                                toController,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  "To Stop",
                            ),
                          ),

                          TextField(
                            controller:
                                seatsController,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  "Seats",
                            ),
                          ),

                          TextField(
                            controller:
                                amountController,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  "Amount",
                            ),
                          ),

                          const SizedBox(
                              height: 10),

                          DropdownButtonFormField<
                              String>(
                            value:
                                paymentStatus,

                            items: const [

                              DropdownMenuItem(
                                value:
                                    "PAID",
                                child: Text(
                                    "PAID"),
                              ),

                              DropdownMenuItem(
                                value:
                                    "PENDING",
                                child: Text(
                                    "PENDING"),
                              ),
                            ],

                            onChanged:
                                (value) {

                              setState(() {

                                paymentStatus =
                                    value!;

                              });
                            },
                          ),

                          const SizedBox(
                              height: 15),

                          ElevatedButton(
                            onPressed:
                                editId ==
                                        null
                                    ? addTicket
                                    : updateTicket,

                            child: Text(
                              editId ==
                                      null
                                  ? "Add Ticket"
                                  : "Update Ticket",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 15),

                  TextField(
                    controller:
                        searchController,

                    onChanged:
                        searchTicket,

                    decoration:
                        const InputDecoration(
                      hintText:
                          "Search Passenger ID",
                      prefixIcon:
                          Icon(Icons.search),
                    ),
                  ),

                  const SizedBox(
                      height: 15),

                  Row(
                    children: [

                      Expanded(
                        child:
                            statCard(
                          "Tickets",
                          tickets.length
                              .toString(),
                        ),
                      ),

                      Expanded(
                        child:
                            statCard(
                          "Active",
                          activeTickets
                              .toString(),
                        ),
                      ),

                      Expanded(
                        child:
                            statCard(
                          "Revenue",
                          "₹${totalRevenue.toStringAsFixed(0)}",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 15),

                  ListView.builder(

                    shrinkWrap: true,

                    physics:
                        const NeverScrollableScrollPhysics(),

                    itemCount:
                        filteredTickets.length,

                    itemBuilder:
                        (context, index) {

                      final ticket =
                          filteredTickets[index];

                      return Card(

                        child: ListTile(

                          title: Text(
                            "Ticket #${ticket["id"]}",
                          ),

                          subtitle:
                              Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

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

                              Text(
                                "Amount: ₹${ticket["amount"]}",
                              ),
                            ],
                          ),

                          trailing:
                              Row(
                            mainAxisSize:
                                MainAxisSize.min,

                            children: [

                              IconButton(
                                icon:
                                    const Icon(
                                  Icons.edit,
                                  color:
                                      Colors.orange,
                                ),
                                onPressed:
                                    () {
                                  editTicket(
                                      ticket);
                                },
                              ),

                              IconButton(
                                icon:
                                    const Icon(
                                  Icons.delete,
                                  color:
                                      Colors.red,
                                ),
                                onPressed:
                                    () {
                                  deleteTicket(
                                    ticket["id"],
                                  );
                                },
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
    );
  }

  Widget statCard(
      String title,
      String value) {

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(12),
        child: Column(
          children: [

            Text(title),

            const SizedBox(
                height: 5),

            Text(
              value,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xFF6C3DF4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
