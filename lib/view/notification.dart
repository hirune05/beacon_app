//通知のimport
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sumple_beacon/view/pages/beacon_scanning_page.dart';

String detail = '';
//iOSの通知設定
Future<void> notifyIOS() {
  final flnp = FlutterLocalNotificationsPlugin();
  if (notificationCount == 0) {
    detail = 'アプリご利用ありがとうございます！';
    notificationCount++;
  } else {
    detail = '近くに助けを求めている人がいます。アプリを開き、詳細を確かめましょう';
  }
  return flnp
      .initialize(
        InitializationSettings(
          iOS: IOSInitializationSettings(),
        ),
      )
      .then((_) => flnp.show(0, 'help!', detail, NotificationDetails()));
}

//androidの通知設定
Future<void> notifyAndroid() {
  final flnp = FlutterLocalNotificationsPlugin();
  return flnp
      .initialize(
        InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      )
      .then((_) => flnp.show(
          0,
          'title',
          'body',
          NotificationDetails(
            android: AndroidNotificationDetails(
              'channel_id',
              'channel_name',
              //'channel_description',
              importance: Importance.high,
              priority: Priority.high,
            ),
          )));
}
