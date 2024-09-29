import 'package:flutter/material.dart';
import 'home.dart';
import 'register_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    final loginData = {
      'officerId': _usernameController.text,
      'password': _passwordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('https://st3y.helioho.st/login.php'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(loginData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['error'] != null) {
          setState(() {
            _errorMessage = responseData['error'];
          });
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SafeSyncDashboard()),
          );
        }
      } else {
        setState(() {
          _errorMessage =
              "Failed to login. Status code: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Exception: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background - loginpage.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 60.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo - loginpage.png',
                    fit: BoxFit.cover,
                    width: 240,
                    height: 240,
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Officer ID',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 15),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.indigo),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 15),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.indigo),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            const Color(0xFF0ABF74)),
                        foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.white),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 40,
                              width: 180,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : const SizedBox(
                              height: 40,
                              width: 180,
                              child: Center(
                                child: Text('Sign In'),
                              ),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all<Color>(Colors.white),
                        foregroundColor: WidgetStateProperty.all<Color>(
                            const Color(0xFF0ABF74)),
                      ),
                      child: const SizedBox(
                        height: 40,
                        width: 180,
                        child: Center(
                          child: Text('Create Account'),
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
    );
  }
}
