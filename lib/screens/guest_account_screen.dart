import 'package:flutter/material.dart';

class GuestAccountScreen extends StatelessWidget {
  const GuestAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to auth screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('Sign In')),
                  body: const Center(child: Text('Sign In Page Content')),
                ),
              ),
            );
          },
          child: const Text('Go to Sign In'),
        ),
      ),
    );
  }
}