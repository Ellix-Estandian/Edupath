import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/ai_backend_service.dart';
import '../../../core/services/learning_material_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../models/course.dart';
import '../../../models/learning_material.dart';
import '../../../core/services/file_service.dart';

extension LearningMaterialServiceAddMaterial on LearningMaterialService {
  Future<Map<String, dynamic>> createMaterial({
    required String courseId,
    required String fileName,
    required String filePath,
    required String fileType,
  }) async {
    final response = await Supabase.instance.client
        .from('learning_materials')
        .insert({
          'course_id': courseId,
          'file_name': fileName,
          'file_path': filePath,
          'file_type': fileType,
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
  final FileService fileService = FileService();

  List<LearningMaterial> materials = [];

  final searchController = TextEditingController();
  String search = '';

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadMaterials();
  }

  Future<void> loadMaterials() async {
    try {
      materials = await service.getMaterials(widget.course.id);
    } catch (e) {
      debugPrint('Load materials error: $e');
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> uploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
      );

      if (result == null) return;

      final file = File(result.files.single.path!);
      final uploadedPath = await storageService.uploadMaterial(file);

      final material = await service.addMaterial(
        courseId: widget.course.id,
        fileName: result.files.single.name,
        filePath: uploadedPath,
        fileType: result.files.single.extension ?? '',
      );

      // Optimistically update UI with the newly created material so it shows immediately
      try {
        final newMaterial = LearningMaterial.fromJson(material);
        if (mounted) {
          setState(() {
            materials.insert(0, newMaterial);
          });
        }
      } catch (e) {
        // ignore parsing errors and fallback to reload below
        debugPrint('Failed to parse new material for optimistic update: $e');
      }

      await aiBackend.indexMaterial(
        materialId: material['id'],
        pdfPath: uploadedPath,
      );

      final enrollments = await Supabase.instance.client
          .from('enrollments')
          .select('student_id')
          .eq('course_id', widget.course.id);

      for (final enrollment in enrollments) {
        await notificationService.createNotification(
          userId: enrollment['student_id'],
          title: 'New Learning Material',
          message:
              '${result.files.single.name} has been uploaded to ${widget.course.title}.',
        );
      }

      // Ensure eventual consistency by refreshing the list in background (non-blocking)
      loadMaterials();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
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
      allowedExtensions: ['pdf', 'docx', 'txt'],
    );

    if (result == null) return;

    final file = File(result.files.single.path!);
    final newPath = await storageService.uploadMaterial(file);

    await storageService.deleteMaterial(material.filePath);

    await service.updateMaterial(
      id: material.id,
      fileName: result.files.single.name,
      filePath: newPath,
      fileType: result.files.single.extension ?? '',
    );

    await loadMaterials();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredMaterials = materials.where((material) {
      return material.fileName.toLowerCase().contains(search.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: uploadFile,
        icon: const Icon(Icons.cloud_upload_rounded),
        label: const Text('Upload'),
      ),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.xlarge),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.folder_copy_rounded,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Learning materials',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Keep course documents organized and easy to find.',
                                  style: TextStyle(
                                      color: Colors.white70, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search learning materials...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) => setState(() => search = value),
                    ),
                  ),
                  Expanded(
                    child: filteredMaterials.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.xlarge),
                                  border: Border.all(color: AppColors.border),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: const Icon(
                                        Icons.folder_open_rounded,
                                        size: 48,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    const Text(
                                      'No learning materials',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Upload your first document to get started.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(18, 0, 18, 90),
                            itemCount: filteredMaterials.length,
                            itemBuilder: (_, index) {
                              final material = filteredMaterials[index];

                              IconData icon;
                              Color color;

                              switch (material.fileType.toLowerCase()) {
                                case 'pdf':
                                  icon = Icons.picture_as_pdf_rounded;
                                  color = AppColors.danger;
                                  break;
                                case 'docx':
                                  icon = Icons.description_rounded;
                                  color = AppColors.primary;
                                  break;
                                case 'txt':
                                  icon = Icons.text_snippet_rounded;
                                  color = AppColors.success;
                                  break;
                                default:
                                  icon = Icons.insert_drive_file_rounded;
                                  color = AppColors.textMuted;
                              }

                              return InkWell(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.large),
                                onTap: () async {
                                  try {
                                    await fileService.openFile(
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
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.large),
                                    border: Border.all(color: AppColors.border),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.14),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child:
                                            Icon(icon, color: color, size: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              material.fileName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              material.fileType.toUpperCase(),
                                              style: const TextStyle(
                                                  color:
                                                      AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'replace') {
                                            replaceMaterial(material);
                                          } else if (value == 'delete') {
                                            deleteMaterial(material);
                                          }
                                        },
                                        itemBuilder: (_) => const [
                                          PopupMenuItem(
                                            value: 'replace',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit_rounded),
                                                SizedBox(width: 10),
                                                Text('Replace'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_rounded),
                                                SizedBox(width: 10),
                                                Text('Delete'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
