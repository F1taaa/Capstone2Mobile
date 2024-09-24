// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedEmergency;
  String? _selectedSeverity;
  XFile? _imageFile;
  bool _isUploading = false;
  bool _policeDept = false;
  bool _fireDept = false;
  bool _emergencyUnit = false;
  bool _barangay = false;

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
    if (!mounted) return; // Check if the widget is still mounted
    setState(() {
      _imageFile = image;
    });
  }

  bool _validateDepartments() {
    return _policeDept || _fireDept || _emergencyUnit || _barangay;
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isUploading = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return; // Check if the widget is still mounted
      setState(() {
        _isUploading = false;
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
        title: const Text("Report Incident"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIncidentLocation(),
                const SizedBox(height: 20),
                _buildTypeAndSeverityDropdowns(),
                const SizedBox(height: 20),
                _buildDepartmentsCheckbox(),
                const SizedBox(height: 20),
                _buildUploadEvidenceButton(),
                const SizedBox(height: 20),
                _buildSubmitButton(),
                if (_isUploading) const LinearProgressIndicator(),
              ],
            ),
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
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: const Center(
        child: Text(
          'Incident Location',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 18,
            fontWeight: FontWeight.w600,
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
    return DropdownButtonFormField<String>(
      value: _selectedEmergency,
      onChanged: (newValue) {
        setState(() {
          _selectedEmergency = newValue;
        });
      },
      items: _emergencyTypes.map((emergency) {
        return DropdownMenuItem(
          value: emergency,
          child: Row(
            children: [
              const Icon(Icons.warning, color: Colors.blue),
              const SizedBox(width: 8),
              Text(emergency),
            ],
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Select Type',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      validator: (value) {
        if (value == null) {
          return 'Please select an emergency type.';
        }
        return null;
      },
    );
  }

  Widget _buildSeverityDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSeverity,
      onChanged: (newValue) {
        setState(() {
          _selectedSeverity = newValue;
        });
      },
      items: _severityLevels.map((severity) {
        return DropdownMenuItem(
          value: severity,
          child: Row(
            children: [
              const Icon(Icons.priority_high, color: Colors.red),
              const SizedBox(width: 8),
              Text(severity),
            ],
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Select Severity',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      validator: (value) {
        if (value == null) {
          return 'Please select a severity level.';
        }
        return null;
      },
    );
  }

  Widget _buildDepartmentsCheckbox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Departments Needed',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: const Text("Police Department"),
                value: _policeDept,
                onChanged: (bool? value) {
                  setState(() {
                    _policeDept = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: const Text("Fire Department"),
                value: _fireDept,
                onChanged: (bool? value) {
                  setState(() {
                    _fireDept = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: const Text("Emergency Unit"),
                value: _emergencyUnit,
                onChanged: (bool? value) {
                  setState(() {
                    _emergencyUnit = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: const Text("Barangay"),
                value: _barangay,
                onChanged: (bool? value) {
                  setState(() {
                    _barangay = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (!_validateDepartments())
          const Text(
            'Please select at least one department.',
            style: TextStyle(color: Colors.red),
          ),
      ],
    );
  }

  Widget _buildUploadEvidenceButton() {
    return GestureDetector(
      onTap: _takePhoto,
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
          ],
        ),
        child: _imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_imageFile!.path),
                  fit: BoxFit.cover,
                ),
              )
            : const Center(
                child: Text(
                  'Upload Evidence',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitReport,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Report New Incident'),
      ),
    );
  }
}
