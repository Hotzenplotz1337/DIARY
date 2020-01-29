import '../services/stoppable_service.dart';

class LocationService extends StoppableService {
  @override
  void start() {
    super.start();
    //start listening
    print('LoationService started $serviceStopped');
  }

  @override
  void stop() {
    super.stop();
    //stop listening
    print('LoationService stopped $serviceStopped');
  }
}