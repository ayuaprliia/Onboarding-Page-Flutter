import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:tugas1/utility/colors.dart';

class AddAnggotaView extends StatefulWidget {
  const AddAnggotaView({super.key});

  @override
  State<AddAnggotaView> createState() => _AddAnggotaViewState();
}

class _AddAnggotaViewState extends State<AddAnggotaView> {
  final _dio = Dio();
  final _storage = GetStorage();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';

  final noIndukController = TextEditingController();
  final namaController = TextEditingController();
  final tanggalLahirController = TextEditingController();
  final alamatController = TextEditingController();
  final phoneController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: blueColor),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tambahkan Anggota pada Komunitas',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Text(
              'Masukkan Data Pribadi!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Nomor Induk',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black,
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: TextField(
                controller: noIndukController,
                decoration: const InputDecoration(
                  hintText: 'Nomor Induk',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Nama Lengkap',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black,
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: TextField(
                controller: namaController,
                decoration: const InputDecoration(
                  hintText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Alamat',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black,
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: TextField(
                controller: alamatController,
                decoration: const InputDecoration(
                  hintText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tanggal Lahir',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black,
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: TextFormField(
                controller: tanggalLahirController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'TTTT-BB-HH',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null && pickedDate != selectedDate) {
                        setState(() {
                          selectedDate = pickedDate;
                          tanggalLahirController.text =
                              DateFormat('yyyy-MM-dd').format(selectedDate);
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No HP',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black,
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  hintText: 'No HP',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Center(
              child: SizedBox(
                width: 270,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    goAddAnggota(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: blueColor,
                  ),
                  child: const Text(
                    'Tambahkan Sebagai Anggota',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  void goAddAnggota(BuildContext context) async {
    // Menampilkan dialog konfirmasi
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content:
              const Text("Apakah Anda yakin ingin menambahkan anggota ini?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Memberikan nilai false saat dibatalkan
              },
            ),
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Memberikan nilai true saat dikonfirmasi
              },
            ),
          ],
        );
      },
    );

    // Jika dikonfirmasi, lakukan request HTTP
    if (confirm == true) {
      try {
        final response = await _dio.post(
          '$_apiUrl/anggota',
          options: Options(
            headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
          ),
          data: {
            'nomor_induk': noIndukController.text,
            'nama': namaController.text,
            'alamat': alamatController.text,
            'tgl_lahir': tanggalLahirController.text,
            'telepon': phoneController.text,
            'status_aktif': 1,
          },
        );

        _storage.write('data', response.data['data']);

        if (response.statusCode == 200) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Berhasil"),
                content: const Text("Anggota Baru Berhasil Ditambahkan!"),
                actions: <Widget>[
                  MaterialButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/community');
                    },
                  ),
                ],
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Error"),
                content:
                    const Text("Anggota Baru Gagal Ditambahkan. Coba Lagi!"),
                actions: <Widget>[
                  MaterialButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } on DioException catch (e) {
        print('${e.response} - ${e.response?.statusCode}');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("Anggota Baru Gagal Ditambahkan. Coba Lagi!"),
              actions: <Widget>[
                MaterialButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }
}
