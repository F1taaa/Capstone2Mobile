import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

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

  final List<String> _departments = [
    'Police Department',
    'Fire Department',
    'Emergency Unit',
    'Barangay'
  ];
  List<String> _selectedDepartments = [];

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

      // Clear all fields after submission
      setState(() {
        _isUploading = false;
        _selectedEmergency = null;
        _selectedSeverity = null;
        _imageFile = null;
        _selectedDepartments.clear();
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
      appBar: AppBar(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Padding(
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
                        _buildDepartmentsDropdown(),
                        const SizedBox(height: 20),
                        _buildUploadEvidenceButton(),
                        const SizedBox(height: 20),
                        Center(child: _buildSubmitButton()),
                      ],
                    ),
                  ),
                ),
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
              Icon(icon, color: Colors.blue),
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

  Widget _buildDepartmentsDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Departments Needed',
          style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        MultiSelectDialogField(
          items: _departments
              .map((department) => MultiSelectItem(department, department))
              .toList(),
          title: const Text("Departments"),
          selectedColor: Colors.blueAccent,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey,
              width: 2,
            ),
          ),
          buttonIcon: const Icon(
            Icons.arrow_drop_down,
            color: Colors.blueAccent,
          ),
          buttonText: const Text(
            "Select Departments",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
          onConfirm: (values) {
            setState(() {
              _selectedDepartments = values.map((value) => value).toList();
            });
          },
          itemsTextStyle: const TextStyle(fontSize: 16),
          confirmText: const Text('Confirm',
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
          cancelText: const Text('Cancel',
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
        ),
        const SizedBox(height: 10),
        if (_selectedDepartments.isEmpty)
          const Text(
            'Please select at least one department.',
            style: TextStyle(color: Colors.red),
          ),
      ],
    );
  }

  Widget _buildUploadEvidenceButton() {
    return GestureDetector(
      onTap: _imageFile == null
          ? _takePhoto
          : null, // Disable tap if there's an image
      behavior: HitTestBehavior.translucent, // Prevent the blue flash effect
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
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _submitReport,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        child: _isUploading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Submit Report'),
      ),
    );
  }
}
