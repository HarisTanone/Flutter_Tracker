import 'dart:io';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../helpers/image_helper.dart';
import '../helpers/location_helper.dart';
import '../models/nopol_model.dart';
import '../models/usage_car_model.dart';
import '../models/user_model.dart';
import '../screens/main_screen.dart';
import '../services/auth_service.dart';
import '../services/nopol_service.dart';
import '../services/usage_car_service.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_message.dart';

class StartKmScreen extends StatefulWidget {
  const StartKmScreen({super.key});

  @override
  State<StartKmScreen> createState() => _VehicleDataScreenState();
}

class _VehicleDataScreenState extends State<StartKmScreen> {
  String nomorPolisi = "";
  final TextEditingController _speedometerController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNomorPolisi();
  }

  Future<void> _loadNomorPolisi() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = await AuthService().getUserData();
      String? username = user?.username;

      if (username == null || username.isEmpty) {
        if (mounted) {
          CustomMessage.show(context, "Username tidak ditemukan",
              backgroundColor: AppColors.primaryRed);
        }
        return;
      }

      NopolResponse? nopolResponse = await NopolService().getNopol(username);
      String nopol = nopolResponse?.shipHeadLabelComment ?? "Tidak tersedia";

      if (nopolResponse != null) {
        setState(() {
          nomorPolisi = nopol;
        });
      } else {
        if (mounted) {
          CustomMessage.show(context, "Gagal memuat data nomor polisi",
              backgroundColor: AppColors.primaryRed);
        }
      }
    } catch (e) {
      if (mounted) {
        CustomMessage.show(context, "Terjadi kesalahan: ${e.toString()}",
            backgroundColor: AppColors.primaryRed);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _takePicture() async {
    final image = await ImageHelper.takePicture();
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    } else {
      if (mounted) {
        CustomMessage.show(context, "Gagal mengambil gambar",
            backgroundColor: AppColors.primaryRed);
      }
    }
  }

  Future<void> _submitData() async {
    if (_speedometerController.text.isEmpty) {
      CustomMessage.show(context, "Harap masukkan nilai speedometer",
          backgroundColor: AppColors.primaryRed);
      return;
    }

    if (_imageFile == null) {
      CustomMessage.show(context, "Harap ambil gambar terlebih dahulu",
          backgroundColor: AppColors.primaryRed);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final speedometerValue = int.parse(_speedometerController.text);
      final user = await AuthService().getUserData();

      if (user == null || user.username == null) {
        CustomMessage.show(context, "Data pengguna tidak ditemukan",
            backgroundColor: AppColors.primaryRed);
        return;
      }

      // Ambil lokasi terkini
      final position = await LocationHelper.getCurrentLocation();
      if (position == null) {
        CustomMessage.show(context, "Gagal mendapatkan lokasi",
            backgroundColor: AppColors.primaryRed);
        return;
      }

      final usageCar = UsageCar(
        username: user.username!,
        noKendaraan: nomorPolisi,
        km: speedometerValue,
        fotoKm: "", // Akan diisi di service
        lat: position.latitude.toString(), // Pakai lokasi yang didapat
        lng: position.longitude.toString(),
        tanggal: DateTime.now().toString().split(' ')[0],
        status: "begin",
      );
      // print("jnck sendUsageCar: $usageCar");
      final success =
          await UsageCarService().sendUsageCar(usageCar, _imageFile!);

      if (success) {
        if (mounted) {
          CustomMessage.show(context, "Data berhasil dikirim",
              backgroundColor: Colors.green);
          _speedometerController.clear();
          setState(() {
            _imageFile = null;
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(
                username: user.username!,
                latitude: position.latitude.toString(),
                longitude: position.longitude.toString(),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          CustomMessage.show(context, "Gagal mengirim data ke server",
              backgroundColor: AppColors.primaryRed);
        }
      }
    } catch (e) {
      if (mounted) {
        CustomMessage.show(context, "Gagal mengirim data: ${e.toString()}",
            backgroundColor: AppColors.primaryRed);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(
        title: "Speedometer Awal",
      ),
      body: _isLoading && nomorPolisi.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nomor Polisi Display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          nomorPolisi,
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24.0),

                  // Speedometer Input
                  TextField(
                    controller: _speedometerController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Nilai Awal Speedometer",
                      hintText: "Masukkan angka speedometer",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: const Icon(Icons.speed),
                    ),
                  ),

                  const SizedBox(height: 24.0),

                  // Camera Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Foto Speedometer:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          height: 444,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey[400]!),
                          ),
                          child: // Modifikasi bagian tampilan gambar
                              _imageFile == null
                                  ? const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.camera_alt,
                                          size: 48.0,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8.0),
                                        Text(
                                          "Tap untuk mengambil foto",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    )
                                  : FutureBuilder<bool>(
                                      future: _imageFile!.exists(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }

                                        if (snapshot.hasData &&
                                            snapshot.data == true) {
                                          return Image.file(
                                            _imageFile!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Center(
                                                child: Text(
                                                    "Gagal memuat gambar",
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              );
                                            },
                                          );
                                        } else {
                                          return const Center(
                                            child: Text(
                                                "File gambar tidak ditemukan",
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          );
                                        }
                                      },
                                    ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32.0),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: "Kirim Data",
                      isLoading: _isLoading,
                      onPressed: _submitData,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _speedometerController.dispose();
    super.dispose();
  }
}
