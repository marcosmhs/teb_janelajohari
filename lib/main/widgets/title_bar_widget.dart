// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teb_janelajohari/main/widgets/site_title_widget.dart';
import 'package:teb_janelajohari/public_area/session/session.dart';
import 'package:teb_janelajohari/public_area/session_feedbacks/session_feedbacks.dart';
import 'package:teb_package/messaging/teb_custom_message.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class TitleBarWidget extends StatefulWidget {
  final Session session;
  final BuildContext context;
  final bool mobile;
  final String title;
  final FeedbackType feedbackType;

  const TitleBarWidget({
    super.key,
    required this.session,
    required this.context,
    this.mobile = false,
    this.title = '',
    required this.feedbackType,
  });

  @override
  State<TitleBarWidget> createState() => _TitleBarWidgetState();
}

class _TitleBarWidgetState extends State<TitleBarWidget> {
  Widget _sessionCode(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            TebText(
              'Código de acesso da sessão: ',
              textSize: Theme.of(context).textTheme.labelLarge!.fontSize,
              textWeight: FontWeight.w700,
            ),
            TebText(
              '(${widget.session.accessCode})',
              textSize: Theme.of(context).textTheme.labelLarge!.fontSize,
              padding: const EdgeInsets.only(left: 3),
            ),
          ],
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: widget.session.accessCode)).then(
              (value) => TebCustomMessage(
                context: context,
                messageText: 'Código da sessão copiado para a área de transferência',
                messageType: TebMessageType.info,
              ),
            );
          },
          child: const Icon(Icons.copy, size: 15),
        ),
      ],
    );
  }

  Widget _feedbackLink(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            TebText(
              widget.mobile ? 'Copiar Link para feedbacks: ' : 'Link para feedbacks: ',
              textSize: Theme.of(context).textTheme.labelLarge!.fontSize,
              textWeight: FontWeight.w700,
            ),

            if (!widget.mobile)
              TebText(
                widget.session.sessionFeedbackUrl,
                textSize: Theme.of(context).textTheme.labelLarge!.fontSize,
                padding: const EdgeInsets.only(left: 3),
              ),
          ],
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: widget.session.sessionFeedbackUrl)).then(
              (value) => TebCustomMessage(
                context: context,
                messageText: 'Link copiado para a área de transferência',
                messageType: TebMessageType.info,
              ),
            );
          },
          child: const Icon(Icons.copy, size: 15),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.mobile
        ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.only(bottom: 10), child: SiteTitleWidget(mobile: widget.mobile)),
            if (widget.feedbackType == FeedbackType.self)
              Row(children: [Padding(padding: const EdgeInsets.only(bottom: 10), child: _sessionCode(context))]),
            if (widget.feedbackType == FeedbackType.self) _feedbackLink(context),
          ],
        )
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.only(bottom: 10), child: SiteTitleWidget(mobile: widget.mobile)),
            if (widget.feedbackType == FeedbackType.self)
              Row(
                children: [const SizedBox(width: 10), _sessionCode(context), const SizedBox(width: 30), _feedbackLink(context)],
              ),
          ],
        );
  }
}
