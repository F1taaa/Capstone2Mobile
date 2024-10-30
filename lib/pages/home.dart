import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
          )
        : null;
  }

  Widget _buildGoogleNavBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
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
      padding: const EdgeInsets.all(10),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

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

  Widget _buildOfficerButton(BuildContext context) {
    return FutureBuilder<Map<String, String?>>(
      future: _getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data'));
        }

        final userData = snapshot.data;

        return Card(
          elevation: 4.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountDashboard(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.profile_circled,
                    size: 60,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData?['name'] ?? 'Officer Name',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text("Officer: ${userData?['position'] ?? 'N/A'}"),
                        Text("Contact: ${userData?['number'] ?? 'N/A'}"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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

  Widget _buildIncidentCard(String incident, String location, String status) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              incident,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Location: $location"),
            const SizedBox(height: 4),
            Text("Status: $status"),
          ],
        ),
      ),
    );
  }

  Future<Map<String, String?>> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('name'),
      'position': prefs.getString('position'),
      'number': prefs.getString('number'),
    };
  }
}
