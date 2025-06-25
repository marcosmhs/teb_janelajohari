// ignore_for_file: use_build_context_synchronously

// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:teb_janelajohari/main/widgets/about_jorari_window_area.dart';
import 'package:teb_janelajohari/main/widgets/contact_area.dart';
import 'package:teb_janelajohari/main/widgets/how_it_works_area.dart';
import 'package:teb_janelajohari/main/widgets/site_title_widget.dart';
import 'package:teb_janelajohari/public_area/wellcome_screen/widgets/find_session_widget.dart';
import 'package:teb_janelajohari/public_area/wellcome_screen/widgets/new_session_widget.dart';
import 'package:teb_package/screen_widgets/teb_expandable_fab/teb_expandable_fab.dart';
import 'package:teb_package/teb_package.dart';

class WellcomeScreenMobile extends StatefulWidget {
  const WellcomeScreenMobile({super.key});

  @override
  State<WellcomeScreenMobile> createState() => _WellcomeScreenMobileState();
}

class _WellcomeScreenMobileState extends State<WellcomeScreenMobile> {
  late AutoScrollController _autoScrollController;
  final _scrollDirection = Axis.vertical;

  final _key = GlobalKey<TebExpandableFabState>();

  @override
  void initState() {
    _autoScrollController = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: _scrollDirection,
    )..addListener(() {});
    super.initState();
  }

  Future _scrollToIndex(int index) async {
    await _autoScrollController.scrollToIndex(index, preferPosition: AutoScrollPosition.begin);
    _autoScrollController.highlight(index);
  }

  Widget _wrapScrollTag({required int index, required Widget child}) {
    return AutoScrollTag(key: ValueKey(index), controller: _autoScrollController, index: index, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return TebScaffold(
      showAppBar: false,
      responsive: false,
      floatingActionButtonLocation: TebExpandableFab.location,
      floatingActionButton: TebExpandableFab(
        key: _key,

        distance: 50.0,
        type: ExpandableFabType.up,
        childrenAnimation: ExpandableFabAnimation.none,

        children: [
          TebButton(
            foregroundColor: Theme.of(context).canvasColor,
            icon: Icon(FontAwesomeIcons.question),
            size: Size(200, 40),
            label: 'O que é',
            onPressed: () async {
              _scrollToIndex(0);
              final state = _key.currentState;
              if (state != null) state.toggle();
            },
          ),

          TebButton(
            foregroundColor: Theme.of(context).canvasColor,
            size: Size(200, 40),
            label: 'Como Funciona',
            onPressed: () async {
              _scrollToIndex(1);
              final state = _key.currentState;
              if (state != null) state.toggle();
            },
          ),
          TebButton(
            foregroundColor: Theme.of(context).canvasColor,

            size: Size(200, 40),
            label: 'Criar sua sessão',
            onPressed: () async {
              _scrollToIndex(2);
              final state = _key.currentState;
              if (state != null) state.toggle();
            },
          ),
          TebButton(
            foregroundColor: Theme.of(context).canvasColor,
            size: Size(200, 40),
            label: 'Dar um feedback',
            onPressed: () async {
              _scrollToIndex(3);
              final state = _key.currentState;
              if (state != null) state.toggle();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        primary: true,
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SiteTitleWidget(mobile: true),
            const SizedBox(height: 20),
            // main
            Row(
              children: [
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
                              _wrapScrollTag(index: 0, child: AboutArea(mobile: true)),
                              const SizedBox(height: 80),

                              _wrapScrollTag(index: 1, child: HowItWorksArea(mobile: true)),
                              const SizedBox(height: 80),

                              _wrapScrollTag(index: 2, child: NewSessionWidget(size: size, mobile: true)),
                              const SizedBox(height: 80),

                              _wrapScrollTag(index: 3, child: FindSessionWidget(size: size, mobile: true)),
                              const SizedBox(height: 80),

                              ContactArea(mobile: true),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
