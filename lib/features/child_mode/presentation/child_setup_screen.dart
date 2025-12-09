import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/tracker_provider.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/device_service.dart';
import '../../../config/theme/app_theme.dart';

/// Pantalla para configurar el dispositivo como rastreador de un hijo
class ChildSetupScreen extends ConsumerStatefulWidget {
  static const String name = 'child-setup';

  const ChildSetupScreen({super.key});

  @override
  ConsumerState<ChildSetupScreen> createState() => _ChildSetupScreenState();
}

class _ChildSetupScreenState extends ConsumerState<ChildSetupScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isScanning = false;
  bool _isProcessingQR = false; // Prevenir detecciones múltiples
  String? _deviceInfo;
  String? _errorMessage;
  MobileScannerController? _scannerController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
    _setupAnimations();
    _fadeController.forward();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
  }

  Future<void> _loadDeviceInfo() async {
    final deviceService = DeviceService();
    final data = await deviceService.getDeviceData();
    setState(() {
      _deviceInfo = '${data.manufacturer ?? ''} ${data.model ?? ''}'.trim();
      if (_deviceInfo!.isEmpty) {
        _deviceInfo = data.name;
      }
    });
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _errorMessage = null;
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
      );
    });
  }

  void _stopScanning() {
    _scannerController?.dispose();
    setState(() {
      _isScanning = false;
      _scannerController = null;
    });
  }

  Future<void> _onQRDetected(BarcodeCapture capture) async {
    // Prevenir detecciones múltiples
    if (_isLoading || _isProcessingQR) return;
    _isProcessingQR = true;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) {
      _isProcessingQR = false;
      return;
    }

    final String? code = barcodes.first.rawValue;
    if (code == null) {
      _isProcessingQR = false;
      return;
    }

    _stopScanning();

    try {
      developer.log('QR code detected: $code', name: 'ChildSetup');
      final data = jsonDecode(code) as Map<String, dynamic>;
      final childId = data['childId'] as int?;
      final childName = data['childName'] as String?;
      final schoolId = data['schoolId'] as int?;

      developer.log(
        'Parsed QR: childId=$childId, childName=$childName, schoolId=$schoolId',
        name: 'ChildSetup',
      );

      if (childId == null || childName == null || schoolId == null) {
        _isProcessingQR = false;
        setState(() {
          _errorMessage =
              'Código QR inválido. Genera uno nuevo desde la app de padres.';
        });
        return;
      }

      await _configure(
        childId: childId,
        childName: childName,
        schoolId: schoolId,
      );
    } catch (e) {
      developer.log('QR parse error: $e', name: 'ChildSetup');
      _isProcessingQR = false;
      setState(() {
        _errorMessage = 'No se pudo leer el código QR. Intenta de nuevo.';
      });
    }
  }

  Future<void> _configure({
    required int childId,
    required String childName,
    required int schoolId,
  }) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    developer.log('Configuring device...', name: 'ChildSetup');

    final success = await ref
        .read(trackerNotifierProvider.notifier)
        .configure(childId: childId, childName: childName, schoolId: schoolId);

    developer.log(
      'Configure result: $success, mounted: $mounted',
      name: 'ChildSetup',
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      // Analytics en try-catch para que no afecte el flujo principal
      try {
        final analytics = AnalyticsService();
        await analytics.logQrScanned(success: true);
        await analytics.logChildLinked(childId: childId, schoolId: schoolId);
      } catch (e) {
        developer.log('Analytics error (ignored): $e', name: 'ChildSetup');
      }
      developer.log('Navigating to /child/tracking', name: 'ChildSetup');
      if (mounted) context.go('/child/tracking');
    } else {
      try {
        await AnalyticsService().logQrScanned(
          success: false,
          error: 'configuration_failed',
        );
      } catch (e) {
        developer.log('Analytics error (ignored): $e', name: 'ChildSetup');
      }
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al configurar dispositivo. Intenta de nuevo.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                : [Colors.grey.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: _isScanning
              ? _buildScannerView(isDark)
              : _buildSetupView(theme, isDark),
        ),
      ),
    );
  }

  Widget _buildSetupView(ThemeData theme, bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            // Botón de regreso
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => context.go('/mode'),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: theme.colorScheme.onSurface,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.shade100,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Logo
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondaryColor.withOpacity(0.2),
                      blurRadius: 25,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Image.asset(
                    'assets/geofencing_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.phone_android_rounded,
                      size: 42,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Título
            Text(
              'Configurar dispositivo',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            Text(
              'Este teléfono enviará la ubicación del niño',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Card principal
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2a2a4a) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Info del dispositivo
                  if (_deviceInfo != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.smartphone_rounded,
                              color: AppTheme.secondaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dispositivo',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _deviceInfo!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 28),

                  // Icono QR
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 36,
                      color: AppTheme.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Escanea el código QR',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Pide al padre/madre que genere un código QR desde su app',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 28),

                  // Botón escanear
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _startScanning,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.qr_code_scanner_rounded, size: 22),
                      label: Text(
                        _isLoading ? 'Configurando...' : 'Escanear código QR',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Nota informativa
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.infoColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.infoColor,
                    size: 22,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'El código QR contiene la información necesaria para vincular este dispositivo.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : AppTheme.infoColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerView(bool isDark) {
    return Stack(
      children: [
        // Scanner
        MobileScanner(controller: _scannerController, onDetect: _onQRDetected),

        // Overlay
        Container(
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.6)),
          child: Stack(
            children: [
              // Área de escaneo transparente
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),

              // Texto superior
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    const Text(
                      'Apunta al código QR',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Coloca el código dentro del recuadro',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Botón cancelar
              Positioned(
                bottom: 50,
                left: 24,
                right: 24,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _stopScanning,
                    icon: const Icon(Icons.close_rounded, size: 22),
                    label: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
