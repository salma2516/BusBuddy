import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'admin_dashboard.dart';
import 'driver_dashboard.dart';
import 'passenger_dashboard.dart';
import 'conductor_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final TextEditingController
      emailController =
      TextEditingController();

  final TextEditingController
      passwordController =
      TextEditingController();

  final FlutterSecureStorage
      storage =
      const FlutterSecureStorage();

  bool isLoading = false;

  final String baseUrl =
      "http://10.131.101.232:5000";

  Future<void> login() async {
    if (emailController.text
            .trim()
            .isEmpty ||
        passwordController.text
            .trim()
            .isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Enter Email & Password",
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await http.post(
        Uri.parse(
          "$baseUrl/api/auth/login",
        ),
        headers: {
          "Content-Type":
              "application/json",
        },
        body: jsonEncode({
          "email":
              emailController.text
                  .trim(),
          "password":
              passwordController.text
                  .trim(),
        }),
      );

      print(
          "STATUS CODE: ${response.statusCode}");
      print(
          "RESPONSE: ${response.body}");

      final data =
          jsonDecode(response.body);

      if (response.statusCode ==
              200 &&
          data["success"] ==
              true) {
        await storage.write(
          key: "token",
          value: data["token"]
              .toString(),
        );

        await storage.write(
          key: "role",
          value: data["user"]["role"]
              .toString(),
        );

        await storage.write(
          key: "name",
          value: data["user"]["name"]
              .toString(),
        );

        if (!mounted) return;

        String role =
            data["user"]["role"]
                .toString();

        if (role == "ADMIN") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AdminDashboard(),
            ),
          );
        } else if (role ==
            "DRIVER") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const DriverDashboard(),
            ),
          );
        } else if (role ==
            "PASSENGER") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const PassengerDashboard(),
            ),
          );
        } else if (role ==
            "CONDUCTOR") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const ConductorDashboard(),
            ),
          );
        }
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              data["message"]
                      ?.toString() ??
                  "Login Failed",
            ),
          ),
        );
      }
    } catch (e) {
      print(
          "LOGIN ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Server Error\n$e",
          ),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "BusBuddy Login",
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(
          20,
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),

            TextField(
              controller:
                  emailController,
              keyboardType:
                  TextInputType
                      .emailAddress,
              decoration:
                  const InputDecoration(
                labelText:
                    "Email",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            TextField(
              controller:
                  passwordController,
              obscureText: true,
              decoration:
                  const InputDecoration(
                labelText:
                    "Password",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            SizedBox(
              width:
                  double.infinity,
              height: 50,
              child:
                  ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : login,
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors
                            .white,
                      )
                    : const Text(
                        "Login",
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}