class Note {
  final String id;
  final String title;
  final String content;
  final String userId;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      userId: map['user_id'] as String,
    );
  }
}
