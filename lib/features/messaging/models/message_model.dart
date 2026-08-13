
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
final String id;
final String senderId;
final String senderName;

final String text;
final String messageType;

final String status;

final bool edited;
final bool deleted;
final bool seen;

final Timestamp? createdAt;
final Timestamp? deliveredAt;
final Timestamp? seenAt;

const MessageModel({
required this.id,
required this.senderId,
required this.senderName,
required this.text,
required this.messageType,
required this.status,
required this.edited,
required this.deleted,
required this.seen,
this.createdAt,
this.deliveredAt,
this.seenAt,
});

factory MessageModel.fromFirestore(
String id,
Map<String, dynamic> json,
) {
return MessageModel(
id: id,
senderId: json['senderId'] ?? '',
senderName: json['senderName'] ?? '',
text: json['text'] ?? '',
messageType: json['messageType'] ?? 'text',
status: json['status'] ?? 'sent',
edited: json['edited'] ?? false,
deleted: json['deleted'] ?? false,
seen: json['seen'] ?? false,
createdAt: json['createdAt'],
deliveredAt: json['deliveredAt'],
seenAt: json['seenAt'],
);
}

factory MessageModel.fromDocument(
DocumentSnapshot doc,
) {
final data =
doc.data() as Map<String, dynamic>;

return MessageModel.fromFirestore(
doc.id,
data,
);
}

Map<String, dynamic> toMap() {
return {
'senderId': senderId,
'senderName': senderName,
'text': text,
'messageType': messageType,
'status': status,
'edited': edited,
'deleted': deleted,
'seen': seen,
'createdAt': createdAt,
'deliveredAt': deliveredAt,
'seenAt': seenAt,
};
}

MessageModel copyWith({
String? id,
String? senderId,
String? senderName,
String? text,
String? messageType,
String? status,
bool? edited,
bool? deleted,
bool? seen,
Timestamp? createdAt,
Timestamp? deliveredAt,
Timestamp? seenAt,
}) {
return MessageModel(
id: id ?? this.id,
senderId: senderId ?? this.senderId,
senderName:
senderName ?? this.senderName,
text: text ?? this.text,
messageType:
messageType ?? this.messageType,
status: status ?? this.status,
edited: edited ?? this.edited,
deleted: deleted ?? this.deleted,
seen: seen ?? this.seen,
createdAt:
createdAt ?? this.createdAt,
deliveredAt:
deliveredAt ?? this.deliveredAt,
seenAt: seenAt ?? this.seenAt,
);
}

bool get isTextMessage =>
messageType == 'text';

bool get isSent =>
status == 'sent';

bool get isDelivered =>
status == 'delivered';

bool get isRead =>
status == 'read';

@override
String toString() {
return '''
MessageModel(
  id: $id,
  senderId: $senderId,
  senderName: $senderName,
  text: $text,
  status: $status
)
''';
}
}
