// ==========================================
// REVENUE SCREEN
// ==========================================

import 'package:flutter/material.dart';

class RevenueScreen
    extends StatefulWidget {

  const RevenueScreen({
    super.key,
  });

  @override
  State<RevenueScreen>
      createState() =>
          _RevenueScreenState();
}

class _RevenueScreenState
    extends State<
        RevenueScreen> {

  final TextEditingController
      dateController =
      TextEditingController();

  final TextEditingController
      amountController =
      TextEditingController();

  List<Map<String, dynamic>>
      revenues = [];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        backgroundColor:
            Colors.deepPurple,

        title: const Text(
          "Revenue Analytics",
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
            Icons.add_chart,
            "Add Revenue",
          ),

          card(
            context,
            Icons.edit,
            "Update Revenue",
          ),

          card(
            context,
            Icons.delete,
            "Delete Revenue",
          ),

          card(
            context,
            Icons.bar_chart,
            "View Revenue",
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
            "Add Revenue") {

          showRevenueDialog();
        }

        else if (title ==
            "View Revenue") {

          showRevenueList();
        }

        else if (title ==
            "Delete Revenue") {

          if (revenues
              .isNotEmpty) {

            setState(() {

              revenues
                  .removeAt(0);
            });

            showMsg(
              "Revenue Deleted",
            );
          }
        }

        else if (title ==
            "Update Revenue") {

          if (revenues
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

  void showRevenueDialog() {

    showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Add Revenue",
          ),

          content: Column(

            mainAxisSize:
                MainAxisSize.min,

            children: [

              TextField(

                controller:
                    dateController,

                decoration:
                    const InputDecoration(

                  labelText:
                      "Date",
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
            ],
          ),

          actions: [

            ElevatedButton(

              onPressed: () {

                setState(() {

                  revenues.add({

                    "date":
                        dateController.text,

                    "amount":
                        amountController
                            .text,
                  });
                });

                Navigator.pop(
                  context,
                );

                showMsg(
                  "Revenue Added",
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

    dateController.text =
        revenues[index]["date"];

    amountController.text =
        revenues[index]["amount"];

    showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Update Revenue",
          ),

          content: Column(

            mainAxisSize:
                MainAxisSize.min,

            children: [

              TextField(
                controller:
                    dateController,
              ),

              TextField(
                controller:
                    amountController,
              ),
            ],
          ),

          actions: [

            ElevatedButton(

              onPressed: () {

                setState(() {

                  revenues[index] = {

                    "date":
                        dateController.text,

                    "amount":
                        amountController
                            .text,
                  };
                });

                Navigator.pop(
                  context,
                );

                showMsg(
                  "Revenue Updated",
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

  void showRevenueList() {

    showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Revenue List",
          ),

          content: SizedBox(

            width: double.maxFinite,

            child: ListView.builder(

              shrinkWrap: true,

              itemCount:
                  revenues.length,

              itemBuilder:
                  (context, index) {

                return ListTile(

                  leading:
                      const Icon(
                    Icons.currency_rupee,
                  ),

                  title: Text(

                    revenues[index]
                        ["date"],
                  ),

                  subtitle: Text(

                    "₹${revenues[index]["amount"]}",
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