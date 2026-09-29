import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

/// Always-on notification that shows this month's expense and income.
///
/// It runs as an Android foreground service so it cannot be swiped away,
/// and tapping it opens the app on the Transactions (Home) screen.
class ExpenseNotificationService {
  ExpenseNotificationService._();

  static final ExpenseNotificationService instance =
      ExpenseNotificationService._();

  static const int notificationId = 1001;
  static const String payload = 'transactions';
  static const String channelId = 'budget_budy_summary';
  static const String channelName = 'BudgetBudy summary';
  static const String channelDescription =
      'Persistent expense and income summary';

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _serviceStarted = false;

  final NumberFormat _money =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  /// Sets up the plugin. Returns true if the app was cold-started by tapping
  /// the notification.
  Future<bool> initialize({required void Function() onTap}) async {
    const androidSettings =
        AndroidInitializationSettings('@drawable/ic_stat_budget');
    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == payload) onTap();
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

    final launch = await _notifications.getNotificationAppLaunchDetails();
    return (launch?.didNotificationLaunchApp ?? false) &&
        launch?.notificationResponse?.payload == payload;
  }

  AndroidNotificationDetails get _details => AndroidNotificationDetails(
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
        visibility: NotificationVisibility.public,
      );

  Future<void> showSummary({
    required int expense,
    required int income,
  }) async {
    final month = DateFormat('MMMM').format(DateTime.now());
    final title = '$month • Expense ${_money.format(expense)}';
    final body =
        'Income ${_money.format(income)}  •  Balance ${_money.format(income - expense)}';

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (!_serviceStarted && android != null) {
      // Foreground service => notification stays even if the user swipes.
      try {
        await android.startForegroundService(
          notificationId,
          title,
          body,
          notificationDetails: _details,
          payload: payload,
          foregroundServiceTypes: {
            AndroidServiceForegroundType.foregroundServiceTypeSpecialUse,
          },
        );
        _serviceStarted = true;
        return;
      } catch (_) {
        // Fall back to a plain ongoing notification below.
      }
    }

    await _notifications.show(
      notificationId,
      title,
      body,
      NotificationDetails(android: _details),
      payload: payload,
    );
  }

  Future<void> cancel() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (_serviceStarted) {
      await android?.stopForegroundService();
      _serviceStarted = false;
    }
    await _notifications.cancel(notificationId);
  }
}
