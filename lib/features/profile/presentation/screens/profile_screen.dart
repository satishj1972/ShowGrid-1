// lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/widgets/sg_bottom_nav.dart';
import '../../../../core/services/entry_service.dart';
import '../../../../core/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SGColors.carbonBlack,
      body: Container(
        decoration: const BoxDecoration(gradient: SGColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProfileInfo(),
              _buildStats(),
              _buildTabs(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUploadsTab(),
                    _buildPerformanceTab(),
                    _buildSettingsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SGBottomNav(currentIndex: 3),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(
                startAngle: 2.4,
                colors: [Color(0xFFFF4FD8), Color(0xFFFFB84D), Color(0xFF5CF1FF), Color(0xFFFF4FD8)],
              ),
              boxShadow: [BoxShadow(color: const Color(0xFFFF4FD8).withOpacity(0.7), blurRadius: 14)],
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'PROFILE',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.white),
          ),
          const Spacer(),
          IconButton(
            onPressed: _showLogoutDialog,
            icon: const Icon(Icons.logout, color: SGColors.htmlMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    final displayName = user?.displayName ?? 'GridMaster';
    final email = user?.email ?? user?.phoneNumber ?? 'Anonymous';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Avatar with gradient ring
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [SGColors.htmlViolet, SGColors.htmlPink, SGColors.htmlCyan]),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: SGColors.carbonBlack,
              child: user?.photoURL != null
                  ? ClipOval(child: Image.network(user!.photoURL!, fit: BoxFit.cover, width: 76, height: 76))
                  : Text(
                      displayName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // Name & email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(fontSize: 13, color: SGColors.htmlMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    if (user == null) {
      return const SizedBox(height: 20);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final stats = data?['stats'] as Map<String, dynamic>?;
        
        final totalEntries = stats?['totalEntries'] ?? 0;
        final totalScore = stats?['totalScore'] ?? 0.0;
        final avgScore = totalEntries > 0 ? totalScore / totalEntries : 0.0;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: SGColors.htmlGlass,
            border: Border.all(color: SGColors.borderSubtle),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Entries', totalEntries.toString(), SGColors.htmlViolet),
              _buildStatDivider(),
              _buildStatItem('Avg Score', avgScore.toStringAsFixed(1), SGColors.htmlGold),
              _buildStatDivider(),
              _buildStatItem('Rank', '#${stats?['rank'] ?? '-'}', SGColors.htmlPink),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: SGColors.htmlMuted)),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 40, color: SGColors.borderSubtle);
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: SGColors.htmlGlass,
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: SGColors.htmlViolet,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: SGColors.htmlMuted,
        tabs: const [
          Tab(text: 'Uploads'),
          Tab(text: 'Performance'),
          Tab(text: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildUploadsTab() {
    if (user == null) {
      return const Center(child: Text('Please log in', style: TextStyle(color: SGColors.htmlMuted)));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: EntryService.getUserEntries(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: SGColors.htmlViolet));
        }

        final entries = snapshot.data?.docs ?? [];

        if (entries.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined, size: 60, color: SGColors.htmlMuted),
                SizedBox(height: 16),
                Text('No uploads yet', style: TextStyle(fontSize: 16, color: SGColors.htmlMuted)),
                SizedBox(height: 8),
                Text('Start participating in challenges!', style: TextStyle(fontSize: 14, color: SGColors.htmlMuted)),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index].data() as Map<String, dynamic>;
            return _buildUploadItem(entry);
          },
        );
      },
    );
  }

  Widget _buildUploadItem(Map<String, dynamic> entry) {
    final score = entry['aiScore']?['overallScore'] ?? 0.0;
    final gridType = entry['gridType'] ?? 'fortune';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SGColors.borderSubtle),
        image: entry['thumbnailUrl'] != null || entry['mediaUrl'] != null
            ? DecorationImage(
                image: NetworkImage(entry['thumbnailUrl'] ?? entry['mediaUrl']),
                fit: BoxFit.cover,
              )
            : null,
        color: _getGridColor(gridType).withOpacity(0.2),
      ),
      child: Stack(
        children: [
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
          ),
          // Score
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.black54,
              ),
              child: Text(
                score.toStringAsFixed(1),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
          // Media type icon
          if (entry['mediaType'] == 'video')
            const Positioned(
              top: 6,
              right: 6,
              child: Icon(Icons.play_circle_fill, size: 18, color: Colors.white70),
            ),
          if (entry['mediaType'] == 'audio')
            const Positioned(
              top: 6,
              right: 6,
              child: Icon(Icons.headphones, size: 18, color: Colors.white70),
            ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    if (user == null) {
      return const Center(child: Text('Please log in', style: TextStyle(color: SGColors.htmlMuted)));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: EntryService.getUserEntries(user!.uid),
      builder: (context, snapshot) {
        final entries = snapshot.data?.docs ?? [];
        
        // Calculate stats by grid type
        Map<String, List<double>> scoresByGrid = {
          'fortune': [],
          'fanverse': [],
          'gridvoice': [],
        };

        for (var doc in entries) {
          final entry = doc.data() as Map<String, dynamic>;
          final gridType = entry['gridType'] ?? 'fortune';
          final score = (entry['aiScore']?['overallScore'] ?? 0.0).toDouble();
          if (scoresByGrid.containsKey(gridType)) {
            scoresByGrid[gridType]!.add(score);
          }
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPerformanceCard('Fortune Grid', scoresByGrid['fortune']!, SGColors.htmlGold, Icons.emoji_events),
            const SizedBox(height: 12),
            _buildPerformanceCard('Fanverse', scoresByGrid['fanverse']!, SGColors.htmlPink, Icons.movie),
            const SizedBox(height: 12),
            _buildPerformanceCard('GridVoice', scoresByGrid['gridvoice']!, SGColors.htmlGreen, Icons.mic),
          ],
        );
      },
    );
  }

  Widget _buildPerformanceCard(String title, List<double> scores, Color color, IconData icon) {
    final count = scores.length;
    final avg = count > 0 ? scores.reduce((a, b) => a + b) / count : 0.0;
    final best = count > 0 ? scores.reduce((a, b) => a > b ? a : b) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: SGColors.htmlGlass,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('Entries', count.toString(), Colors.white),
              _buildMiniStat('Avg Score', avg.toStringAsFixed(1), color),
              _buildMiniStat('Best', best.toStringAsFixed(1), SGColors.htmlGold),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: SGColors.htmlMuted)),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSettingsItem(Icons.person_outline, 'Edit Profile', () {}),
        _buildSettingsItem(Icons.notifications_outlined, 'Notifications', () {}),
        _buildSettingsItem(Icons.lock_outline, 'Privacy', () {}),
        _buildSettingsItem(Icons.help_outline, 'Help & Support', () {}),
        _buildSettingsItem(Icons.info_outline, 'About', () {}),
        const SizedBox(height: 20),
        _buildSettingsItem(Icons.logout, 'Log Out', _showLogoutDialog, isDestructive: true),
      ],
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.redAccent : SGColors.htmlMuted),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.redAccent : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: SGColors.htmlMuted),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SGColors.carbonBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to log out?', style: TextStyle(color: SGColors.htmlMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.signOut();
              if (mounted) context.go('/login');
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Color _getGridColor(String gridType) {
    switch (gridType) {
      case 'fortune': return SGColors.htmlGold;
      case 'fanverse': return SGColors.htmlPink;
      case 'gridvoice': return SGColors.htmlGreen;
      default: return SGColors.htmlViolet;
    }
  }
}
