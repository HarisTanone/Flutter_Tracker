import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:slider_button/slider_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import '../models/shipping_model.dart';
import '../screens/delivered_screen.dart';
import '../services/shipping_service.dart';
import '../widgets/custom_appbar.dart';

class MapScreen extends StatefulWidget {
  final String customerId;
  final String customerName;
  final String customerAddress;
  final double customerLatitude;
  final double customerLongitude;

  const MapScreen({
    super.key,
    required this.customerId,
    required this.customerName,
    required this.customerAddress,
    required this.customerLatitude,
    required this.customerLongitude,
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final ShippingService _shippingService = ShippingService();
  late MapController _mapController;
  ShippingDocumentsByCustomerResponse? _documentsResponse;
  int _selectedButtonIndex = -1;
  bool _isLoading = true;
  String? _errorMessage;
  latlong.LatLng? _currentPosition;
  List<latlong.LatLng> _routePoints = [];
  Stream<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadShippingDocuments();
    _startLocationTracking();
  }

  void _fitMapToBounds() {
    if (_currentPosition != null && _routePoints.isNotEmpty) {
      // Buat list semua titik yang akan dimasukkan ke bounds
      List<latlong.LatLng> allPoints = [
        _currentPosition!,
        latlong.LatLng(widget.customerLatitude, widget.customerLongitude),
        ..._routePoints, // Sertakan semua titik rute
      ];

      // Hitung bounds dari semua titik
      final bounds = LatLngBounds.fromPoints(allPoints);

      // Sesuaikan peta dengan bounds
      _mapController.fitBounds(
        bounds,
        options: const FitBoundsOptions(
          padding: EdgeInsets.all(50.0),
        ),
      );
    }
  }

  Future<void> _loadShippingDocuments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _shippingService
          .getShippingDocumentsByCustomer(widget.customerId);
      if (!mounted) return;
      setState(() {
        _documentsResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load shipping documents: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _startLocationTracking() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _errorMessage = 'Location permission denied');
          return;
        }
      }

      // Initial position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = latlong.LatLng(position.latitude, position.longitude);
      await _fetchRoute(
        _currentPosition!,
        latlong.LatLng(widget.customerLatitude, widget.customerLongitude),
      );

