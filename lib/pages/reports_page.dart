import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Main class for the ReportsPage
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  ReportsPageState createState() => ReportsPageState();
}

// State class for ReportsPage
class ReportsPageState extends State<ReportsPage> {
  final _formKey = GlobalKey<FormState>(); // Key for the form
  String? _selectedEmergency; // Selected emergency type
  String? _selectedSeverity; // Selected severity level
  String? _selectedDepartment; // Selected department
  XFile? _imageFile; // File for the uploaded image
  bool _isUploading = false; // Flag to check if uploading

  // List of departments for the dropdown
  final List<String> _departments = [
    'Police Department',
    'Fire Department',
    'Emergency Unit',
    'Barangay'
  ];

  // List of emergency types for the dropdown
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

  // List of severity levels for the dropdown
  final List<String> _severityLevels = ['Low', 'Medium', 'High'];

  // Function to take a photo using the camera
  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (!mounted) return; // Check if the widget is still mounted
    setState(() {
      _imageFile = image; // Update the image file
    });
  }

  // Function to submit the report
  Future<void> _submitReport() async {
    // Validate the form
    if (_formKey.currentState?.validate() ?? false) {
      if (_isUploading) return; // Prevent multiple uploads

      setState(() {
        _isUploading = true; // Start uploading
      });

      // Simulate a network call
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return; // Check if the widget is still mounted

      // Reset form fields after submission
      setState(() {
        _isUploading = false; // End uploading
        _selectedEmergency = null;
        _selectedSeverity = null;
        _imageFile = null;
        _selectedDepartment = null;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted successfully!'),
        ),
      );
    } else {
      // Show error message if validation fails
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
          style: GoogleFonts.poppins(
            fontSize: MediaQuery.of(context).size.width * 0.1,
            fontWeight: FontWeight.w500,
            color: Colors.blueAccent,
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey, // Assign the form key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIncidentLocation(), // Widget for incident location
                      const SizedBox(height: 20),
                      _buildTypeAndSeverityDropdowns(), // Dropdowns for type and severity
                      const SizedBox(height: 20),
                      _buildDepartmentDropdown(), // Dropdown for department selection
                      const SizedBox(height: 20),
                      _buildUploadEvidenceButton(), // Button to upload evidence
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Center(
                child: _buildSubmitButton(), // Button to submit the report
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to display incident location
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

  // Widget to build dropdowns for incident type and severity
  Widget _buildTypeAndSeverityDropdowns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _buildIncidentTypeDropdown(), // Incident type dropdown
        ),
        _buildSeverityDropdown(), // Severity dropdown
      ],
    );
  }

  // Widget for incident type dropdown
  Widget _buildIncidentTypeDropdown() {
    return _buildDropdown<String>(
      value: _selectedEmergency,
      onChanged: (newValue) {
        setState(() {
          _selectedEmergency = newValue; // Update selected emergency
        });
      },
      items: _emergencyTypes,
      label: 'Select Type',
      icon: Icons.warning,
    );
  }

  // Widget for severity dropdown
  Widget _buildSeverityDropdown() {
    return _buildDropdown<String>(
      value: _selectedSeverity,
      onChanged: (newValue) {
        setState(() {
          _selectedSeverity = newValue; // Update selected severity
        });
      },
      items: _severityLevels,
      label: 'Select Severity',
      icon: Icons.priority_high,
    );
  }

  // Generic dropdown widget
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
          return 'Please select a $label.'; // Validation message
        }
        return null; // Return null if validation passes
      },
    );
  }

  // Widget for department dropdown
  Widget _buildDepartmentDropdown() {
    return _buildDropdown<String>(
      value: _selectedDepartment,
      onChanged: (newValue) {
        setState(() {
          _selectedDepartment = newValue; // Update selected department
        });
      },
      items: _departments,
      label: 'Select Department',
      icon: Icons.business,
    );
  }

  // Widget for the upload evidence button
  Widget _buildUploadEvidenceButton() {
    return GestureDetector(
      onTap: _imageFile == null
          ? _takePhoto
          : null, // Take photo if no image uploaded
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        height: 150,
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
                        _imageFile!.name, // Display uploaded image name
                        style: const TextStyle(color: Color(0xFF3115F6)),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // Widget for the submit button
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitReport, // Submit report on press
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: _isUploading
          ? const CircularProgressIndicator(
              color: Colors.white) // Show loading indicator while uploading
          : const Text(
              'Submit Report',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
    );
  }
}
