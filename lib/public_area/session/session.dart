import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teb_janelajohari/consts.dart';
import 'package:teb_janelajohari/web_handoff.dart';
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

  static const String collectionName = 'session';

  String id;
  String name;
  String feedbackCode;
  DateTime? createDate;
  List<String> positiveAdjectives = [];
  List<String> constructiveAdjectives = [];

  /// Código de acesso em texto puro, mantido apenas em memória.
  /// No Firestore ele nunca é gravado em claro — apenas sua versão cifrada
  /// (ver [encryptedAccessCode]).
  String _accessCode = '';

  Session({
    this.id = '',
    this.name = '',
    String accessCode = '',
    this.feedbackCode = '',
    this.createDate,
    List<String>? positiveAdjectives,
    List<String>? constructiveAdjectives,
  }) {
    _accessCode = accessCode.trim();
    createDate ??= DateTime.now();
    this.positiveAdjectives = positiveAdjectives ?? [...basePositiveAdjectives];
    this.constructiveAdjectives = constructiveAdjectives ?? [...baseConstructiveAdjectives];
  }

  static final TebAesEncrypt _aes = TebAesEncrypt(
    ivKey: Consts.textEncriptStaticKey,
    // Necessário apenas para ler dados no formato antigo (ver _decryptAccessCode).
    fixedIvKey: Consts.textEncriptStaticKey,
  );

  /// Código de acesso em texto puro, pronto para exibição.
  String get accessCode => _accessCode.toUpperCase();
  set accessCode(String value) => _accessCode = value.trim();

  /// Valor cifrado (AES-CTR com IV aleatório) gravado no Firestore apenas para
  /// permitir exibir o código de volta. Muda a cada gravação, então NÃO serve
  /// para consultas — use [accessCodeHash] para isso.
  String get encryptedAccessCode => _accessCode.isEmpty ? '' : _aes.aesEncryp(text: _accessCode);

  /// Índice determinístico (HMAC-SHA256) usado para PESQUISAR a sessão pelo
  /// código. Não é reversível. É case-insensitive.
  String get accessCodeHash => accessCodeHashOf(_accessCode);

  /// Gera o mesmo [accessCodeHash] a partir de um código em texto puro — use ao
  /// montar a consulta por código de acesso.
  static String accessCodeHashOf(String plainText) {
    final code = plainText.trim();
    return code.isEmpty ? '' : _aes.searchableHash(text: code);
  }

  /// Valor cifrado no formato ANTIGO (determinístico, IV fixo). Serve apenas
  /// para localizar sessões ainda não migradas; novas gravações usam o formato
  /// aleatório + [accessCodeHash].
  static String legacyEncryptedAccessCodeOf(String plainText) {
    final code = plainText.trim();
    // ignore: deprecated_member_use
    return code.isEmpty ? '' : _aes.encryp(text: code);
  }

  static String _decryptAccessCode(String storedValue) {
    if (storedValue.isEmpty) return '';
    // Formato novo (aesEncryp) é "iv:cipher"; o antigo (encryp) é base64 puro,
    // sem ':'. Base64 nunca contém ':', então o separador distingue os dois.
    if (storedValue.contains(':')) {
      final result = _aes.aesDecrypt(encryptedText: storedValue);
      return (result['decryptedText'] ?? '').toString();
    }
    // ignore: deprecated_member_use
    final result = _aes.decrypt(encryptedText: storedValue);
    return (result['decryptedText'] ?? '').toString();
  }

  factory Session.fromDocument(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Session.fromMap(data);
  }

  static Session fromMap(Map<String, dynamic> map) {
    final encrypted = (map['encryptedAccessCode'] ?? '').toString();
    // Compatibilidade: sessões antigas podem ter sido gravadas com o código em
    // texto puro no campo 'accessCode'.
    final accessCode = encrypted.isNotEmpty ? _decryptAccessCode(encrypted) : (map['accessCode'] ?? '').toString();

    final session = Session(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      accessCode: accessCode,
      feedbackCode: map['feedbackCode'] ?? '',
      createDate: map['createDate'] == null ? null : DateTime.tryParse(map['createDate']),
      positiveAdjectives:
          map['positiveAdjectives'] != null ? List<String>.from(map['positiveAdjectives'].map((item) => item.toString())) : [],
      constructiveAdjectives:
          map['constructiveAdjectives'] != null
              ? List<String>.from(map['constructiveAdjectives'].map((item) => item.toString()))
              : [],
    );

    session.positiveAdjectives = session.positiveAdjectives.toSet().toList();
    session.constructiveAdjectives = session.constructiveAdjectives.toSet().toList();

    return session;
  }

  static const _productionUrl = 'https://teb-janelajohari.web.app/app/';

  /// Endereço do app no site aberto: /app/ no deploy híbrido (landing estática
  /// na raiz) ou a raiz em desenvolvimento; sem origem http, a produção.
  static String get _appUrl {
    if (!Uri.base.isScheme('http') && !Uri.base.isScheme('https')) return _productionUrl;
    return '${Uri.base.origin}${WebHandoff.underApp ? '/app/' : '/'}';
  }

  String get sessionFeedbackUrl => '$_appUrl?session_feedback_code=$feedbackCode';

  Map<String, dynamic> get toMap => {
    'id': id,
    'name': name,
    'encryptedAccessCode': encryptedAccessCode,
    'accessCodeHash': accessCodeHash,
    'feedbackCode': feedbackCode,
    'createDate': createDate?.toString(),
    'positiveAdjectives': positiveAdjectives,
    'constructiveAdjectives': constructiveAdjectives,
  };
}
