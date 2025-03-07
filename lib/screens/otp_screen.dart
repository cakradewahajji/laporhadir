import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({Key? key}) : super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  Timer? _timer;
  int _secondsRemaining = 120;

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

    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 120;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _resendCode() {
    // Logika pemanggilan API untuk mengirim ulang OTP bisa ditambahkan di sini.
    // Setelah itu, reset timer kembali ke 120 detik.
    _startTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Deteksi apakah keyboard aktif
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    // Atur tinggi ilustrasi (collapse saat keyboard aktif)
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
              // Form OTP
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Verifikasi OTP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Masukkan kode OTP yang telah dikirim ke email/nomor Anda.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Field input OTP (hanya angka, maksimal 6 digit, dengan placeholder underscore)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              // autofocus: true,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              maxLength: 6,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.message),
                                hintText: '______',
                                counterText: '', // Menghilangkan teks counter
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Timer dan tombol Resend Code
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Waktu tersisa: $_secondsRemaining detik',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed:
                                    _secondsRemaining == 0 ? _resendCode : null,
                                child: const Text(
                                  'Resend Code',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Tombol Verifikasi OTP
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
                                // Panggil API untuk verifikasi OTP, jika sukses pindah ke dashboard
                                Navigator.pushNamed(context, '/dashboard');
                              },
                              child: const Text(
                                'Verifikasi',
                                style: TextStyle(
                                  color: Color(0xFF1F2452),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Tombol untuk kembali ke halaman Login
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Kembali ke Login',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Footer: Copyright dan versi aplikasi
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
