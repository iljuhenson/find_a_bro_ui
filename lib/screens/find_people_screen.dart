// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_route_service/open_route_service.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 52.2320049, 21.0116115
// 52.1691183, 21.0404706

class FindPeopleScreen extends StatefulWidget {
  @override
  State<FindPeopleScreen> createState() => _FindPeopleScreenState();
}

class _FindPeopleScreenState extends State<FindPeopleScreen> {
  List<LatLng> _path = <LatLng>[];
  final OpenRouteService client =
      OpenRouteService(apiKey: dotenv.env['OPEN_ROUTE_SERVICE_TOKEN']!);

  double _zoom = 6;
  LatLng _center = LatLng(52.2320049, 21.0116115);
  final mapController = MapController();

  Future<void> generatePath() async {
    final double startLat = 52.2320049, startLng = 21.0116115;

    final double endLat = 52.1691183, endLng = 21.0404706;

    final List<ORSCoordinate> routeCoordinates =
        await client.directionsRouteCoordsGet(
      startCoordinate: ORSCoordinate(latitude: startLat, longitude: startLng),
      endCoordinate: ORSCoordinate(latitude: endLat, longitude: endLng),
      profileOverride: ORSProfile.footWalking,
    );

    final List<LatLng> routePoints = routeCoordinates
        .map((coordinate) => LatLng(coordinate.latitude, coordinate.longitude))
        .toList();

    setState(() {
      _path = routePoints;
    });
  }

  void zoomIn() {
    setState(() {
      _zoom += 0.5;
      mapController.move(_center, _zoom);
    });
  }

  void zoomOut() {
    setState(() {
      _zoom -= 0.5;
      mapController.move(_center, _zoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return FutureBuilder(
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return FlutterMap(
          mapController: mapController,
          options: MapOptions(
            center: _center,
            zoom: _zoom,
            onMapReady: () {
              mapController.mapEventStream.listen((evt) {
                // print(evt);
              });
              // And any other `MapController` dependent non-movement methods
            },
          ),
          nonRotatedChildren: [
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: generatePath,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        print(_zoom);
                        zoomIn();
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(
                              theme.colorScheme.background.withOpacity(0.5))),
                      child: Icon(Icons.zoom_in),
                    ),
                    SizedBox.square(
                      dimension: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        zoomOut();
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(
                              theme.colorScheme.background.withOpacity(0.5))),
                      child: Icon(Icons.zoom_out),
                      // color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _path,
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
