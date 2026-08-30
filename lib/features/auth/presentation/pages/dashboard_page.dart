
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/attendance_service.dart';
import '../../../../core/services/session_service.dart';
import '../../../common/widgets/app_drawer.dart';
import '../../../dashboard/login_logout_page.dart';
import '../../../documents/presentation/employee_documents_page.dart';
import '../../../holidays/presentation/holiday_page.dart';
import '../../../leave/presentation/leave_request_page.dart';
import '../../../messaging/presentation/chat_notification_badge.dart';
import '../../../messaging/presentation/group_chat_page.dart';
import '../../../messaging/presentation/messages_page.dart';
import 'announcements_page.dart';
import 'attendance_calendar_page.dart';
import 'attendance_popup_page.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() =>
      _DashboardPageState();
}

class _DashboardPageState
    extends State<DashboardPage> {

  //==================================================
  // FIREBASE
  //==================================================

  final User? user =
      FirebaseAuth.instance.currentUser;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  //==================================================
  // EMPLOYEE PROFILE
  //==================================================

  Map<String, dynamic>? employeeData;

  bool employeeLoading = true;

  //==================================================
  // SERVICES
  //==================================================

  final AttendanceService attendanceService =
  AttendanceService();

  final SessionService sessionService =
  SessionService();

  //==================================================
  // TIMER
  //==================================================

  StreamSubscription<Duration>? timerSubscription;

  Timer? _workingTimeTimer;

  //==================================================
  // DASHBOARD DATA
  //==================================================

  String timerText = "00:00:00";

  String todayLoginTime = "--:--";

  String todayWorkingTime = "00:00:00";

  Duration todayWorkDuration = Duration.zero;

  bool isLoggedIn = false;

  bool isCheckedIn = false;

  DateTime? loginStartTime;


@override
void initState() {
  super.initState();

  _initData();

  timerSubscription =
      attendanceService.liveTimer().listen(
            (duration) async {
          if (!mounted) return;

          final checkedIn =
          await attendanceService.isCheckedIn();

          if (!mounted) return;

          setState(() {
            isCheckedIn = checkedIn;

            if (checkedIn) {
              timerText =
                  _formatDuration(duration);
            } else {
              timerText =
                  todayWorkingTime;
            }
          });
        },
      );
  _workingTimeTimer = Timer.periodic(
    const Duration(seconds: 1),
        (_) {
      if (mounted) {
        _loadTodaySessionInfo();
      }
    },
  );
}
Future<void> _initData() async {
  isCheckedIn =
  await attendanceService.isCheckedIn();
  await _loadTodaySessionInfo();

  await _detectActiveSession();

  await loadEmployeeProfile();
}


Future<void> loadEmployeeProfile() async {

  if (user == null) return;

  try {

    final document = await _firestore
        .collection("employees")
        .doc(user!.uid)
        .get();

    if (!mounted) return;

    if (document.exists) {

      setState(() {

        employeeData = document.data();

        employeeLoading = false;

      });

    } else {

      setState(() {

        employeeLoading = false;

      });

    }

  } catch (e) {

    if (!mounted) return;

    setState(() {

      employeeLoading = false;

    });

  }
}
@override
void dispose() {
  timerSubscription?.cancel();
  _workingTimeTimer?.cancel();
  super.dispose();
}

Future<void> _loadTodaySessionInfo() async {
  try {
    final sessions =
    await sessionService.sessionHistory();

    final now = DateTime.now();

    Duration totalDuration =
        Duration.zero;

    DateTime? firstLogin;

    for (final session in sessions) {
      if (session.loginTime.year == now.year &&
          session.loginTime.month == now.month &&
          session.loginTime.day == now.day) {

        totalDuration += session.sessionDuration;

        firstLogin ??= session.loginTime;
      }
    }
    if (!mounted) return;
    setState(() {
      todayWorkDuration = totalDuration;

      todayWorkingTime =
          _formatDuration(totalDuration);

      // IMPORTANT
      if (!isCheckedIn) {
        timerText =
            _formatDuration(totalDuration);
      }

      todayLoginTime =
      firstLogin == null
          ? "--:--"
          : _formatTime(
        firstLogin!,
      );
    });


  } catch (_) {}
}


Future<void>
_detectActiveSession() async {
try {
final active =
await sessionService
.currentSession();

if (!mounted) return;

if (active != null) {
setState(() {
isLoggedIn = true;
loginStartTime =
active.loginTime;
});
} else {
setState(() {
isLoggedIn = false;
loginStartTime = null;
});
}
} catch (_) {
if (!mounted) return;

setState(() {
isLoggedIn = false;
loginStartTime = null;
});
}
}

Future<void>
_openAttendancePopup() async {
final result =
await showDialog(
context: context,
builder: (_) =>
const AttendancePopupPage(),
);

if (result == true &&
mounted) {
await _initData();
}
}

String _formatDuration(
Duration d) {
String two(int n) =>
n.toString().padLeft(
2,
'0',
);

return "${two(d.inHours)}:"
"${two(d.inMinutes.remainder(60))}:"
"${two(d.inSeconds.remainder(60))}";
}

String _formatTime(
DateTime date) {
int hour =
date.hour % 12;

if (hour == 0) {
hour = 12;
}

final minute =
date.minute
.toString()
.padLeft(2, '0');

final period =
date.hour >= 12
? "PM"
: "AM";

return "$hour:$minute $period";
}

Future<void>
_openLoginLogoutPage() async {
await Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const LoginLogoutPage(),
),
);

