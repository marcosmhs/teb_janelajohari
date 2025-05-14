import 'package:flutter/material.dart';
import 'package:teb_janelajohari/admin_area/site_text/site_text_controller.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class SiteTitleWidget extends StatefulWidget {
  final bool mobile;
  const SiteTitleWidget({super.key, this.mobile = false});

  @override
  State<SiteTitleWidget> createState() => _SiteTitleWidgetState();
}

class _SiteTitleWidgetState extends State<SiteTitleWidget> {
  var _initializing = true;
  final _siteTextController = SiteTextController();
  var _titleTebTextWidget = TebText('');

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      _siteTextController.fillSiteTextList(page: widget.mobile ? 'wellcome_page_mobile' : 'wellcome_page_web').then((value) {
        setState(() {
          _titleTebTextWidget = _siteTextController.getTebTextWidget(local: 'title');
        });
      });
      _initializing = false;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Image.asset('assets/images/logo.png', fit: BoxFit.fitHeight, height: widget.mobile ? 30 : 45),
          ),
          _titleTebTextWidget,
        ],
      ),
    );
  }
}
