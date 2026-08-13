
import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
final String chatId;

final List<String> participants;

final Map<String, dynamic> participantNames;

final Map<String, dynamic> participantPhotos;

final String lastMessage;

final String lastMessageSender;

final String lastMessageStatus;

final Timestamp? lastMessageTime;

final Timestamp? createdAt;

final Map<String, dynamic> unreadCount;

final Map<String, dynamic> typing;

final Map<String, dynamic> lastSeen;

const ConversationModel({
required this.chatId,
required this.participants,
required this.participantNames,
required this.participantPhotos,
required this.lastMessage,
required this.lastMessageSender,
required this.lastMessageStatus,
required this.lastMessageTime,
required this.createdAt,
required this.unreadCount,
required this.typing,
required this.lastSeen,
});

factory ConversationModel.fromFirestore(
String id,
Map<String, dynamic> json,
) {
return ConversationModel(
chatId: id,

participants: List<String>.from(
json['participants'] ?? [],
),

participantNames:
Map<String, dynamic>.from(
json['participantNames'] ?? {},
),

participantPhotos:
Map<String, dynamic>.from(
json['participantPhotos'] ?? {},
),

lastMessage:
json['lastMessage'] ?? '',

lastMessageSender:
json['lastMessageSender'] ?? '',

lastMessageStatus:
json['lastMessageStatus'] ?? 'sent',

lastMessageTime:
json['lastMessageTime'],

createdAt:
json['createdAt'],

unreadCount:
Map<String, dynamic>.from(
json['unreadCount'] ?? {},
),

typing:
Map<String, dynamic>.from(
json['typing'] ?? {},
),

lastSeen:
Map<String, dynamic>.from(
json['lastSeen'] ?? {},
),
);
}

factory ConversationModel.fromDocument(
DocumentSnapshot doc,
) {
final data =
doc.data() as Map<String, dynamic>;

return ConversationModel.fromFirestore(
doc.id,
data,
);
}

Map<String, dynamic> toMap() {
return {
'participants': participants,
'participantNames':
participantNames,
'participantPhotos':
participantPhotos,
'lastMessage': lastMessage,
'lastMessageSender':
lastMessageSender,
'lastMessageStatus':
lastMessageStatus,
'lastMessageTime':
lastMessageTime,
'createdAt': createdAt,
'unreadCount': unreadCount,
'typing': typing,
'lastSeen': lastSeen,
};
}

ConversationModel copyWith({
String? chatId,
List<String>? participants,
Map<String, dynamic>?
participantNames,
Map<String, dynamic>?
participantPhotos,
String? lastMessage,
String? lastMessageSender,
String? lastMessageStatus,
Timestamp? lastMessageTime,
Timestamp? createdAt,
Map<String, dynamic>? unreadCount,
Map<String, dynamic>? typing,
Map<String, dynamic>? lastSeen,
}) {
return ConversationModel(
chatId: chatId ?? this.chatId,
participants:
participants ??
this.participants,
participantNames:
participantNames ??
this.participantNames,
participantPhotos:
participantPhotos ??
this.participantPhotos,
lastMessage:
lastMessage ??
this.lastMessage,
lastMessageSender:
lastMessageSender ??
this.lastMessageSender,
lastMessageStatus:
lastMessageStatus ??
this.lastMessageStatus,
lastMessageTime:
lastMessageTime ??
this.lastMessageTime,
createdAt:
createdAt ?? this.createdAt,
unreadCount:
unreadCount ??
this.unreadCount,
typing: typing ?? this.typing,
lastSeen:
lastSeen ?? this.lastSeen,
);
}

int unreadForUser(String uid) {
return unreadCount[uid] ?? 0;
}

bool isTyping(String uid) {
return typing[uid] ?? false;
}

Timestamp? userLastSeen(
String uid) {
return lastSeen[uid];
}

String getOtherParticipant(
String currentUserId) {
return participants.firstWhere(
(id) => id != currentUserId,
orElse: () => '',
);
}

@override
String toString() {
return '''
ConversationModel(
  chatId: $chatId,
  lastMessage: $lastMessage,
  status: $lastMessageStatus
)
''';
}
}
