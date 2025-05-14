import 'package:flutter/material.dart';
import 'package:teb_janelajohari/admin_area/site_text/site_text_controller.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class AreaTitleWidget extends StatefulWidget {
  final bool mobile;
  final Size size;
  final String title;
  final double? lineWidth;
  final String siteTextPage;
  final String siteTextLocal;
  final bool cropped;

  const AreaTitleWidget({
    super.key,
    required this.size,
    required this.title,
    this.lineWidth,
    this.siteTextPage = '',
    this.siteTextLocal = '',
    required this.mobile,
    this.cropped = false,
  });

  @override
  State<AreaTitleWidget> createState() => _AreaTitleWidgetState();
}

class _AreaTitleWidgetState extends State<AreaTitleWidget> {
  final _siteTextController = SiteTextController();
  var _titleTebTextWidget = TebText('');
  var _initializing = true;
  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      if (widget.siteTextPage.isNotEmpty && widget.siteTextPage.isNotEmpty) {
        _siteTextController.fillSiteTextList(page: widget.siteTextPage).then((value) {
          setState(() {
            _titleTebTextWidget = _siteTextController.getTebTextWidget(local: widget.siteTextLocal);
          });
        });
      } else {
        _titleTebTextWidget = TebText(widget.title, textSize: 32.0, letterSpacing: 3.0, textWeight: FontWeight.w700);
      }

      _initializing = false;
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.mobile) Expanded(child: _titleTebTextWidget),
            if (!widget.mobile) _titleTebTextWidget,
            if (!widget.mobile) SizedBox(width: widget.size.width * 0.005),
            if (!widget.mobile)
              Container(width: widget.lineWidth ?? widget.size.width / 4, height: 2.50, color: Theme.of(context).dividerColor),
          ],
        ),
        if (!widget.cropped) SizedBox(height: 30),
      ],
    );
  }
}
