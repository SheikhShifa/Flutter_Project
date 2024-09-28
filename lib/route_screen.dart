//new code
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';

class RouteScreen extends StatefulWidget {
  final LatLng startLocation;
  final LatLng stopLocation;

  RouteScreen({required this.startLocation, required this.stopLocation});

  @override
  _RouteScreenState createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> routePoints = [];
  double totalKMs = 0.0;

  @override
  void initState() {
    super.initState();
    _createMarkers();
    _drawRoute();
    _calculateTotalDistance();
  }

  // Create markers for start and stop locations
  void _createMarkers() {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId('start'),
        position: widget.startLocation,
        infoWindow: InfoWindow(title: 'Start Location'),
      ));

      _markers.add(Marker(
        markerId: MarkerId('stop'),
        position: widget.stopLocation,
        infoWindow: InfoWindow(title: 'Stop Location'),
      ));
    });
  }

  // Draw route between start and stop locations
  void _drawRoute() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'YOUR_GOOGLE_MAPS_API_KEY',
      PointLatLng(widget.startLocation.latitude, widget.startLocation.longitude),
      PointLatLng(widget.stopLocation.latitude, widget.stopLocation.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        routePoints.add(LatLng(point.latitude, point.longitude));
      });
    }

    setState(() {
      _polylines.add(Polyline(
        polylineId: PolylineId('route'),
        visible: true,
        points: routePoints,
        color: Colors.blue,
        width: 4,
      ));
    });
  }

  // Calculate total kilometers traveled
  void _calculateTotalDistance() {
    totalKMs = Geolocator.distanceBetween(
      widget.startLocation.latitude,
      widget.startLocation.longitude,
      widget.stopLocation.latitude,
      widget.stopLocation.longitude,
    ) /
        1000;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Route Details"),
      ),
      body: Column(
        children: [
          // Map displaying the route
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: widget.startLocation,
                zoom: 12.0,
              ),
              markers: _markers,
              polylines: _polylines,
            ),
          ),
          // Route information
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Start Location: (${widget.startLocation.latitude}, ${widget.startLocation.longitude})'),
                Text('Stop Location: (${widget.stopLocation.latitude}, ${widget.stopLocation.longitude})'),
                Text('Total Distance: ${totalKMs.toStringAsFixed(2)} KM'),
                // TODO: Calculate total duration based on start and stop time
                Text('Total Duration: 30 mins'), // Placeholder
              ],
            ),
          ),
        ],
      ),
    );
  }
}



