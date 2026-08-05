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
  State<StudentLearningMaterialsPage> createState() =>
      _StudentLearningMaterialsPageState();
}

class _StudentLearningMaterialsPageState
    extends State<StudentLearningMaterialsPage> {
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
      case "pdf":
        return Icons.picture_as_pdf;

      case "doc":
      case "docx":
        return Icons.description;

      case "ppt":
      case "pptx":
        return Icons.slideshow;

      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Learning Materials"),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : materials.isEmpty
              ? const Center(
                  child: Text("No learning materials yet."),
                )
              : ListView.builder(
                  itemCount: materials.length,
                  itemBuilder: (_, index) {
                    final material = materials[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: Icon(getIcon(material.fileType)),
                        title: Text(material.fileName),
                        subtitle: Text(material.fileType.toUpperCase()),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () async {
                          try {
                            await _fileService.openFile(
                              filePath: material.filePath,
                              fileName: material.fileName,
                            );
                          } catch (e) {
                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
