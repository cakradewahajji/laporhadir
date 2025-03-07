import 'package:flutter/material.dart';
import 'dart:async';

class AnimatedLoginScreen extends StatefulWidget {
  const AnimatedLoginScreen({Key? key}) : super(key: key);

  @override
  _AnimatedLoginScreenState createState() => _AnimatedLoginScreenState();
}

class _AnimatedLoginScreenState extends State<AnimatedLoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cek apakah keyboard aktif dengan memeriksa viewInsets
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    // Tentukan tinggi ilustrasi, jika keyboard aktif, tinggi jadi 0
    final double illustrationHeight =
        isKeyboardOpen ? 0 : MediaQuery.of(context).size.height * 0.4;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              // Ilustrasi dengan AnimatedContainer untuk transisi halus
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: illustrationHeight,
                // padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                child:
                    illustrationHeight > 0
                        ? Image.asset(
                          'assets/images/otp.gif',
                          fit: BoxFit.contain,
                        )
                        : null,
              ),
              // Form login
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1F2452),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 32.0,
                    ),
                    child: SingleChildScrollView(
                      // Agar form dapat discroll saat keyboard muncul
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome to DWS Mobile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Field Email
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.email),
                                hintText: 'Username',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Field Password
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              obscureText: true,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock),
                                hintText: 'Password',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            // child: TextButton(
                            //   onPressed: () {
                            //     // Aksi untuk forgot password
                            //   },
                            //   // child: const Text(
                            //   //   'Forgot password?',
                            //   //   style: TextStyle(
                            //   //     color: Colors.white70,
                            //   //     fontSize: 14,
                            //   //   ),
                            //   // ),
                            // ),
                          ),
                          const SizedBox(height: 16),
                          // Tombol Sign-in
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                // Aksi sign-in (panggil API, dll.)
                                Navigator.pushNamed(context, '/otp');
                              },
                              child: const Text(
                                'Sign-in',
                                style: TextStyle(
                                  color: Color(0xFF1F2452),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Tambahan informasi copyright dan versi aplikasi
                          Center(
                            child: Column(
                              children: const [
                                Text(
                                  'Copyright by Pusdatik',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'DWS Mobile versi 1.0',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
