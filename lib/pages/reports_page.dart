// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  ReportsPageState createState() => ReportsPageState();
}

class ReportsPageState extends State<ReportsPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedEmergency;
  String? _selectedSeverity;
  String? _selectedDepartment;
  XFile? _imageFile;
  bool _isUploading = false;
  String? _currentAddress;

  final List<String> _departments = [
    'Police Department',
    'Fire Department',
    'Emergency Unit',
    'Barangay',
  ];

  final List<String> _emergencyTypes = [
    'Fire Outbreak',
    'Car Crash',
    'Theft',
    'Medical Attention',
  ];

  final List<String> _severityLevels = [
    'Low',
    'Medium',
    'High',
    'Critical',
  ];

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (!mounted) return;
    setState(() {
      _imageFile = image;
    });
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services are disabled.'),
        ),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied.'),
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permissions are permanently denied.'),
        ),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];

      setState(() {
        _currentAddress =
            '${place.locality ?? ''}, ${place.thoroughfare ?? ''}, ${place.country ?? ''}'
                .trim();
      });
    }
  }

  Future<void> _submitReport() async {
    setState(() {
      _isUploading = true;
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.56.1/Safesync_api/reporting/submit_report.php'),
    );

    request.fields['emergency'] = _selectedEmergency ?? '';
    request.fields['severity'] = _selectedSeverity ?? '';
    request.fields['department'] = _selectedDepartment ?? '';
    request.fields['location'] = _currentAddress ?? '';

    if (_imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _imageFile!.path,
        ),
      );
    }

    // Send the request
    final response = await request.send();

    // Handle response
    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final jsonResponse = json.decode(responseData.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(jsonResponse['message'])),
      );

      setState(() {
        _selectedEmergency = null;
        _selectedSeverity = null;
        _selectedDepartment = null;
        _currentAddress = null;
        _imageFile = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit report.')),
      );
    }

    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Report Incident',
          style: GoogleFonts.poppins(
            fontSize: MediaQuery.of(context).size.width * 0.1,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIncidentLocation(),
                      const SizedBox(height: 20),
                      _buildTypeAndSeverityDropdowns(),
                      const SizedBox(height: 20),
                      _buildDepartmentDropdown(),
                      const SizedBox(height: 20),
                      _buildUploadEvidenceButton(),
                    ],
                  ),
                ),
              ),
              Center(
                child: _buildSubmitButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncidentLocation() {
    return GestureDetector(
      onTap: _getCurrentLocation,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(2, 2)),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_currentAddress != null)
                Text(
                  _currentAddress!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                )
              else
                const Text(
                  'Tap to get current location',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeAndSeverityDropdowns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _buildIncidentTypeDropdown(),
        ),
        _buildSeverityDropdown(),
      ],
    );
  }

  Widget _buildIncidentTypeDropdown() {
    return _buildDropdown<String>(
      value: _selectedEmergency,
      onChanged: (newValue) {
        setState(() {
          _selectedEmergency = newValue;
        });
      },
      items: _emergencyTypes,
      label: 'Select Type',
      icon: Icons.warning,
    );
  }

  Widget _buildSeverityDropdown() {
    return _buildDropdown<String>(
      value: _selectedSeverity,
      onChanged: (newValue) {
        setState(() {
          _selectedSeverity = newValue;
        });
      },
      items: _severityLevels,
      label: 'Select Urgency',
      icon: Icons.priority_high,
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required ValueChanged<T?>? onChanged,
    required List<String> items,
    required String label,
    required IconData icon,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<T>>((String item) {
            return DropdownMenuItem<T>(
              value: item as T,
              child: Text(item),
            );
          }).toList(),
          hint: const Text('Select an option'),
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return _buildDropdown<String>(
      value: _selectedDepartment,
      onChanged: (newValue) {
        setState(() {
          _selectedDepartment = newValue;
        });
      },
      items: _departments,
      label: 'Select Department',
      icon: Icons.business,
    );
  }

  Widget _buildUploadEvidenceButton() {
    return GestureDetector(
      onTap: _takePhoto,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(2, 2)),
          ],
        ),
        child: Center(
          child: _imageFile == null
              ? const Text(
                  'Tap to upload evidence (Image)',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : Image.file(File(_imageFile!.path)),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isUploading ? null : _submitReport,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(150, 50),
        backgroundColor: Colors.blueAccent,
      ),
      child: _isUploading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
          : const Text(
              'Submit Report',
              style: TextStyle(color: Colors.white),
            ),
    );
  }
}
