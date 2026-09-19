import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/project_model.dart';
import 'project_details_screen.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final firestoreService = Provider.of<FirestoreService>(context);
    final bool isAdmin = authService.isAdmin;

    return Scaffold(
      appBar: AppBar(title: const Text('المشاريع المنجزة')),
      body: StreamBuilder<List<ProjectModel>>(
        stream: firestoreService.getProjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد مشاريع'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final project = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectDetailsScreen(project: project),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getProjectIcon(project.projectType),
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                project.projectType,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              if (project.clientReview != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '"${project.clientReview}"',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _showAddProjectDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  IconData _getProjectIcon(String type) {
    switch (type) {
      case 'بيت':
        return Icons.home;
      case 'بناية':
        return Icons.apartment;
      case 'عمارة':
        return Icons.business;
      case 'مدن سكنية':
        return Icons.location_city;
      default:
        return Icons.construction;
    }
  }

  void _showAddProjectDialog(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    
    final nameController = TextEditingController();
    final clientReviewController = TextEditingController();
    String selectedType = 'بيت';
    final types = ['بيت', 'بناية', 'عمارة', 'مدن سكنية', 'مشاريع اخرى'];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('إضافة مشروع جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'اسم المشروع'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'نوع المشروع'),
                  items: types.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => selectedType = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: clientReviewController,
                  decoration: const InputDecoration(labelText: 'رأي مالك المشروع (اختياري)'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('يرجى إدخال اسم المشروع')),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                final project = ProjectModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  projectType: selectedType,
                  clientReview: clientReviewController.text.isEmpty 
                      ? null 
                      : clientReviewController.text,
                  createdAt: DateTime.now(),
                );

                await firestoreService.addProject(project);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إضافة المشروع بنجاح')),
                  );
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }
}
