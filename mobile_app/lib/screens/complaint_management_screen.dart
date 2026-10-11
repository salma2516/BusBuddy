import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ComplaintManagementScreen extends StatefulWidget {
  const ComplaintManagementScreen({super.key});

  @override
  State<ComplaintManagementScreen> createState() =>
      _ComplaintManagementScreenState();
}

class _ComplaintManagementScreenState
    extends State<ComplaintManagementScreen> {

  final String baseUrl =
     "http://10.131.101.232:5000";

  List complaints = [];
  List filteredComplaints = [];

  bool loading = true;

  int? editId;

  final userIdController =
      TextEditingController();

  final complaintController =
      TextEditingController();

  final searchController =
      TextEditingController();

  String selectedStatus = "OPEN";

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    try {

      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/complaints",
        ),
      );

      if (response.statusCode == 200) {

        setState(() {

          complaints =
              jsonDecode(response.body);

          filteredComplaints =
              complaints;

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

  Future<void> addComplaint() async {

    try {

      await http.post(
        Uri.parse(
          "$baseUrl/api/complaints/add",
        ),
        headers: {
          "Content-Type":
              "application/json",
        },
        body: jsonEncode({
          "user_id":
              userIdController.text,
          "complaint_text":
              complaintController.text,
          "status":
              selectedStatus,
        }),
      );

      clearFields();
      fetchComplaints();

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateComplaint() async {

    try {

      await http.put(
        Uri.parse(
          "$baseUrl/api/complaints/update/$editId",
        ),
        headers: {
          "Content-Type":
              "application/json",
        },
        body: jsonEncode({
          "user_id":
              userIdController.text,
          "complaint_text":
              complaintController.text,
          "status":
              selectedStatus,
        }),
      );

      clearFields();
      fetchComplaints();

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteComplaint(
      int id) async {

    try {

      await http.delete(
        Uri.parse(
          "$baseUrl/api/complaints/delete/$id",
        ),
      );

      fetchComplaints();

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void editComplaint(
      Map complaint) {

    setState(() {

      editId =
          complaint["id"];

      userIdController.text =
          complaint["user_id"]
              .toString();

      complaintController.text =
          complaint[
              "complaint_text"];

      selectedStatus =
          complaint["status"];

    });
  }

  void searchComplaint(
      String value) {

    setState(() {

      filteredComplaints =
          complaints.where((c) {

        return c["complaint_text"]
            .toString()
            .toLowerCase()
            .contains(
              value.toLowerCase(),
            );

      }).toList();

    });
  }

  void clearFields() {

    userIdController.clear();

    complaintController.clear();

    selectedStatus = "OPEN";

    editId = null;
  }

  @override
  Widget build(BuildContext context) {

    int openCount =
        complaints.where(
      (c) =>
          c["status"] == "OPEN",
    ).length;

    int resolvedCount =
        complaints.where(
      (c) =>
          c["status"] ==
          "RESOLVED",
    ).length;

    return Scaffold(

      backgroundColor:
          const Color(0xFFF4F6FB),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF6C3DF4),
        title: const Text(
          "Complaint Management",
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
                                userIdController,
                            keyboardType:
                                TextInputType
                                    .number,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  "User ID",
                            ),
                          ),

                          const SizedBox(
                              height:
                                  10),

                          TextField(
                            controller:
                                complaintController,
                            decoration:
                                const InputDecoration(
                              labelText:
                                  "Complaint",
                            ),
                          ),

                          const SizedBox(
                              height:
                                  10),

                          DropdownButtonFormField<
                              String>(
                            value:
                                selectedStatus,

                            items: const [

                              DropdownMenuItem(
                                value:
                                    "OPEN",
                                child: Text(
                                    "OPEN"),
                              ),

                              DropdownMenuItem(
                                value:
                                    "IN_PROGRESS",
                                child: Text(
                                    "IN_PROGRESS"),
                              ),

                              DropdownMenuItem(
                                value:
                                    "RESOLVED",
                                child: Text(
                                    "RESOLVED"),
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
                              height:
                                  15),

                          SizedBox(
                            width:
                                double.infinity,

                            child:
                                ElevatedButton(
                              onPressed:
                                  editId ==
                                          null
                                      ? addComplaint
                                      : updateComplaint,

                              child: Text(
                                editId ==
                                        null
                                    ? "Add Complaint"
                                    : "Update Complaint",
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
                        searchComplaint,

                    decoration:
                        const InputDecoration(
                      hintText:
                          "Search Complaint",
                      prefixIcon:
                          Icon(
                        Icons.search,
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 15),

                  Row(
                    children: [

                      Expanded(
                        child:
                            statCard(
                          "Total",
                          complaints.length
                              .toString(),
                        ),
                      ),

                      Expanded(
                        child:
                            statCard(
                          "Open",
                          openCount
                              .toString(),
                        ),
                      ),

                      Expanded(
                        child:
                            statCard(
                          "Resolved",
                          resolvedCount
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
                        filteredComplaints
                            .length,

                    itemBuilder:
                        (context,
                            index) {

                      final complaint =
                          filteredComplaints[
                              index];

                      return Card(

                        child: ListTile(

                          title: Text(
                            complaint[
                                    "complaint_text"] ??
                                "",
                          ),

                          subtitle:
                              Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              Text(
                                "User ID: ${complaint["user_id"]}",
                              ),

                              Text(
                                "Status: ${complaint["status"]}",
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
                                  editComplaint(
                                      complaint);
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
                                  deleteComplaint(
                                    complaint[
                                        "id"],
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
            const EdgeInsets.all(
                15),
        child: Column(
          children: [

            Text(title),

            const SizedBox(
                height: 5),

            Text(
              value,
              style:
                  const TextStyle(
                fontSize: 24,
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
    );
  }
}
