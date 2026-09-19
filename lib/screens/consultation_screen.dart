import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class ConsultationScreen extends StatelessWidget {
  const ConsultationScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final firestoreService = Provider.of<FirestoreService>(context);
    final bool isAdmin = authService.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلب استشارة'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditSettingsDialog(context),
            ),
        ],
      ),
      body: StreamBuilder(
        stream: firestoreService.getConsultationSettings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() as Map<String, dynamic>?;
          
          final instagramUrl = data?['instagram'] ?? 'https://instagram.com/fawry';
          final facebookUrl = data?['facebook'] ?? 'https://facebook.com/fawry';
          final tiktokUrl = data?['tiktok'] ?? 'https://tiktok.com/@fawry';
          final whatsappNumber = data?['whatsapp'] ?? '9647700000000';

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.support_agent,
                    size: 80,
                    color: Color(0xFF1565C0),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'تواصل معنا',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اختر وسيلة التواصل المناسبة لك',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  _buildSocialButton(
                    context,
                    'Instagram',
                    Icons.camera_alt,
                    const Color(0xFFE1306C),
                    instagramUrl,
                  ),
                  const SizedBox(height: 16),
                  _buildSocialButton(
                    context,
                    'Facebook',
                    Icons.facebook,
                    const Color(0xFF1877F2),
                    facebookUrl,
                  ),
                  const SizedBox(height: 16),
                  _buildSocialButton(
                    context,
                    'TikTok',
                    Icons.video_library,
                    Colors.black,
                    tiktokUrl,
                  ),
                  const SizedBox(height: 16),
                  _buildSocialButton(
                    context,
                    'WhatsApp',
                    Icons.phone,
                    const Color(0xFF25D366),
                    'https://wa.me/$whatsappNumber',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String url,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 4,
        ),
        icon: Icon(icon, size: 24),
        label: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onPressed: () => _launchURL(url),
      ),
    );
  }

  void _showEditSettingsDialog(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    
    final instagramController = TextEditingController();
    final facebookController = TextEditingController();
    final tiktokController = TextEditingController();
    final whatsappController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تعديل روابط التواصل'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: instagramController,
                decoration: const InputDecoration(labelText: 'رابط Instagram'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: facebookController,
                decoration: const InputDecoration(labelText: 'رابط Facebook'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tiktokController,
                decoration: const InputDecoration(labelText: 'رابط TikTok'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: whatsappController,
                decoration: const InputDecoration(labelText: 'رقم WhatsApp'),
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
              await firestoreService.updateConsultationSettings(
                instagram: instagramController.text,
                facebook: facebookController.text,
                tiktok: tiktokController.text,
                whatsapp: whatsappController.text,
              );

              Navigator.pop(dialogContext);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تحديث الروابط بنجاح')),
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
