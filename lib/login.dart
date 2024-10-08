import 'package:flutter/material.dart';
import 'package:schedule_web_app/main.dart'; // Ensure the path is correct

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  String? _errorMessage;

  void _login() {
    // Replace these with the actual usernames
    if (_usernameController.text == "your_username") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(user: "User 1")),
      );
    } else if (_usernameController.text == "girlfriend_username") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(user: "User 2")),
      );
    } else {
      setState(() {
        _errorMessage = "Invalid username";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 8),
            ElevatedButton(onPressed: _login, child: Text('Login')),
            if (_errorMessage != null) ...[
              SizedBox(height: 8),
              Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
