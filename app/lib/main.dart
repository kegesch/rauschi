import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rauschmelder/api/network.dart';
import 'package:rauschmelder/pages/drink_selection.dart';
import 'package:rauschmelder/pages/login.dart';
import 'package:rauschmelder/repositories/location_repository.dart';
import 'package:rauschmelder/repositories/party_repository.dart';
import 'package:rauschmelder/repositories/user_repository.dart';
import 'package:rauschmelder/services/authentication_service.dart';
import 'package:rauschmelder/services/location_service.dart';
import 'package:rauschmelder/widgets/authentication/bloc/authentication_bloc.dart';
import 'package:rauschmelder/widgets/location/bloc/location_bloc.dart';
import 'package:rauschmelder/widgets/location/bloc/location_event.dart';
import 'package:rauschmelder/widgets/party/bloc/party_listing_bloc.dart';
import 'package:rauschmelder/widgets/user/bloc/user_bloc.dart';
import 'package:rauschmelder/widgets/user/user_state.dart';

void main() {
  var model = UserModel();
  var locationService = LocationService();
  var networkProvider = NetworkProvider();
  var authenticationService =
      AuthenticationService(networkProvider: networkProvider);

  runApp(MyApp(
      model: model,
      locationService: locationService,
      networkProvider: networkProvider,
      authenticationService: authenticationService));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  final UserModel model;
  final LocationService locationService;
  final NetworkProvider networkProvider;
  final AuthenticationService authenticationService;

  const MyApp(
      {Key? key,
      required this.model,
      required this.locationService,
      required this.networkProvider,
      required this.authenticationService})
      : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final loginPage = MaterialPage(
        key: const ValueKey("LoginPage"), child: LoginPage(model: model));

    final homePage = MaterialPage(
        key: const ValueKey("DrinkSelectionPage"),
        child: DrinkSelectionPage(
          model: model,
        ));

    final navigator = Navigator(
      key: navigatorKey,
      pages: [loginPage, homePage],
      onPopPage: (route, result) => route.didPop(result),
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepository(networkProvider: networkProvider),
        ),
        RepositoryProvider<PartyRepository>(
          create: (context) => PartyRepository(),
        ),
        RepositoryProvider<LocationRepository>(
          create: (context) =>
              LocationRepository(locationService: locationService),
        )
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(
              create: (context) => AuthenticationBloc(
                  authenticationService: authenticationService)
                ..add(AppLoaded())),
          BlocProvider<LocationBloc>(
              create: (context) => LocationBloc(
                  locationRepository: context.read<LocationRepository>())
                ..add(GetLocation())),
          BlocProvider<PartyListingBloc>(
              create: (context) => PartyListingBloc(
                  partyListingRepository: context.read<PartyRepository>(),
                  locationBloc: context.read<LocationBloc>())),
          BlocProvider<UserBloc>(
              create: (context) =>
                  UserBloc(userRepository: context.read<UserRepository>())),
        ],
        child: MaterialApp(
            title: 'Rauschmelder',
            theme: ThemeData(
              primarySwatch: Colors.amber,
            ),
            home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, state) {
                if (state.status == AuthenticationStateStatus.authenticated) {
                  // show home page
                  return DrinkSelectionPage(model: model,);
                }
                // otherwise show login page
                return LoginPage(model: model);
              },
            )),
      ),
    );
  }
}
