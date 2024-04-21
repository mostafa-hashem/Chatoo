import 'package:chat_app/features/auth/cubit/auth_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/notifications/cubit/notifications_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/provider/app_provider.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/my_theme.dart';
import 'package:chat_app/utils/bloc_observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Bloc.observer = AppBlocObserver();
  runApp(
    ChangeNotifierProvider(
      create: (BuildContext context) => MyAppProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MyAppProvider provider;

  @override
  void initState() {
    _initPackageInfo();
    super.initState();
  }

  final String requiredVersion = '1.0.1';
  String? appVersion;
  String routeName = Routes.updateScreen;

  Future<void> _initPackageInfo() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
      if (appVersion!.compareTo(requiredVersion) < 0) {
        routeName = Routes.updateScreen;
      } else {
        routeName = Routes.splash;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<MyAppProvider>(context);
    getPreferences();
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => AuthCubit()..getAuthStatus(),
            ),
            if (routeName == Routes.splash)
              BlocProvider(
                create: (_) => NotificationsCubit()..initNotifications(),
                lazy: false,
              ),
            BlocProvider(
              create: (_) => ProfileCubit(),
            ),
            BlocProvider(
              create: (_) => GroupCubit(),
            ),
            BlocProvider(
              create: (_) => FriendCubit(),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: provider.themeMode,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale(provider.language),
            initialRoute: routeName,
            onGenerateRoute: onGenerateRoute,
          ),
        );
      },
    );
  }

  Future<void> getPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? language = prefs.getString('language');
    if (language != null) {
      provider.changeLanguage(language);
    }
    if (prefs.getString('theme') == 'dark') {
      provider.changeTheme(ThemeMode.dark);
    } else if (prefs.getString('theme') == 'system') {
      provider.changeTheme(ThemeMode.system);
    } else {
      provider.changeTheme(ThemeMode.light);
    }
  }
}
