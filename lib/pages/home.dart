import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:safesync/pages/account_page.dart';
import 'package:safesync/pages/reports_page.dart';
import 'package:safesync/pages/incidents_page.dart';

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
        body: Stack(
          children: [
            _buildPageView(),
            if (_selectedIndex == 0) _buildAppBar(),
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return Positioned.fill(
      top: _selectedIndex == 0 ? kAppBarHeight : 0,
      bottom: kBottomNavBarHeight,
      child: PageView(
        physics: const NeverScrollableScrollPhysics(),
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
    );
  }

  Widget _buildAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: kAppBarHeight,
      child: AppBar(
        title: const Text(
          "SafeSync",
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              size: 30,
              color: Colors.blueAccent,
            ),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: kBottomNavBarHeight,
      child: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: "Report"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Incidents"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        _buildDashboardButtonRow(context), // Pass context here
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
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDashboardButtonRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _buildOfficerButton(context), // Pass context here
          ),
        ],
      ),
    );
  }

  Widget _buildOfficerButton(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: GestureDetector(
        // No splash effect
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
                    Text("Badge Number: 123456"),
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

  Widget _buildActivityRow() {
    return Row(
      children: [
        Expanded(
            child:
                _buildActivityCard("Incident Report", "5 reports submitted")),
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
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description),
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
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(incident, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(location),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text("Status: $status",
                  style: const TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}

// Constants
const double kAppBarHeight = 80.0;
const double kBottomNavBarHeight = 60.0;
