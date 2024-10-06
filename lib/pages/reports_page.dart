import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<void> _submitReport() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isUploading) return;

      setState(() {
        _isUploading = true;
      });

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      setState(() {
        _isUploading = false;
        _selectedEmergency = null;
        _selectedSeverity = null;
        _imageFile = null;
        _selectedDepartment = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted successfully!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields correctly.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Report Incident',
          style: GoogleFonts.poppins(),
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
                      const SizedBox(height: 20),
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
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2)),
        ],
      ),
      child: const Center(
        child: Text(
          'Incident Location',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 20,
            fontWeight: FontWeight.w700,
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
      label: 'Select Severity',
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
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item as T,
          child: Row(
            children: [
              Icon(icon,
                  color: const Color(0xFF3115F6)), // Consistent icon color
              const SizedBox(width: 8),
              Text(item, style: const TextStyle(fontSize: 16)),
            ],
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      validator: (value) {
        if (value == null) {
          return 'Please select a $label.';
        }
        return null;
      },
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
      onTap: _imageFile == null ? _takePhoto : null,
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        height: 100,
        width: double.infinity,
        child: DecoratedBox(
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
                    'Upload Evidence (Tap to Take Photo)',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Evidence Uploaded',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _imageFile!.name,
                        style: const TextStyle(
                            color: Color(0xFF3115F6)), // Consistent text color
                      ),
                    ],
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
        backgroundColor: Colors.blueAccent, // Button background color
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      ),
      child: _isUploading
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : Text(
              'Submit Report',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.white, // Change this to your desired text color
              ),
            ),
    );
  }
}
