class ProjectModel {
  final String id;
  final String name;
  final String projectType; // بيت، بناية، عمارة، مدن سكنية، مشاريع اخرى
  final String? clientReview;
  final List<String> beforeImages;
  final List<String> duringImages;
  final List<String> afterImages;
  final List<PaintMaterial> paintMaterials;
  final DateTime createdAt;

  ProjectModel({
    required this.id,
    required this.name,
    required this.projectType,
    this.clientReview,
    this.beforeImages = const [],
    this.duringImages = const [],
    this.afterImages = const [],
    this.paintMaterials = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'projectType': projectType,
      'clientReview': clientReview,
      'beforeImages': beforeImages,
      'duringImages': duringImages,
      'afterImages': afterImages,
      'paintMaterials': paintMaterials.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      projectType: map['projectType'] ?? '',
      clientReview: map['clientReview'],
      beforeImages: List<String>.from(map['beforeImages'] ?? []),
      duringImages: List<String>.from(map['duringImages'] ?? []),
      afterImages: List<String>.from(map['afterImages'] ?? []),
      paintMaterials: (map['paintMaterials'] as List?)
              ?.map((e) => PaintMaterial.fromMap(e))
              .toList() ??
          [],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  ProjectModel copyWith({
    String? id,
    String? name,
    String? projectType,
    String? clientReview,
    List<String>? beforeImages,
    List<String>? duringImages,
    List<String>? afterImages,
    List<PaintMaterial>? paintMaterials,
    DateTime? createdAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      projectType: projectType ?? this.projectType,
      clientReview: clientReview ?? this.clientReview,
      beforeImages: beforeImages ?? this.beforeImages,
      duringImages: duringImages ?? this.duringImages,
      afterImages: afterImages ?? this.afterImages,
      paintMaterials: paintMaterials ?? this.paintMaterials,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PaintMaterial {
  final String id;
  final String name;
  final String code;
  final String? imageUrl;

  PaintMaterial({
    required this.id,
    required this.name,
    required this.code,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'imageUrl': imageUrl,
    };
  }

  factory PaintMaterial.fromMap(Map<String, dynamic> map) {
    return PaintMaterial(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      imageUrl: map['imageUrl'],
    );
  }
}
