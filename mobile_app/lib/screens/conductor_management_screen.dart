import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ConductorManagementScreen extends StatefulWidget {
  const ConductorManagementScreen({super.key});

  @override
  State<ConductorManagementScreen> createState() =>
      _ConductorManagementScreenState();
}

class _ConductorManagementScreenState
    extends State<ConductorManagementScreen> {

  final String baseUrl =
      "http://10.131.101.232:5000";

  List conductors = [];
  List filteredConductors = [];

  bool loading = true;
  int? editId;

  final nameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final searchController =
      TextEditingController();

  String selectedStatus = "ACTIVE";

  @override
  void initState() {
    super.initState();
    fetchConductors();
  }

  Future<void> fetchConductors() async {
    try {
      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/conductors",
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          conductors =
              jsonDecode(response.body);

          filteredConductors =
              conductors;

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

  Future<void> addConductor() async {
    try {
      await http.post(
        Uri.parse(
          "$baseUrl/api/conductors/add",
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
          "status":
              selectedStatus,
        }),
      );

      clearFields();
      fetchConductors();

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateConductor() async {
    try {
      await http.put(
        Uri.parse(
          "$baseUrl/api/conductors/update/$editId",
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
          "status":
              selectedStatus,
        }),
      );

      clearFields();
      fetchConductors();

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteConductor(
      int id) async {

    try {
      await http.delete(
        Uri.parse(
          "$baseUrl/api/conductors/delete/$id",
        ),
      );

      fetchConductors();

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void editConductor(
      Map conductor) {

    setState(() {

      editId =
          conductor["id"];

      nameController.text =
          conductor["name"];

      emailController.text =
          conductor["email"];

      phoneController.text =
          conductor["phone"];

      selectedStatus =
          conductor["status"];
    });
  }

  void searchConductor(
      String value) {

    setState(() {

      filteredConductors =
          conductors.where((c) {

        return c["name"]
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

    selectedStatus = "ACTIVE";
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
          "Conductor Management",
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
                                  "Name",
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

                          DropdownButtonFormField<String>(
                            value:
                                selectedStatus,
                            items: const [

                              DropdownMenuItem(
                                value:
                                    "ACTIVE",
                                child: Text(
                                  "ACTIVE",
                                ),
                              ),

                              DropdownMenuItem(
                                value:
                                    "INACTIVE",
                                child: Text(
                                  "INACTIVE",
                                ),
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
                                      ? addConductor
                                      : updateConductor,
                              child: Text(
                                editId ==
                                        null
                                    ? "Add Conductor"
                                    : "Update Conductor",
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
                        searchConductor,
                    decoration:
                        const InputDecoration(
                      hintText:
                          "Search Conductor",
                      prefixIcon:
                          Icon(Icons.search),
                    ),
                  ),

                  const SizedBox(
                      height: 15),

                  Row(
                    children: [

                      Expanded(
                        child: statCard(
                          "Total",
                          conductors.length
                              .toString(),
                        ),
                      ),

                      Expanded(
                        child: statCard(
                          "Active",
                          conductors
                              .where((c) =>
                                  c["status"] ==
                                  "ACTIVE")
                              .length
                              .toString(),
                        ),
                      ),

                      Expanded(
                        child: statCard(
                          "Inactive",
                          conductors
                              .where((c) =>
                                  c["status"] ==
                                  "INACTIVE")
                              .length
                              .toString(),
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
                        filteredConductors.length,
                    itemBuilder:
                        (context, index) {

                      final conductor =
                          filteredConductors[
                              index];

                      return Card(
                        margin:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: ListTile(
                          title: Text(
                            conductor["name"],
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [

                              Text(
                                conductor["email"],
                              ),

                              Text(
                                conductor["phone"],
                              ),

                              Text(
                                conductor["status"],
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
                                  editConductor(
                                      conductor);
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
                                  deleteConductor(
                                    conductor["id"],
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
            const EdgeInsets.all(15),
        child: Column(
          children: [

            Text(title),

            const SizedBox(
                height: 8),

            Text(
              value,
              style:
                  const TextStyle(
                fontSize: 24,
                color:
                    Color(0xFF6C3DF4),
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}