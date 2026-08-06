import 'package:flutter/material.dart';

import '../../../core/services/learning_material_service.dart';
import '../../../models/course.dart';
import '../../../models/learning_material.dart';
import '../../../core/services/file_service.dart';

class StudentLearningMaterialsPage extends StatefulWidget {
  final Course course;

  const StudentLearningMaterialsPage({
    super.key,
    required this.course,
  });

  @override
  State<StudentLearningMaterialsPage> createState() => _StudentLearningMaterialsPageState();
}

class _StudentLearningMaterialsPageState extends State<StudentLearningMaterialsPage> {
  final LearningMaterialService _service = LearningMaterialService();
  final FileService _fileService = FileService();

  List<LearningMaterial> materials = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadMaterials();
  }

  Future<void> loadMaterials() async {
    materials = await _service.getMaterials(widget.course.id);

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  IconData getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Materials'),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onBackground,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => loadMaterials(),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : materials.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.folder_open, size: 56, color: theme.colorScheme.primary),
                            const SizedBox(height: 12),
                            Text('No learning materials yet', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Text('Materials uploaded by your instructor will appear here.', style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: materials.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final material = materials[index];

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(getIcon(material.fileType), color: theme.colorScheme.primary),
                        ),
                        title: Text(material.fileName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        subtitle: Text(material.fileType.toUpperCase(), style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () async {
                            try {
                              await _fileService.openFile(filePath: material.filePath, fileName: material.fileName);
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
