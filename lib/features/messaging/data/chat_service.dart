
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
    final FirebaseFirestore _firestore =
        FirebaseFirestore.instance;

// =========================
// CHAT ID
// =========================

    String generateChatId(String uid1,
        String uid2,) {
        final ids = [uid1, uid2]..sort();
        return ids.join('_');
    }

// =========================
// CREATE CHAT
// =========================

    Future<String> createDirectChat({
        required String currentUserId,
        required String currentUserName,
        required String currentUserPhoto,
        required String otherUserId,
        required String otherUserName,
        required String otherUserPhoto,
    }) async {
        final chatId = generateChatId(
            currentUserId,
            otherUserId,
        );

        final chatRef = _firestore
            .collection('direct_chats')
            .doc(chatId);

        final doc = await chatRef.get();

        if (!doc.exists) {
            await chatRef.set({
                'participants': [
                    currentUserId,
                    otherUserId,
                ],

                'participantNames': {
                    currentUserId: currentUserName,
                    otherUserId: otherUserName,
                },

                'participantPhotos': {
                    currentUserId: currentUserPhoto,
                    otherUserId: otherUserPhoto,
                },

                'lastMessage': '',
                'lastMessageSender': '',

                'lastMessageStatus': 'sent',

                'lastMessageTime':
                FieldValue.serverTimestamp(),

                'createdAt':
                FieldValue.serverTimestamp(),

// unread count
                'unreadCount': {
                    currentUserId: 0,
                    otherUserId: 0,
                },

// typing indicator
                'typing': {
                    currentUserId: false,
                    otherUserId: false,
                },

// online status
                'lastSeen': {
                    currentUserId:
                    FieldValue.serverTimestamp(),
                    otherUserId:
                    FieldValue.serverTimestamp(),
                },
            });
        }

        return chatId;
    }

// =========================
// SEND MESSAGE
// =========================

    Future<void> sendMessage({
        required String chatId,
        required String senderId,
        required String senderName,
        required String text,
    }) async {
        final chatRef = _firestore
            .collection('direct_chats')
            .doc(chatId);

        final chatDoc = await chatRef.get();

        if (!chatDoc.exists) return;

        final chatData =
            chatDoc.data() ?? {};

        final participants =
        List<String>.from(
            chatData['participants'] ?? [],
        );

        final receiverId =
        participants.firstWhere(
                (id) => id != senderId,
            orElse: () => '',
        );

        final messageRef = chatRef
            .collection('messages')
            .doc();

        await messageRef.set({
            'senderId': senderId,

            'senderName': senderName,

            'text': text,

            'messageType': 'text',

            'status': 'sent',

            'createdAt':
            FieldValue.serverTimestamp(),

            'deliveredAt': null,

            'seenAt': null,

            'edited': false,

            'deleted': false,
        });

        await chatRef.update({
            'lastMessage': text,

            'lastMessageSender':
            senderName,

            'lastMessageStatus':
            'sent',

            'lastMessageTime':
            FieldValue.serverTimestamp(),

            'unreadCount.$receiverId':
            FieldValue.increment(1),
        });
    }

// =========================
// MESSAGE STREAM
// =========================

    Stream<QuerySnapshot> messagesStream(String chatId,) {
        return _firestore
            .collection('direct_chats')
            .doc(chatId)
            .collection('messages')
            .orderBy(
            'createdAt',
            descending: false,
        )
            .snapshots();
    }

// =========================
// RECENT CHATS
// =========================

    Stream<QuerySnapshot> getRecentChats(String currentUserId,) {
        return _firestore
            .collection('direct_chats')
            .where(
            'participants',
            arrayContains:
            currentUserId,
        )
            .orderBy(
            'lastMessageTime',
            descending: true,
        )
            .snapshots();
    }

// =========================
// EDIT MESSAGE
// =========================

    Future<void> editMessage({
        required String chatId,
        required String messageId,
        required String newText,
    }) async {
        await _firestore
            .collection('direct_chats')
            .doc(chatId)
            .collection('messages')
            .doc(messageId)
            .update({
            'text': newText,

            'edited': true,
        });
    }

// =========================
// DELETE MESSAGE
// =========================

    Future<void> deleteMessage({
        required String chatId,
        required String messageId,
    }) async {
        await _firestore
            .collection('direct_chats')
            .doc(chatId)
            .collection('messages')
            .doc(messageId)
            .update({
            'deleted': true,

            'text': '',

            'status': 'deleted',
        });
    }

// =========================
// MARK AS DELIVERED
// =========================

    Future<void> markMessageDelivered({
        required String chatId,
        required String messageId,
    }) async {
        await _firestore
            .collection('direct_chats')
            .doc(chatId)
            .collection('messages')
            .doc(messageId)
            .update({
            'status': 'delivered',

            'deliveredAt':
            FieldValue.serverTimestamp(),
        });
    }

// =========================
// MARK AS READ
// =========================

    Future<void> markMessageRead({
        required String chatId,
        required String messageId,
    }) async {
        await _firestore
            .collection('direct_chats')
            .doc(chatId)
            .collection('messages')
            .doc(messageId)
            .update({
            'status': 'read',

            'seen': true,

            'seenAt':
            FieldValue.serverTimestamp(),
        });
    }

// =========================
// RESET UNREAD COUNT
// =========================

    Future<void> resetUnreadCount({
        required String chatId,
        required String userId,
    }) async {
        await _firestore
            .collection('direct_chats')
            .doc(chatId)
            .update({
            'unreadCount.$userId': 0,
        });
    }

// =========================
// TYPING STATUS
// =========================

    Future<void> updateTypingStatus({
        required String chatId,
        required String userId,
        required bool isTyping,
    }) async {
        await _firestore
            .collection('direct_chats')
            .doc(chatId)
            .update({
            'typing.$userId':
            isTyping,
        });
    }

    Stream<DocumentSnapshot>
    chatStream(String chatId,) {
        return _firestore
            .collection('direct_chats')
            .doc(chatId)
            .snapshots();
    }

// =========================
// LAST SEEN
// =========================

    Future<void> updateLastSeen({
        required String chatId,
        required String userId,
    }) async {
        await _firestore
            .collection('direct_chats')
            .doc(chatId)
            .update({
            'lastSeen.$userId':
            FieldValue.serverTimestamp(),
        });
    }


    Future<String> createGroup({
        required String groupName,
        required String createdBy,
        required String createdByName,
        required List<String> memberIds,
    }) async {

        final groupRef =
        _firestore.collection(
            'group_chats',
        ).doc();

        final members = {
            createdBy,
            ...memberIds,
        }.toList();

        await groupRef.set({
            'groupId': groupRef.id,

            'groupName': groupName,

            'groupDescription': '',

            'groupImage': '',

            'createdBy': createdBy,

            'createdByName': createdByName,

            'members': members,

            'admins': [
                createdBy,
            ],

            'memberCount':
            members.length,

            'isCompanyGroup': false,

            'lastMessage': '',

            'lastMessageSender': '',

            'lastMessageTime':
            FieldValue.serverTimestamp(),

            'createdAt':
            FieldValue.serverTimestamp(),

            'typing': {},

            'unreadCount': {},
        });

        return groupRef.id;
    }
}