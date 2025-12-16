enum PaymentMethodType {
  paypal,
  creditCard,
}

class PaymentMethod {
  final String id;
  final PaymentMethodType type;
  final String displayName;
  final String? lastFourDigits;
  final String? email;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.displayName,
    this.lastFourDigits,
    this.email,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'displayName': displayName,
      'lastFourDigits': lastFourDigits,
      'email': email,
      'isDefault': isDefault,
    };
  }

  PaymentMethod copyWith({
    String? id,
    PaymentMethodType? type,
    String? displayName,
    String? lastFourDigits,
    String? email,
    bool? isDefault,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      displayName: displayName ?? this.displayName,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      email: email ?? this.email,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: PaymentMethodType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      displayName: json['displayName'],
      lastFourDigits: json['lastFourDigits'],
      email: json['email'],
      isDefault: json['isDefault'] ?? false,
    );
  }
}