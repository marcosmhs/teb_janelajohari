// ignore_for_file: use_build_context_synchronously

// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:teb_janelajohari/main/widgets/about_jorari_window_area.dart';
import 'package:teb_janelajohari/main/widgets/contact_area.dart';
import 'package:teb_janelajohari/main/widgets/how_it_works_area.dart';
import 'package:teb_janelajohari/main/widgets/site_title_widget.dart';
import 'package:teb_janelajohari/main/widgets/social_links_area.dart';
import 'package:teb_janelajohari/public_area/wellcome_screen/widgets/find_session_widget.dart';
import 'package:teb_janelajohari/public_area/wellcome_screen/widgets/new_session_widget.dart';
import 'package:teb_janelajohari/routes.dart';
import 'package:teb_package/teb_package.dart';

class WellcomeScreen extends StatefulWidget {
  const WellcomeScreen({super.key});

  @override
  State<WellcomeScreen> createState() => _WellcomeScreenState();
}

class _WellcomeScreenState extends State<WellcomeScreen> {
  late AutoScrollController _autoScrollController;
  final _scrollDirection = Axis.vertical;
  bool get _isAppBarExpanded => _autoScrollController.hasClients && _autoScrollController.offset > (160 - kToolbarHeight);
  bool _isExpaned = true;

  @override
  void initState() {
    _autoScrollController = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: _scrollDirection,
    )..addListener(() {
      _isAppBarExpanded
          ? _isExpaned != false
              ? setState(() => _isExpaned = false)
              : {}
          : _isExpaned != true
          ? setState(() => _isExpaned = true)
          : {};
    });
    super.initState();
  }

  Future _scrollToIndex(int index) async {
    await _autoScrollController.scrollToIndex(index, preferPosition: AutoScrollPosition.begin);
    _autoScrollController.highlight(index);
  }

  Widget _wrapScrollTag({required int index, required Widget child}) {
    return AutoScrollTag(key: ValueKey(index), controller: _autoScrollController, index: index, child: child);
  }

  Widget _appBarTitle({required String text}) {
    return Tab(
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TebText(text, textAlign: TextAlign.center, textSize: 14, letterSpacing: 2, textColor: Colors.black),
        ),
      ),
    );
  }

  Widget _navigationBar(Size size) {
    List<Widget> tabList = [];

    tabList.add(_appBarTitle(text: 'O que é'));
    tabList.add(_appBarTitle(text: 'Como funciona'));
    tabList.add(_appBarTitle(text: 'Criar sua sessão'));
    tabList.add(_appBarTitle(text: 'Dar Feedback'));

    return Column(
      children: [
        SizedBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                SiteTitleWidget(),
                // menu
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: DefaultTabController(
                      length: tabList.length,
                      child: TabBar(onTap: (index) async => _scrollToIndex(index), tabs: tabList),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    var mobile = size.width <= 1000;

    return TebCustomScaffold(
      showAppBar: false,
      responsive: false,
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        primary: true,
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            //Navigation Bar
            _navigationBar(size),

            // main
            Row(
              children: [
                SocialLinksArea(context: context, size: size),
                Expanded(
                  child: SizedBox(
                    height: size.height - 82,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: CustomScrollView(
                        controller: _autoScrollController,
                        slivers: <Widget>[
                          SliverList(
                            delegate: SliverChildListDelegate([
                              _wrapScrollTag(index: 0, child: AboutArea(mobile: mobile)),
                              const SizedBox(height: 80),

                              _wrapScrollTag(index: 1, child: HowItWorksArea(mobile: mobile)),
                              const SizedBox(height: 80),

                              _wrapScrollTag(index: 2, child: NewSessionWidget(size: size, mobile: mobile)),
                              const SizedBox(height: 80),

                              _wrapScrollTag(index: 3, child: FindSessionWidget(size: size, mobile: mobile)),

                              const SizedBox(height: 80),
                              ContactArea(),
                              Center(
                                child: TebButton(
                                  label: 'Área Restrita',
                                  buttonType: TebButtonType.outlinedButton,
                                  onPressed: () => Navigator.of(context).pushNamed(Routes.loginScreen),
                                  padding: EdgeInsets.only(bottom: 10),
                                ),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SocialLinksArea(context: context, size: size),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
