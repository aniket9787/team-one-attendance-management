class DashboardSummaryModel {
  final int totalEmployees;
  final int activeEmployees;
  final int inactiveEmployees;

  final int presentToday;
  final int absentToday;
  final int onLeaveToday;

  final int pendingLeaves;
  final int approvedLeaves;

  final int totalAnnouncements;
  final int totalDocuments;

  const DashboardSummaryModel({
    required this.totalEmployees,
    required this.activeEmployees,
    required this.inactiveEmployees,
    required this.presentToday,
    required this.absentToday,
    required this.onLeaveToday,
    required this.pendingLeaves,
    required this.approvedLeaves,
    required this.totalAnnouncements,
    required this.totalDocuments,
  });

  factory DashboardSummaryModel.empty() {
    return const DashboardSummaryModel(
      totalEmployees: 0,
      activeEmployees: 0,
      inactiveEmployees: 0,
      presentToday: 0,
      absentToday: 0,
      onLeaveToday: 0,
      pendingLeaves: 0,
      approvedLeaves: 0,
      totalAnnouncements: 0,
      totalDocuments: 0,
    );
  }
}