// lib/core/models/reservation.dart
import 'package:moovapp/core/models/ride_model.dart';

class Reservation {
  final int id;
  final int rideId;
  final String passengerId;
  final String? passengerName;
  final String? passengerPhoto;
  final int seatsReserved;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final RideModel? ride;
  final String? driverId;
  final bool hasUnreadMessages;
  final int unreadMessagesCount;

  Reservation({
    required this.id,
    required this.rideId,
    required this.passengerId,
    this.passengerName,
    this.passengerPhoto,
    required this.seatsReserved,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.ride,
    this.driverId,
    this.hasUnreadMessages = false,
    this.unreadMessagesCount = 0,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    String pName = json['passenger_name'] ?? 'Passager';
    String? pPhoto = json['passenger_photo'];
    String pId = json['passenger_id']?.toString() ?? '0';

    // Support nested user object (common in some APIs)
    if (json['user'] != null && json['user'] is Map) {
      final user = json['user'];
      pName = user['name'] ?? user['username'] ?? user['first_name'] ?? pName;
      pPhoto =
          user['photo'] ?? user['avatar'] ?? user['profile_picture'] ?? pPhoto;
      pId = user['id']?.toString() ?? pId;
    }
    // Support nested passenger object
    else if (json['passenger'] != null && json['passenger'] is Map) {
      final passenger = json['passenger'];
      pName = passenger['name'] ?? passenger['username'] ?? pName;
      pPhoto = passenger['photo'] ?? passenger['avatar'] ?? pPhoto;
      pId = passenger['id']?.toString() ?? pId;
    }

    return Reservation(
      id: int.tryParse(json['id'].toString()) ?? 0,
      rideId: int.tryParse(json['ride_id'].toString()) ?? 0,
      passengerId: pId,
      passengerName: pName,
      passengerPhoto: pPhoto,
      seatsReserved: int.tryParse(json['seats'].toString()) ??
          int.tryParse(json['seats_booked'].toString()) ??
          1,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString().toLowerCase() ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      driverId: json['driver_id']?.toString(),
      hasUnreadMessages: json['has_unread_messages'] as bool? ?? false,
      unreadMessagesCount:
          int.tryParse(json['unread_messages_count'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ride_id': rideId,
      'passenger_id': passengerId,
      'seats': seatsReserved,
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'driver_id': driverId,
      'has_unread_messages': hasUnreadMessages,
      'unread_messages_count': unreadMessagesCount,
    };
  }

  // Méthodes utilitaires
  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get formattedTime {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  bool get isActive => status == 'confirmed' || status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmée';
      case 'pending':
        return 'En attente';
      case 'cancelled':
        return 'Annulée';
      case 'completed':
        return 'Terminée';
      default:
        return status;
    }
  }

  Reservation copyWith({
    int? id,
    int? rideId,
    String? passengerId,
    String? passengerName,
    String? passengerPhoto,
    int? seatsReserved,
    double? totalPrice,
    String? status,
    DateTime? createdAt,
    RideModel? ride,
    String? driverId,
    bool? hasUnreadMessages,
    int? unreadMessagesCount,
  }) {
    return Reservation(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      passengerId: passengerId ?? this.passengerId,
      passengerName: passengerName ?? this.passengerName,
      passengerPhoto: passengerPhoto ?? this.passengerPhoto,
      seatsReserved: seatsReserved ?? this.seatsReserved,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      ride: ride ?? this.ride,
      driverId: driverId ?? this.driverId,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
      unreadMessagesCount: unreadMessagesCount ?? this.unreadMessagesCount,
    );
  }

  @override
  String toString() {
    return 'Reservation(id: $id, rideId: $rideId, status: $status, seats: $seatsReserved, hasUnread: $hasUnreadMessages)';
  }
}
