import '../services/stoppable_service.dart';

class BackgroundFetchService extends StoppableService {
  @override
  void start() {
    super.start();
    //start listening
    print('BackgroundFetchService started $serviceStopped');
  }

  @override
  void stop() {
    super.stop();
    //stopped listening
    print('BackgroundFetchService stopped $serviceStopped');
  }
}