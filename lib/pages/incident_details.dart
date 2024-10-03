import 'package:flutter/material.dart';

class IncidentDetails extends StatelessWidget {
  final Map<String, dynamic> incident;

  const IncidentDetails({Key? key, required this.incident}) : super(key: key);

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
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident["officerName"] as String? ?? "Unknown",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Officer ID: ${incident["officerID"] as String? ?? "N/A"}",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                incident["type"] as String? ?? "Incident",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5),
              Text(incident["location"] as String? ?? "Unknown Location"),
              const SizedBox(height: 5),
              Text(incident["incidentDate"] as String? ?? "Date"),
              const SizedBox(height: 10),

              // Incident Status
              Text(
                "Status: ${incident["status"] as String? ?? "N/A"}",
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Center(
                  child: Text("Incident Location",
                      style: TextStyle(color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 20),

              const Text("Images taken",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text("${incident["images"]} images"),
              const SizedBox(height: 20),

              // Departments Notified
              const Text("Departments Notified",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...List.generate(incident["departmentsNotified"]?.length ?? 0,
                  (index) {
                return Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[600]),
                    const SizedBox(width: 8),
                    Text(incident["departmentsNotified"][index] as String? ??
                        "Unknown"),
                  ],
                );
              }),
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
}
