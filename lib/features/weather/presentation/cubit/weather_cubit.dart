import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/weather.dart';
import '../../domain/usecases/get_current_weather.dart';

part 'weather_state.dart';

/// Why Cubit (flutter_bloc)?
/// - This screen has a small, enumerable set of states
///   (initial / loading / loaded / error) that map 1:1 to Cubit's
///   explicit state emissions — no hidden mutable UI state.
/// - Business logic lives here, fully unit-testable without widgets
///   (see test/features/weather/presentation/weather_cubit_test.dart).
/// - Cubit is Bloc without the event boilerplate, which a single-action
///   screen (search) doesn't need.
class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit(this._getCurrentWeather) : super(const WeatherInitial());

  final GetCurrentWeather _getCurrentWeather;

  /// Fetches weather for [city] and emits loading → loaded/error.
  Future<void> search(String city) async {
    emit(const WeatherLoading());
    try {
      final result = await _getCurrentWeather(city);
      emit(WeatherLoaded(result.weather, isFromCache: result.isFromCache));
    } on Failure catch (failure) {
      emit(WeatherError(failure.message));
    }
  }
}
