import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings();
    const macOSSettings = DarwinInitializationSettings();
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open',
    );
    final windowsSettings = WindowsInitializationSettings(
      appName: 'FitTrack Pro',
      // your app name
      appUserModelId: 'com.example.fittrackpro',
      // use your actual Windows App User Model ID
      guid: const Uuid().v4(), // generate a random GUID
    );

    InitializationSettings initializationSettings;

    if (Platform.isAndroid) {
      initializationSettings =
      const InitializationSettings(android: androidSettings);
    } else if (Platform.isIOS) {
      initializationSettings = const InitializationSettings(iOS: iOSSettings);
    } else if (Platform.isMacOS) {
      initializationSettings =
      const InitializationSettings(macOS: macOSSettings);
    } else if (Platform.isLinux) {
      initializationSettings =
      const InitializationSettings(linux: linuxSettings);
    } else if (Platform.isWindows) {
      initializationSettings = InitializationSettings(windows: windowsSettings);
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showRestCompleteNotification() async {
  }
}

