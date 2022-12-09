import 'dart:io';

import 'package:fcmpush/homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'localnotificationservice.dart';
import 'statiksinif.dart';


// fcm için bu mail kullanıldı : ddramazan.07@gmail.com
Future<void> backgroundHandler(RemoteMessage message) async {
  // print(message.data.toString());
  // print(message.notification!.title);
}

Future<void> main() async  {
  WidgetsFlutterBinding.ensureInitialized();

  try{
    //fcm
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(backgroundHandler);
    LocalNotificationService.initialize();
    //(sonradan eklendi) Update the iOS foreground notification presentation options to allow heads up notifications.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,

    );

    var _messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await _messaging.requestPermission(
        alert: true, badge: true, sound: true, provisional: false);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _messaging.getToken();
      print("IOS TOKEN : " + (token ?? ""));
    }


    runApp( MyApp());
  }catch(ex){
    print("hata "+ex.toString());
  }



}

class MyApp extends StatefulWidget {
   MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fcmRun();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM PUSH',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home:  HomePage(),
    );
  }


  void fcmRun() {


    /*
    // uygulama kapalı iken çalışacak metot
    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        print("1-> FirebaseMessaging.instance.getInitialMessage()");
      },
    );*/




    // 2. This method only call when App in forground it mean app must be opened
// uygulama açıkken tıklanınca çalışan metot
    FirebaseMessaging.onMessage.listen((message) {
        print("2-> FirebaseMessaging.instance.getInitialMessage()");
        if(Platform.isAndroid){
          LocalNotificationService.createanddisplaynotification(message);
        }
      },
    );


    // 3. This method only call when App in background and not terminated(not closed)
    // uygulama açık ama arka plandayken çalışan metot
    FirebaseMessaging.onMessageOpenedApp.listen(
          (message) {
        print("3-> FirebaseMessaging.onMessageOpenedApp.listen");

      },
    );

    FirebaseMessaging.instance
        .subscribeToTopic("all")
        .then((value) => print("topic all olarak eklendi"));

    FirebaseMessaging.instance.getToken().then((value) {
      print('firebaseToken $value');
      StatikSinif.token = value!;
    });

  }

}


