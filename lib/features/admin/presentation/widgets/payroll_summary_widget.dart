import 'package:flutter/material.dart';

class PayrollSummaryWidget extends StatelessWidget {

final String title;

final double value;

final IconData icon;

final Color color;

const PayrollSummaryWidget({

super.key,

required this.title,

required this.value,

required this.icon,

required this.color,

});

@override
Widget build(BuildContext context) {


return Container(

padding: const EdgeInsets.all(16),

decoration: BoxDecoration(

color: Colors.white,

borderRadius:
BorderRadius.circular(16),

boxShadow: [

BoxShadow(

color: Colors.grey.shade200,

blurRadius: 8,

offset: const Offset(0, 4),

),

],

),

child: Column(

crossAxisAlignment:
CrossAxisAlignment.start,

children: [


CircleAvatar(

radius: 22,

backgroundColor:
color.withOpacity(0.15),

child: Icon(

icon,

color: color,

),

),

const SizedBox(height: 16),



Text(

title,

style: TextStyle(

color: Colors.grey.shade600,

fontSize: 14,

),

),

const SizedBox(height: 8),


Text(

"₹ ${value.toStringAsFixed(2)}",

style: const TextStyle(

fontSize: 22,

fontWeight: FontWeight.bold,

),

),


],

),

);

}

}

