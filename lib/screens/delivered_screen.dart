import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../helpers/image_helper.dart';
import '../helpers/location_helper.dart';
import '../models/fail_code_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/delivered_service.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_button.dart';
import 'main_screen.dart';

class DeliveryScreen extends StatefulWidget {
  final String custID;

  const DeliveryScreen({super.key, required this.custID});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  bool _isLoading = false;
  String? _selectedStatus;
  String? _selectedFailCode;
  List<FailCode> _failCodes = [];
  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;
  final DeliveredService _apiService = DeliveredService();

  @override
  void initState() {
    super.initState();
    _loadFailCodes();
  }

  Future<void> _loadFailCodes() async {
    try {
      final failCodes = await _apiService.getFailCodes();
      setState(() {
        _failCodes = failCodes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load fail codes: $e')),
      );
    }
  }

  Future<void> _takePicture() async {
    final image = await ImageHelper.takePicture();
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<void> _submitData() async {
    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a status')),
      );
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take a picture')),
      );
      return;
    }

    if (_selectedStatus == 'Gagal' && _selectedFailCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason for failure')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? user = await AuthService().getUserData();
      String? username = user?.username ?? '';

      final position = await LocationHelper.getCurrentLocation();

      if (position == null) {
        throw Exception('Failed to get location');
      }

      final bytes = await _imageFile!.readAsBytes();
      final base64Image = base64Encode(bytes);

      await _apiService.postItemDeliver(
        username: username,
        keterangan: _descriptionController.text.trim(),
        codeGagal: _selectedStatus == 'Gagal' ? _selectedFailCode : null,
        foto: base64Image,
        lat: position.latitude.toString(),
        lng: position.longitude.toString(),
        custID: widget.custID,
      );

      await _apiService.updateStatus(
        status: _selectedStatus!,
        customerId: widget.custID,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(
              username: username,
              latitude: position.latitude.toString(),
              longitude: position.longitude.toString(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(
        title: "Delivery Task",
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundColor,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Capture Section
              GestureDetector(
                onTap: _takePicture,
                child: Container(
                  height: 460,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: _imageFile == null
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt,
                                    size: 50, color: AppColors.secondaryGrey),
                                SizedBox(height: 8),
                                Text(
                                  'Tap to take picture',
                                  style:
                                      TextStyle(color: AppColors.secondaryGrey),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Status Selection
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryRed,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedStatus = 'Berhasil'),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _selectedStatus == 'Berhasil'
                                    ? AppColors.primaryRed.withOpacity(0.1)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _selectedStatus == 'Berhasil'
                                      ? AppColors.primaryRed
                                      : Colors.transparent,
                                ),
                              ),
                              child: const Center(child: Text('Berhasil')),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedStatus = 'Gagal'),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _selectedStatus == 'Gagal'
                                    ? AppColors.primaryRed.withOpacity(0.1)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _selectedStatus == 'Gagal'
                                      ? AppColors.primaryRed
                                      : Colors.transparent,
                                ),
                              ),
                              child: const Center(child: Text('Gagal')),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Fail Code Dropdown
                    if (_selectedStatus == 'Gagal') ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Reason for Failure',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedFailCode,
                        items: _failCodes.map((failCode) {
                          return DropdownMenuItem(
                            value: failCode.id.toString(),
                            child: Text(failCode.keterangan),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedFailCode = value);
                        },
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Description Field
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              CustomButton(
                text: "Simpan",
                isLoading: _isLoading,
                onPressed: _submitData,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
