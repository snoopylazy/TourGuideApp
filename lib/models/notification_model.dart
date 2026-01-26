class NotificationModel {
  final String id;
  final String type; // 'review' or 'admin_response'
  final String title;
  final String message;
  final String? placeId;
  final String? placeTitle;
  final String? reviewId;
  final String? userId;
  final String? userName;
  final String? comment;
  final String? adminResponse;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.placeId,
    this.placeTitle,
    this.reviewId,
    this.userId,
    this.userName,
    this.comment,
    this.adminResponse,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      placeId: data['placeId'],
      placeTitle: data['placeTitle'],
      reviewId: data['reviewId'],
      userId: data['userId'],
      userName: data['userName'],
      comment: data['comment'],
      adminResponse: data['adminResponse'],
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'message': message,
      'placeId': placeId,
      'placeTitle': placeTitle,
      'reviewId': reviewId,
      'userId': userId,
      'userName': userName,
      'comment': comment,
      'adminResponse': adminResponse,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }
}

