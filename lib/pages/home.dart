import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:safesync/pages/account_page.dart';
import 'package:safesync/pages/reports_page.dart';
import 'package:safesync/pages/incidents_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const SafeSyncDashboard());
}

class SafeSyncDashboard extends StatefulWidget {
  const SafeSyncDashboard({super.key});

  @override
  SafeSyncDashboardState createState() => SafeSyncDashboardState();
}

class SafeSyncDashboardState extends State<SafeSyncDashboard> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: const [
              SafeSyncBody(),
              ReportsPage(),
              IncidentsPage(),
            ],
          ),
        ),
        bottomNavigationBar: _buildGoogleNavBar(),
      ),
    );
  }

  // Method to build the AppBar
  AppBar? _buildAppBar(BuildContext context) {
    return _selectedIndex == 0
        ? AppBar(
            title: Text(
              "SafeSync",
              style: GoogleFonts.poppins(
                fontSize: MediaQuery.of(context).size.width * 0.1,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  CupertinoIcons.bell,
                  size: 30,
                  color: Colors.blueAccent,
                ),
                onPressed: () {},
              ),
            ],
            backgroundColor: Colors.transparent,
            elevation: 0,
          )
        : null;
  }

  // Method to build the Google Navigation Bar
  Widget _buildGoogleNavBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.00,
      ),
      child: GNav(
        backgroundColor: Colors.white,
        color: Colors.grey,
        activeColor: Colors.blueAccent,
        tabBackgroundColor: Colors.blueAccent.withOpacity(0.1),
        gap: 2,
        padding: const EdgeInsets.all(20),
        tabs: const [
          GButton(
            icon: CupertinoIcons.home,
            text: 'Dashboard',
          ),
          GButton(
            icon: CupertinoIcons.doc_append,
            text: 'Report',
          ),
          GButton(
            icon: CupertinoIcons.list_dash,
            text: 'Incidents',
          ),
        ],
        selectedIndex: _selectedIndex,
        onTabChange: _onItemTapped,
      ),
    );
  }
}

class SafeSyncBody extends StatelessWidget {
  const SafeSyncBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(5),
      children: [
        _buildDashboardButtonRow(context),
        const SizedBox(height: 20.0),
        _buildSectionTitle("Recent Activity"),
        const SizedBox(height: 12.0),
        _buildActivityRow(),
        const SizedBox(height: 20.0),
        _buildSectionTitle("Recent Incidents"),
        const SizedBox(height: 12.0),
        _buildIncidentCard("Vehicle Accident", "On Main Street", "In Progress"),
        _buildIncidentCard("Road Hazard", "At Junction A", "Acknowledged"),
      ],
    );
  }

  // Method to build section title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Method to build the dashboard button row
  Widget _buildDashboardButtonRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _buildOfficerButton(context),
          ),
        ],
      ),
    );
  }

  // Method to build the officer button
  Widget _buildOfficerButton(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AccountDashboard()),
          );
        },
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.profile_circled,
                size: 50,
                color: Colors.blueAccent,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Officer John Doe",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text("Officer: 123456"),
                    Text("Contact: (123) 456-7890"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build activity row
  Widget _buildActivityRow() {
    return Row(
      children: [
        Expanded(
          child: _buildActivityCard("Incident Report", "5 reports submitted"),
        ),
        const SizedBox(width: 10),
        Expanded(child: _buildActivityCard("Notifications", "2 new alerts")),
      ],
    );
  }

  // Method to build activity card
  Widget _buildActivityCard(String title, String description) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(description, style: GoogleFonts.poppins()),
          ],
        ),
      ),
    );
  }

  // Method to build incident card
  Widget _buildIncidentCard(String incident, String location, String status) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              incident,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(location, style: GoogleFonts.poppins()),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Status: $status",
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
