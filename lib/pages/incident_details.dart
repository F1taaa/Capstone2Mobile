import 'package:flutter/material.dart';

class IncidentDetails extends StatelessWidget {
  final Map<String, dynamic> incident;

  const IncidentDetails({super.key, required this.incident});

  static const String defaultOfficerName = "Unknown";
  static const String defaultOfficerID = "N/A";
  static const String defaultLocation = "Unknown Location";
  static const String defaultDate = "Date";
  static const String defaultStatus = "N/A";
  static const String imagesLabel = "images";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOfficerInfo(),
              const SizedBox(height: 20),
              _buildIncidentInfo(),
              const SizedBox(height: 20),
              _buildIncidentStatus(),
              const SizedBox(height: 20),
              _buildIncidentLocation(),
              const SizedBox(height: 20),
              _buildImagesTaken(),
              const SizedBox(height: 20),
              _buildDepartmentsNotified(),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text("Close"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _buildOfficerInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[300],
          child:
              const Icon(Icons.person, color: Colors.grey), // Placeholder icon
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              incident["officerName"] as String? ?? defaultOfficerName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              "Officer ID: ${incident["officerID"] as String? ?? defaultOfficerID}",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIncidentInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          incident["type"] as String? ?? "Incident",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 5),
        Text(incident["location"] as String? ?? defaultLocation),
        const SizedBox(height: 5),
        Text(incident["incidentDate"] as String? ?? defaultDate),
      ],
    );
  }

  Widget _buildIncidentStatus() {
    return Text(
      "Status: ${incident["status"] as String? ?? defaultStatus}",
      style: const TextStyle(
        color: Colors.blueAccent,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildIncidentLocation() {
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Center(
        child: Text("Incident Location", style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildImagesTaken() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Images taken",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text("${incident["images"]} $imagesLabel"),
      ],
    );
  }

  Widget _buildDepartmentsNotified() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Departments Notified",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...List.generate(
          incident["departmentsNotified"]?.length ?? 0,
          (index) {
            return Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(incident["departmentsNotified"][index] as String? ??
                    "Unknown"),
              ],
            );
          },
        ),
      ],
    );
  }
}
