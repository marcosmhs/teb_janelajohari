import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_janelajohari/admin_area/admin_area_invalid_access_screen.dart';
import 'package:teb_janelajohari/admin_area/user/user.dart';
import 'package:teb_janelajohari/public_area/session/session_controller.dart';
import 'package:teb_janelajohari/public_area/session_feedbacks/session_feedbacks_controller.dart';
import 'package:teb_janelajohari/routes.dart';
import 'package:teb_package/teb_package.dart';

class AdminAreaScreen extends StatefulWidget {
  final User? user;
  const AdminAreaScreen({super.key, this.user});

  @override
  State<AdminAreaScreen> createState() => _AdminAreaScreenState();
}

class _AdminAreaScreenState extends State<AdminAreaScreen> {
  var _initializing = true;
  var _user = User();
  var _info = TebUtil.packageInfo;

  Map<String, dynamic> _sessionStats = {};
  Map<String, dynamic> _feedbackStats = {};

  Widget _menuItens() {
    return SizedBox(
      width: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: InkWell(
              onTap: () => Navigator.of(context).pushNamed(Routes.userForm, arguments: {'user': _user}),
              child: CircleAvatar(child: Icon(FontAwesomeIcons.user, color: Theme.of(context).colorScheme.primary, size: 50)),
            ),
            accountName: TebText(_user.name, textColor: Theme.of(context).colorScheme.surface),
            accountEmail: TebText(_user.email, textColor: Theme.of(context).colorScheme.surface),
          ),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.palette, color: Theme.of(context).colorScheme.primary),
            title: TebText('Textos', textColor: Theme.of(context).colorScheme.primary),
            onTap: () => Navigator.of(context).pushNamed(Routes.siteTextForm, arguments: {'user': _user}),
          ),

          const SizedBox(height: 10),
          TebText(
            "v${_info.version}.${_info.buildNumber}",
            textColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.only(bottom: 10),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _user = arguments['user'] ?? User();

      _user = widget.user != null && widget.user!.id.isNotEmpty ? widget.user! : _user;

      _initializing = false;

      TebUtil.version.then((info) => setState(() => _info = info));

      SessionController().stats.then((sessionStats) {
        setState(() => _sessionStats = sessionStats);
        SessionFeedbackController().stats(sessionIdList: _sessionStats['sessionsIdList']).then((feedbackStats) {
          setState(() => _feedbackStats = feedbackStats);
        });
      });
    }

    if (_user.id.isEmpty) {
      return AdminAreaInvalidAccessScreen();
    } else {
      return TebCustomScaffold(
        appBar: AppBar(title: TebText('Janela de Johari - That Exotic Bug')),
        showAppBar: true,
        drawer: _menuItens(),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(left: 100),
          child: SizedBox(
            width: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 100),
                Row(
                  children: [
                    Icon(FontAwesomeIcons.hashtag),
                    TebText(
                      'Quantidade de sessões criadas: ${_sessionStats['sessionsCount']}',
                      textSize: 16,
                      padding: EdgeInsets.all(10),
                    ),
                  ],
                ),
                if (_sessionStats['lastSession'] != null)
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.calendar),
                      TebText(
                        'Última sessão criada em: ${TebUtil.dateTimeFormat(date: _sessionStats['lastSession']!, mask: 'dd/MM/yyyy HH:mm')}',
                        textSize: 16,
                        padding: EdgeInsets.all(10),
                      ),
                    ],
                  ),
                SizedBox(height: 100),
                Row(
                  children: [
                    Icon(FontAwesomeIcons.hashtag),
                    TebText(
                      'Quantidade de feedbacks: ${_feedbackStats['sessionFeedbacksCount']}',
                      textSize: 16,
                      padding: EdgeInsets.all(10),
                    ),
                  ],
                ),
                if (_feedbackStats['lastFeedback'] != null)
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.calendar),
                      TebText(
                        'Último feedback em: ${TebUtil.dateTimeFormat(date: _feedbackStats['lastFeedback']!, mask: 'dd/MM/yyyy HH:mm')}',
                        textSize: 16,
                        padding: EdgeInsets.all(10),
                      ),
                    ],
                  ),
                Row(
                  children: [
                    Icon(FontAwesomeIcons.hashtag),
                    TebText(
                      'Quantidade de adjetivos utilizados: ${_feedbackStats['totalAdjectives']}',
                      textSize: 16,
                      padding: EdgeInsets.all(10),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(FontAwesomeIcons.comment),
                    TebText(
                      'Quantidade de comentários: ${_feedbackStats['totalComments']}',
                      textSize: 16,
                      padding: EdgeInsets.all(10),
                    ),
                  ],
                ),
                SizedBox(height: 100),
                if (_feedbackStats['positiveAdjectivesCount'] != null)
                  ExpansionTile(
                    title: TebText(
                      'Adjetivos positivos utilizados (${_feedbackStats['positiveAdjectivesCount'].length})',
                      textSize: 16,
                      padding: EdgeInsets.all(10),
                    ),
                    children: [
                      ListView.builder(
                        scrollDirection: Axis.vertical,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _feedbackStats['positiveAdjectivesCount'].length,
                        itemBuilder: (context, index) {
                          final adjective = _feedbackStats['positiveAdjectivesCount'].keys.elementAt(index);
                          final count = _feedbackStats['positiveAdjectivesCount'][adjective];
                          return ListTile(
                            leading: Icon(FontAwesomeIcons.tag, color: Theme.of(context).colorScheme.primary),
                            title: TebText('$adjective: $count', textSize: 16),
                          );
                        },
                      ),
                    ],
                  ),

                if (_feedbackStats['constructiveAdjectivesCount'] != null)
                  ExpansionTile(
                    
                    title: TebText(
                      'Adjetivos construtivos utilizados (${_feedbackStats['constructiveAdjectivesCount'].length})',
                      textSize: 16,
                      padding: EdgeInsets.all(10),
                    ),
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: _feedbackStats['constructiveAdjectivesCount'].length,
                        itemBuilder: (context, index) {
                          final adjective = _feedbackStats['constructiveAdjectivesCount'].keys.elementAt(index);
                          final count = _feedbackStats['constructiveAdjectivesCount'][adjective];
                          return ListTile(
                            leading: Icon(FontAwesomeIcons.tag, color: Theme.of(context).colorScheme.primary),
                            title: TebText('$adjective: $count', textSize: 16),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
