import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../../../core/services/presentation_service.dart';
import '../../../models/course.dart';
import '../../../models/presentation.dart';

class PresentationsPage extends StatefulWidget {
  final Course course;

  const PresentationsPage({
    super.key,
    required this.course,
  });

  @override
  State<PresentationsPage> createState() => _PresentationsPageState();
}

class _PresentationsPageState extends State<PresentationsPage> {
  final PresentationService service = PresentationService();

  List<Presentation> presentations = [];
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  String search = "";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPresentations();
  }

  Future<void> loadPresentations() async {
    presentations = await service.getPresentations(widget.course.id);

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  Future<void> generatePresentation() async {
    final TextEditingController controller = TextEditingController();
    String localTopic = '';

    // Use a modal bottom sheet so the input is more visible and feels native
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Generate Presentation', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Describe the topic and generate a presentation for this course.', style: Theme.of(ctx).textTheme.bodyMedium),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Topic',
                    hintText: 'e.g. Introduction to Linear Algebra',
                    prefixIcon: Icon(Icons.topic_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, null),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          localTopic = controller.text.trim();
                          Navigator.pop(ctx, localTopic);
                        },
                        child: const Text('Generate'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );

    final topic = result;
    if (topic == null || topic.isEmpty) return;

    // Show a loading dialog while generating
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final file = await service.generatePresentation(
        courseId: widget.course.id,
        topic: topic,
      );

      await service.savePresentation(
        courseId: widget.course.id,
        topic: topic,
        file: file,
      );

      if (mounted) Navigator.pop(context);

      await loadPresentations();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Presentation generated successfully."),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> openPresentation(Presentation presentation) async {
    final file = await service.downloadPresentation(
      presentation.filePath,
    );

    await OpenFilex.open(file.path);
  }

  Future<void> deletePresentation(Presentation presentation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Presentation"),
        content: Text(
          "Are you sure you want to delete '${presentation.title}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await service.supabase.storage.from("presentations").remove([
      presentation.filePath,
    ]);

    await service.supabase
        .from("presentations")
        .delete()
        .eq("id", presentation.id);

    await loadPresentations();
  }

  @override
  Widget build(BuildContext context) {
    final filteredPresentations = presentations.where((presentation) {
      return presentation.title.toLowerCase().contains(search.toLowerCase()) ||
          presentation.topic.toLowerCase().contains(search.toLowerCase());
    }).toList();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "AI Presentations",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Focus search',
            onPressed: () {
              FocusScope.of(context).requestFocus(searchFocusNode);
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: generatePresentation,
        icon: const Icon(Icons.add),
        label: const Text("Generate"),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    "${filteredPresentations.length} Presentation${filteredPresentations.length == 1 ? "" : "s"}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Always show search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    focusNode: searchFocusNode,
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        search = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search presentations...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                presentations.isEmpty
                    ? Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.slideshow_outlined,
                                size: 90,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "No presentations yet",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Generate your first AI presentation.",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredPresentations.length,
                          itemBuilder: (_, index) {
                            final presentation = filteredPresentations[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundColor:
                                              Colors.blue.shade100,
                                          child: const Icon(
                                            Icons.slideshow,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                presentation.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                presentation.topic,
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () =>
                                                openPresentation(presentation),
                                            icon: const Icon(Icons.open_in_new),
                                            label: const Text("Open"),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            onPressed: () =>
                                                deletePresentation(presentation),
                                            icon: const Icon(Icons.delete),
                                            label: const Text("Delete"),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
    );
  }
}
