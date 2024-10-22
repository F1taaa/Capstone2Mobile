// ignore_for_file: use_build_context_synchronously

import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

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
    'Barangay'
  ];

  final List<String> _emergencyTypes = [
    'Fire Outbreak',
    'Car Crash',
    'Theft',
    'Harassment',
    'Shooting',
    'Noise Complaint',
    'Medical Attention',
    'Other'
  ];

  final List<String> _severityLevels = ['Low', 'Medium', 'High'];

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
    if (_selectedEmergency == null ||
        _selectedSeverity == null ||
        _selectedDepartment == null ||
        _currentAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields must be filled.'),
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      if (_isUploading) return;

      setState(() {
        _isUploading = true;
      });

      try {
        var url = Uri.parse(
            'https://capstonestey.helioho.st/safesync-mobile/submit_report.php');
        var request = http.MultipartRequest('POST', url);

        request.fields['emergency_type'] = _selectedEmergency!;
        request.fields['severity_level'] = _selectedSeverity!;
        request.fields['department'] = _selectedDepartment!;
        request.fields['location'] = _currentAddress!;

        if (_imageFile != null) {
          var file =
              await http.MultipartFile.fromPath('image', _imageFile!.path);
          request.files.add(file);
        }
        var response = await request.send();

        if (response.statusCode == 200) {
          // Resetting form fields
          setState(() {
            _selectedEmergency = null;
            _selectedSeverity = null;
            _selectedDepartment = null;
            _imageFile = null;
            _currentAddress = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report submitted successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Failed to submit the report. Please try again.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly.')),
      );
    }
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<T>(
              value: item as T,
              child: Text(item),
            );
          }).toList(),
          isExpanded: true,
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
          child: _imageFile != null
              ? Image.file(
                  File(_imageFile!.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 150,
                )
              : const Text(
                  'Tap to Take Photo',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitReport,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(150, 50),
        backgroundColor: Colors.blueAccent,
      ),
      child: _isUploading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'Submit Report',
              style: TextStyle(color: Colors.white),
            ),
    );
  }
}
