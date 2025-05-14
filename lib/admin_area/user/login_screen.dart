// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_janelajohari/admin_area/user/user.dart';
import 'package:teb_janelajohari/admin_area/user/user_controller.dart';
import 'package:teb_janelajohari/routes.dart';
import 'package:teb_package/messaging/teb_custom_dialog.dart';
import 'package:teb_package/screen_elements/teb_custom_scaffold.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_util.dart';
import 'package:teb_package/visual_elements/teb_text.dart';
import 'package:teb_package/visual_elements/teb_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  var _initializing = true;
  var _info = TebUtil.packageInfo;

  late String _email = '';
  late String _password = '';

  // utilizado para o controle de foco
  final _passwordFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  void _login() async {
    setState(() => _isLoading = true);

    if (!(_formKey.currentState?.validate() ?? true)) {
      setState(() => _isLoading = false);
    } else {
      // salva os dados
      _formKey.currentState?.save();
      var userController = UserController();
      TebCustomReturn retorno;
      try {
        User user = User();
        user.email = _email;
        user.setPassword(TebUtil.encrypt(_password));
        retorno = await userController.login(user: user);
        if (retorno.returnType == TebReturnType.sucess) {
          Navigator.of(context).pushReplacementNamed(Routes.adminAreaScreen, arguments: {'user': userController.currentUser});
        }
        // se houve um erro no login ou no cadastro exibe o erro
        if (retorno.returnType == TebReturnType.error) {
          TebCustomDialog(context: context).errorMessage(message: retorno.message);
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      TebUtil.version.then((info) => setState(() => _info = info));
      _initializing = false;
      if (_password.isNotEmpty) _passwordController.text = _password;
      if (_email.isNotEmpty) _emailController.text = _email;
    }

    return TebCustomScaffold(
      responsive: false,
      showAppBar: false,
      title: const Text('Login'),
      body: Center(
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(height: 100, fit: BoxFit.cover, image: const AssetImage('assets/images/logo.png')),
                TebText(
                  'Janela de Johari',
                  textColor: Theme.of(context).colorScheme.secondary,
                  textSize: 30,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  letterSpacing: 4,
                  textWeight: FontWeight.w600,
                ),
                TebText(
                  'Marcos Silva',
                  textColor: Theme.of(context).colorScheme.secondary,
                  textSize: 20,
                  letterSpacing: 4,
                  textWeight: FontWeight.w600,
                ),
                TebText(
                  'Ambiente Administrativo',
                  textSize: 14,
                  letterSpacing: 2,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                TebTextEdit(
                  context: context,
                  controller: _emailController,
                  labelText: 'E-mail',
                  hintText: 'Informe seu e-mail',
                  onSave: (value) => _email = value ?? '',
                  prefixIcon: const FaIcon(FontAwesomeIcons.user).icon,
                  nextFocusNode: _passwordFocus,
                  validator: (value) {
                    final finalValue = value ?? '';
                    if (finalValue.trim().isEmpty) return 'Informe o e-mail';
                    if (!finalValue.contains('@') || !finalValue.contains('.')) return 'Informe um e-mail válido';
                    return null;
                  },
                ),
                TebTextEdit(
                  context: context,
                  controller: _passwordController,
                  labelText: 'Senha',
                  hintText: 'Informe sua senha',
                  isPassword: true,
                  onSave: (value) => _password = value ?? '',
                  prefixIcon: const FaIcon(FontAwesomeIcons.lock).icon,
                  textInputAction: TextInputAction.done,
                  focusNode: _passwordFocus,
                  validator: (value) {
                    final finalValue = value ?? '';
                    if (finalValue.trim().isEmpty) return 'Informe a senha';
                    if (finalValue.trim().length < 6) return 'Senha deve possuir 6 ou mais caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _isLoading
                    ? const CircularProgressIndicator.adaptive()
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // criar nova conta
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ButtonStyle(foregroundColor: WidgetStateProperty.all(Theme.of(context).disabledColor)),
                          child: const Text('Voltar'),
                        ),
                        const SizedBox(width: 20),
                        // botão login
                        ElevatedButton(onPressed: _login, child: const Text('Entrar')),
                      ],
                    ),
                TebText(
                  "v${_info.version}.${_info.buildNumber}",
                  textSize: 10,

                  letterSpacing: 2,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
