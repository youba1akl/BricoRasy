import 'package:flutter/material.dart';

class ErrorWidgetCustom extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorWidgetCustom({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image (make sure you have this asset)
            Image.asset(
              'assets/images/default02.png',  // Change to your asset path
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),

            // "Opps!...." title
            const Text(
              'Opps!....',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Small description
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),

            // Retry Button
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,  // Light blue theme
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
