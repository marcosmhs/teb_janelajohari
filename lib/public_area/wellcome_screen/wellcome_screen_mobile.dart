// ignore_for_file: use_build_context_synchronously

// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:teb_janelajohari/main/widgets/about_jorari_window_area.dart';
import 'package:teb_janelajohari/main/widgets/contact_area.dart';
import 'package:teb_janelajohari/main/widgets/how_it_works_area.dart';
import 'package:teb_janelajohari/main/widgets/site_title_widget.dart';
import 'package:teb_janelajohari/public_area/wellcome_screen/widgets/find_session_widget.dart';
import 'package:teb_janelajohari/public_area/wellcome_screen/widgets/new_session_widget.dart';
import 'package:teb_package/teb_package.dart';

class WellcomeScreenMobile extends StatefulWidget {
  const WellcomeScreenMobile({super.key});

  @override
  State<WellcomeScreenMobile> createState() => _WellcomeScreenMobileState();
}

class _WellcomeScreenMobileState extends State<WellcomeScreenMobile> {
  @override
  Widget build(BuildContext context) {


    final Size size = MediaQuery.of(context).size;

    return TebCustomScaffold(
      showAppBar: false,
      responsive: false,
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
                        slivers: <Widget>[
                          SliverList(
                            delegate: SliverChildListDelegate([
                              AboutArea(mobile: true),
                              const SizedBox(height: 80),

                              HowItWorksArea(mobile: true),
                              const SizedBox(height: 80),

                              NewSessionWidget(size: size, mobile: true),
                              const SizedBox(height: 80),

                              FindSessionWidget(size: size, mobile: true),

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
