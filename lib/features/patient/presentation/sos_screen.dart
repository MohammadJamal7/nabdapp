import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../shared/theme/app_theme.dart';
import '../presentation/patient_providers.dart';

class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen> {
  int _countdown = 10;
  bool _isTriggered = false;
  bool _isLoading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          timer.cancel();
          _triggerSos();
        }
      });
    });
  }

  void _cancelCountdown() {
    _timer?.cancel();
    Navigator.pop(context);
  }

  Future<void> _triggerSos() async {
    setState(() => _isTriggered = true);

    double? latitude;
    double? longitude;

    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final position = await Geolocator.getCurrentPosition();
      latitude = position.latitude;
      longitude = position.longitude;
    } catch (_) {}

    setState(() => _isLoading = true);

    try {
      await ref.read(alertsNotifierProvider.notifier).createSos(
        latitude: latitude,
        longitude: longitude,
      );

      if (mounted) {
        _showSosConfirmation();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSosConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.secondaryColor, size: 32),
            SizedBox(width: 12),
            Text('تم إرسال النداء'),
          ],
        ),
        content: const Text(
          'تم إرسال نداء الطوارئ لمقدمي الرعاية为你设置了紧急警报。照顾者将收到通知。',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isTriggered ? AppTheme.sosColor : Colors.black87,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isTriggered) ...[
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 100,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'سيتم إرسال نداء الطوارئ خلال',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '$_countdown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 120,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'ثانية',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: _cancelCountdown,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.sosColor,
                      ),
                      child: const Text('إلغاء'),
                    ),
                  ),
                ] else ...[
                  if (_isLoading) ...[
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 24),
                    const Text(
                      'جاري إرسال النداء...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ] else ...[
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 100,
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'تم إرسال نداء الطوارئ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'مقدمو الرعايةتم إخطار照顾者已被通知。',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.sosColor,
                      ),
                      child: const Text('العودة للشاشة الرئيسية'),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}