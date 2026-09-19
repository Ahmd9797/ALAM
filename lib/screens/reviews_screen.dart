import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/review.dart';

class ReviewsScreen extends StatelessWidget {
  final bool isAdmin; // يتغير بناءً على تسجيل دخول المدير
  
  const ReviewsScreen({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();

    return Scaffold(
      appBar: AppBar(title: Text(isAdmin ? "إدارة الآراء (المدير)" : "آراء العملاء")),
      floatingActionButton: !isAdmin ? FloatingActionButton(
        onPressed: () => _showAddReviewDialog(context),
        child: Icon(Icons.add_comment),
      ) : null,
      body: StreamBuilder<List<CustomerReview>>(
        stream: dbService.getAllReviews(isAdmin),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          
          final reviews = snapshot.data!;
          
          return ListView.separated(
            padding: EdgeInsets.all(10),
            itemCount: reviews.length,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, index) {
              final review = reviews[index];
              
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(review.userName.substring(0,1))),
                  title: Text(review.userName),
                  subtitle: Text(review.text),
                  trailing: isAdmin && review.status == ReviewStatus.pending
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check_circle, color: Colors.green),
                              tooltip: "نشر للعموم",
                              onPressed: () => dbService.approveReview(review.id),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_forever, color: Colors.red),
                              tooltip: "حذف نهائي",
                              onPressed: () {}, // منطق الحذف
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddReviewDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("أضف رأيك"),
        content: TextField(controller: controller, maxLines: 3, decoration: InputDecoration(hintText: "اكتب تجربتك معنا...")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء")),
          ElevatedButton(
            onPressed: () {
              if(controller.text.isNotEmpty) {
                DatabaseService().submitUserReview("زائر", controller.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("تم إرسال الرأي بانتظار موافقة الإدارة")));
              }
            },
            child: Text("إرسال"),
          ),
        ],
      ),
    );
  }
}
