import 'package:flutter/material.dart';

// Simple test widget to verify image loading
class ImageTestScreen extends StatelessWidget {
  const ImageTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Testing spy_1.png:'),
            const SizedBox(height: 20),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(60),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.asset(
                  'assets/images/spies/spy_1.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('❌ Test: Image loading failed: $error');
                    return Container(
                      width: 120,
                      height: 120,
                      color: Colors.red.withOpacity(0.3),
                      child: const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 48,
                      ),
                    );
                  },
                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                    if (frame != null) {
                      print('✅ Test: Image loaded successfully!');
                    }
                    return child;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
