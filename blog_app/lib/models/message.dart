class Message {
  int? id;
  final String content;
  final String? imagePath;
  final DateTime? createdAt;
  final String? description;

  Message({this.id, required this.content, this.imagePath, this.createdAt,this.description});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'imagePath': imagePath,
      'createdAt': createdAt?.toIso8601String(),
      'description': description,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      content: map['content'],
      imagePath: map['imagePath'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      description: map['description']
    );
  }
}
