import 'package:flutter/material.dart';

import '../data/holiday_service.dart';
import '../domain/holiday_model.dart';
import '../widgets/delete_holiday_dialog.dart';
import '../widgets/holiday_card.dart';
import '../widgets/holiday_dialog.dart';
import '../widgets/holiday_filter_chips.dart';
import '../widgets/holiday_header.dart';
import '../widgets/holiday_search_bar.dart';
import '../widgets/holiday_statistics.dart';




class HolidayManagementPage extends StatefulWidget {
  const HolidayManagementPage({super.key});

  @override
  State<HolidayManagementPage> createState() =>
      _HolidayManagementPageState();
}

class _HolidayManagementPageState
    extends State<HolidayManagementPage> {

final HolidayService holidayService =
HolidayService();

final TextEditingController
searchController =
TextEditingController();

String selectedFilter = "All";

final List<String> filters = const [

"All",

"National",

"Festival",

"Company",

"Optional",

];

@override
void dispose() {

searchController.dispose();

super.dispose();

}

//-----------------------------------------
// Add Holiday
//-----------------------------------------

Future<void> addHoliday() async {

final result = await showDialog(

context: context,

builder: (_) => const HolidayDialog(),

);

if (result == true && mounted) {

setState(() {});

ScaffoldMessenger.of(context).showSnackBar(

const SnackBar(

backgroundColor: Colors.green,

content: Text(
"Holiday Added Successfully",
),

),

);

}

}

//-----------------------------------------
// Edit Holiday
//-----------------------------------------

Future<void> editHoliday(
HolidayModel holiday,
) async {

final result = await showDialog(

context: context,

builder: (_) => HolidayDialog(
holiday: holiday,
),

);

if (result == true && mounted) {

setState(() {});

ScaffoldMessenger.of(context).showSnackBar(

const SnackBar(

backgroundColor: Colors.green,

content: Text(
"Holiday Updated Successfully",
),

),

);

}

}

//-----------------------------------------
// Delete Holiday
//-----------------------------------------

Future<void> deleteHoliday(
HolidayModel holiday,
) async {

await showDialog(

context: context,

builder: (_) => DeleteHolidayDialog(

holidayName: holiday.title,

onDelete: () async {

await holidayService.deleteHoliday(
holiday.id,
);

if (mounted) {

ScaffoldMessenger.of(context)
.showSnackBar(

const SnackBar(

backgroundColor: Colors.red,

content: Text(
"Holiday Deleted Successfully",
),

),

);

}

},

),

);

}
@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xffF5F7FA),

appBar: AppBar(
title: const Text("Holiday Management"),
centerTitle: true,
),

floatingActionButton: FloatingActionButton.extended(
onPressed: addHoliday,
icon: const Icon(Icons.add),
label: const Text("Add Holiday"),
),

body: StreamBuilder<List<HolidayModel>>(
stream: holidayService.holidayStream(),
builder: (context, snapshot) {
if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (snapshot.hasError) {
return Center(
child: Text(snapshot.error.toString()),
);
}

List<HolidayModel> holidays =
snapshot.data ?? [];

//-----------------------------------
// Search
//-----------------------------------

if (searchController.text
.trim()
.isNotEmpty) {
final keyword =
searchController.text.toLowerCase();

holidays = holidays.where((holiday) {
return holiday.title
.toLowerCase()
.contains(keyword) ||
holiday.description
.toLowerCase()
.contains(keyword) ||
holiday.holidayType
.toLowerCase()
.contains(keyword);
}).toList();
}

//-----------------------------------
// Filter
//-----------------------------------

if (selectedFilter != "All") {
holidays = holidays.where((holiday) {
return holiday.holidayType ==
selectedFilter;
}).toList();
}

//-----------------------------------
// Statistics
//-----------------------------------

final total = holidays.length;

final upcoming = holidays
.where((holiday) =>
holiday.holidayDate
.isAfter(DateTime.now()))
.length;

final optional = holidays
.where((holiday) =>
holiday.isOptional)
.length;

final mandatory =
total - optional;

return RefreshIndicator(
onRefresh: () async {
setState(() {});
},
child: CustomScrollView(
physics:
const AlwaysScrollableScrollPhysics(),
slivers: [

SliverToBoxAdapter(
child: HolidayHeader(
onAddHoliday: addHoliday,
),
),

SliverToBoxAdapter(
child: HolidayStatistics(
totalHolidays: total,
upcomingHolidays: upcoming,
optionalHolidays: optional,
mandatoryHolidays: mandatory,
),
),

const SliverToBoxAdapter(
child: SizedBox(height: 16),
),

SliverToBoxAdapter(
child: HolidaySearchBar(
controller: searchController,
onChanged: (_) {
setState(() {});
},
onClear: () {
searchController.clear();
setState(() {});
},
onRefresh: () {
setState(() {});
},
),
),

SliverToBoxAdapter(
child: HolidayFilterChips(
selectedFilter: selectedFilter,
filters: filters,
onSelected: (value) {
setState(() {
selectedFilter = value;
});
},
),
),

const SliverToBoxAdapter(
child: SizedBox(height: 20),
),

if (holidays.isEmpty)
SliverFillRemaining(
hasScrollBody: false,
child: Center(
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [

Icon(
Icons.event_busy,
size: 80,
color:
Colors.grey.shade400,
),

const SizedBox(
height: 15,
),

const Text(
"No Holidays Found",
style: TextStyle(
fontSize: 18,
fontWeight:
FontWeight.bold,
),
),

],
),
),
)
else
SliverPadding(
padding:
const EdgeInsets.fromLTRB(
16,
0,
16,
100,
),
sliver: SliverList(
delegate:
SliverChildBuilderDelegate(
(context, index) {
final holiday =
holidays[index];

return HolidayCard(
holiday: holiday,
onEdit: () =>
editHoliday(
holiday),
onDelete: () =>
deleteHoliday(
holiday),
);
},
childCount:
holidays.length,
),
),
),
],
),
);
},
),
);
}

}