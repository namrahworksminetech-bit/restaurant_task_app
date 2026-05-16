import 'package:flutter/material.dart';

class ErrorFallbackWidget
    extends StatelessWidget {
  final String message;

  final VoidCallback onRetry;

  const ErrorFallbackWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 70,
              color: Colors.red.shade300,
            ),

            const SizedBox(height: 18),

            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              message,
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    Colors.grey.shade700,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh,
              ),
              label:
                  const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}