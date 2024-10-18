import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:io'; // Import dart:io for File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator package

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
  String? _currentLocation; // Variable to store the current location

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

  // Function to get current location
  Future<void> _getCurrentLocation() async {
    LocationPermission permission;

    // Check if location services are enabled
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

    setState(() {
      _currentLocation =
          'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
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
        _currentLocation = null; // Reset current location
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
            fontWeight: FontWeight.bold,
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
                      if (_currentLocation != null) // Display current location
                        Text(
                          _currentLocation!,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black54),
                        ),
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

  // Widget to display incident location and get location
  Widget _buildIncidentLocation() {
    return GestureDetector(
      onTap: _getCurrentLocation, // Get current location on tap
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
          child: Text(
            _currentLocation ?? 'Tap to get current location',
            style: TextStyle(
              color: _currentLocation != null ? Colors.black : Colors.black54,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
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
      label: 'Select Urgency',
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

  // Widget for upload evidence that matches the location design
  Widget _buildUploadEvidenceButton() {
    return GestureDetector(
      onTap: _takePhoto, // Call the take photo method
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
                  fit: BoxFit.cover, // Adjust the image to cover the area
                  width: double.infinity, // Full width
                  height: 150, // Fixed height
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

  // Widget for submit button
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitReport, // Submit the report on press
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(150, 50),
        backgroundColor: Colors.blueAccent, // Submit button color
      ),
      child: _isUploading
          ? const CircularProgressIndicator(
              color: Colors.white) // Show loading spinner
          : const Text(
              'Submit Report',
              style: TextStyle(color: Colors.white),
            ),
    );
  }
}
