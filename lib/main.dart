import 'package:flutter/material.dart';
import 'package:rauschmelder/drink_selection.dart';
import 'package:rauschmelder/login.dart';
import 'package:rauschmelder/user_state.dart';

void main() {
  var model = UserModel();
  runApp(MyApp(model: model,));
}

final GlobalKey<NavigatorState> navigatorKey =  GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  final UserModel model;
  const MyApp({Key? key, required this.model}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    MaterialPage page;
    return FutureBuilder(
      future: model.load(),
      builder: (context, snapshot) {
        print("loading app");
        if(snapshot.connectionState == ConnectionState.done) {
          print("app loaded");
          if(model.userName != null) {
            print("app has data");
            page = MaterialPage(
                key: const ValueKey("DrinkSelectionPage"),
                child: DrinkSelectionPage(model: model,));
          } else {
            page = MaterialPage(
                key: const ValueKey("LoginPage"),
                child: LoginPage(model: model)
            );
          }
        } else if (snapshot.hasError) {
          print("app has error");
          page = const MaterialPage(child: Center(child: Text("Failure in getting user"),));
        } else {
          print("...");
          page = const MaterialPage(child: Center(child: CircularProgressIndicator(),));
        }
        return MaterialApp(
            title: 'Rauschmelder',
            theme: ThemeData(
              primarySwatch: Colors.yellow,
            ),
            home: Navigator(
              key: navigatorKey,
              pages: [
                page
              ],
              onPopPage: (route, result) => route.didPop(result),
            )
        );
      },
    );
  }
}
