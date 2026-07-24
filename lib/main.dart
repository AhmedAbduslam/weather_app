import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/api_constants.dart';
import 'core/di/injection_container.dart' as di;
import 'features/weather/presentation/cubit/weather_cubit.dart';
import 'features/weather/presentation/pages/weather_page.dart';

Future<void> main() async {
  assert(
    ApiConstants.baseUrl.isNotEmpty && ApiConstants.apiKey.isNotEmpty,
    'Missing API config. Run with --dart-define-from-file=env/dev.json',
  );
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // set up Hive + the get_it service locator
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (_) => di.sl<WeatherCubit>(),
        child: const WeatherPage(),
      ),
    );
  }
}
