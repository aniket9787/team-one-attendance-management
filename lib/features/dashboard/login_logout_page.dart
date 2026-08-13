import 'package:flutter/material.dart';
import 'dart:async';

import '../../../core/models/session_model.dart';
import '../../../core/services/session_service.dart';

class LoginLogoutPage extends StatefulWidget {
  const LoginLogoutPage({super.key});

  @override
  State<LoginLogoutPage> createState() =>
      _LoginLogoutPageState();
}

class _LoginLogoutPageState
    extends State<LoginLogoutPage> {
final SessionService _sessionService =
SessionService();

bool loading = true;
bool isLoggedIn = false;

Duration todayWorkDuration =
Duration.zero;

DateTime? todayLoginTime;
DateTime? todayLogoutTime;

Timer? _liveTimer;

@override
void initState() {
  super.initState();

  loadStatus();

  _liveTimer = Timer.periodic(
    const Duration(seconds: 1),
        (_) {
      if (mounted) {
        loadTodaySummary();
      }
    },
  );
}



@override
void dispose() {
  _liveTimer?.cancel();
  super.dispose();
}



Future<void> loadStatus() async {
final result =
await _sessionService.isLoggedIn();

if (!mounted) return;

setState(() {
isLoggedIn = result;
loading = false;
});

await loadTodaySummary();
}

Future<void> loadTodaySummary() async {
final history =
await _sessionService.sessionHistory();

final now = DateTime.now();

Duration total =
Duration.zero;

DateTime? firstLogin;
DateTime? lastLogout;

for (final session in history) {
if (session.loginTime.year ==
now.year &&
session.loginTime.month ==
now.month &&
session.loginTime.day ==
now.day) {
total += session.sessionDuration;

firstLogin ??=
session.loginTime;

if (session.logoutTime !=
null) {
if (lastLogout == null ||
session.logoutTime!
.isAfter(
lastLogout,
)) {
lastLogout =
session.logoutTime;
}
}
}
}

if (!mounted) return;

setState(() {
todayWorkDuration =
total;

todayLoginTime =
firstLogin;

todayLogoutTime =
lastLogout;
});
}

Future<void> handleSession() async {
try {
setState(() {
loading = true;
});

if (isLoggedIn) {
await _sessionService.logout();
} else {
await _sessionService.login();
}

await loadStatus();
await loadTodaySummary();
} catch (e) {
setState(() {
loading = false;
});

ScaffoldMessenger.of(context)
.showSnackBar(
SnackBar(
content:
Text(e.toString()),
),
);
}
}

String formatDuration(
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

String formatDate(
DateTime date) {
return "${date.day}/${date.month}/${date.year}";
}

String formatTime(
DateTime date) {
int hour =
date.hour % 12;

if (hour == 0) {
hour = 12;
}

final minute = date.minute
.toString()
.padLeft(2, '0');

final period =
date.hour >= 12
? "PM"
: "AM";

return "$hour:$minute $period";
}



Widget _summaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ) {
  return Container(
    width: 280,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.05),
          blurRadius: 12,
        ),
      ],
    ),
    child: Row(
      children: [

        CircleAvatar(
          backgroundColor:
          color.withOpacity(.15),
          child: Icon(
            icon,
            color: color,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}










@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor:
const Color(0xFF0F172A),

appBar: AppBar(
elevation: 0,
backgroundColor:
const Color(0xFF111827),

title: const Text(
"Login / Logout",
style: TextStyle(
color: Colors.white,
fontWeight:
FontWeight.bold,
),
),

iconTheme:
const IconThemeData(
color: Colors.white,
),
),

    body: loading
        ? const Center(
      child: CircularProgressIndicator(),
    )
        : SingleChildScrollView(
        child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1200,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

                    // HERO CARD

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF6366F1),
                            Color(0xFF8B5CF6),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(.25),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [

                          Icon(
                            isLoggedIn
                                ? Icons.login_rounded
                                : Icons.logout_rounded,
                            color: Colors.white,
                            size: 60,
                          ),

                          const SizedBox(height: 15),

                          Text(
                            isLoggedIn
                                ? "Currently Logged In"
                                : "Currently Logged Out",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 25),

                          StreamBuilder<Duration>(
                            stream:
                            _sessionService.liveSessionTimer(),
                            builder: (
                                context,
                                snapshot,
                                ) {
                              final duration =
                                  snapshot.data ??
                                      Duration.zero;

                              return Text(
                                formatDuration(
                                  duration,
                                ),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                  MediaQuery.of(context)
                                      .size
                                      .width >
                                      700
                                      ? 48
                                      : 34,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 25),

                          Container(
                            padding:
                            const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius:
                              BorderRadius.circular(
                                  20),
                            ),
                            child: Column(
                              children: [

                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                                  children: [

                                    const Text(
                                      "Today's Login",
                                      style: TextStyle(
                                        color:
                                        Colors.white70,
                                      ),
                                    ),

                                    Text(
                                      todayLoginTime ==
                                          null
                                          ? "--"
                                          : formatTime(
                                        todayLoginTime!,
                                      ),
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

                                const SizedBox(
                                    height: 12),

                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                                  children: [

                                    const Text(
                                      "Today's Logout",
                                      style: TextStyle(
                                        color:
                                        Colors.white70,
                                      ),
                                    ),

                                    Text(
                                      todayLogoutTime ==
                                          null
                                          ? "--"
                                          : formatTime(
                                        todayLogoutTime!,
                                      ),
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

                                const Divider(
                                  color: Colors.white24,
                                  height: 30,
                                ),

                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                                  children: [

                                    const Text(
                                      "Total Working",
                                      style: TextStyle(
                                        color:
                                        Colors.white70,
                                      ),
                                    ),

                                    Text(
                                      formatDuration(
                                        todayWorkDuration,
                                      ),
                                      style:
                                      const TextStyle(
                                        color:
                                        Colors.white,
                                        fontWeight:
                                        FontWeight
                                            .bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // LOGIN BUTTON

                    SizedBox(
                      width: MediaQuery.of(context)
                          .size
                          .width >
                          700
                          ? 350
                          : double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: handleSession,
                        style: ElevatedButton
                            .styleFrom(
                          backgroundColor:
                          isLoggedIn
                              ? Colors.red
                              : Colors.green,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              16,
                            ),
                          ),
                        ),
                        child: Text(
                          isLoggedIn
                              ? "LOGOUT"
                              : "LOGIN",
                          style:
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // SUMMARY CARDS

                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [

                        _summaryCard(
                          "Today's Login",
                          todayLoginTime == null
                              ? "--"
                              : formatTime(
                            todayLoginTime!,
                          ),
                          Icons.login,
                          Colors.green,
                        ),

                        _summaryCard(
                          "Today's Logout",
                          todayLogoutTime == null
                              ? "--"
                              : formatTime(
                            todayLogoutTime!,
                          ),
                          Icons.logout,
                          Colors.red,
                        ),

                        _summaryCard(
                          "Working Time",
                          formatDuration(
                            todayWorkDuration,
                          ),
                          Icons.timer,
                          Colors.blue,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    const Align(
                      alignment:
                      Alignment.centerLeft,
                      child: Text(
                        "Session History",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),



// PART 3 STARTS HERE






                    FutureBuilder<List<SessionModel>>(
                      future: _sessionService.sessionHistory(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final history = snapshot.data!;

                        if (history.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                "No Session History Found",
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics:
                          const NeverScrollableScrollPhysics(),
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            final item = history[index];

                            return Container(
                              margin: const EdgeInsets.only(
                                bottom: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1E293B,
                                ),
                                borderRadius:
                                BorderRadius.circular(
                                  16,
                                ),
                              ),
                              child: ListTile(
                                contentPadding:
                                const EdgeInsets.all(
                                  12,
                                ),
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: item.isActive
                                      ? Colors.green
                                      .withOpacity(0.15)
                                      : Colors.red
                                      .withOpacity(0.15),
                                  child: Icon(
                                    item.isActive
                                        ? Icons.login
                                        : Icons.logout,
                                    color: item.isActive
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                title: Text(
                                  formatDate(
                                    item.loginTime,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding:
                                  const EdgeInsets.only(
                                    top: 6,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(
                                        "Login : ${formatTime(item.loginTime)}",
                                        style:
                                        const TextStyle(
                                          color:
                                          Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        "Logout : ${item.logoutTime == null ? '--' : formatTime(item.logoutTime!)}",
                                        style:
                                        const TextStyle(
                                          color:
                                          Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: Container(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration:
                                  BoxDecoration(
                                    color: Colors.blue
                                        .withOpacity(
                                      0.15,
                                    ),
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      10,
                                    ),
                                  ),
                                  child: Text(
                                    formatDuration(
                                      item.sessionDuration,
                                    ),
                                    style:
                                    const TextStyle(
                                      color:
                                      Colors.blue,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ),
    ),
);
}
}