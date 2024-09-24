// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'incident_details.dart';

class IncidentsPage extends StatefulWidget {
  const IncidentsPage({super.key});

  @override
  _IncidentsPageState createState() => _IncidentsPageState();
}

class _IncidentsPageState extends State<IncidentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _incidentTypes = ["All", "High", "Medium", "Low"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _incidentTypes.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Incidents"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: _incidentTypes.map((type) => Tab(text: type)).toList(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(context),
            const SizedBox(height: 20),
            const Text(
              "Incident List",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _incidentTypes.map((type) {
                  return _buildIncidentList(context, type);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search incidents...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case "High":
        return Colors.red;
      case "Medium":
        return Colors.orange;
      case "Low":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildIncidentList(BuildContext context, String type) {
    final incidents = [
      {
        "type": "Rear-end Collision",
        "location": "Lacson St. Bacolod City",
        "status": "In Progress",
        "severity": "High",
      },
      {
        "type": "Road Hazard - Fallen Tree",
        "location": "Junction A, Bacolod City",
        "status": "Acknowledged",
        "severity": "Medium",
      },
      {
        "type": "Traffic Jam - Road Construction",
        "location": "B.S. Aquino Drive, Bacolod City",
        "status": "In Progress",
        "severity": "Medium",
      },
      {
        "type": "Flooding Due to Heavy Rain",
        "location": "Banago, Bacolod City",
        "status": "Acknowledged",
        "severity": "High",
      },
      {
        "type": "Public Disturbance - Loud Party",
        "location": "Brgy. 3, Bacolod City",
        "status": "Resolved",
        "severity": "Low",
      },
      {
        "type": "Accident - Motorcycle Collision",
        "location": "Circumferential Road, Bacolod City",
        "status": "In Progress",
        "severity": "High",
      },
    ];

    // Filter incidents based on selected tab
    List<Map<String, dynamic>> filteredIncidents = incidents.where((incident) {
      return type == "All" || incident["severity"] == type;
    }).toList();

    return ListView.builder(
      itemCount: filteredIncidents.length,
      itemBuilder: (context, index) {
        final incident = filteredIncidents[index];
        return Material(
          color: Colors.transparent, // Make the material transparent
          child: InkWell(
            splashColor: Colors.transparent, // Disable splash color
            highlightColor: Colors.transparent, // Disable highlight color
            onTap: () {
              _showIncidentDetails(context, incident);
            },
            child: Card(
              elevation: 4.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ListTile(
                title: Text(
                  incident["type"] as String? ?? "Unknown",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text(incident["location"] as String? ?? "Unknown"),
                trailing: Text(
                  "Status: ${incident["status"] as String? ?? "Unknown"}",
                  style: TextStyle(
                    color: _getSeverityColor(incident["severity"] as String),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showIncidentDetails(
      BuildContext context, Map<String, dynamic> incident) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return IncidentDetails(incident: incident);
      },
    );
  }
}
