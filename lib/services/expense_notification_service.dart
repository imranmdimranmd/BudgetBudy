import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ExpenseNotificationService {
  ExpenseNotificationService._();

  static final ExpenseNotificationService instance =
      ExpenseNotificationService._();

  static const int notificationId = 1001;
  static const String channelId = 'budget_budy_summary';
  static const String channelName = 'BudgetBudy summary';
  static const String channelDescription =
      'Persistent expense and income summary';

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize({required void Function() onTap}) async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        if (response.id == notificationId) {
          onTap();
        }
      },
    );

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await android?.requestNotificationsPermission();

    const channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
      showBadge: false,
    );

    await android?.createNotificationChannel(channel);
  }

  Future<void> showSummary({
    required int expense,
    required int income,
  }) async {
    final details = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      playSound: false,
      enableVibration: false,
      showWhen: false,
      category: AndroidNotificationCategory.status,
      styleInformation: BigTextStyleInformation(
        'Expense: ₹$expense\nIncome: ₹$income',
        contentTitle: 'BudgetBudy',
        summaryText: 'Tap to open Transactions',
      ),
    );

    await _notifications.show(
      notificationId,
      'BudgetBudy • Expense ₹$expense',
      'Income ₹$income  •  Tap to open Transactions',
      NotificationDetails(android: details),
      payload: 'transactions',
    );
  }

  Future<void> cancel() => _notifications.cancel(notificationId);
}
