import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  // Generator
  final _textCtrl = TextEditingController();
  final _ssidCtrl = TextEditingController();
  final _wifiPwCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _esewaCtrl = TextEditingController();
  final _esewaAmtCtrl = TextEditingController();

  String _qrData = '';
  String _qrType = 'text';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _textCtrl.dispose();
    _ssidCtrl.dispose();
    _wifiPwCtrl.dispose();
    _urlCtrl.dispose();
    _esewaCtrl.dispose();
    _esewaAmtCtrl.dispose();
    super.dispose();
  }

  void _generate() {
    String data = '';
    switch (_qrType) {
      case 'text':
        data = _textCtrl.text.trim();
        break;
      case 'url':
        data = _urlCtrl.text.trim();
        break;
      case 'wifi':
        if (_ssidCtrl.text.isEmpty) return;
        data = 'WIFI:S:${_ssidCtrl.text};T:WPA;P:${_wifiPwCtrl.text};;';
        break;
      case 'esewa':
        if (_esewaCtrl.text.isEmpty || _esewaAmtCtrl.text.isEmpty) return;
        data = 'esewa://p2p?receiver=${_esewaCtrl.text}&amount=${_esewaAmtCtrl.text}';
        break;
    }
    if (data.isNotEmpty) setState(() => _qrData = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code', style: TextStyle(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Generator'),
            Tab(text: 'Scanner'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildGenerator(context),
          _buildScanner(context),
        ],
      ),
    );
  }

  Widget _buildGenerator(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('QR Type', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              _typeChip('Text', 'text', Icons.text_fields_rounded),
              _typeChip('URL', 'url', Icons.link_rounded),
              _typeChip('WiFi', 'wifi', Icons.wifi_rounded),
              _typeChip('eSewa', 'esewa', Icons.payments_rounded),
            ],
          ),
          const SizedBox(height: 20),
          _buildInputForType(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _generate,
              icon: const Icon(Icons.qr_code_2_rounded),
              label: const Text('Generate QR'),
            ),
          ),
          if (_qrData.isNotEmpty) ...[
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: cs.primary.withOpacity(0.1), blurRadius: 20),
                      ],
                    ),
                    child: QrImageView(
                      data: _qrData,
                      version: QrVersions.auto,
                      size: 220,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _qrData));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data copied to clipboard')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Copy data'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputForType() {
    switch (_qrType) {
      case 'url':
        return TextField(
          controller: _urlCtrl,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Enter URL',
            prefixIcon: Icon(Icons.link_rounded),
          ),
        );
      case 'wifi':
        return Column(
          children: [
            TextField(
              controller: _ssidCtrl,
              decoration: const InputDecoration(
                labelText: 'WiFi Name (SSID)',
                prefixIcon: Icon(Icons.wifi_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _wifiPwCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_rounded),
              ),
            ),
          ],
        );
      case 'esewa':
        return Column(
          children: [
            TextField(
              controller: _esewaCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'eSewa ID / Phone Number',
                prefixIcon: Icon(Icons.phone_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _esewaAmtCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (Rs)',
                prefixIcon: Icon(Icons.payments_rounded),
              ),
            ),
          ],
        );
      default:
        return TextField(
          controller: _textCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Enter text',
            prefixIcon: Icon(Icons.text_fields_rounded),
            alignLabelWithHint: true,
          ),
        );
    }
  }

  Widget _buildScanner(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Center(child: Icon(Icons.qr_code_scanner_rounded, size: 80, color: cs.onPrimaryContainer.withOpacity(0.4))),
                  Positioned(top: 20, left: 20, child: _corner()),
                  Positioned(top: 20, right: 20, child: _corner(flip: true)),
                  Positioned(bottom: 20, left: 20, child: _corner(bottom: true)),
                  Positioned(bottom: 20, right: 20, child: _corner(flip: true, bottom: true)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'QR Scanner',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              'Camera scanning requires the mobile_scanner package. Add it to pubspec.yaml and implement MobileScannerController to enable this feature.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.5),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add mobile_scanner to pubspec.yaml to enable scanning')),
                );
              },
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('Open Camera'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _corner({bool flip = false, bool bottom = false}) {
    return Transform(
      transform: Matrix4.diagonal3Values(flip ? -1.0 : 1.0, bottom ? -1.0 : 1.0, 1.0),
      alignment: Alignment.center,
      child: SizedBox(
        width: 20,
        height: 20,
        child: CustomPaint(
          painter: _CornerPainter(Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  Widget _typeChip(String label, String value, IconData icon) {
    final isSelected = _qrType == value;
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => setState(() {
        _qrType = value;
        _qrData = '';
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? cs.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? cs.primary : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? cs.primary : Colors.grey),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? cs.primary : Colors.grey,
            )),
          ],
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  _CornerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
