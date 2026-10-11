import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {

  final TextEditingController
      nameController =
      TextEditingController(
    text: "Admin",
  );

  final TextEditingController
      emailController =
      TextEditingController(
    text: "admin@busbuddy.com",
  );

  final TextEditingController
      phoneController =
      TextEditingController(
    text: "9876543210",
  );

  final TextEditingController
      passwordController =
      TextEditingController();

  void updateProfile() {

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
                    15),
          ),

          title: const Row(
            children: [

              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),

              SizedBox(width: 10),

              Text(
                "Profile Updated",
              ),
            ],
          ),

          content: const Text(
            "Your profile has been updated successfully.",
          ),

          actions: [

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                    context);
              },
              child: const Text(
                "OK",
              ),
            ),
          ],
        );
      },
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
          "Settings",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(
                16),

        child: Column(

          children: [

            Row(
              children: [

                Expanded(
                  child: statCard(
                    "Role",
                    "Admin",
                    Icons.admin_panel_settings,
                  ),
                ),

                const SizedBox(
                    width: 10),

                Expanded(
                  child: statCard(
                    "Status",
                    "Active",
                    Icons.verified,
                  ),
                ),

                const SizedBox(
                    width: 10),

                Expanded(
                  child: statCard(
                    "System",
                    "BusBuddy",
                    Icons.directions_bus,
                  ),
                ),
              ],
            ),

            const SizedBox(
                height: 20),

            Card(
              elevation: 4,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                        15),
              ),

              child: Padding(

                padding:
                    const EdgeInsets.all(
                        16),

                child: Column(

                  children: [

                    TextField(
                      controller:
                          nameController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            "Name",
                        prefixIcon:
                            Icon(
                          Icons.person,
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 12),

                    TextField(
                      controller:
                          emailController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            "Email",
                        prefixIcon:
                            Icon(
                          Icons.email,
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 12),

                    TextField(
                      controller:
                          phoneController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            "Phone Number",
                        prefixIcon:
                            Icon(
                          Icons.phone,
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 12),

                    TextField(
                      controller:
                          passwordController,
                      obscureText: true,
                      decoration:
                          const InputDecoration(
                        labelText:
                            "New Password",
                        prefixIcon:
                            Icon(
                          Icons.lock,
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 20),

                    SizedBox(
                      width:
                          double.infinity,

                      height: 50,

                      child:
                          ElevatedButton(

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                            0xFF6C3DF4,
                          ),
                        ),

                        onPressed:
                            updateProfile,

                        child:
                            const Text(
                          "Update Profile",
                          style:
                              TextStyle(
                            color:
                                Colors.white,
                            fontSize:
                                16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget statCard(
    String title,
    String value,
    IconData icon,
  ) {

    return Container(

      padding:
          const EdgeInsets.all(
              15),

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
            blurRadius: 6,
          ),
        ],
      ),

      child: Column(

        children: [

          Icon(
            icon,
            color:
                const Color(
              0xFF6C3DF4,
            ),
            size: 30,
          ),

          const SizedBox(
              height: 10),

          Text(
            title,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
              height: 5),

          Text(
            value,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF6C3DF4,
              ),
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}