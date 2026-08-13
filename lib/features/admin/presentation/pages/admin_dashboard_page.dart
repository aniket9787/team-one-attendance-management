import 'package:flutter/material.dart';

import 'package:stallion_one/features/admin/data/dashboard_service.dart';
import 'package:stallion_one/features/admin/data/employee_service.dart';

import 'package:stallion_one/features/admin/domain/dashboard_summary_model.dart';
import 'package:stallion_one/features/admin/models/employee_model.dart';

import 'package:stallion_one/features/admin/widgets/dashboard_header.dart';
import 'package:stallion_one/features/admin/widgets/dashboard_stat_card.dart';
import 'package:stallion_one/features/admin/widgets/dashboard_quick_action.dart';
import 'package:stallion_one/features/admin/widgets/dashboard_recent_employee_card.dart';
import 'package:stallion_one/features/admin/widgets/dashboard_leave_card.dart';
import 'package:stallion_one/features/admin/widgets/dashboard_holiday_card.dart';
import 'package:stallion_one/features/admin/widgets/dashboard_document_card.dart';
import 'package:stallion_one/features/admin/widgets/dashboard_chat_card.dart';
import 'package:stallion_one/features/admin/widgets/dashboard_activity_card.dart';

import 'package:stallion_one/features/admin/presentation/pages/employees_management_page.dart';
import 'package:stallion_one/features/admin/presentation/pages/attendance_report_page.dart';
import 'package:stallion_one/features/admin/presentation/pages/payroll_management_page.dart';
import 'package:stallion_one/features/admin/presentation/pages/payslip_management_page.dart';
import 'package:stallion_one/features/admin/presentation/pages/daily_summary_page.dart';
import 'package:stallion_one/features/admin/presentation/pages/settings_page.dart';
import 'package:stallion_one/features/admin/presentation/pages/announcements_management_page.dart';

import 'package:stallion_one/features/leave/data/leave_service.dart';
import 'package:stallion_one/features/leave/domain/leave_model.dart';
import 'package:stallion_one/features/leave/presentation/leave_management_page.dart';

import 'package:stallion_one/features/documents/data/document_service.dart';
import 'package:stallion_one/features/documents/domain/document_model.dart';
import 'package:stallion_one/features/documents/presentation/admin_documents_page.dart';

import 'package:stallion_one/features/holidays/data/holiday_service.dart';
import 'package:stallion_one/features/holidays/domain/holiday_model.dart';
import 'package:stallion_one/features/holidays/presentation/holiday_management_page.dart';

import 'package:stallion_one/features/messaging/presentation/messages_page.dart';
import 'package:stallion_one/features/messaging/presentation/group_chat_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() =>
      _AdminDashboardPageState();
}

