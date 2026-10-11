
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DriverManagementScreen extends StatefulWidget {
  const DriverManagementScreen({super.key});

  @override
  State<DriverManagementScreen> createState() =>
      _DriverManagementScreenState();
}

class _DriverManagementScreenState
    extends State<DriverManagementScreen> {

  final String baseUrl =
    "http://10.131.101.232:5000";

  List drivers = [];
  List filteredDrivers = [];

  bool loading = true;
  int? editId;

  final TextEditingController
      nameController =
      TextEditingController();

  final TextEditingController
      emailController =
      TextEditingController();

  final TextEditingController
      phoneController =
      TextEditingController();

  final TextEditingController
      passwordController =
      TextEditingController();

  final TextEditingController
      searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDrivers();
  }

  Future<void> fetchDrivers() async {
    try {

      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/drivers",
        ),
      );

      if (response.statusCode == 200) {

        setState(() {

          drivers =
              jsonDecode(response.body);

          filteredDrivers =
              drivers;

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

  Future<void> addDriver() async {
    try {

      await http.post(
        Uri.parse(
          "$baseUrl/api/drivers/add",
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
      fetchDrivers();

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateDriver() async {
    try {

      await http.put(
        Uri.parse(
          "$baseUrl/api/drivers/update/$editId",
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
      fetchDrivers();

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteDriver(
      int id) async {

    try {

      await http.delete(
        Uri.parse(
          "$baseUrl/api/drivers/delete/$id",
        ),
      );

      fetchDrivers();

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void editDriver(Map driver) {

    setState(() {

      editId = driver["id"];

      nameController.text =
          driver["name"];

      emailController.text =
          driver["email"];

      phoneController.text =
          driver["phone"];

      passwordController.clear();
    });
  }

  void searchDriver(String value) {

    setState(() {

      filteredDrivers =
          drivers.where((driver) {

        return driver["name"]
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
          "Driver Management",
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

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(
                    "👨‍✈️ Driver Management",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                      height: 15),

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
                              hintText:
                                  "Driver Name",
                            ),
                          ),

                          const SizedBox(
                              height: 10),

                          TextField(
                            controller:
                                emailController,
                            decoration:
                                const InputDecoration(
                              hintText:
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
                              hintText:
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
                              hintText:
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
                                      ? addDriver
                                      : updateDriver,
                              child: Text(
                                editId == null
                                    ? "Add Driver"
                                    : "Update Driver",
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
                        searchDriver,
                    decoration:
                        const InputDecoration(
                      hintText:
                          "Search Driver",
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
                            "Total Drivers",
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                              height: 10),

                          Text(
                            drivers.length
                                .toString(),
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                      0xFF6C3DF4),
                              fontSize: 32,
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
                        filteredDrivers.length,
                    itemBuilder:
                        (context, index) {

                      final driver =
                          filteredDrivers[
                              index];

                      return Card(
                        margin:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: ListTile(
                          title: Text(
                            driver["name"],
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [

                              Text(
                                driver["email"],
                              ),

                              Text(
                                driver["phone"],
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
                                  editDriver(
                                      driver);
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
                                  deleteDriver(
                                    driver["id"],
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
