import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/project_model.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final firestoreService = Provider.of<FirestoreService>(context);
    final bool isAdmin = authService.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'قبل العمل'),
            Tab(text: 'أثناء العمل'),
            Tab(text: 'بعد العمل'),
            Tab(text: 'الأصباغ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildImagesTab('before', widget.project.beforeImages, firestoreService, isAdmin),
          _buildImagesTab('during', widget.project.duringImages, firestoreService, isAdmin),
          _buildImagesTab('after', widget.project.afterImages, firestoreService, isAdmin),
          _buildPaintMaterialsTab(firestoreService, isAdmin),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _showAddContentDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildImagesTab(String category, List<String> images, FirestoreService firestoreService, bool isAdmin) {
    if (images.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'لا توجد صور في هذه الفئة',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Card(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    );
                  },
                ),
              ),
              if (isAdmin)
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () {
                      // حذف الصورة
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaintMaterialsTab(FirestoreService firestoreService, bool isAdmin) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.project.paintMaterials.length,
      itemBuilder: (context, index) {
        final material = widget.project.paintMaterials[index];
        return Card(
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.color_lens),
            ),
            title: Text(material.name),
            subtitle: Text('الكود: ${material.code}'),
            trailing: isAdmin
                ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // حذف المادة
                    },
                  )
                : null,
          ),
        );
      },
    );
  }

  void _showAddContentDialog(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final picker = ImagePicker();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إضافة محتوى'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('إضافة صورة'),
              onTap: () async {
                Navigator.pop(dialogContext);
                final picked = await picker.pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  // رفع الصورة وإضافتها للمشروع
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('جاري رفع الصورة...')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('إضافة مادة صبغية'),
              onTap: () {
                Navigator.pop(dialogContext);
                _showAddPaintMaterialDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPaintMaterialDialog(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    
    final nameController = TextEditingController();
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إضافة مادة صبغية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'اسم المادة'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'كود المادة'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty || codeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى ملء جميع الحقول')),
                );
                return;
              }

              Navigator.pop(dialogContext);

              final material = PaintMaterial(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                code: codeController.text,
              );

              // إضافة المادة للمشروع
              final updatedProject = widget.project.copyWith(
                paintMaterials: [...widget.project.paintMaterials, material],
              );

              firestoreService.updateProject(updatedProject);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إضافة المادة بنجاح')),
              );
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
