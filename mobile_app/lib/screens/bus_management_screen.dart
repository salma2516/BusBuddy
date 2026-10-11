import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BusManagementScreen extends StatefulWidget {
  const BusManagementScreen({super.key});

  @override
  State<BusManagementScreen> createState() =>
      _BusManagementScreenState();
}

class _BusManagementScreenState
    extends State<BusManagementScreen> {

  final String baseUrl =
      "http://10.131.101.232:5000";

  List buses = [];
  List filteredBuses = [];

  bool loading = true;
  int? editId;

  final busNumberController =
      TextEditingController();

  final busNameController =
      TextEditingController();

  final capacityController =
      TextEditingController();

  final searchController =
      TextEditingController();

  String selectedStatus = "ACTIVE";

  @override
  void initState() {
    super.initState();
    fetchBuses();
  }

  Future<void> fetchBuses() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/buses"),
      );

      if (response.statusCode == 200) {
        setState(() {
          buses = jsonDecode(response.body);
          filteredBuses = buses;
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> addBus() async {
    try {
      await http.post(
        Uri.parse("$baseUrl/api/buses/add"),
        headers: {
          "Content-Type":
              "application/json",
        },
        body: jsonEncode({
          "bus_number":
              busNumberController.text,
          "bus_name":
              busNameController.text,
          "capacity": int.parse(
            capacityController.text,
          ),
          "status": selectedStatus,
        }),
      );

      clearFields();
      await fetchBuses();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateBus() async {
    try {
      await http.put(
        Uri.parse(
          "$baseUrl/api/buses/update/$editId",
        ),
        headers: {
          "Content-Type":
              "application/json",
        },
        body: jsonEncode({
          "bus_number":
              busNumberController.text,
          "bus_name":
              busNameController.text,
          "capacity": int.parse(
            capacityController.text,
          ),
          "status": selectedStatus,
        }),
      );

      clearFields();
      await fetchBuses();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteBus(int id) async {
    try {
      await http.delete(
        Uri.parse(
          "$baseUrl/api/buses/delete/$id",
        ),
      );

      await fetchBuses();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void editBus(Map bus) {
    setState(() {
      editId = bus["id"];

      busNumberController.text =
          bus["bus_number"];

      busNameController.text =
          bus["bus_name"];

      capacityController.text =
          bus["capacity"].toString();

      selectedStatus =
          bus["status"];
    });
  }

  void searchBus(String value) {
    setState(() {
      filteredBuses =
          buses.where((bus) {
        return bus["bus_number"]
            .toString()
            .toLowerCase()
            .contains(
              value.toLowerCase(),
            );
      }).toList();
    });
  }

  void clearFields() {
    busNumberController.clear();
    busNameController.clear();
    capacityController.clear();

    selectedStatus = "ACTIVE";
    editId = null;
  }

  Widget statCard(
      String title,
      String value) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding:
              const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title),
              const SizedBox(
                  height: 8),
              Text(
                value,
                style:
                    const TextStyle(
                  color:
                      Color(0xFF6C3DF4),
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F6FB),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF6C3DF4),
        title: const Text(
          "Bus Management",
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
                                busNumberController,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  "Bus Number",
                            ),
                          ),

                          const SizedBox(
                              height: 10),

                          TextField(
                            controller:
                                busNameController,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  "Bus Name",
                            ),
                          ),

                          const SizedBox(
                              height: 10),

                          TextField(
                            controller:
                                capacityController,
                            keyboardType:
                                TextInputType
                                    .number,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  "Capacity",
                            ),
                          ),

                          const SizedBox(
                              height: 10),

                          DropdownButtonFormField<
                              String>(
                            value:
                                selectedStatus,
                            items: const [
                              DropdownMenuItem(
                                value:
                                    "ACTIVE",
                                child: Text(
                                    "ACTIVE"),
                              ),
                              DropdownMenuItem(
                                value:
                                    "MAINTENANCE",
                                child: Text(
                                    "MAINTENANCE"),
                              ),
                              DropdownMenuItem(
                                value:
                                    "INACTIVE",
                                child: Text(
                                    "INACTIVE"),
                              ),
                            ],
                            onChanged:
                                (value) {
                              setState(() {
                                selectedStatus =
                                    value!;
                              });
                            },
                          ),

                          const SizedBox(
                              height: 15),

                          SizedBox(
                            width:
                                double.infinity,
                            child:
                                ElevatedButton(
                              onPressed:
                                  editId ==
                                          null
                                      ? addBus
                                      : updateBus,
                              child: Text(
                                editId ==
                                        null
                                    ? "Add Bus"
                                    : "Update Bus",
                              ),
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
                        searchBus,
                    decoration:
                        const InputDecoration(
                      hintText:
                          "Search Bus Number",
                      prefixIcon:
                          Icon(Icons.search),
                    ),
                  ),

                  const SizedBox(
                      height: 15),

                  Row(
                    children: [

                      statCard(
                        "Total",
                        buses.length
                            .toString(),
                      ),

                      statCard(
                        "Active",
                        buses
                            .where((b) =>
                                b["status"] ==
                                "ACTIVE")
                            .length
                            .toString(),
                      ),

                      statCard(
                        "Maintenance",
                        buses
                            .where((b) =>
                                b["status"] ==
                                "MAINTENANCE")
                            .length
                            .toString(),
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
                        filteredBuses.length,
                    itemBuilder:
                        (context, index) {

                      final bus =
                          filteredBuses[
                              index];

                      return Card(
                        margin:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets
                                  .all(15),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [

                              Text(
                                bus[
                                    "bus_number"],
                                style:
                                    const TextStyle(
                                  fontSize:
                                      18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(
                                  height:
                                      8),

                              Text(
                                  "Bus Name: ${bus["bus_name"]}"),

                              Text(
                                  "Capacity: ${bus["capacity"]}"),

                              Text(
                                  "Status: ${bus["status"]}"),

                              Text(
                                  "Available Seats: ${bus["available_seats"]}"),

                              const SizedBox(
                                  height:
                                      10),

                              Row(
                                children: [

                                  Expanded(
                                    child:
                                        ElevatedButton.icon(
                                      icon:
                                          const Icon(
                                        Icons
                                            .edit,
                                      ),
                                      label:
                                          const Text(
                                        "Edit",
                                      ),
                                      onPressed:
                                          () {
                                        editBus(
                                            bus);
                                      },
                                    ),
                                  ),

                                  const SizedBox(
                                      width:
                                          10),

                                  Expanded(
                                    child:
                                        ElevatedButton.icon(
                                      style:
                                          ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.red,
                                      ),
                                      icon:
                                          const Icon(
                                        Icons
                                            .delete,
                                        color:
                                            Colors.white,
                                      ),
                                      label:
                                          const Text(
                                        "Delete",
                                        style:
                                            TextStyle(
                                          color:
                                              Colors.white,
                                        ),
                                      ),
                                      onPressed:
                                          () {
                                        deleteBus(
                                          bus[
                                              "id"],
                                        );
                                      },
                                    ),
                                  ),
                                ],
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
}