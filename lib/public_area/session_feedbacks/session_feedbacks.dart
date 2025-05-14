import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum FeedbackType { self, others }

class SessionFeedbacks {
  /// Cor para a área 'Aberta' (Arena): Conhecido por mim, Conhecido pelos outros.
  /// Sugere clareza, confiança e comunicação aberta.
  static const Color openAreaColor = Color(0xFF64B5F6); // Azul Claro (Material Blue 400)

  /// Cor para a área 'Cega' (Blind Spot): Desconhecido por mim, Conhecido pelos outros.
  /// Sugere descoberta, feedback e percepção externa. Um verde suave pode indicar crescimento através do feedback.
  static const Color blindAreaColor = Color(0xFFAED581); // Verde Claro (Material Light Green 400)

  /// Cor para a área 'Oculta' (Facade): Conhecido por mim, Desconhecido pelos outros.
  /// Sugere introspecção, privacidade, o que guardamos para nós. Um verde-azulado pode ter essa conotação mais reservada.
  static const Color hiddenAreaColor = Color(0xFF4DB6AC); // Verde-azulado (Material Teal 300)

  /// Cor para a área 'Desconhecida' (Unknown): Desconhecido por mim, Desconhecido pelos outros.
  /// Sugere potencial, mistério, o inconsciente, exploração. Um cinza neutro representa bem o desconhecido.
  static const Color unknorAreaColor = Color(0xFF757575); // Cinza (Material Grey 600)

  /// Cor de Destaque/Geral: Para itens gerais do menu (Home, Sobre) ou para dar destaque.
  /// Um laranja suave pode trazer calor, energia e um ponto de foco amigável.
  static const Color selfFeedbackAreaColor = Color.fromARGB(255, 248, 204, 137); // Laranja (Material Orange 300)

  /// Cor de Destaque/Geral: Para itens gerais do menu (Home, Sobre) ou para dar destaque.
  /// Um laranja suave pode trazer calor, energia e um ponto de foco amigável.
  static const Color othersFeedbackAreaColor = Color.fromARGB(252, 214, 130, 253); // Laranja (Material Orange 300)

  static const String colletcionName = 'session_feedbacks';

  late String sessionId;
  late String id;
  late List<String> positiveAdjectives = [];
  late List<String> constructiveAdjectives = [];
  late FeedbackType feedbackType;
  late String comments;
  late DateTime createDate;

  SessionFeedbacks({
    this.sessionId = '',
    this.id = '',
    List<String>? positiveAdjectives,
    List<String>? constructiveAdjectives,
    this.feedbackType = FeedbackType.self,
    this.comments = '',
    DateTime? createDate,
  }) {
    this.positiveAdjectives = positiveAdjectives ?? [];
    this.constructiveAdjectives = constructiveAdjectives ?? [];
    this.createDate = createDate ?? DateTime.now();
  }

  factory SessionFeedbacks.fromDocument(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return SessionFeedbacks.fromMap(data);
  }

  static SessionFeedbacks fromMap(Map<String, dynamic> map) {
    var u = SessionFeedbacks();

    u = SessionFeedbacks(
      sessionId: map['sessionId'] ?? '',
      id: map['id'] ?? '',
      positiveAdjectives:
          map['positiveAdjectives'] != null ? List<String>.from(map['positiveAdjectives'].map((item) => item.toString())) : [],
      constructiveAdjectives:
          map['constructiveAdjectives'] != null
              ? List<String>.from(map['constructiveAdjectives'].map((item) => item.toString()))
              : [],
      feedbackType: feedbackTypeFromString(map['feedbackType']),
      comments: map['comments'] ?? '',
      createDate: map['createDate'] == null ? null : DateTime.tryParse(map['createDate']),
    );
   
    return u;
  }

  static FeedbackType feedbackTypeFromString(String stringValue) {
    switch (stringValue) {
      case 'FeedbackType.self':
        return FeedbackType.self;
      case 'FeedbackType.others':
        return FeedbackType.others;
      default:
        return FeedbackType.self;
    }
  }

  int get totalAdjectivesLengh {
    return positiveAdjectives.length + constructiveAdjectives.length;
  }

  void addAdjective({required String adjective, bool isPositive = true}) {
    if (isPositive) {
      positiveAdjectives.add(adjective);
    } else {
      constructiveAdjectives.add(adjective);
    }
  }

  void removeAdjective({required String adjective, bool isPositive = true}) {
    if (isPositive) {
      positiveAdjectives.remove(adjective);
    } else {
      constructiveAdjectives.remove(adjective);
    }
  }

  Map<String, dynamic> get toMap {
    Map<String, dynamic> r = {};
    r = {
      'id': id,
      'sessionId': sessionId,
      'positiveAdjectives': positiveAdjectives,
      'constructiveAdjectives': constructiveAdjectives,
      'feedbackType': feedbackType.toString(),
      'comments': comments,
      'createDate': createDate.toString(),
    };

    return r;
  }
}
