import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type; // 'lost', 'found', 'match'
  final String itemId; // Reference to the lost/found item
  final String userId; // User who should receive this notification
  final bool isRead;
  final bool isGlobal;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.itemId,
    required this.userId,
    this.isRead = false,
    this.isGlobal = false,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    if (json['createdAt'] is Timestamp) {
      parsedDate = (json['createdAt'] as Timestamp).toDate();
    } else {
      // Default to now if timestamp hasn't synced yet
      parsedDate = DateTime.now();
    }

    return NotificationItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? '',
      itemId: json['itemId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      isGlobal: json['isGlobal'] as bool? ?? false,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'itemId': itemId,
      'userId': userId,
      'isRead': isRead,
      'isGlobal': isGlobal,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? itemId,
    String? userId,
    bool? isRead,
    bool? isGlobal,
    DateTime? createdAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      itemId: itemId ?? this.itemId,
      userId: userId ?? this.userId,
      isRead: isRead ?? this.isRead,
      isGlobal: isGlobal ?? this.isGlobal,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
