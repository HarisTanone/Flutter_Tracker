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

class EndKmScreen extends StatefulWidget {
  const EndKmScreen({super.key});

  @override
  State<EndKmScreen> createState() => _VehicleDataScreenState();
}

class _VehicleDataScreenState extends State<EndKmScreen> {
  String nomorPolisi = "";
  TextEditingController km_begin = TextEditingController();
  TextEditingController km_end = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNomorPolisi();
    _loadUsageCar();
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

  Future<void> _loadUsageCar() async {
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

      final usageCar = await UsageCarService().fetchUsageCar(username);

      if (usageCar != null) {
        if (mounted) {
          setState(() {
            km_begin.text = usageCar.km.toString();
          });
        }
      } else {
        if (mounted) {
          CustomMessage.show(context, "Data speedometer awal tidak ditemukan",
              backgroundColor: AppColors.primaryRed);
        }
      }
    } catch (e) {
      if (mounted) {
        CustomMessage.show(
            context, "Gagal memuat data speedometer: ${e.toString()}",
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

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true; // Tampilkan loading
    });

    try {
      await _loadNomorPolisi(); // Muat ulang data nomor polisi
      await _loadUsageCar(); // Muat ulang data penggunaan kendaraan
    } catch (e) {
      if (mounted) {
        CustomMessage.show(context, "Gagal memuat data: ${e.toString()}",
            backgroundColor: AppColors.primaryRed);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Selesai loading
        });
      }
    }
  }

  Future<void> _submitData() async {
    if (km_end.text.isEmpty) {
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
      final speedometerValue = int.parse(km_end.text);
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
        status: "end",
      );

      final success =
          await UsageCarService().sendUsageCar(usageCar, _imageFile!);

      if (success) {
        if (mounted) {
          CustomMessage.show(context, "Data berhasil dikirim",
              backgroundColor: Colors.green);
          km_begin.clear();
          km_end.clear();
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
          title: "Speedometer Akhir",
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: _isLoading && nomorPolisi.isEmpty
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
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Speedometer",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: km_begin,
                                      readOnly: true,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: "Awal",
                                        hintText: "0 km",
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        prefixIcon: const Icon(Icons.speed),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: km_end,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: "Akhir",
                                        hintText: "0 km",
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        prefixIcon: const Icon(Icons.speed),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
                                              style:
                                                  TextStyle(color: Colors.grey),
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
                                                errorBuilder: (context, error,
                                                    stackTrace) {
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
        ));
  }

  @override
  void dispose() {
    km_begin.dispose();
    km_end.dispose();
    super.dispose();
  }
}
