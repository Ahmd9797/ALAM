import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/database_service.dart';
import 'offers_screen.dart';
import 'reviews_screen.dart';
import 'projects_gallery.dart';
import 'products_screen.dart';
import 'consultation_screen.dart'; // الشريط السفلي منفصل عادة، لكن يمكن ربطه هنا كزر سريع

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  int _currentIndex = 0; // للباناتر المتقلب

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("مكتب اعلام شركة فاوري ذي قار"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Column(
        children: [
          // 1. بانر متقلب للعروض
          SizedBox(height: 200, child: _buildBanner()),
          
          // 2. الخيارات الأربعة
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildOptionCard(context, Icons.local_offer, "أحدث العروض", OffersScreen()),
                  _buildOptionCard(context, Icons.star_border, "آراء الزبائن", ReviewsScreen(isAdmin: false)),
                  _buildOptionCard(context, Icons.construction, "تصوير المشاريع", ProjectsGallery()),
                  _buildOptionCard(context, Icons.inventory_2_outlined, "المنتجات", ProductsScreen()),
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.help_outline), label: "طلب استشارة"),
        ],
        onTap: (index) {
          if(index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => ConsultationScreen()));
        },
      ),
    );
  }

  Widget _buildBanner() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _dbService.getLatestOffers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("خطأ في التحميل"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(color: Colors.grey[200], child: Center(child: Text("لا توجد عروض حالياً")));
        }

        final offers = snapshot.data!;
        // منطق بسيط للدوران التلقائي يمكن إضافته لاحقاً
        
        return PageView.builder(
          itemCount: offers.length,
          onPageChanged: (i) => setState(() => _currentIndex = i),
          itemBuilder: (context, index) {
            final offer = offers[index];
            return CachedNetworkImage(
              imageUrl: offer['imageUrl'] ?? '',
              fit: BoxFit.cover,
              placeholder: (context, url) => CircularProgressIndicator(),
              // تطبيق قاعدة العلامة الحمراء هنا: استخدام أسماء واضحة
              errorWidget: (context, error, stackTrace) { 
                print("Image Error: $error"); 
                return Icon(Icons.broken_image, size: 50); 
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOptionCard(BuildContext context, IconData icon, String title, Widget screen) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blueAccent),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
