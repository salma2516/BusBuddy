// ==========================================
// COMPLAINTS SCREEN
// ==========================================

import 'package:flutter/material.dart';

class ComplaintsScreen
    extends StatefulWidget {

  const ComplaintsScreen({
    super.key,
  });

  @override
  State<ComplaintsScreen>
      createState() =>
          _ComplaintsScreenState();
}

class _ComplaintsScreenState
    extends State<
        ComplaintsScreen> {

  final TextEditingController
      passengerController =
      TextEditingController();

  final TextEditingController
      complaintController =
      TextEditingController();

  List<Map<String, dynamic>>
      complaints = [];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        backgroundColor:
            Colors.deepPurple,

        title: const Text(
          "Complaints",
        ),
      ),

      body: GridView.count(

        padding:
            const EdgeInsets.all(20),

        crossAxisCount: 2,

        crossAxisSpacing: 15,

        mainAxisSpacing: 15,

        children: [

          card(
            context,
            Icons.add_comment,
            "Add Complaint",
          ),

          card(
            context,
            Icons.edit,
            "Update Complaint",
          ),

          card(
            context,
            Icons.delete,
            "Delete Complaint",
          ),

          card(
            context,
            Icons.report,
            "View Complaints",
          ),
        ],
      ),
    );
  }

  Widget card(

    BuildContext context,
    IconData icon,
    String title,
  ) {

    return InkWell(

      onTap: () {

        if (title ==
            "Add Complaint") {

          showComplaintDialog();
        }

        else if (title ==
            "View Complaints") {

          showComplaintList();
        }

        else if (title ==
            "Delete Complaint") {

          if (complaints
              .isNotEmpty) {

            setState(() {

              complaints
                  .removeAt(0);
            });

            showMsg(
              "Complaint Deleted",
            );
          }
        }

        else if (title ==
            "Update Complaint") {

          if (complaints
              .isNotEmpty) {

            updateDialog(0);
          }
        }
      },

      child: Container(

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
              BorderRadius.circular(
            20,
          ),

          boxShadow: [

            BoxShadow(

              color:
                  Colors.grey.withOpacity(
                0.2,
              ),

              blurRadius: 5,
            ),
          ],
        ),

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              icon,
              size: 40,
              color: Colors.deepPurple,
            ),

            const SizedBox(
              height: 10,
            ),

            Text(title),
          ],
        ),
      ),
    );
  }

  void showComplaintDialog() {

    showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Add Complaint",
          ),

          content: Column(

            mainAxisSize:
                MainAxisSize.min,

            children: [

              TextField(

                controller:
                    passengerController,

                decoration:
                    const InputDecoration(

                  labelText:
                      "Passenger Name",
                ),
              ),

              TextField(

                controller:
                    complaintController,

                decoration:
                    const InputDecoration(

                  labelText:
                      "Complaint",
                ),
              ),
            ],
          ),

          actions: [

            ElevatedButton(

              onPressed: () {

                setState(() {

                  complaints.add({

                    "passenger":
                        passengerController
                            .text,

                    "complaint":
                        complaintController
                            .text,
                  });
                });

                Navigator.pop(
                  context,
                );

                showMsg(
                  "Complaint Added",
                );
              },

              child: const Text(
                "Add",
              ),
            ),
          ],
        );
      },
    );
  }

  void updateDialog(
    int index,
  ) {

    passengerController.text =
        complaints[index]["passenger"];

    complaintController.text =
        complaints[index]["complaint"];

    showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Update Complaint",
          ),

          content: Column(

            mainAxisSize:
                MainAxisSize.min,

            children: [

              TextField(
                controller:
                    passengerController,
              ),

              TextField(
                controller:
                    complaintController,
              ),
            ],
          ),

          actions: [

            ElevatedButton(

              onPressed: () {

                setState(() {

                  complaints[index] = {

                    "passenger":
                        passengerController
                            .text,

                    "complaint":
                        complaintController
                            .text,
                  };
                });

                Navigator.pop(
                  context,
                );

                showMsg(
                  "Complaint Updated",
                );
              },

              child: const Text(
                "Update",
              ),
            ),
          ],
        );
      },
    );
  }

  void showComplaintList() {

    showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Complaints",
          ),

          content: SizedBox(

            width: double.maxFinite,

            child: ListView.builder(

              shrinkWrap: true,

              itemCount:
                  complaints.length,

              itemBuilder:
                  (context, index) {

                return ListTile(

                  leading:
                      const Icon(
                    Icons.report,
                  ),

                  title: Text(

                    complaints[index]
                        ["passenger"],
                  ),

                  subtitle: Text(

                    complaints[index]
                        ["complaint"],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void showMsg(String msg) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(
        content: Text(msg),
      ),
    );
  }
}