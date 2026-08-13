  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';
import 'package:stallion_one/features/documents/presentation/employee_documents_page.dart';
import 'package:stallion_one/features/employees/models/employee_directory_page.dart';

  import '../../admin/presentation/pages/employees_management_page.dart';
  import '../../auth/presentation/pages/announcements_page.dart';
  import '../../auth/presentation/pages/attendance_calendar_page.dart';
  import '../../auth/presentation/pages/dashboard_page.dart';
  import '../../auth/presentation/pages/login_page.dart';
  import '../../dashboard/login_logout_page.dart';
  import '../../messaging/presentation/messages_page.dart';

  class AppDrawer extends StatelessWidget {
    const AppDrawer({super.key});

    @override
    Widget build(BuildContext context) {
      final User? user = FirebaseAuth.instance.currentUser;

      return Drawer(
        backgroundColor: const Color(0xFF111827),
        child: SafeArea(
          child: Column(
            children: [
              // ==================================
              // PROFILE HEADER
              // ==================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? const Icon(
                        Icons.person,
                        size: 55,
                        color: Color(0xFF6366F1),
                      )
                          : null,
                    ),

                    const SizedBox(height: 15),

                    Text(
                      user?.displayName ?? "Employee",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      user?.email ?? "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 8),

                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('employees')
                          .doc(user?.uid)
                          .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox();
                        }

                        final data =
                        snapshot.data!.data() as Map<String, dynamic>?;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            data?['role'] ?? 'Employee',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ==================================
              // MENU ITEMS
              // ==================================

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _menuTile(
                      context,
                      icon: Icons.dashboard_rounded,
                      title: "Dashboard",
                      onTap: () {
                        Navigator.pop(context);


                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DashboardPage(),
                          ),
                        );
                      },
                    ),

                    _menuTile(
                      context,
                      icon: Icons.chat_rounded,
                      title: "Messages",
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MessagePage(),
                          ),
                        );
                      },
                    ),

                    _menuTile(
                      context,
                      icon: Icons.people_alt_rounded,
                      title: "Employees Directory",
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const EmployeeDirectoryPage(),
                          ),
                        );
                      },
                    ),

                    _menuTile(
                      context,
                      icon: Icons.calendar_month_rounded,
                      title: "Attendance Calendar",
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const AttendanceCalendarPage(),
                          ),
                        );
                      },
                    ),

                    _menuTile(
                      context,
                      icon: Icons.login_rounded,
                      title: "Login / Logout",
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const LoginLogoutPage(),
                          ),
                        );
                      },
                    ),

                    _menuTile(
                      context,
                      icon: Icons.campaign_rounded,
                      title: "Announcements",
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const AnnouncementsPage(),
                          ),
                        );
                      },
                    ),

                    _menuTile(
                      context,
                      icon: Icons.settings_rounded,
                      title: "Settings",
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Settings module coming soon",
                            ),
                          ),
                        );
                      },
                    ),

                    _menuTile(
                      context,
                      icon: Icons.info_outline_rounded,
                      title: "About Company",
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: "Stallion One",
                          applicationVersion: "1.0.0",
                          children: const [
                            Text(
                              "Internal Employee Management Application",
                            ),
                          ],
                        );
                      },
                    ),

                    const Divider(
                      color: Colors.white24,
                      height: 30,
                    ),

                    _menuTile(
                      context,
                      icon: Icons.logout_rounded,
                      title: "Logout",
                      color: Colors.red,
                      onTap: () async {
                        Navigator.pop(context);

                        final confirm =
                            await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) {
                                return AlertDialog(
                                  title: const Text(
                                    "Logout",
                                  ),
                                  content: const Text(
                                    "Are you sure you want to logout?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(dialogContext)
                                            .pop(false);
                                      },
                                      child: const Text(
                                        "Cancel",
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(dialogContext)
                                            .pop(true);
                                      },
                                      child: const Text(
                                        "Logout",
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ) ??
                                false;
                        try {
                          await FirebaseFirestore.instance
                              .collection('employees')
                              .doc(user?.uid)
                              .update({
                            'isOnline': false,
                            'lastSeen':
                            FieldValue.serverTimestamp(),
                          });

                          await FirebaseAuth.instance
                              .signOut();

                          if (!context.mounted) return;

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const LoginPage(),
                            ),
                                (route) => false,
                          );
                        } catch (e) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                'Logout failed: $e',
                              ),
                            ),
                          );
                        }

                        await FirebaseFirestore.instance
                            .collection('employees')
                            .doc(user?.uid)
                            .update({
                          'isOnline': false,
                          'lastSeen': FieldValue.serverTimestamp(),
                        });

                        try {
                          // Update user offline status
                          await FirebaseFirestore.instance
                              .collection('employees')
                              .doc(FirebaseAuth.instance.currentUser?.uid)
                              .update({
                            'isOnline': false,
                            'lastSeen': FieldValue.serverTimestamp(),
                          });

                          // Sign out from Firebase
                          await FirebaseAuth.instance.signOut();

                          if (!context.mounted) return;

                          // Remove all previous pages
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                                (route) => false,
                          );
                        } catch (e) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Logout failed: $e',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _menuTile(
        BuildContext context, {
          required IconData icon,
          required String title,
          required VoidCallback onTap,
          Color color = Colors.white,
        }) {
      return ListTile(
        leading: Icon(
          icon,
          color: color,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.white38,
        ),
        onTap: onTap,
      );
    }
  }