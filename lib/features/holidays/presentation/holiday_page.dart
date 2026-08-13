import 'package:flutter/material.dart';

import '../data/holiday_service.dart';
import '../domain/holiday_model.dart';

class HolidayPage extends StatefulWidget {
  const HolidayPage({super.key});

  @override
  State<HolidayPage> createState() =>
      _HolidayPageState();
}

class _HolidayPageState
    extends State<HolidayPage> {
final HolidayService holidayService =
HolidayService();

final TextEditingController
searchController =
TextEditingController();

String selectedMonth = "All";

final List<String> months = const [
"All",
"January",
"February",
"March",
"April",
"May",
"June",
"July",
"August",
"September",
"October",
"November",
"December",
];

@override
void dispose() {
searchController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor:
const Color(0xffF5F7FA),

appBar: AppBar(
centerTitle: true,
title: const Text(
"Company Holidays",
),
),

body: Column(
children: [

//==================================
// HEADER
//==================================

Container(
width: double.infinity,
margin:
const EdgeInsets.all(
16,
),
padding:
const EdgeInsets.all(
18,
),
decoration: BoxDecoration(
gradient:
const LinearGradient(
colors: [
Color(0xff2563EB),
Color(0xff1D4ED8),
],
),
borderRadius:
BorderRadius.circular(
18,
),
),
child: const Column(
crossAxisAlignment:
CrossAxisAlignment
.start,
children: [

Text(
"Company Holiday Calendar",
style: TextStyle(
color:
Colors.white,
fontSize: 22,
fontWeight:
FontWeight.bold,
),
),

SizedBox(height: 8),

Text(
"View upcoming company holidays and plan your work schedule.",
style: TextStyle(
color:
Colors.white70,
),
),
],
),
),

//==================================
// SEARCH
//==================================

Padding(
padding:
const EdgeInsets.symmetric(
horizontal: 16,
),
child: TextField(
controller:
searchController,
decoration:
InputDecoration(
hintText:
"Search Holiday",
prefixIcon:
const Icon(
Icons.search,
),
border:
OutlineInputBorder(
borderRadius:
BorderRadius.circular(
12,
),
),
),
onChanged: (_) {
setState(() {});
},
),
),

const SizedBox(height: 15),

//==================================
// MONTH FILTER
//==================================

Padding(
padding:
const EdgeInsets.symmetric(
horizontal: 16,
),
child:
DropdownButtonFormField<
String>(
value:
selectedMonth,
decoration:
const InputDecoration(
labelText:
"Filter by Month",
),
items: months
.map(
(month) =>
DropdownMenuItem(
value: month,
child:
Text(month),
),
)
.toList(),
onChanged:
(value) {
if (value ==
null) return;

setState(() {
selectedMonth =
value;
});
},
),
),

const SizedBox(height: 15),

//==================================
// HOLIDAY LIST
//==================================

Expanded(
child: StreamBuilder<
List<
HolidayModel>>(
stream:
holidayService
.holidayStream(),
builder:
(context, snapshot) {

//==========================
// PART 2 STARTS HERE


if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (!snapshot.hasData ||
snapshot.data!.isEmpty) {
return const Center(
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
Icons.event_busy,
size: 80,
color: Colors.grey,
),
SizedBox(height: 10),
Text(
"No Holidays Available",
style: TextStyle(
fontSize: 18,
fontWeight:
FontWeight.bold,
),
),
],
),
);
}

List<HolidayModel> holidays =
snapshot.data!;

//==============================
// SEARCH FILTER
//==============================

if (searchController.text
.trim()
.isNotEmpty) {
final keyword =
searchController.text
.toLowerCase();

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

//==============================
// MONTH FILTER
//==============================

if (selectedMonth != "All") {
holidays = holidays.where((holiday) {
return holiday.monthName ==
selectedMonth;
}).toList();
}

if (holidays.isEmpty) {
return const Center(
child: Text(
"No Holidays Found",
),
);
}

final today = DateTime.now();

HolidayModel? todayHoliday;

for (final holiday in holidays) {
if (holiday.holidayDate.day ==
today.day &&
holiday.holidayDate.month ==
today.month &&
holiday.holidayDate.year ==
today.year) {
todayHoliday = holiday;
break;
}
}

return ListView(
padding:
const EdgeInsets.symmetric(
horizontal: 16,
),
children: [

if (todayHoliday != null)
Container(
margin:
const EdgeInsets.only(
bottom: 15,
),
padding:
const EdgeInsets.all(
16,
),
decoration: BoxDecoration(
gradient:
const LinearGradient(
colors: [
Colors.orange,
Colors.deepOrange,
],
),
borderRadius:
BorderRadius.circular(
15,
),
),
child: Row(
children: [

const Icon(
Icons.celebration,
color: Colors.white,
size: 40,
),

const SizedBox(width: 15),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
.start,
children: [

const Text(
"Today's Holiday 🎉",
style: TextStyle(
color:
Colors.white,
fontWeight:
FontWeight.bold,
fontSize: 18,
),
),

const SizedBox(
height: 5),

Text(
todayHoliday.title,
style:
const TextStyle(
color:
Colors.white,
fontSize: 16,
),
),
],
),
),
],
),
),

...holidays.map(
(holiday) {

final isUpcoming =
holiday.holidayDate
.isAfter(
DateTime.now(),
);

//==========================
// PART 3 STARTS HERE

  return Card(
    elevation: 3,
    margin: const EdgeInsets.only(
      bottom: 12,
    ),
    shape: RoundedRectangleBorder(
      borderRadius:
      BorderRadius.circular(
        15,
      ),
    ),
    child: Padding(
      padding:
      const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              CircleAvatar(
                radius: 28,
                backgroundColor:
                holiday.isOptional
                    ? Colors.orange
                    : Colors.blue,
                child: const Icon(
                  Icons.event,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Text(
                      holiday.title,
                      style:
                      const TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      holiday.description,
                      style: TextStyle(
                        color: Colors
                            .grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [

              Chip(
                avatar: const Icon(
                  Icons.category,
                  size: 18,
                ),
                label: Text(
                  holiday.holidayType,
                ),
              ),

              Chip(
                avatar: Icon(
                  holiday.isOptional
                      ? Icons.star
                      : Icons.check_circle,
                  size: 18,
                ),
                label: Text(
                  holiday.isOptional
                      ? "Optional"
                      : "Mandatory",
                ),
                backgroundColor:
                holiday.isOptional
                    ? Colors.orange
                    .shade100
                    : Colors.green
                    .shade100,
              ),

              if (isUpcoming)
                const Chip(
                  avatar: Icon(
                    Icons
                        .notifications_active,
                    size: 18,
                  ),
                  label: Text(
                    "Upcoming",
                  ),
                  backgroundColor:
                  Color(0xFFE3F2FD),
                ),
            ],
          ),

          const Divider(height: 25),

          Row(
            children: [

              const Icon(
                Icons.calendar_today,
                color: Colors.blue,
                size: 18,
              ),

              const SizedBox(width: 8),

              Text(
                holiday.formattedDate,
                style:
                const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const Spacer(),

              Text(
                holiday.dayName,
                style: TextStyle(
                  color:
                  Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
},
),
],
);
},
),
),
],
),
);
}
}