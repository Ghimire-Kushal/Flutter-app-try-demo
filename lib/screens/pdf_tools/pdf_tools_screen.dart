import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as spdf;

class PdfToolsScreen extends StatelessWidget {
  const PdfToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      _Tool('Image to PDF', 'Convert photos to PDF document', Icons.image_rounded, const Color(0xFFF57C00), _PdfToolType.imageToPdf),
      _Tool('Merge PDF', 'Combine multiple PDFs into one', Icons.merge_type_rounded, const Color(0xFF5C6BC0), _PdfToolType.mergePdf),
      _Tool('Compress PDF', 'Reduce PDF file size', Icons.compress_rounded, const Color(0xFF26A69A), _PdfToolType.compressPdf),
      _Tool('Scan Document', 'Scan physical documents', Icons.document_scanner_rounded, const Color(0xFFEC407A), _PdfToolType.scanDocument),
      _Tool('Share PDF', 'Share PDF via any app', Icons.share_rounded, const Color(0xFF42A5F5), _PdfToolType.sharePdf),
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
            ...tools.map((tool) => _buildToolCard(context, tool)),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, _Tool tool) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: tool.color.withValues(alpha:0.08), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: tool.color.withValues(alpha:0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(tool.icon, color: tool.color, size: 26),
        ),
        title: Row(
          children: [
            Text(tool.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(tool.description, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey[400]),
        onTap: () {
          switch (tool.type) {
            case _PdfToolType.imageToPdf:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ImageToPdfScreen()));
              break;
            case _PdfToolType.mergePdf:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MergePdfScreen()));
              break;
            case _PdfToolType.compressPdf:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CompressPdfScreen()));
              break;
            case _PdfToolType.scanDocument:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanDocumentScreen()));
              break;
            case _PdfToolType.sharePdf:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SharePdfScreen()));
              break;
          }
        },
      ),
    );
  }
}

enum _PdfToolType { imageToPdf, mergePdf, compressPdf, scanDocument, sharePdf }

class _Tool {
  final String name, description;
  final IconData icon;
  final Color color;
  final _PdfToolType type;
  _Tool(this.name, this.description, this.icon, this.color, this.type);
}

// ─── Image to PDF Screen ───────────────────────────────────────────────────────

class ImageToPdfScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color primaryAccent;

  const ImageToPdfScreen({
    super.key,
    this.title = 'Image to PDF',
    this.subtitle = 'Convert photos to PDF document.',
    this.primaryAccent = const Color(0xFFF57C00),
  });

  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

// ─── Merge PDF Screen ────────────────────────────────────────────────────────

class MergePdfScreen extends StatefulWidget {
  const MergePdfScreen({super.key});

  @override
  State<MergePdfScreen> createState() => _MergePdfScreenState();
}

class _MergePdfScreenState extends State<MergePdfScreen> {
  final List<String> _pdfPaths = [];
  bool _isProcessing = false;
  String? _outputPath;