if (!mounted) return;

await _initData();
}


@override
Widget build(BuildContext context) {
final width =
MediaQuery.of(context).size.width;

return Scaffold(
  backgroundColor:
  const Color(0xFF0F172A),

  drawer: const AppDrawer(),

  appBar: AppBar(
    elevation: 0,
    backgroundColor:
    const Color(0xFF111827),

    iconTheme:
    const IconThemeData(
      color: Colors.white,
    ),

    title: const Text(
      "Team One",
      style: TextStyle(
        color: Colors.white,
        fontWeight:
        FontWeight.bold,
      ),
    ),

    actions: [

      // ==========================
      // CHATS
      // ==========================

      Padding(
        padding:
        const EdgeInsets.only(
          right: 4,
        ),
        child: ChatNotificationBadge(
          child: IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const MessagePage(),
                ),
              );
            },
          ),
        ),
      ),

      // ==========================
      // NOTIFICATIONS
      // ==========================

      IconButton(
        icon: const Icon(
          Icons.notifications_none,
          color: Colors.white,
        ),
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            const SnackBar(
              content: Text(
                "Notifications Coming Soon",
              ),
            ),
          );
        },
      ),

      // ==========================
      // ATTENDANCE TIMER
      // ==========================

      Padding(
        padding:
        const EdgeInsets.only(
          right: 8,
        ),
        child: GestureDetector(
          onTap:
          _openAttendancePopup,
          child: Container(
            padding:
            const EdgeInsets
                .symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration:
            BoxDecoration(
              color:
              Colors.white10,
              borderRadius:
              BorderRadius
                  .circular(
                20,
              ),
            ),
            child: Row(
              children: [

                const Icon(
                  Icons.timer_outlined,
                  color:
                  Colors.white,
                  size: 18,
                ),

                const SizedBox(
                  width: 6,
                ),

                Text(
                  timerText,
                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                    fontWeight:
                    FontWeight
                        .bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ==========================
      // USER PROFILE
      // ==========================

      Padding(
        padding:
        const EdgeInsets.only(
          right: 12,
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor:
          Colors.white24,

          backgroundImage:
          user?.photoURL !=
              null
              ? NetworkImage(
            user!
                .photoURL!,
          )
              : null,

          child:
          user?.photoURL ==
              null
              ? Text(
            (user?.displayName ??
                "E")[0]
                .toUpperCase(),
            style:
            const TextStyle(
              color:
              Colors.white,
              fontWeight:
              FontWeight
                  .bold,
            ),
          )
              : null,
        ),
      ),
    ],
  ),
body: RefreshIndicator(
onRefresh: _initData,
child: SingleChildScrollView(
physics:
const AlwaysScrollableScrollPhysics(),
padding:
const EdgeInsets.all(
20,
),
child: Column(
children: [

// HERO CARD

Container(
width:
double.infinity,
padding:
const EdgeInsets
.all(25),
decoration:
BoxDecoration(
borderRadius:
BorderRadius
.circular(
30,
),
gradient:
const LinearGradient(
begin:
Alignment
.topLeft,
end:
Alignment
.bottomRight,
colors: [
Color(
0xFF6366F1),
Color(
0xFF8B5CF6),
],
),
boxShadow: [
BoxShadow(
color: Colors
.purple
.withOpacity(
.3),
blurRadius: 30,
offset:
const Offset(
0, 10),
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment
.start,
children: [

const Text(
"Welcome Back 👋",
style:
TextStyle(
color: Colors
.white70,
),
),

const SizedBox(
height: 10),

  employeeLoading
      ? const CircularProgressIndicator(
    color: Colors.white,
  )
      : Text(
    employeeData?["name"] ??
        user?.displayName ??
        "Employee",
    style: const TextStyle(
      color: Colors.white,
      fontSize: 30,
      fontWeight: FontWeight.bold,
    ),
  ),
const SizedBox(
height: 5),
  Text(
    employeeData?["email"] ??
        user?.email ??
        "",
    style: const TextStyle(
      color: Colors.white70,
    ),
  ),

  const SizedBox(height: 15),

  Row(
    children: [

      const Icon(
        Icons.badge,
        color: Colors.white70,
        size: 18,
      ),

      const SizedBox(width: 8),

      Expanded(
        child: Text(
          "Employee ID : ${employeeData?["employeeId"] ?? "--"}",
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    ],
  ),

  const SizedBox(height: 8),

  Row(
    children: [

      const Icon(
        Icons.work,
        color: Colors.white70,
        size: 18,
      ),

      const SizedBox(width: 8),

      Expanded(
        child: Text(
          "Department : ${employeeData?["department"] ?? "--"}",
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    ],
  ),

  const SizedBox(height: 8),

  Row(
    children: [

      const Icon(
        Icons.person,
        color: Colors.white70,
        size: 18,
      ),

      const SizedBox(width: 8),

      Expanded(
        child: Text(
          "Designation : ${employeeData?["role"] ?? "--"}",
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    ],
  ),
const SizedBox(
height: 25),




GestureDetector(
onTap: () async {
if (isLoggedIn) {
await sessionService
.logout();
} else {
await sessionService
.login();
}

await _initData();
},

onLongPress:
_openLoginLogoutPage,

child: Container(
width:
double.infinity,
padding:
const EdgeInsets
.all(20),
decoration:
BoxDecoration(
color:
Colors.white10,
borderRadius:
BorderRadius
.circular(
20,
),
border:
Border.all(
color: Colors
.white24,
),
),
child: Column(
children: [

Icon(
isLoggedIn
? Icons
.logout_rounded
: Icons
.login_rounded,
size: 40,
color: Colors
.white,
),

const SizedBox(
height:
10),

Text(
isLoggedIn
? "Tap To Logout"
: "Tap To Login",
style:
const TextStyle(
color: Colors
.white,
fontSize:
18,
fontWeight:
FontWeight
.bold,
),
),

  const SizedBox(
    height: 10,
  ),

  Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
    decoration: BoxDecoration(
      color: Colors.white10,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [

        const Text(
          "Today's Working Hours",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 4),

        const SizedBox(height: 15),

        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceEvenly,
          children: [

            Column(
              children: [
                const Text(
                  "Login Time",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  todayLoginTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            Container(
              width: 1,
              height: 35,
              color: Colors.white24,
            ),

            Column(
              children: [
                const Text(
                  "Attendance",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isCheckedIn
                      ? "Checked In"
                      : "Checked Out",
                  style: TextStyle(
                    color: isCheckedIn
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),

        Text(
          todayWorkingTime,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
  const SizedBox(height: 8),



  const SizedBox(height: 6),

  const Text(
    "Long Press For Session Details",
    style: TextStyle(
      color: Colors.white60,
      fontSize: 12,
    ),
  ),
],
),
),
),
],
),
),

const SizedBox(height: 25),
// ATTENDANCE CALENDAR

_menuTile(
title: "Attendance Calendar",
icon:
Icons.calendar_month_rounded,
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const AttendanceCalendarPage(),
),
);
},
),

const SizedBox(height: 25),

// QUICK ACTIONS TITLE

const Align(
alignment:
Alignment.centerLeft,
child: Text(
"Quick Actions",
style: TextStyle(
color: Colors.white,
fontSize: 22,
fontWeight:
FontWeight.bold,
),
),
),

const SizedBox(height: 15),

// QUICK ACTIONS GRID

  GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: width > 900 ? 4 : 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    childAspectRatio: 1.05,
    children: [

      DashboardCard(
        title: "Announcements",
        icon: Icons.campaign_rounded,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AnnouncementsPage(),
            ),
          );
        },
      ),
      DashboardCard(
        title: "Messages",
        icon: Icons.chat_bubble_rounded,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MessagePage(),
            ),
          );
        },
      ),

      DashboardCard(
        title: " Company Group",
        icon: Icons.groups_rounded,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const GroupChatPage(
                groupId: 'company_group',
                groupName: 'Company Group',
              ),
            ),
          );
        },
      ),

      DashboardCard(
        title: "Leave",
        icon: Icons.event_available_rounded,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LeaveRequestPage(),
            ),
          );
        },
      ),

      DashboardCard(
        title: "Holidays",
        icon: Icons.celebration_rounded,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HolidayPage(),
            ),
          );
        },
      ),

      DashboardCard(
        title: "Documents",
        icon: Icons.folder_copy_rounded,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EmployeeDocumentsPage(),
            ),
          );
        },
      ),

      DashboardCard(
        title: "Profile",
        icon: Icons.person_rounded,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile Coming Soon"),
            ),
          );
        },
      ),


      /*DashboardCard(
        title: "My Payslips",
        icon: Icons.receipt_long,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EmployeePayslipPage(),
            ),
          );
        },
      ),

       */

      DashboardCard(
        title: "Attendance",
        icon: Icons.fact_check,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AttendanceCalendarPage(),
            ),
          );
        },
      ),
    ],
  ),
