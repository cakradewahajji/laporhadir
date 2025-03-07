import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart'; // Sesuaikan path-nya

class AnimatedLoginScreen extends StatefulWidget {
  const AnimatedLoginScreen({Key? key}) : super(key: key);

  @override
  _AnimatedLoginScreenState createState() => _AnimatedLoginScreenState();
}

class _AnimatedLoginScreenState extends State<AnimatedLoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  // Controller untuk menangani input email dan password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cek apakah keyboard aktif
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final double illustrationHeight =
        isKeyboardOpen ? 0 : MediaQuery.of(context).size.height * 0.4;

    // Mengakses AuthProvider
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              // Ilustrasi dengan AnimatedContainer
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: illustrationHeight,
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
                              controller: _emailController,
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
                              controller: _passwordController,
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
                          // Tampilkan error jika ada
                          if (auth.error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                auth.error!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
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
                              onPressed:
                                  auth.loading
                                      ? null
                                      : () {
                                        // Panggil login melalui AuthProvider
                                        auth.login(
                                          _emailController.text.trim(),
                                          _passwordController.text,
                                          context,
                                        );
                                      },
                              child:
                                  auth.loading
                                      ? const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Color(0xFF1F2452),
                                            ),
                                      )
                                      : const Text(
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
                          // Informasi tambahan (copyright, versi)
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