      // Sesuaikan peta setelah posisi awal dan rute diperoleh
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _fitMapToBounds();
        });
      }

      // Start listening to position updates
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
      _positionStream!.listen((Position position) {
        if (!mounted) return;
        setState(() {
          _currentPosition =
              latlong.LatLng(position.latitude, position.longitude);
          _fetchRoute(
            _currentPosition!,
            latlong.LatLng(widget.customerLatitude, widget.customerLongitude),
          );
        });
      });
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Error getting location: $e');
      }
    }
  }

  Future<void> _fetchRoute(latlong.LatLng start, latlong.LatLng end) async {
    const String osrmUrl = 'http://router.project-osrm.org/route/v1/driving/';
    final String requestUrl =
        '$osrmUrl${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(requestUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> coordinates =
            data['routes'][0]['geometry']['coordinates'];
        _routePoints = coordinates
            .map((coord) => latlong.LatLng(coord[1], coord[0]))
            .toList();
        if (mounted) {
          setState(() {
            // Sesuaikan peta setelah rute diperbarui
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fitMapToBounds();
            });
          });
        }
      } else {
        throw 'Failed to fetch route: ${response.statusCode}';
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Error fetching route: $e');
      }
    }
  }

  void _showDetailBottomSheet(String legalNumber, int index) async {
    setState(() {
      _selectedButtonIndex = index;
    });

    try {
      final details =
          await _shippingService.getShippingDocumentDetails(legalNumber);
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    // Header
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryRed.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.inventory_2_outlined,
                                  color: AppColors.primaryRed,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Document Details',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    legalNumber,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.close,
                              color: Colors.grey[600],
                              size: 22,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        height: 1,
                        color: Colors.grey.withOpacity(0.2),
                      ),
                    ),

                    // Table header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Part Number',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Quantity',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Table content
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: details.value.length,
                              itemBuilder: (context, index) {
                                final detail = details.value[index];
                                final isEven = index % 2 == 0;

                                return Container(
                                  color:
                                      isEven ? Colors.white : Colors.grey[50],
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          detail.partNum,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          detail.lineDesc,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 8),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryRed
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${NumberFormat("###").format(double.tryParse(detail.inventoryShipQty.toString()) ?? 0)} ${detail.inventoryShipUOM}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primaryRed,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Summary footer
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 16.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Items:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              '${details.value.length} products',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading details: $e')),
      );
    }
  }

  void _openGoogleMaps() async {
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=${widget.customerLatitude},${widget.customerLongitude}';
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(
        title: "Delivery Task",
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _currentPosition ??
                        latlong.LatLng(
                            widget.customerLatitude, widget.customerLongitude),
                    zoom: 12,
                    minZoom: 5,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          strokeWidth: 6.7,
                          color: Colors.indigo,
                          borderColor: Colors.white,
                          isDotted: false,
                          // borderStrokeWidth: 5.0,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: latlong.LatLng(widget.customerLatitude,
                              widget.customerLongitude),
                          width: 80,
                          height: 80,
                          builder: (ctx) => const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                        if (_currentPosition != null)
                          Marker(
                            point: _currentPosition!,
                            width: 80,
                            height: 80,
                            builder: (ctx) => const Icon(
                              Icons.directions_car_rounded,
                              color: Colors.black87,
                              size: 35,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _openGoogleMaps,
                    backgroundColor: AppColors.backgroundColor,
                    tooltip: 'Open in Google Maps',
                    child: const Icon(Icons.directions,
                        color: AppColors.primaryRed),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Header Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.customerName,
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width < 360
                                        ? 16
                                        : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.customerAddress,
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  360
                                              ? 12
                                              : 13,
                                      color: Colors.grey[700],
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryRed.withOpacity(0.9),
                              AppColors.primaryRed
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryRed.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.badge_outlined,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'ID: ${widget.customerId}',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width < 360
                                        ? 12
                                        : 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Container(
                      height: 1,
                      color: Colors.grey.withOpacity(0.2),
                    ),
                  ),

                  // SJ Document Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.description_outlined,
                            size: 20,
                            color: AppColors.primaryRed,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Shipping Documents',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 360
                                  ? 15
                                  : 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _documentsResponse != null
                              ? 'Total: ${_documentsResponse!.totalSJ}'
                              : '0',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // SJ Document List/Status
                  _isLoading
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                height: 32,
                                width: 32,
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryRed,
                                  strokeWidth: 3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Loading documents...',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _errorMessage != null
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red[400],
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    360
                                                ? 13
                                                : 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _documentsResponse == null ||
                                  _documentsResponse!.totalSJ == 0
                              ? Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.grey[600],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'No shipping documents found',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontStyle: FontStyle.italic,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  360
                                              ? 13
                                              : 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _documentsResponse!.data.length,
                                    itemBuilder: (context, index) {
                                      final document =
                                          _documentsResponse!.data[index];
                                      final isSelected =
                                          _selectedButtonIndex == index;
                                      return GestureDetector(
                                        onTap: () => _showDetailBottomSheet(
                                            document.legalNumber, index),
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(right: 12),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primaryRed
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                                20), // Bentuk capsule
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.primaryRed
                                                  : Colors.grey
                                                      .withOpacity(0.3),
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: isSelected
                                                    ? AppColors.primaryRed
                                                        .withOpacity(0.25)
                                                    : Colors.grey
                                                        .withOpacity(0.1),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize
                                                .min, // Membuat Row sesuai dengan konten
                                            children: [
                                              Icon(
                                                Icons.file_present_outlined,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.grey[700],
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                document.legalNumber,
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.black87,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              360
                                                          ? 11
                                                          : 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                  // Add a Spacer to push the Slider Button to the bottom
                  const Spacer(),

                  // Slider Button with enhanced styling
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryRed.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SliderButton(
                      action: () async {
                        // Navigator.pop(context);
                        // return true;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DeliveryScreen(custID: widget.customerId),
                          ),
                        );
                        return null;
                      },
                      label: Text(
                        'Slide to Complete Delivery',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize:
                              MediaQuery.of(context).size.width < 360 ? 14 : 16,
                        ),
                      ),
                      icon: Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: MediaQuery.of(context).size.width < 360 ? 20 : 24,
                      ),
                      width: double.infinity,
                      radius: 16,
                      buttonColor: AppColors.primaryRed,
                      backgroundColor: Colors.white,
                      highlightedColor: AppColors.primaryRed.withOpacity(0.2),
                      baseColor: AppColors.primaryRed,
                      shimmer: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
