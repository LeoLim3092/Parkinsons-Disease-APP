import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:pd_app/Constants.dart';
import 'package:pd_app/api/LoginService.dart';
import 'package:pd_app/prefs/SessionPrefs.dart';
import 'package:pd_app/ui/login/LoginPage.dart';
import 'package:pd_app/ui/patient/list/PatientListViewModel.dart';
import 'package:pd_app/ui/patient/walk/WalkRecordingCubit.dart';
import 'ui/patient/list/PatientListPage.dart';
import 'package:provider/provider.dart';
import 'package:pd_app/prefs/UploadStatus.dart';



var dio = Dio(BaseOptions(
  baseUrl: Constants.BASE_HOST
));

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  try {
    var session = await LoginService.refresh();
    SessionPrefs.save(session);
    runApp(MyApp(shouldLogin: false));
  } catch (e) {
    runApp(MyApp(shouldLogin: true));
  }
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  bool shouldLogin;

  MyApp({Key? key, required this.shouldLogin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget home = const LoginPage(title: 'NTU PD');
    if (shouldLogin) {
      home = const LoginPage(title: 'NTU PD');
    }

    return MultiBlocProvider(
      providers: [
        // BlocProvider<PatientListCubit>(create: (context) => PatientListCubit()),
        BlocProvider<WalkRecordingCubit>(create: (context) => WalkRecordingCubit()),
      ],
      child: ChangeNotifierProvider<UploadStatus>(
        create: (_) => UploadStatus(),
        child: MaterialApp(
          navigatorObservers: [routeObserver],
          title: 'PD Demo',
          theme: ThemeData(
            primarySwatch: MaterialColor(0xFF80E5FF, {
            50: Color(0xFFE1F5FF),
            100: Color(0xFFB3E5FF),
            200: Color(0xFF80E5FF),
            300: Color(0xFF4DD5FF),
            400: Color(0xFF26C1FF),
            500: Color(0xFF00B2FF),
            600: Color(0xFF00A4FF),
            700: Color(0xFF0096FF),
            800: Color(0xFF008AFF),
            900: Color(0xFF007DFF),
          }),
        ),
          home: home,
          builder: EasyLoading.init(),

        )
      )
    );
  }
}
