import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/epicor_model.dart';
import '../services/epicor_service.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_message.dart';
import 'end_km_screen.dart'; // Import EndKmScreen
import 'map_screen.dart';

class MainScreen extends StatefulWidget {
  final String username;
  final String latitude;
  final String longitude;

  const MainScreen({
    super.key,
    required this.username,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final EpicorService _epicorService = EpicorService();
  List<CustomerData> _customers = [];
  List<CustomerData> _filteredCustomers = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_filterCustomers);
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _epicorService.fetchEpicorData(
          widget.username, widget.latitude, widget.longitude);
      if (data != null) {
        setState(() {
          _customers = data.customers;
          _filteredCustomers = data.customers;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers = _customers.where((customer) {
        final fullAddress =
            '${customer.address} ${customer.city}'.toLowerCase();
        return customer.legalNumberCount.toString().contains(query) ||
            customer.name.toLowerCase().contains(query) ||
            fullAddress.contains(query) ||
            customer.status.toLowerCase().contains(query) ||
            customer.distanceKm.toString().contains(query);
      }).toList();
    });
  }

  // Menampilkan dialog konfirmasi kembali ke gudang
  void _showWarehouseConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Pastikan anda telah kembali ke gudang.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EndKmScreen(),
                  ),
                );
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'berhasil':
        return Colors.green;
      case 'gagal':
        return Colors.red;
      case 'belum dikirim':
        return Colors.orange;
      case 'dalam pengiriman':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(
        title: "Delivery Task",
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showWarehouseConfirmation,
        backgroundColor: AppColors.primaryRed,
        child: const Icon(
          Icons.camera_alt,
          color: AppColors.backgroundColor,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: Colors.blue,
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search deliveries...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCustomers.isEmpty
                      ? const Center(child: Text('No deliveries found'))
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = _filteredCustomers[index];
                            return InkWell(
                              onTap: customer.status.toLowerCase() == 'berhasil'
                                  ? () => CustomMessage.show(
                                      context, "Task ini telah selesai",
                                      backgroundColor: Colors.green)
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MapScreen(
                                            customerId: customer.custID,
                                            customerName: customer.name,
                                            customerAddress: customer.address,
                                            customerLatitude: double.parse(
                                                customer.lat ?? '0'),
                                            customerLongitude: double.parse(
                                                customer.lng ?? '0'),
                                          ),
                                        ),
                                      );
                                    },
                              child: Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              customer.name,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(
                                                  customer.status),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              customer.status,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${customer.address}, ${customer.city}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'Legal #: ${customer.legalNumberCount}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              '${customer.distanceKm.toStringAsFixed(1)} km',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
