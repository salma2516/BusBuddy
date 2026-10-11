import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PassengerManagementScreen extends StatefulWidget {
  const PassengerManagementScreen({super.key});

  @override
  State<PassengerManagementScreen> createState() =>
      _PassengerManagementScreenState();
}

class _PassengerManagementScreenState
    extends State<PassengerManagementScreen> {

  final String baseUrl =
      "http://10.131.101.232:5000";

  List passengers = [];
  List filteredPassengers = [];

  bool loading = true;
  int? editId;

  final nameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPassengers();
  }

  Future<void> fetchPassengers() async {
    try {

      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/passengers",
        ),
      );

      if (response.statusCode == 200) {

        setState(() {

          passengers =
              jsonDecode(response.body);

          filteredPassengers =
              passengers;

          loading = false;

        });
      }

    } catch (e) {

      debugPrint(e.toString());

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> addPassenger() async {

    try {

      await http.post(
        Uri.parse(
          "$baseUrl/api/passengers/add",
        ),
        headers: {
          "Content-Type":
              "application/json",
        },
        body: jsonEncode({
          "name":
              nameController.text,
          "email":
              emailController.text,
          "phone":
              phoneController.text,
          "password":
              passwordController.text,
        }),
      );

      clearFields();
      fetchPassengers();

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updatePassenger() async {

    try {

      await http.put(
        Uri.parse(
          "$baseUrl/api/passengers/update/$editId",
        ),
        headers: {
          "Content-Type":
              "application/json",
        },
        body: jsonEncode({
          "name":
              nameController.text,
          "email":
              emailController.text,
          "phone":
              phoneController.text,
          "password":
              passwordController.text,
        }),
      );

      clearFields();
      fetchPassengers();

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deletePassenger(
      int id) async {

    try {

      await http.delete(
        Uri.parse(
          "$baseUrl/api/passengers/delete/$id",
        ),
      );

      fetchPassengers();

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void editPassenger(
      Map passenger) {

    setState(() {

      editId =
          passenger["id"];

      nameController.text =
          passenger["name"];

      emailController.text =
          passenger["email"];

      phoneController.text =
          passenger["phone"];

      passwordController.clear();

    });
  }

  void searchPassenger(
      String value) {

    setState(() {

      filteredPassengers =
          passengers.where((p) {

        return p["name"]
            .toString()
            .toLowerCase()
            .contains(
              value.toLowerCase(),
            );

      }).toList();

    });
  }

  void clearFields() {

    nameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();

    editId = null;
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
          "Passenger Management",
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
                  const EdgeInsets.all(15),

              child: Column(

                children: [

                  Card(
                    elevation: 4,

                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                              15),

                      child: Column(
                        children: [

                          TextField(
                            controller:
                                nameController,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  "Passenger Name",
                            ),
                          ),

                          const SizedBox(
                              height: 10),

                          TextField(
                            controller:
                                emailController,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  "Email",
                            ),
                          ),

                          const SizedBox(
                              height: 10),

                          TextField(
                            controller:
                                phoneController,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  "Phone",
                            ),
                          ),

                          const SizedBox(
                              height: 10),

                          TextField(
                            controller:
                                passwordController,
                            obscureText: true,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  "Password",
                            ),
                          ),

                          const SizedBox(
                              height: 15),

                          SizedBox(
                            width:
                                double.infinity,

                            child:
                                ElevatedButton(
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(
                                        0xFF6C3DF4),
                              ),

                              onPressed:
                                  editId == null
                                      ? addPassenger
                                      : updatePassenger,

                              child: Text(
                                editId == null
                                    ? "Add Passenger"
                                    : "Update Passenger",
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
                        searchPassenger,

                    decoration:
                        const InputDecoration(
                      hintText:
                          "Search Passenger",
                      prefixIcon:
                          Icon(Icons.search),
                    ),
                  ),

                  const SizedBox(
                      height: 15),

                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                              20),

                      child: Column(
                        children: [

                          const Text(
                            "Total Passengers",
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                              height: 10),

                          Text(
                            passengers.length
                                .toString(),
                            style:
                                const TextStyle(
                              fontSize: 32,
                              color:
                                  Color(
                                      0xFF6C3DF4),
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 15),

                  ListView.builder(
                    shrinkWrap: true,

                    physics:
                        const NeverScrollableScrollPhysics(),

                    itemCount:
                        filteredPassengers.length,

                    itemBuilder:
                        (context, index) {

                      final passenger =
                          filteredPassengers[
                              index];

                      return Card(

                        margin:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),

                        child: ListTile(

                          title: Text(
                            passenger["name"],
                          ),

                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              Text(
                                passenger["email"],
                              ),

                              Text(
                                passenger["phone"],
                              ),
                            ],
                          ),

                          trailing: Row(
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
                                onPressed: () {
                                  editPassenger(
                                      passenger);
                                },
                              ),

                              IconButton(
                                icon:
                                    const Icon(
                                  Icons.delete,
                                  color:
                                      Colors.red,
                                ),
                                onPressed: () {
                                  deletePassenger(
                                    passenger["id"],
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
}
