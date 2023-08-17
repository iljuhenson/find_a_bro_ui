// import 'dart:html';

import 'package:find_a_bro/utils/on_map_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_route_service/open_route_service.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 52.2320049, 21.0116115
// 52.1691183, 21.0404706

//37.4234505,-122.0773459 for the android device

class FindPeopleScreen extends StatefulWidget {
  @override
  State<FindPeopleScreen> createState() => _FindPeopleScreenState();
}

class _FindPeopleScreenState extends State<FindPeopleScreen> {
  List<LatLng> _path = <LatLng>[];
  final OpenRouteService client =
      OpenRouteService(apiKey: dotenv.env['OPEN_ROUTE_SERVICE_TOKEN']!);

  double _zoom = 16;
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
      mapController.move(mapController.center, _zoom);
    });
  }

  void zoomOut() {
    setState(() {
      _zoom -= 0.5;
      mapController.move(mapController.center, _zoom);
    });
  }

  void positionTo(LatLng coords) {
    setState(() {
      _center = coords;
      mapController.move(coords, mapController.zoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    double buttonSize = 65.0;

    return FutureBuilder(
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          var pos = snapshot.data;
          double userLat = pos.latitude as double,
              userLon = pos.longitude as double;
          LatLng userPos = LatLng(userLat, userLon);
          _center = userPos;
          print("$userLat $userLon");

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          width: buttonSize,
                          height: buttonSize,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.background,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: IconButton(
                            // color: theme.colorScheme.onBackground,
                            icon: Icon(
                              Icons.zoom_in,
                              size: buttonSize / 2.2,
                              color: theme.colorScheme.onBackground,
                            ),
                            onPressed: () {
                              zoomIn();
                            },
                          ),
                        ),
                        SizedBox.square(
                          dimension: 10,
                        ),
                        Container(
                          width: buttonSize,
                          height: buttonSize,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.background,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: IconButton(
                            onPressed: () {
                              zoomOut();
                            },
                            icon: Icon(
                              Icons.zoom_out,
                              color: theme.colorScheme.onBackground,
                              size: buttonSize / 2.2,
                            ),
                          ),
                        ),
                        SizedBox.square(
                          dimension: 10,
                        ),
                        Container(
                          width: buttonSize,
                          height: buttonSize,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.background,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: IconButton(
                            onPressed: () {
                              mapController.center;
                              positionTo(userPos);
                            },
                            icon: Icon(
                              Icons.gps_fixed,
                              color: theme.colorScheme.onBackground,
                              size: buttonSize / 2.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SimpleAttributionWidget(
                    alignment: Alignment.bottomLeft,
                    source: Text('OpenStreetMap contributors'),
                  ),
                ],
              ),
              // RichAttributionWidget(
              //   attributions: [
              //     TextSourceAttribution(
              //       'OpenStreetMap contributors',
              //       onTap: generatePath,
              //     ),
              //   ],
              // ),
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
                    color: theme.colorScheme.onBackground,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    anchorPos: AnchorPos.align(AnchorAlign.top),
                    point: userPos,
                    width: 50,
                    height: 50,
                    builder: (context) => Icon(
                      Icons.location_on,
                      color: theme.colorScheme.primary,
                      size: 50,
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
      future: determinePosition(),
    );
  }
}
