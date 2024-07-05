import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Placemark?> convertPlacemarkvalve(Position? position) async {
    if (position != null) {
      try {
        final palcemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (palcemarks.isNotEmpty) {
          return palcemarks[0];
        }
      } catch (e) {
        print('error fetching location name');
      }

      return null;
    }
  }
}
