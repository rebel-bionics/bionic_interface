import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'route_generator.dart';

import 'data_handling/ble_interface.dart';
import 'data_handling/data_handler.dart';
import 'screens/home.dart';

void main() {
  runApp(const MainApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BleInterface(),),
        ChangeNotifierProvider(create: (context) => DataHandler(Provider.of<BleInterface>(context, listen: false)))
      ],
      child: MaterialApp(
        title: 'Bionic Interface',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a blue toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          useMaterial3: true,
        ),
        initialRoute: '/home',
        onGenerateRoute: RouteGenerator.generateRoute,
        navigatorKey: navigatorKey,
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

