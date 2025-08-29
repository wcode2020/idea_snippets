class Idea {
  final String id;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Idea({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  // إنشاء فكرة جديدة
  factory Idea.create(String content) {
    final now = DateTime.now();
    return Idea(
      id: _generateId(),
      content: content,
      createdAt: now,
      updatedAt: now,
    );
  }

  // تحويل من JSON
  factory Idea.fromJson(Map<String, dynamic> json) {
    return Idea(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // نسخ مع تعديل
  Idea copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Idea(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // تحديث المحتوى
  Idea updateContent(String newContent) {
    return copyWith(
      content: newContent,
      updatedAt: DateTime.now(),
    );
  }

  // توليد معرف فريد
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        (DateTime.now().microsecond % 1000).toString();
  }

  @override
  String toString() {
    return 'Idea(id: $id, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content}, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Idea && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