const SizedBox(height: 30),
],
),
),
),
);
}


Widget _summaryCard(
String title,
String value,
IconData icon,
Color color,
) {
return Container(
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: const Color(0xFF1E293B),
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: Colors.white10,
),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

CircleAvatar(
radius: 18,
backgroundColor:
color.withOpacity(.15),
child: Icon(
icon,
color: color,
size: 18,
),
),

const SizedBox(height: 15),

Text(
title,
style: const TextStyle(
color: Colors.white54,
fontSize: 12,
),
),

const SizedBox(height: 6),

Text(
value,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
style: const TextStyle(
color: Colors.white,
fontSize: 18,
fontWeight:
FontWeight.bold,
),
),
],
),
);
}

Widget _menuTile({
required String title,
required IconData icon,
required VoidCallback onTap,
}) {
return InkWell(
onTap: onTap,
borderRadius:
BorderRadius.circular(20),
child: Container(
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: const Color(0xFF1E293B),
borderRadius:
BorderRadius.circular(20),
border: Border.all(
color: Colors.white10,
),
),
child: Row(
children: [

CircleAvatar(
backgroundColor:
Colors.blue.withOpacity(.15),
child: Icon(
icon,
color: Colors.blue,
),
),

const SizedBox(width: 15),

Expanded(
child: Text(
title,
style: const TextStyle(
color: Colors.white,
fontWeight:
FontWeight.w600,
),
),
),

const Icon(
Icons.arrow_forward_ios,
color: Colors.white54,
size: 16,
),
],
),
),
);
}




}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });



  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius:
                    BorderRadius.circular(18),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF8B5CF6),
                    size: 32,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight:
                    FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
