import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'incident_details.dart';

class IncidentsPage extends StatefulWidget {
  const IncidentsPage({super.key});

  @override
  IncidentsPageState createState() => IncidentsPageState();
}

class IncidentsPageState extends State<IncidentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _incidentTypes = ["All", "High", "Medium", "Low"];
  String _searchQuery = '';

  final List<Map<String, dynamic>> _incidents = [
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _incidentTypes.map((type) => Tab(text: type)).toList(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(context),
              const SizedBox(height: 20),
              Text(
                "Incident List",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      onChanged: (query) {
        setState(() {
          _searchQuery = query;
        });
      },
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
    const severityColors = {
      "High": Colors.red,
      "Medium": Colors.orange,
      "Low": Colors.green,
    };
    return severityColors[severity] ?? Colors.grey;
  }

  Widget _buildIncidentList(BuildContext context, String type) {
    List<Map<String, dynamic>> filteredIncidents = _incidents.where((incident) {
      return (type == "All" || incident["severity"] == type) &&
          (incident["type"]
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              incident["location"]
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()));
    }).toList();

    return ListView.builder(
      itemCount: filteredIncidents.length,
      itemBuilder: (context, index) {
        return _buildIncidentCard(context, filteredIncidents[index]);
      },
    );
  }

  Widget _buildIncidentCard(
      BuildContext context, Map<String, dynamic> incident) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
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
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              incident["location"] as String? ?? "Unknown",
              style: GoogleFonts.poppins(),
            ),
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
