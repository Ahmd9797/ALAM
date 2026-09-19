import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ConsultationScreen extends StatelessWidget {
  const ConsultationScreen({super.key});

  // هذه القيم يجب أن تكون ديناميكية إذا كان المدير يستطيع تغييرها من لوحة التحكم
  final String instagramUrl = "https://instagram.com/fauri_dhi_qar";
  final String facebookUrl = "https://facebook.com/fauri_media";
  final String tiktokUrl = "https://tiktok.com/@fauri_media";
  final String whatsappNumber = "+96477xxxxxxx";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("طلب استشارة / تواصل معنا")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("يسعدنا خدمتكم", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            
            _buildSocialButton(context, Icons.facebook, "Facebook", facebookUrl),
            SizedBox(height: 20),
            _buildSocialButton(context, Icons.camera_alt, "Instagram", instagramUrl),
            SizedBox(height: 20),
            _buildSocialButton(context, Icons.music_note, "TikTok", tiktokUrl),
            SizedBox(height: 20),
            _buildContactButton(context, Icons.phone_in_talk, "WhatsApp", whatsappNumber),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(BuildContext context, IconData icon, String label, String url) {
    return OutlinedButton.icon(
      icon: Icon(icon, color: Colors.blue),
      label: Text(label, style: TextStyle(fontSize: 18)),
      onPressed: () async {
        Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $url';
        }
      },
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
        side: BorderSide(color: Colors.blue),
      ),
    );
  }

  Widget _buildContactButton(BuildContext context, IconData icon, String label, String number) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: () async {
        // فتح واتساب مباشرة
        Uri whatsAppUri = Uri.parse("whatsapp://send?phone=$number&text=مرحباً، أرغب باستشارة من مكتب فاوري");
        if (await canLaunchUrl(whatsAppUri)) {
           await launchUrl(whatsAppUri);
        } else {
           // fallback للمتصفح
           await launchUrl(Uri.parse("https://wa.me/${number.replaceAll('+', '')}?text=Hello"));
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 50),
      ),
    );
  }
}
