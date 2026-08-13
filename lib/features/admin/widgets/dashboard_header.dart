import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String adminName;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onRefreshTap;

  const DashboardHeader({
    super.key,
    required this.adminName,
    this.onNotificationTap,
    this.onRefreshTap, required int totalEmployees, required int pendingLeaves,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isPhone = width < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isPhone ? 18 : 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff2563EB),
            Color(0xff1D4ED8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: isPhone
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildText(context),
          const SizedBox(height: 18),
          _buildActions(),
        ],
      )
          : Row(
        children: [
          Expanded(
            child: _buildText(context),
          ),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Welcome Back 👋",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          adminName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Manage employees, attendance, payroll, leaves and documents.",
          style: TextStyle(
            color: Colors.white.withOpacity(.9),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onRefreshTap,
          icon: const Icon(
            Icons.refresh,
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: onNotificationTap,
          icon: const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
          ),
        ),
        const CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.person,
            color: Color(0xff2563EB),
          ),
        ),
      ],
    );
  }
}