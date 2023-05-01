class NotificationModel {
  final String username;
  final String avatarUrl;
  final String message;
  final String imageUrl;
  final bool isFollowing;
  final bool isLiked;
  final bool isCommented;

  NotificationModel({
    required this.username,
    required this.avatarUrl,
    required this.message,
    required this.imageUrl,
    required this.isFollowing,
    required this.isLiked,
    required this.isCommented,
  });
}
