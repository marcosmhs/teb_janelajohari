import 'package:web/web.dart' as web;

/// Integração com a landing estática (HTML em "/"), que repassa ao app em
/// "/app/" o pedido do visitante: criar sessão (`?criar=1`) ou entrar com o
/// código de acesso. O código não vai na URL (ficaria no histórico e em logs):
/// a landing o deixa no sessionStorage da aba e o app o consome uma única vez.
class WebHandoff {
  static const _accessCodeKey = 'johari.accessCode';

  /// Verdadeiro no deploy híbrido, com o app servido em /app/. Em
  /// `flutter run` o app fica na raiz e mantém a tela de boas-vindas própria.
  static bool get underApp => Uri.base.path.startsWith('/app');

  static bool get wantsCreateSession => Uri.base.queryParameters['criar'] == '1';

  /// Lê e apaga o código deixado pela landing.
  static String takeAccessCode() {
    final storage = web.window.sessionStorage;
    final code = storage.getItem(_accessCodeKey) ?? '';
    storage.removeItem(_accessCodeKey);
    return code.trim();
  }

  /// Tira os parâmetros da landing da barra de endereço, mantendo a rota.
  static void clearQuery() {
    final location = web.window.location;
    web.window.history.replaceState(null, '', '${location.pathname}${location.hash}');
  }

  static void goToLanding() => web.window.location.assign('/');
}
