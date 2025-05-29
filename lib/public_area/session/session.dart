import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teb_janelajohari/consts.dart';
import 'package:teb_package/util/teb_aes_encrypt.dart';

class Session {
  static const List<String> basePositiveAdjectives = [
    'Amigável',
    'Criativo',
    'Determinado',
    'Empático',
    'Honesto',
    'Organizado',
    'Paciente',
    'Proativo',
    'Responsável',
    'Sincero',
    'Adaptável',
    'Ambicioso',
    'Atencioso',
    'Carismático',
    'Colaborativo',
    'Comprometido',
    'Confiante',
    'Curioso',
    'Decidido',
    'Diplomático',
    'Disciplinado',
    'Eficiente',
    'Entusiasta',
    'Flexível',
    'Generoso',
    'Inovador',
    'Motivado',
    'Pragmático',
    'Resiliente',
    'Visionário',
  ];

  static const List<String> baseConstructiveAdjectives = [
    'Propensão à Impaciência', // Indica uma tendência que precisa ser gerenciada.
    'Tendência à Teimosia / Inflexibilidade', // Deixa claro a dificuldade em ser flexível.
    'Demonstra Insegurança', // Foca na manifestação observável da insegurança.
    'Desafios com Organização', // Aponta diretamente a dificuldade na área.
    'Tendência à Indecisão', // Indica um padrão de dificuldade em decidir.
    'Visão predominantemente Crítica', // Sugere um desequilíbrio, foco excessivo na crítica.
    'Propensão à Ansiedade', // Indica uma tendência a sentir ansiedade.
    'Tendência ao Perfeccionismo', // Reconhece o perfeccionismo como algo a ser gerenciado.
    'Tendência ao Isolamento / Reserva Excessiva', // Foca no comportamento que pode limitar interações (relacionado à introversão/reserva).
    'Necessidade de Validação / Apoio Constante', // Descreve a dependência de forma comportamental.
    'Tendência à Impulsividade', // Indica um padrão de agir sem pensar.
    'Dificuldade em se Abrir / Compartilhar', // Relacionado a ser reservado, foca na barreira.
    'Competitividade Elevada', // Sugere que a competitividade pode ser excessiva.
    'Tendência ao Ceticismo Excessivo', // Indica que o ceticismo pode ser uma barreira.
    'Intensidade Emocional / Reativo', // Descreve a forte influência das emoções nas reações.
    'Tendência ao Autoritarismo', // Indica um padrão de comportamento autoritário.
    'Tendência à Desconfiança', // Aponta a dificuldade em confiar como padrão.
    'Individualista / Foco excessivo no Próprio Interesse', // Descreve o egoísmo de forma mais comportamental.
    'Tendência ao Pessimismo', // Indica um padrão de pensamento negativo.
    'Tendência à Rigidez / Inflexibilidade', // Similar a teimosia, foca na resistência à mudança.
  ];

  static const String colletcionName = 'session';

  late String id;
  late String name;
  late String encryptedAccessCode;
  late String feedbackCode;
  late DateTime? createDate;
  late List<String> positiveAdjectives = [];
  late List<String> constructiveAdjectives = [];

  Session({
    this.id = '',
    this.name = '',
    this.encryptedAccessCode = '',
    this.feedbackCode = '',
    this.createDate,
    List<String>? positiveAdjectives,
    List<String>? constructiveAdjectives,
  }) {
    createDate ??= DateTime.now();
    this.positiveAdjectives = positiveAdjectives ?? [...basePositiveAdjectives];
    this.constructiveAdjectives = constructiveAdjectives ?? [...baseConstructiveAdjectives];
  }

  factory Session.fromDocument(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Session.fromMap(data);
  }

  String get accessCode {
    var decryptRetutn = TebAesEncrypt(
      ivKey: Consts.textEncriptStaticKey,
      fixedIvKey: Consts.textEncriptStaticKey,
    ).decrypt(encryptedText: encryptedAccessCode);
    return decryptRetutn['decryptedText'].toString().toUpperCase();
  }

  static Session fromMap(Map<String, dynamic> map) {
    var session = Session();

    session = Session(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      encryptedAccessCode:
          (map['encryptedAccessCode'] ?? '').isEmpty
              ? TebAesEncrypt(
                ivKey: Consts.textEncriptStaticKey,
                fixedIvKey: Consts.textEncriptStaticKey,
              ).encryp(text: map['accessCode'] ?? '')
              : map['encryptedAccessCode'] ?? '',
      feedbackCode: map['feedbackCode'] ?? '',
      createDate: map['createDate'] == null ? null : DateTime.tryParse(map['createDate']),
      positiveAdjectives:
          map['positiveAdjectives'] != null ? List<String>.from(map['positiveAdjectives'].map((item) => item.toString())) : [],
      constructiveAdjectives:
          map['constructiveAdjectives'] != null
              ? List<String>.from(map['constructiveAdjectives'].map((item) => item.toString()))
              : [],
    );

    if (session.positiveAdjectives.isNotEmpty) {
      session.positiveAdjectives = session.positiveAdjectives.toSet().toList();
    }
    if (session.constructiveAdjectives.isNotEmpty) {
      session.constructiveAdjectives = session.constructiveAdjectives.toSet().toList();
    }

    return session;
  }

  String get sessionFeedbackUrl {
    //return 'http://localhost:1234?session_feedback_code=$feedbackCode';
    return 'https://teb-janelajohari.web.app?session_feedback_code=$feedbackCode';
  }

  Map<String, dynamic> get toMap {
    Map<String, dynamic> r = {};
    r = {
      'id': id,
      'name': name,
      'encryptedAccessCode': encryptedAccessCode,
      'feedbackCode': feedbackCode,
      'createDate': createDate?.toString(),
      'positiveAdjectives': positiveAdjectives,
      'constructiveAdjectives': constructiveAdjectives,
    };

    return r;
  }
}
