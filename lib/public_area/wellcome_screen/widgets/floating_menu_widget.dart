import 'package:flutter/material.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/screen_widgets/teb_expandable_fab/teb_expandable_fab.dart';


class FloatingMenuWidget extends StatefulWidget {
  final List<Widget> children;
  final GlobalKey<TebExpandableFabState> globalKey;
  const FloatingMenuWidget({super.key, required this.children, required this.globalKey});

  @override
  State<FloatingMenuWidget> createState() => _FloatingMenuWidgetState();
}

class _FloatingMenuWidgetState extends State<FloatingMenuWidget> {
  @override
  Widget build(BuildContext context) {
    return TebExpandableFab(
      key: widget.globalKey,
      margin: const EdgeInsets.only(right: 80),
      distance: 60.0,
      type: ExpandableFabType.up,
      childrenAnimation: ExpandableFabAnimation.none,
      children: widget.children,
    );
  }
}

class MenuWidgetItem extends StatelessWidget {
  final Future<void> Function() scrollToIndex;
  final GlobalKey<TebExpandableFabState> globalKey;
  final String label;
  final bool bold;
  final IconData icon;
  const MenuWidgetItem({
    super.key,
    required this.scrollToIndex,
    required this.globalKey,
    required this.label,
    this.bold = false,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await scrollToIndex();
        final state = globalKey.currentState;
        if (state != null) state.toggle();
      },
      child: Container(
        width: 250,
        height: 45,

        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withAlpha(200),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Icon(icon, color: Theme.of(context).canvasColor),
            const SizedBox(width: 10),
            TebText(
              textColor: Theme.of(context).canvasColor,
              label,
              textSize: bold ? 18 : 16,
              letterSpacing: 1.5,
              textWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ],
        ),
      ),
    );
  }
}
