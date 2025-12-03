import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/tracker_provider.dart';
import '../../../core/services/device_service.dart';
import '../../../config/theme/app_theme.dart';
import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/widgets.dart';

/// Pantalla para configurar el dispositivo como rastreador de un hijo
/// Usa escaneo de código QR para configuración rápida
class ChildSetupScreen extends ConsumerStatefulWidget {
  static const String name = 'child-setup';

  const ChildSetupScreen({super.key});

  @override
  ConsumerState<ChildSetupScreen> createState() => _ChildSetupScreenState();
}

class _ChildSetupScreenState extends ConsumerState<ChildSetupScreen> {
  bool _isLoading = false;
  bool _isScanning = false;
  String? _deviceInfo;
  String? _errorMessage;
  MobileScannerController? _scannerController;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
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
    if (_isLoading) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null) return;

    // Detener escáner inmediatamente
    _stopScanning();

    // Parsear QR
    try {
      final data = jsonDecode(code) as Map<String, dynamic>;
      final childId = data['childId'] as int?;
      final childName = data['childName'] as String?;
      final schoolId = data['schoolId'] as int?;

      if (childId == null || childName == null) {
        setState(() {
          _errorMessage =
              'Código QR inválido. Genera uno nuevo desde la app de padres.';
        });
        return;
      }

      // Configurar dispositivo con datos del QR
      await _configure(
        childId: childId,
        childName: childName,
        schoolId: schoolId,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudo leer el código QR. Intenta de nuevo.';
      });
    }
  }

  Future<void> _configure({
    required int childId,
    required String childName,
    int? schoolId,
  }) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await ref
        .read(trackerNotifierProvider.notifier)
        .configure(childId: childId, childName: childName, schoolId: schoolId);

    setState(() => _isLoading = false);

    if (success && mounted) {
      context.go('/child/tracking');
    } else {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al configurar dispositivo. Intenta de nuevo.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return AnimatedBackground(
      style: BackgroundStyle.surface,
      animated: true,
      intensity: 0.6,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: _isScanning
              ? _buildScannerView(r, isDark)
              : _buildSetupView(r, isDark, textColor, subtitleColor),
        ),
      ),
    );
  }

  Widget _buildSetupView(
    Responsive r,
    bool isDark,
    Color textColor,
    Color subtitleColor,
  ) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Botón de regreso
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => context.go('/mode'),
              icon: Icon(Icons.arrow_back_ios_new, color: textColor),
            ),
          ),

          SizedBox(height: r.hp(2)),

          // Icono
          Center(
            child: Container(
              padding: EdgeInsets.all(r.wp(6)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.phone_android,
                size: r.dp(8),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          SizedBox(height: r.hp(3)),

          // Título
          Text(
            'Configurar Rastreador',
            style: TextStyle(
              fontSize: r.dp(2.8),
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: r.hp(1)),

          Text(
            'Este dispositivo enviará la ubicación del niño',
            style: TextStyle(fontSize: r.dp(1.7), color: subtitleColor),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: r.hp(4)),

          // Card principal
          GlassCard(
            padding: EdgeInsets.all(AppTheme.spacingLarge),
            borderRadius: AppTheme.borderRadiusLarge,
            child: Column(
              children: [
                // Error message
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppTheme.spacingNormal),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColorLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusNormal,
                      ),
                      border: Border.all(
                        color: AppTheme.errorColorLight.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppTheme.errorColorLight,
                          size: r.dp(2.2),
                        ),
                        SizedBox(width: r.wp(2)),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: AppTheme.errorColorLight,
                              fontSize: r.dp(1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: r.hp(2)),
                ],

                // Info del dispositivo
                if (_deviceInfo != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppTheme.spacingNormal),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusNormal,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.smartphone,
                          color: subtitleColor,
                          size: r.dp(2.5),
                        ),
                        SizedBox(width: r.wp(3)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dispositivo',
                                style: TextStyle(
                                  fontSize: r.dp(1.4),
                                  color: subtitleColor,
                                ),
                              ),
                              Text(
                                _deviceInfo!,
                                style: TextStyle(
                                  fontSize: r.dp(1.7),
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: r.hp(3)),

                // Instrucciones
                Icon(
                  Icons.qr_code_scanner,
                  size: r.dp(6),
                  color: Theme.of(context).colorScheme.primary,
                ),

                SizedBox(height: r.hp(2)),

                Text(
                  'Escanea el código QR',
                  style: TextStyle(
                    fontSize: r.dp(2),
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: r.hp(1)),

                Text(
                  'Pide al padre/madre que genere un código QR desde su app o panel web',
                  style: TextStyle(fontSize: r.dp(1.5), color: subtitleColor),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: r.hp(3)),

                // Botón escanear
                CustomFilledButton(
                  text: _isLoading ? 'Configurando...' : 'Escanear código QR',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _startScanning,
                  buttonColor: AppTheme.primaryColor,
                ),
              ],
            ),
          ),

          SizedBox(height: r.hp(2)),

          // Nota informativa
          GlassCard(
            padding: EdgeInsets.all(AppTheme.spacingNormal),
            borderRadius: AppTheme.borderRadiusNormal,
            backgroundColor: AppTheme.infoColor.withValues(
              alpha: isDark ? 0.15 : 0.1,
            ),
            borderColor: AppTheme.infoColor.withValues(alpha: 0.2),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.infoColor,
                  size: r.dp(2.5),
                ),
                SizedBox(width: r.wp(3)),
                Expanded(
                  child: Text(
                    'El código QR contiene la información necesaria para vincular este dispositivo con el perfil del niño.',
                    style: TextStyle(
                      fontSize: r.dp(1.4),
                      color: isDark ? Colors.white70 : AppTheme.infoColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerView(Responsive r, bool isDark) {
    return Stack(
      children: [
        // Scanner
        MobileScanner(controller: _scannerController, onDetect: _onQRDetected),

        // Overlay
        Container(
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5)),
          child: Stack(
            children: [
              // Área de escaneo transparente
              Center(
                child: Container(
                  width: r.wp(70),
                  height: r.wp(70),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              // Texto superior
              Positioned(
                top: r.hp(8),
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      'Apunta al código QR',
                      style: TextStyle(
                        fontSize: r.dp(2.2),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: r.hp(1)),
                    Text(
                      'Coloca el código dentro del recuadro',
                      style: TextStyle(
                        fontSize: r.dp(1.6),
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Botón cancelar
              Positioned(
                bottom: r.hp(6),
                left: AppTheme.spacingLarge,
                right: AppTheme.spacingLarge,
                child: GlassCard(
                  onTap: _stopScanning,
                  padding: EdgeInsets.symmetric(
                    vertical: AppTheme.spacingNormal,
                    horizontal: AppTheme.spacingLarge,
                  ),
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close, color: Colors.white, size: r.dp(2.5)),
                      SizedBox(width: r.wp(2)),
                      Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: r.dp(1.8),
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