  Future<void> _pickPdfs() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      allowMultiple: true,
    );

    if (result == null || result.files.isEmpty) return;

    setState(() {
      _pdfPaths.addAll(result.files.where((f) => f.path != null).map((f) => f.path!).toList());
      _outputPath = null;
    });
  }

  void _removePdf(int index) {
    setState(() {
      _pdfPaths.removeAt(index);
      _outputPath = null;
    });
  }

  Future<void> _mergePdfs() async {
    if (_pdfPaths.length < 2) return;
    setState(() => _isProcessing = true);

    try {
      final output = spdf.PdfDocument();

      for (final path in _pdfPaths) {
        final inputDoc = spdf.PdfDocument(inputBytes: await File(path).readAsBytes());
        for (var i = 0; i < inputDoc.pages.count; i++) {
          final page = inputDoc.pages[i];
          final template = page.createTemplate();
          final mergedPage = output.pages.add();
          mergedPage.graphics.drawPdfTemplate(template, Offset.zero);
        }
        inputDoc.dispose();
      }

      final dir = await getTemporaryDirectory();
      final outFile = File('${dir.path}/merged_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await outFile.writeAsBytes(output.saveSync());
      output.dispose();

      setState(() {
        _outputPath = outFile.path;
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDFs merged successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Merge failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _shareMerged() async {
    if (_outputPath == null) return;
    await Share.shareXFiles([XFile(_outputPath!)], text: 'Merged PDF');
  }

  @override
  Widget build(BuildContext context) {
    return _PdfActionScaffold(
      title: 'Merge PDF',
      subtitle: 'Pick two or more PDF files and combine them into one document.',
      accent: const Color(0xFF5C6BC0),
      body: Column(
        children: [
          _PdfActionBar(
            primaryLabel: 'Add PDFs',
            primaryIcon: Icons.picture_as_pdf_rounded,
            primaryColor: const Color(0xFF5C6BC0),
            secondaryLabel: 'Merge Now',
            secondaryIcon: Icons.merge_type_rounded,
            secondaryColor: const Color(0xFF26A69A),
            onPrimary: _pickPdfs,
            onSecondary: _mergePdfs,
            secondaryEnabled: _pdfPaths.length >= 2 && !_isProcessing,
            secondaryBusy: _isProcessing,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _pdfPaths.isEmpty
                ? const _EmptyToolState(
                    icon: Icons.picture_as_pdf_outlined,
                    title: 'No PDF files selected',
                    subtitle: 'Add two or more PDFs to merge them.',
                  )
                : ListView.builder(
                    itemCount: _pdfPaths.length,
                    itemBuilder: (_, index) {
                      final path = _pdfPaths[index];
                      return _PathTile(
                        icon: Icons.picture_as_pdf_rounded,
                        color: const Color(0xFF5C6BC0),
                        title: 'Document ${index + 1}',
                        subtitle: path.split('/').last,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                          onPressed: () => _removePdf(index),
                        ),
                      );
                    },
                  ),
          ),
          if (_outputPath != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Share Merged PDF'),
                  onPressed: _shareMerged,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Compress PDF Screen ─────────────────────────────────────────────────────

class CompressPdfScreen extends StatefulWidget {
  const CompressPdfScreen({super.key});

  @override
  State<CompressPdfScreen> createState() => _CompressPdfScreenState();
}

class _CompressPdfScreenState extends State<CompressPdfScreen> {
  String? _inputPath;
  String? _outputPath;
  bool _isProcessing = false;

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      allowMultiple: false,
    );
    final path = result?.files.single.path;
    if (path == null) return;

    setState(() {
      _inputPath = path;
      _outputPath = null;
    });
  }

  Future<void> _compressPdf() async {
    if (_inputPath == null) return;
    setState(() => _isProcessing = true);

    try {
      final inputDoc = spdf.PdfDocument(inputBytes: await File(_inputPath!).readAsBytes());
      inputDoc.compressionLevel = spdf.PdfCompressionLevel.best;
      final dir = await getTemporaryDirectory();
      final outFile = File('${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await outFile.writeAsBytes(inputDoc.saveSync());
      inputDoc.dispose();

      setState(() {
        _outputPath = outFile.path;
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF compressed successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Compression failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _shareCompressed() async {
    if (_outputPath == null) return;
    await Share.shareXFiles([XFile(_outputPath!)], text: 'Compressed PDF');
  }

  @override
  Widget build(BuildContext context) {
    return _PdfActionScaffold(
      title: 'Compress PDF',
      subtitle: 'Reduce the size of a PDF by re-saving it with stronger compression.',
      accent: const Color(0xFF26A69A),
      body: Column(
        children: [
          _PdfActionBar(
            primaryLabel: 'Choose PDF',
            primaryIcon: Icons.picture_as_pdf_rounded,
            primaryColor: const Color(0xFF26A69A),
            secondaryLabel: 'Compress',
            secondaryIcon: Icons.compress_rounded,
            secondaryColor: const Color(0xFF5C6BC0),
            onPrimary: _pickPdf,
            onSecondary: _compressPdf,
            secondaryEnabled: _inputPath != null && !_isProcessing,
            secondaryBusy: _isProcessing,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _inputPath == null
                ? const _EmptyToolState(
                    icon: Icons.compress_outlined,
                    title: 'No PDF selected',
                    subtitle: 'Choose a PDF file to create a smaller version.',
                  )
                : ListView(
                    children: [
                      _PathTile(
                        icon: Icons.picture_as_pdf_rounded,
                        color: const Color(0xFF26A69A),
                        title: 'Selected PDF',
                        subtitle: _inputPath!.split('/').last,
                      ),
                      if (_outputPath != null)
                        _PathTile(
                          icon: Icons.file_present_rounded,
                          color: const Color(0xFF5C6BC0),
                          title: 'Compressed PDF',
                          subtitle: _outputPath!.split('/').last,
                          trailing: IconButton(
                            icon: const Icon(Icons.share_rounded),
                            onPressed: _shareCompressed,
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Scan Document Screen ────────────────────────────────────────────────────

class ScanDocumentScreen extends StatelessWidget {
  const ScanDocumentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageToPdfScreen(
      title: 'Scan Document',
      subtitle: 'Capture photos of a document and convert them into a PDF.',
      primaryAccent: Color(0xFFEC407A),
    );
  }
}

// ─── Share PDF Screen ────────────────────────────────────────────────────────

class SharePdfScreen extends StatefulWidget {
  const SharePdfScreen({super.key});

  @override
  State<SharePdfScreen> createState() => _SharePdfScreenState();
}

class _SharePdfScreenState extends State<SharePdfScreen> {
  String? _pdfPath;

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      allowMultiple: false,
    );
    final path = result?.files.single.path;
    if (path == null) return;
    setState(() => _pdfPath = path);
  }

  Future<void> _sharePdf() async {
    if (_pdfPath == null) return;
    await Share.shareXFiles([XFile(_pdfPath!)], text: 'Shared PDF');
  }

  @override
  Widget build(BuildContext context) {
    return _PdfActionScaffold(
      title: 'Share PDF',
      subtitle: 'Pick any PDF from storage and share it instantly.',
      accent: const Color(0xFF42A5F5),
      body: Column(
        children: [
          _PdfActionBar(
            primaryLabel: 'Choose PDF',
            primaryIcon: Icons.picture_as_pdf_rounded,
            primaryColor: const Color(0xFF42A5F5),
            secondaryLabel: 'Share PDF',
            secondaryIcon: Icons.share_rounded,
            secondaryColor: const Color(0xFF5C6BC0),
            onPrimary: _pickPdf,
            onSecondary: _sharePdf,
            secondaryEnabled: _pdfPath != null,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _pdfPath == null
                ? const _EmptyToolState(
                    icon: Icons.share_outlined,
                    title: 'No PDF selected',
                    subtitle: 'Choose a PDF file to share it with other apps.',
                  )
                : _PathTile(
                    icon: Icons.picture_as_pdf_rounded,
                    color: const Color(0xFF42A5F5),
                    title: 'Selected PDF',
                    subtitle: _pdfPath!.split('/').last,
                    trailing: IconButton(
                      icon: const Icon(Icons.share_rounded),
                      onPressed: _sharePdf,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PdfActionScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;
  final Widget body;

  const _PdfActionScaffold({required this.title, required this.subtitle, required this.accent, required this.body});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1F2A) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                        child: Icon(_iconForTitle(title), color: accent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }

  IconData _iconForTitle(String title) {
    switch (title) {
      case 'Merge PDF':
        return Icons.merge_type_rounded;
      case 'Compress PDF':
        return Icons.compress_rounded;
      case 'Scan Document':
        return Icons.document_scanner_rounded;
      case 'Share PDF':
        return Icons.share_rounded;
      default:
        return Icons.picture_as_pdf_rounded;
    }
  }
}

class _PdfActionBar extends StatelessWidget {
  final String primaryLabel;
  final IconData primaryIcon;
  final Color primaryColor;
  final String secondaryLabel;
  final IconData secondaryIcon;
  final Color secondaryColor;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;
  final bool secondaryEnabled;
  final bool secondaryBusy;

  const _PdfActionBar({
    required this.primaryLabel,
    required this.primaryIcon,
    required this.primaryColor,
    required this.secondaryLabel,
    required this.secondaryIcon,
    required this.secondaryColor,
    required this.onPrimary,
    required this.onSecondary,
    required this.secondaryEnabled,
    this.secondaryBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ActionButton(icon: primaryIcon, label: primaryLabel, color: primaryColor, onTap: onPrimary)),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: secondaryBusy ? Icons.hourglass_top_rounded : secondaryIcon,
            label: secondaryBusy ? 'Working…' : secondaryLabel,
            color: secondaryColor,
            onTap: secondaryEnabled ? onSecondary : () {},
          ),
        ),
      ],
    );
  }
}

class _EmptyToolState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyToolState({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }
}

class _PathTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _PathTile({required this.icon, required this.color, required this.title, required this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F2A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
  final List<File> _images = [];
  bool _isConverting = false;
  String? _pdfPath;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 90);
    if (picked.isNotEmpty) {
      setState(() {
        _images.addAll(picked.map((x) => File(x.path)));
        _pdfPath = null;
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 90);
    if (picked != null) {
      setState(() {
        _images.add(File(picked.path));
        _pdfPath = null;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      _pdfPath = null;
    });
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final img = _images.removeAt(oldIndex);
      _images.insert(newIndex, img);
      _pdfPath = null;
    });
  }

  Future<void> _convertToPdf() async {
    if (_images.isEmpty) return;
    setState(() => _isConverting = true);

    try {
      final doc = pw.Document();
      for (final file in _images) {
        final bytes = await file.readAsBytes();
        final image = pw.MemoryImage(bytes);
        doc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.zero,
            build: (ctx) => pw.Center(
              child: pw.Image(image, fit: pw.BoxFit.contain),
            ),
          ),
        );
      }

      final dir = await getTemporaryDirectory();
      final fileName = 'images_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final outFile = File('${dir.path}/$fileName');
      await outFile.writeAsBytes(await doc.save());

      setState(() {
        _pdfPath = outFile.path;
        _isConverting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF created successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _isConverting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _sharePdf() async {
    if (_pdfPath == null) return;
    await Share.shareXFiles([XFile(_pdfPath!)], text: 'PDF created with PDF Tools');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = widget.primaryAccent;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          if (_pdfPath != null)
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: 'Share PDF',
              onPressed: _sharePdf,
            ),
        ],
      ),
      body: Column(
        children: [
          // Toolbar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    color: accent,
                    onTap: _pickImages,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    color: const Color(0xFF5C6BC0),
                    onTap: _pickFromCamera,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Images grid
          Expanded(
            child: _images.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text('No images selected', style: TextStyle(color: Colors.grey[500])),
                        const SizedBox(height: 4),
                        Text(widget.subtitle,
                            style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _images.length,
                    onReorder: _reorder,
                    itemBuilder: (ctx, i) {
                      return _ImageTile(
                        key: ValueKey(_images[i].path),
                        file: _images[i],
                        index: i,
                        onRemove: () => _removeImage(i),
                        isDark: isDark,
                      );
                    },
                  ),
          ),

          // Bottom bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_images.isNotEmpty)
                    Text('${_images.length} image${_images.length == 1 ? '' : 's'} • drag to reorder',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (_pdfPath != null) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.share_rounded),
                            label: const Text('Share PDF'),
                            onPressed: _sharePdf,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: FilledButton.icon(
                          icon: _isConverting
                              ? const SizedBox(width: 16, height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.picture_as_pdf_rounded),
                          label: Text(_isConverting ? 'Converting…' : 'Convert to PDF'),
                          style: FilledButton.styleFrom(
                            backgroundColor: accent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: (_images.isEmpty || _isConverting) ? null : _convertToPdf,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final File file;
  final int index;
  final VoidCallback onRemove;
  final bool isDark;

  const _ImageTile({super.key, required this.file, required this.index, required this.onRemove, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F2A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.06), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
            child: Image.file(file, width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Page ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(file.path.split('/').last,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
            onPressed: onRemove,
          ),
          const Icon(Icons.drag_handle_rounded, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
