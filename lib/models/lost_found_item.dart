import 'package:uuid/uuid.dart';

class LostFoundItem {
  final String id;
  final String title;
  final String description;
  final String location;
  final String type; // "lost" or "found"
  final String userId;
  final int timestamp;
  final String status; // "active" or "claimed"

  LostFoundItem({
    String? id,
    this.title = '',
    this.description = '',
    this.location = '',
    this.type = '',
    this.userId = '',
    int? timestamp,
    this.status = 'active',
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  factory LostFoundItem.fromJson(Map<String, dynamic> json) {
    return LostFoundItem(
      id: json['id'] as String? ?? const Uuid().v4(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      type: json['type'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      timestamp: json['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'type': type,
      'userId': userId,
      'timestamp': timestamp,
      'status': status,
    };
  }

  LostFoundItem copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? type,
    String? userId,
    int? timestamp,
    String? status,
  }) {
    return LostFoundItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}