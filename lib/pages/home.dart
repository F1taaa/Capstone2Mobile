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
        body: Stack(
          children: [
            _buildPageView(),
            if (_selectedIndex == 0) _buildAppBar(),
          ],
        ),
        bottomNavigationBar: _buildGoogleNavBar(),
      ),
    );
  }

  Widget _buildGoogleNavBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: GNav(
        backgroundColor: Colors.white,
        color: Colors.grey,
        activeColor: Colors.blueAccent,
        tabBackgroundColor: Colors.blueAccent.withOpacity(0.1),
        gap: 8,
        padding: const EdgeInsets.all(16),
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

  Widget _buildPageView() {
    return Positioned.fill(
      top: _selectedIndex == 0 ? kAppBarHeight : 0,
      bottom: kBottomNavBarHeight,
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
    );
  }

  Widget _buildAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: kAppBarHeight,
      child: AppBar(
        title: Text(
          "SafeSync",
          style: GoogleFonts.roboto(
            fontSize: 35,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.bold,
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
            Text(title,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 8),
            Text(description, style: GoogleFonts.roboto()),
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
            Text(incident,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 4),
            Text(location, style: GoogleFonts.roboto()),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text("Status: $status",
                  style: GoogleFonts.roboto(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}

const double kAppBarHeight = 50.0;
const double kBottomNavBarHeight = 60.0;
