import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wetherappapiprovider/services/location_service.dart';

class LocationProvider with ChangeNotifier {
  Position? _currenrPosition;
  Position? get currentPosition => _currenrPosition;

  //create instance of locationservice object
  final LocationService _locationService = LocationService();

  Placemark? _currentLocationName;
  Placemark? get currentLocationName => _currentLocationName;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> determinPosition() async {
    print(234);
    _isLoading = true;
    notifyListeners();
    //permision check or not
    bool serviceEnabled;
    LocationPermission permission;
    print('1234');
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('12345');
    if (!serviceEnabled) {
      _currenrPosition = null;
      _isLoading = false;
      // _showErrorSnackbar(context, "Location services are disabled.");
      notifyListeners();
      return;
    }

    //check permission
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _currenrPosition = null;
        _isLoading = false;
        // _showErrorSnackbar(context, "Location permissions are denied.");
        notifyListeners();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _currenrPosition = null;
      _isLoading = false;
      // _showErrorSnackbar(context,
      // "Location permissions are permanently denied, we cannot request permissions.");
      notifyListeners();
      return;
    }

    _currenrPosition = await Geolocator.getCurrentPosition();
    print(currentPosition);
    _currentLocationName =
        await _locationService.convertPlacemarkvalve(currentPosition);
    _isLoading = false;
    print(_currentLocationName);
    notifyListeners();
  }
}
