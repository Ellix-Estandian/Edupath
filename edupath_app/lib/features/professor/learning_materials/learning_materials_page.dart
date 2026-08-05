import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/learning_material_service.dart';
import '../../../models/course.dart';
import '../../../models/learning_material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/ai_backend_service.dart';
import '../../../core/services/notification_service.dart';

extension LearningMaterialServiceAddMaterial on LearningMaterialService {
  Future<Map<String, dynamic>> createMaterial({
    required String courseId,
    required String fileName,
    required String filePath,
    required String fileType,
  }) async {
    final response = await Supabase.instance.client
        .from("learning_materials")
        .insert({
          "course_id": courseId,
          "file_name": fileName,
          "file_path": filePath,
          "file_type": fileType,
        })
        .select()
        .single();

    return response;
  }

  Future<Map<String, dynamic>> addMaterial({
    required String courseId,
    required String fileName,
    required String filePath,
    required String fileType,
  }) {
    return createMaterial(
      courseId: courseId,
      fileName: fileName,
      filePath: filePath,
      fileType: fileType,
    );
  }
}

class LearningMaterialsPage extends StatefulWidget {
  final Course course;

  const LearningMaterialsPage({
    super.key,
    required this.course,
  });

  @override
  State<LearningMaterialsPage> createState() => _LearningMaterialsPageState();
}

class _LearningMaterialsPageState extends State<LearningMaterialsPage> {
  final LearningMaterialService service = LearningMaterialService();
  final StorageService storageService = StorageService();
  final AIBackendService aiBackend = AIBackendService();
  final NotificationService notificationService = NotificationService();
  List<LearningMaterial> materials = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadMaterials();
  }

  Future<void> loadMaterials() async {
    try {
      materials = await service.getMaterials(widget.course.id);
      debugPrint("Materials found: ${materials.length}");
    } catch (e) {
      debugPrint("Load materials error: $e");
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> uploadFile() async {
    final user = Supabase.instance.client.auth.currentUser;

    debugPrint("Current User ID: ${user?.id}");
    debugPrint("Current User Email: ${user?.email}");

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["pdf", "docx", "txt"],
      );

      if (result == null) return;

      final file = File(result.files.single.path!);

      debugPrint("Picked: ${file.path}");

      final uploadedPath = await storageService.uploadMaterial(file);

      debugPrint("Uploaded to Storage: $uploadedPath");

      final material = await service.addMaterial(
        courseId: widget.course.id,
        fileName: result.files.single.name,
        filePath: uploadedPath,
        fileType: result.files.single.extension ?? "",
      );

      debugPrint("Saved to database");

      await aiBackend.indexMaterial(
        materialId: material["id"],
        pdfPath: uploadedPath,
      );

      debugPrint("Indexed successfully");

      await loadMaterials();
      await aiBackend.indexMaterial(
        materialId: material["id"],
        pdfPath: uploadedPath,
      );

      debugPrint("Indexed successfully");

// Get all enrolled students
      final enrollments = await Supabase.instance.client
          .from("enrollments")
          .select("student_id")
          .eq("course_id", widget.course.id);

// Notify each student
      for (final enrollment in enrollments) {
        await notificationService.createNotification(
          userId: enrollment["student_id"],
          title: "New Learning Material",
          message:
              "${result.files.single.name} has been uploaded to ${widget.course.title}.",
        );
      }

      await loadMaterials();
    } catch (e, stackTrace) {
      debugPrint("Upload error: $e");
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: $e")),
        );
      }
    }
  }

  Future<void> deleteMaterial(LearningMaterial material) async {
    await storageService.deleteMaterial(material.filePath);

    await service.deleteMaterial(material.id);

    await loadMaterials();
  }

  Future<void> replaceMaterial(LearningMaterial material) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["pdf", "docx", "txt"],
    );

    if (result == null) return;

    final file = File(result.files.single.path!);

    // Upload the new file
    final newPath = await storageService.uploadMaterial(file);

    // Delete the old file from Storage
    await storageService.deleteMaterial(material.filePath);

    // Update the database
    await service.updateMaterial(
      id: material.id,
      fileName: result.files.single.name,
      filePath: newPath,
      fileType: result.files.single.extension ?? "",
    );

    await loadMaterials();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: uploadFile,
        child: const Icon(Icons.upload),
      ),
      appBar: AppBar(
        title: const Text("Learning Materials"),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: materials.length,
              itemBuilder: (_, index) {
                final material = materials[index];

                return ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => replaceMaterial(material),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => deleteMaterial(material),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
