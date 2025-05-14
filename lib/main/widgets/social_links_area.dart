import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_package/util/teb_url_manager.dart';

class SocialLinksArea extends StatefulWidget {
  final BuildContext context;
  final Size size;
  final bool mobile;

  const SocialLinksArea({super.key, required this.context, required this.size, this.mobile = false});

  @override
  State<SocialLinksArea> createState() => _SocialLinksAreaState();
}

class _SocialLinksAreaState extends State<SocialLinksArea> {
  @override
  Widget build(BuildContext context) {
    var links = [
      IconButton(
        icon: const FaIcon(FontAwesomeIcons.linkedin),
        iconSize: 26.0,
        onPressed: () => TebUrlManager.launchUrl(url: 'https://www.linkedin.com/in/marcosmhs/'),
      ),
      IconButton(
        icon: const FaIcon(FontAwesomeIcons.m),
        iconSize: 26.0,
        onPressed: () => TebUrlManager.launchUrl(url: 'https://www.marcosmhs.com.br/'),
      ),
      IconButton(
        icon: const FaIcon(FontAwesomeIcons.github),
        iconSize: 26.0,
        onPressed: () => TebUrlManager.launchUrl(url: 'https://github.com/marcosmhs/'),
      ),
    ];

    return SizedBox(
      width: widget.mobile ? null : 90,
      height: widget.mobile ? null : widget.size.height - 82,
      child:
          widget.mobile
              ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: links)
              : Column(mainAxisAlignment: MainAxisAlignment.end, children: links),
    );
  }
}
