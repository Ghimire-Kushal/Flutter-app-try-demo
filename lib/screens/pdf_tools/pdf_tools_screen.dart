import 'package:flutter/material.dart';

class PdfToolsScreen extends StatelessWidget {
  const PdfToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tools = [
      _Tool('Image to PDF', 'Convert photos to PDF document', Icons.image_rounded, const Color(0xFFF57C00)),
      _Tool('Merge PDF', 'Combine multiple PDFs into one', Icons.merge_type_rounded, const Color(0xFF5C6BC0)),
      _Tool('Compress PDF', 'Reduce PDF file size', Icons.compress_rounded, const Color(0xFF26A69A)),
      _Tool('Scan Document', 'Scan physical documents', Icons.document_scanner_rounded, const Color(0xFFEC407A)),
      _Tool('Share PDF', 'Share PDF via any app', Icons.share_rounded, const Color(0xFF42A5F5)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Tools', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: cs.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "PDF features require additional packages (pdf, image_picker, share_plus). The UI is ready — tap any tool to see what's needed.",
                      style: TextStyle(fontSize: 12, color: cs.onPrimaryContainer, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...tools.map((tool) => _buildToolCard(context, tool, cs)),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, _Tool tool, ColorScheme cs) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: tool.color.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: tool.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(tool.icon, color: tool.color, size: 26),
        ),
        title: Text(tool.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(tool.description, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey[400]),
        onTap: () => _showComingSoon(context, tool.name, tool.color),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String name, Color color) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(Icons.construction_rounded, color: color, size: 30),
            ),
            const SizedBox(height: 16),
            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'This feature requires the following packages:\n• pdf\n• image_picker\n• share_plus\n\nAdd them to pubspec.yaml and implement the functionality.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tool {
  final String name, description;
  final IconData icon;
  final Color color;
  _Tool(this.name, this.description, this.icon, this.color);
}
