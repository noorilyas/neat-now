import 'package:latlong2/latlong.dart';

class SearchResultModel {
  final String address;
  final LatLng location;

  const SearchResultModel({
    required this.address,
    required this.location,
  });
}