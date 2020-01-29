import 'package:get_it/get_it.dart';
import 'services/location_service.dart';
import 'services/background_fetch_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(()=> LocationService());
  locator.registerLazySingleton(()=> BackgroundFetchService());
}