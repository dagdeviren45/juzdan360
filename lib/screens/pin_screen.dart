import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import 'home_screen.dart';

class PinScreen extends StatefulWidget {
  final String expectedPin;

  const PinScreen({super.key, required this.expectedPin});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _enteredPin = '';
  bool _isError = false;

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
        _isError = false;
      });

      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _isError = false;
      });
    }
  }

  void _verifyPin() async {
    // Small delay to let user see 4th dot
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    if (_enteredPin == widget.expectedPin) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else {
      setState(() {
        _enteredPin = '';
        _isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const Icon(Icons.lock_outline, size: 64, color: AppConstants.primaryGold),
            const SizedBox(height: 24),
            Text(
              'Uygulama PIN Kodunuzu Girin',
              style: TextStyle(color: AppConstants.textLight.withOpacity(0.8), fontSize: 16),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isError ? Colors.red : AppConstants.primaryGold,
                      width: 2,
                    ),
                    color: isFilled
                        ? (_isError ? Colors.red : AppConstants.primaryGold)
                        : Colors.transparent,
                  ),
                );
              }),
            ),
            if (_isError) ...[
              const SizedBox(height: 16),
              const Text('Hatalı Şifre!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                children: [
                  _buildNumRow(['1', '2', '3']),
                  const SizedBox(height: 16),
                  _buildNumRow(['4', '5', '6']),
                  const SizedBox(height: 16),
                  _buildNumRow(['7', '8', '9']),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNumButton('', isTransparent: true),
                      _buildNumButton('0'),
                      _buildNumButton('<', isDelete: true),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildNumRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((n) => _buildNumButton(n)).toList(),
    );
  }

  Widget _buildNumButton(String text, {bool isDelete = false, bool isTransparent = false}) {
    if (isTransparent) {
      return const SizedBox(width: 72, height: 72);
    }

    return GestureDetector(
      onTap: () {
        if (isDelete) {
          _onDeletePressed();
        } else {
          _onNumberPressed(text);
        }
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppConstants.cardDark,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: isDelete
              ? const Icon(Icons.backspace_outlined, color: AppConstants.textLight, size: 28)
              : Text(
                  text,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppConstants.textLight),
                ),
        ),
      ),
    );
  }
}
