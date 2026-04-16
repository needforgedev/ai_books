import 'package:flutter/material.dart';
import 'package:ai_books/app/app.dart';
import 'package:ai_books/core/notifications/notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService.initialize();
  runApp(const AiBooksApp());
}
