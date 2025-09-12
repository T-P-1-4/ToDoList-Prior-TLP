class AppNotification {
  AppNotification();

  static bool _currentNotification = false;
  static Map<String, Map<String, String>> _NotificationMap = {};

  static bool getCurrentNotification() => _currentNotification;

  static List<String> getAvailableNotifications() =>
      _NotificationMap.keys.toList();

  static void setNotification(bool send_notification) {
    _currentNotification = send_notification;
  }
}