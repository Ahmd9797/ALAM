class Project {
  final String id;
  final String name;
  final String type; // بيت، بناية، عمارة...
  final String ownerReview; // رأي مالك البيت
  final List<String> beforeWorkImages;
  final List<String> duringWorkImages;
  final List<String> afterWorkImages;
  final List<PaintMaterial> paintMaterials;

  Project({
    required this.id,
    required this.name,
    required this.type,
    required this.ownerReview,
    this.beforeWorkImages = const [],
    this.duringWorkImages = const [],
    this.afterWorkImages = const [],
    this.paintMaterials = const [],
  });
}

class PaintMaterial {
  final String name;
  final String code;

  PaintMaterial({required this.name, required this.code});
}