class _AdminDashboardPageState
    extends State<AdminDashboardPage> {

//-----------------------------------------
// Services
//-----------------------------------------

final DashboardService _dashboardService =
DashboardService();

final EmployeeService _employeeService =
    EmployeeService.instance;

final LeaveService _leaveService =
LeaveService();

final HolidayService _holidayService =
HolidayService();

final DocumentService _documentService =
DocumentService();

//-----------------------------------------
// Dashboard Data
//-----------------------------------------

DashboardSummaryModel dashboard =
DashboardSummaryModel.empty();

List<EmployeeModel> employees = [];

List<LeaveModel> leaves = [];

List<HolidayModel> holidays = [];

List<DocumentModel> documents = [];

//-----------------------------------------
// UI State
//-----------------------------------------

bool loading = true;

bool refreshing = false;

String? error;

//-----------------------------------------
// Responsive Helpers
//-----------------------------------------

bool get isPhone =>
MediaQuery.of(context).size.width < 600;

bool get isTablet =>
MediaQuery.of(context).size.width >= 600 &&
MediaQuery.of(context).size.width < 1000;

bool get isDesktop =>
MediaQuery.of(context).size.width >= 1000;

int get gridCount {

if (isDesktop) return 4;

if (isTablet) return 3;

return 2;
}

//-----------------------------------------
// Init
//-----------------------------------------

@override
void initState() {
super.initState();

loadDashboard();
}
//-----------------------------------------
// Load Dashboard Data
//-----------------------------------------

Future<void> loadDashboard() async {

try {

setState(() {

loading = true;
error = null;

});

final results = await Future.wait([

_dashboardService.getDashboardSummary(),

  _employeeService.getEmployeesOnce(),

_leaveService.getAllLeaves(),

_holidayService.upcomingHolidays(),

_documentService.getDocuments(),

] as Iterable<Future<dynamic>>);

if (!mounted) return;

setState(() {

dashboard =
results[0] as DashboardSummaryModel;

employees =
results[1] as List<EmployeeModel>;

leaves =
results[2] as List<LeaveModel>;

holidays =
results[3] as List<HolidayModel>;

documents =
results[4] as List<DocumentModel>;

loading = false;

});

} catch (e) {

if (!mounted) return;

setState(() {

loading = false;

error = e.toString();

});

}

}

//-----------------------------------------
// Pull To Refresh
//-----------------------------------------

Future<void> refreshDashboard() async {

refreshing = true;

await loadDashboard();

refreshing = false;

}

//-----------------------------------------
// Navigation Helper
//-----------------------------------------

void openPage(Widget page) {

Navigator.push(

context,

MaterialPageRoute(

builder: (_) => page,

),

).then((_) {

loadDashboard();

});

}

//-----------------------------------------
// Approve Leave
//-----------------------------------------

Future<void> approveLeave(
LeaveModel leave) async {

await _leaveService.approveLeave(

leave.id,

"Admin",

);

loadDashboard();

}

//-----------------------------------------
// Reject Leave
//-----------------------------------------

Future<void> rejectLeave(
LeaveModel leave) async {

await _leaveService.rejectLeave(

leave.id,

"Admin",

);

loadDashboard();

}

//-----------------------------------------
// Loading Widget
//-----------------------------------------

Widget buildLoading() {

return const Center(

child: CircularProgressIndicator(),

);

}

//-----------------------------------------
// Error Widget
//-----------------------------------------

Widget buildError() {

return Center(

child: Column(

mainAxisAlignment:
MainAxisAlignment.center,

children: [

const Icon(

Icons.error_outline,

size: 70,

color: Colors.red,

),

const SizedBox(height: 20),

Text(

error ?? "Unknown Error",

textAlign: TextAlign.center,

),

const SizedBox(height: 20),

ElevatedButton(

onPressed: loadDashboard,

child: const Text(

"Retry",

),

),

],

),

);

}

//-----------------------------------------
// Section Title
//-----------------------------------------

Widget sectionTitle(
String title,
IconData icon,
) {

return Padding(

padding:
const EdgeInsets.only(bottom: 16),

child: Row(

children: [

Icon(

icon,

color: Colors.indigo,

),

const SizedBox(width: 10),

Text(

title,

style: const TextStyle(

fontSize: 22,

fontWeight: FontWeight.bold,

),

),

],

),

);

}


@override
Widget build(BuildContext context) {

if (loading) {

return Scaffold(

backgroundColor: const Color(0xffF5F7FB),

body: buildLoading(),

);

}

if (error != null) {

return Scaffold(

backgroundColor: const Color(0xffF5F7FB),

body: buildError(),

);

}

return Scaffold(

backgroundColor: const Color(0xffF5F7FB),

body: RefreshIndicator(

onRefresh: refreshDashboard,

child: CustomScrollView(

physics: const BouncingScrollPhysics(),

slivers: [

//-----------------------------------
// Header
//-----------------------------------

SliverToBoxAdapter(

child: DashboardHeader(

adminName: "Administrator",

totalEmployees:
dashboard.totalEmployees,

pendingLeaves:
dashboard.pendingLeaves,

),

),

//-----------------------------------
// Dashboard Body
//-----------------------------------

SliverPadding(

padding: EdgeInsets.all(

isPhone ? 16 : 24,

),

sliver: SliverList(

delegate: SliverChildListDelegate(

[

//-----------------------------------
// Statistics
//-----------------------------------

sectionTitle(

"Dashboard Overview",

Icons.dashboard,

),



GridView(

shrinkWrap: true,

physics:
const NeverScrollableScrollPhysics(),

gridDelegate:

SliverGridDelegateWithFixedCrossAxisCount(

crossAxisCount: gridCount,

crossAxisSpacing: 18,

mainAxisSpacing: 18,

childAspectRatio:
isPhone
? 1.25
: 1.45,

),

children: [
DashboardStatCard(

title: "Employees",

value:
dashboard.totalEmployees.toString(),

icon: Icons.people_alt_rounded,

color: Colors.blue,

onTap: () {

openPage(

const EmployeesManagementPage(),

);

},

),

DashboardStatCard(

title: "Present Today",

value:
dashboard.presentToday.toString(),

icon: Icons.check_circle,

color: Colors.green,

onTap: () {

openPage(

const AttendanceReportPage(),

);

},

),

DashboardStatCard(

title: "Absent Today",

value:
dashboard.absentToday.toString(),

icon: Icons.cancel,

color: Colors.red,

onTap: () {

openPage(

const AttendanceReportPage(),

);

},

),

DashboardStatCard(

title: "Pending Leaves",

value:
dashboard.pendingLeaves.toString(),

icon: Icons.event_busy,

color: Colors.orange,

onTap: () {

openPage(

const LeaveManagementPage(),

);

},

),

DashboardStatCard(

title: "Documents",

value:
dashboard.totalDocuments.toString(),

icon: Icons.folder_copy,

color: Colors.indigo,

onTap: () {

openPage(

const AdminDocumentsPage(),

);

},

),

DashboardStatCard(

title: "Announcements",

value:
dashboard.totalAnnouncements.toString(),

icon: Icons.campaign,

color: Colors.deepPurple,

onTap: () {

openPage(

const AnnouncementsManagementPage(),

);

},

),

DashboardStatCard(

title: "On Leave",

value:
dashboard.onLeaveToday.toString(),

icon: Icons.beach_access,

color: Colors.teal,

onTap: () {

openPage(

const LeaveManagementPage(),

);

},

),

DashboardStatCard(

title: "Payroll",

value:
dashboard.activeEmployees.toString(),

icon: Icons.account_balance_wallet,

color: Colors.pink,

onTap: () {

openPage(

const PayrollManagementPage(),

);

},

),
],

),

const SizedBox(height: 35),
//-----------------------------------
// Quick Actions
//-----------------------------------

sectionTitle(
"Quick Actions",
Icons.flash_on,
),

GridView(

shrinkWrap: true,

physics:
const NeverScrollableScrollPhysics(),

gridDelegate:
SliverGridDelegateWithFixedCrossAxisCount(

crossAxisCount: gridCount,

crossAxisSpacing: 18,

mainAxisSpacing: 18,

  mainAxisExtent: isPhone ? 150 : 165,

),

children: [

DashboardQuickAction(

title: "Employees",

subtitle: "Manage employees",

icon: Icons.people,

color: Colors.blue,

onTap: () {

openPage(

const EmployeesManagementPage(),

);

},

),

DashboardQuickAction(

title: "Attendance",

subtitle: "Today's attendance",

icon: Icons.fact_check,

color: Colors.green,

onTap: () {

openPage(

const AttendanceReportPage(),

);

},

),

DashboardQuickAction(

title: "Daily Summary",

subtitle: "Today's report",

icon: Icons.analytics,

color: Colors.orange,

onTap: () {

openPage(

const DailySummaryPage(),

);

},

),

DashboardQuickAction(

title: "Payroll",

subtitle: "Salary management",

icon:
Icons.account_balance_wallet,

color: Colors.purple,

onTap: () {

openPage(

const PayrollManagementPage(),

);

},

),

DashboardQuickAction(

title: "Payslips",

subtitle: "Employee payslips",

icon: Icons.receipt_long,

color: Colors.red,

onTap: () {

openPage(

const PayslipManagementPage(),

);

},

),

DashboardQuickAction(

title: "Announcements",

subtitle: "Company notices",

icon: Icons.campaign,

color: Colors.indigo,

onTap: () {

openPage(

const AnnouncementsManagementPage(),

);

},

),

DashboardQuickAction(

title: "Documents",

subtitle: "Company documents",

icon: Icons.folder,

color: Colors.teal,

onTap: () {

openPage(

const AdminDocumentsPage(),

);

},

),

DashboardQuickAction(

title: "Holidays",

subtitle: "Holiday calendar",

icon: Icons.calendar_month,

color: Colors.amber,

onTap: () {

openPage(

const HolidayManagementPage(),

);

},

),

  DashboardQuickAction(
    title: "Company Chat",
    subtitle: "Open group chat",
    icon: Icons.groups,
    color: Colors.deepPurple,
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
DashboardQuickAction(

title: "Messages",

subtitle: "Employee messages",

icon: Icons.chat,

color: Colors.cyan,

onTap: () {

openPage(

const MessagePage(),

);

},

),

DashboardQuickAction(

title: "Settings",

subtitle: "Application settings",

icon: Icons.settings,

color: Colors.grey,

onTap: () {

openPage(

const SettingsPage(),

);

},

),

],

),

const SizedBox(height: 35),

//-----------------------------------
// Recent Employees
//-----------------------------------

sectionTitle(
"Recent Employees",
Icons.people_alt_rounded,
),

if (employees.isEmpty)

Container(

width: double.infinity,

padding: const EdgeInsets.all(40),

decoration: BoxDecoration(

color: Colors.white,

borderRadius:
BorderRadius.circular(20),

),

child: const Center(

child: Column(

children: [

Icon(
Icons.people_outline,
size: 60,
color: Colors.grey,
),

SizedBox(height: 15),

Text(
"No Employees Found",
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),

],

),

),

)

else

ListView.builder(

shrinkWrap: true,

physics:
const NeverScrollableScrollPhysics(),

itemCount:
employees.length > 5
? 5
: employees.length,

itemBuilder: (context, index) {

final employee =
employees[index];

return DashboardRecentEmployeeCard(

employee: employee,

onTap: () {

openPage(

const EmployeesManagementPage(),

);

},

);

},

),

const SizedBox(height: 35),

//-----------------------------------
// Leaves + Holidays
//-----------------------------------

isPhone

//-----------------------------------
// MOBILE
//-----------------------------------

? Column(

children: [

sectionTitle(
"Pending Leave Requests",
Icons.event_busy,
),

if (leaves.isEmpty)

const Card(

child: Padding(

padding: EdgeInsets.all(30),

child: Center(

child: Text(
"No Pending Leaves",
),

),

),

)

else

...leaves

.where(
(e) =>
e.status ==
"Pending",
)

.take(3)

.map(

(leave) =>

DashboardLeaveCard(

leave: leave,

onApprove: () {

approveLeave(
leave,
);

},

onReject: () {

rejectLeave(
leave,
);

},

),

),

const SizedBox(height: 30),

sectionTitle(
"Upcoming Holidays",
Icons.calendar_month,
),

if (holidays.isEmpty)

const Card(

child: Padding(

padding: EdgeInsets.all(30),

child: Center(

child: Text(
"No Holidays",
),

),

),

)

else

...holidays

.take(3)

.map(

(holiday) =>

DashboardHolidayCard(

holiday: holiday,

onTap: () {

openPage(

const HolidayManagementPage(),

);

},

),

),

],

)

//-----------------------------------
// TABLET & DESKTOP
//-----------------------------------

: Row(

crossAxisAlignment:
CrossAxisAlignment.start,

children: [

Expanded(

child: Column(

crossAxisAlignment:
CrossAxisAlignment.start,

children: [

sectionTitle(

"Pending Leave Requests",

Icons.event_busy,

),

if (leaves.isEmpty)

const Card(

child: Padding(

padding:
EdgeInsets.all(30),

child: Center(

child: Text(
"No Pending Leaves",
),

),

),

)

else

...leaves

.where(
(e) =>
e.status ==
"Pending",
)

.take(3)

.map(

(leave) =>

DashboardLeaveCard(

leave: leave,

onApprove: () {

approveLeave(
leave,
);

},

onReject: () {

rejectLeave(
leave,
);

},

),

),

],

),

),

const SizedBox(width: 24),

Expanded(

child: Column(

crossAxisAlignment:
CrossAxisAlignment.start,

children: [

sectionTitle(

"Upcoming Holidays",

Icons.calendar_month,

),

if (holidays.isEmpty)

const Card(

child: Padding(

padding:
EdgeInsets.all(30),

child: Center(

child: Text(
"No Holidays",
),

),

),

)

else

...holidays

.take(3)

.map(

(holiday) =>

DashboardHolidayCard(

holiday: holiday,

onTap: () {

openPage(

const HolidayManagementPage(),

);

},

),

),

],

),

),

],

),

const SizedBox(height: 35),


//-----------------------------------
// Documents & Chat
//-----------------------------------

if (isPhone)

Column(

children: [

//--------------------------------
// Documents
//--------------------------------

sectionTitle(
"Recent Documents",
Icons.folder_copy,
),

if (documents.isEmpty)

const Card(

child: Padding(

padding: EdgeInsets.all(30),

child: Center(

child: Text(
"No Documents Available",
),

),

),

)

else

...documents
.take(3)
.map(

(document) => DashboardDocumentCard(

document: document,

onTap: () {

openPage(
const AdminDocumentsPage(),
);

},

onPreview: () {

openPage(
const AdminDocumentsPage(),
);

},

onDownload: () {

openPage(
const AdminDocumentsPage(),
);

},

),

),

const SizedBox(height: 30),

//--------------------------------
// Company Chat
//--------------------------------

sectionTitle(
"Company Chat",
Icons.groups,
),

  DashboardChatCard(

    totalMembers: dashboard.totalEmployees,

    onlineMembers: dashboard.activeEmployees,

    unreadMessages: 0,

    lastMessage: "Welcome to Stallion One Company Group.",

    lastMessageTime: "Just Now",

    onTap: () {

      openPage(

        const GroupChatPage(

          groupId: "company_group",

          groupName: "Company Group",

        ),

      );

    },

  ),
],

)

else

Row(

crossAxisAlignment:
CrossAxisAlignment.start,

children: [

//--------------------------------
// Documents
//--------------------------------

Expanded(

flex: 2,

child: Column(

crossAxisAlignment:
CrossAxisAlignment.start,

children: [

sectionTitle(
"Recent Documents",
Icons.folder_copy,
),

if (documents.isEmpty)

const Card(

child: Padding(

padding:
EdgeInsets.all(30),

child: Center(

child: Text(
"No Documents Available",
),

),

),

)

else

...documents
.take(3)
.map(

(document) =>
DashboardDocumentCard(

document: document,

onTap: () {

openPage(
const AdminDocumentsPage(),
);

},

onPreview: () {

openPage(
const AdminDocumentsPage(),
);

},

onDownload: () {

openPage(
const AdminDocumentsPage(),
);

},

),

),

],

),

),

const SizedBox(width: 25),

//--------------------------------
// Company Chat
//--------------------------------

Expanded(

child: Column(

crossAxisAlignment:
CrossAxisAlignment.start,

children: [

sectionTitle(
"Company Chat",
Icons.groups,
),

DashboardChatCard(

totalMembers:
dashboard.totalEmployees,

onlineMembers:
dashboard.activeEmployees,

unreadMessages: 0,

lastMessage:
"Welcome to Stallion One Company Group.",

lastMessageTime:
"Just Now",

onTap: () {

openPage(
const GroupChatPage(groupId: '', groupName: '',),
);

},

),

],

),

),

],

),

const SizedBox(height: 35),


    //-----------------------------------
    // Recent Activity
    //-----------------------------------

    sectionTitle(
      "Recent Activity",
      Icons.timeline,
    ),

    DashboardActivityCard(
      icon: Icons.person_add,
      color: Colors.blue,
      title: "New Employee Joined",
      subtitle:
      "A new employee has been added to the company.",
      time: "Today",
      onTap: () {
        openPage(
          const EmployeesManagementPage(),
        );
      },
    ),

    DashboardActivityCard(
      icon: Icons.event_available,
      color: Colors.green,
      title: "Leave Approved",
      subtitle:
      "A leave request was approved by the administrator.",
      time: "2 Hours Ago",
      onTap: () {
        openPage(
          const LeaveManagementPage(),
        );
      },
    ),

    DashboardActivityCard(
      icon: Icons.folder,
      color: Colors.orange,
      title: "Document Uploaded",
      subtitle:
      "A new company document has been uploaded.",
      time: "Yesterday",
      onTap: () {
        openPage(
          const AdminDocumentsPage(),
        );
      },
    ),

    DashboardActivityCard(
      icon: Icons.campaign,
      color: Colors.deepPurple,
      title: "Announcement Published",
      subtitle:
      "A new company announcement is available.",
      time: "Yesterday",
      onTap: () {
        openPage(
          const AnnouncementsManagementPage(),
        );
      },
    ),


  ],
),
),
),
],
),
),
);
}
}







