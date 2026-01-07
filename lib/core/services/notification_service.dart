// lib/core/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Initialize notifications
  static Future<void> initialize() async {
    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
      
      // Get FCM token
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_saveTokenToFirestore);

      // Initialize local notifications
      await _initLocalNotifications();

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background/terminated messages
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    }
  }

  // Initialize local notifications
  static Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'showgrid_channel',
      'ShowGrid Notifications',
      description: 'Notifications from ShowGrid app',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  // Save FCM token to Firestore
  static Future<void> _saveTokenToFirestore(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message: ${message.notification?.title}');
    
    // Show local notification
    showLocalNotification(
      title: message.notification?.title ?? 'ShowGrid',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );

    // Save to in-app notifications
    _saveNotificationToFirestore(message);
  }

  // Handle message when app opened from notification
  static void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.notification?.title}');
    // Navigate based on message data
    // This would require a navigation callback
  }

  // Handle notification tap
  static void _onNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Navigate based on payload
  }

  // Show local notification
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'showgrid_channel',
      'ShowGrid Notifications',
      channelDescription: 'Notifications from ShowGrid app',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Save notification to Firestore (for in-app notifications)
  static Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db.collection('users').doc(user.uid).collection('notifications').add({
      'title': message.notification?.title ?? '',
      'body': message.notification?.body ?? '',
      'data': message.data,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get user's notifications
  static Stream<QuerySnapshot> getUserNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  // Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  // Mark all as read
  static Future<void> markAllAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final notifications = await _db
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  // Get unread count
  static Stream<int> getUnreadCount() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value(0);
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}
