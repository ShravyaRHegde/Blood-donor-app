enum NotificationType {
  requestReceived,   // donor gets this when receiver sends a request
  requestAccepted,   // receiver gets this when donor accepts
  requestDeclined,   // receiver gets this when donor declines
  requestWithdrawn,  // donor gets this when receiver withdraws
  statusContacted,   // receiver gets this when donor marks contacted
  statusArranged,    // receiver gets this when donor marks arranged
  statusCompleted,   // receiver gets this when donor marks completed
}

extension NotificationTypeMeta on NotificationType {
  String get wire => name;

  static NotificationType parse(String s) =>
      NotificationType.values.firstWhere((e) => e.name == s,
          orElse: () => NotificationType.requestReceived);
}

class AppNotification {
  final String id;
  final String recipientUid;   // who receives this notification
  final String title;
  final String body;
  final NotificationType type;
  final String? requestId;     // optional — to navigate to the right screen
  final bool read;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.recipientUid,
    required this.title,
    required this.body,
    required this.type,
    this.requestId,
    this.read = false,
    required this.createdAt,
  });

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        recipientUid: recipientUid,
        title: title,
        body: body,
        type: type,
        requestId: requestId,
        read: read ?? this.read,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'recipientUid': recipientUid,
        'title': title,
        'body': body,
        'type': type.wire,
        'requestId': requestId,
        'read': read,
        'createdAt': createdAt.toIso8601String(),
      };

  static AppNotification fromMap(Map<String, dynamic> m) => AppNotification(
        id: m['id'] as String,
        recipientUid: m['recipientUid'] as String,
        title: m['title'] as String,
        body: m['body'] as String,
        type: NotificationTypeMeta.parse(m['type'] as String),
        requestId: m['requestId'] as String?,
        read: (m['read'] ?? false) as bool,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
}