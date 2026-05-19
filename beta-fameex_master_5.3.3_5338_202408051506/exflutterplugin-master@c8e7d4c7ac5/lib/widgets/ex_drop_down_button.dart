import 'package:chainup_flutter_ex/constants/color_constant.dart';
import 'package:chainup_flutter_ex/themes/Themes.dart';
import 'package:chainup_flutter_ex/widgets/gaps.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class ExDropDownButton extends StatefulWidget {
  final List<String>? items;
  final String? selectedValue;
  final ValueChanged? selectedCallback;
  const ExDropDownButton({
    this.items,
    this.selectedValue,
    this.selectedCallback,
    super.key,
  });

  @override
  State<ExDropDownButton> createState() => _ExDropDownButtonState();
}

class _ExDropDownButtonState extends State<ExDropDownButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;

  bool _isArrowUp = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation1 = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.addListener(() {
      setState(() {});
    });
  }

  void _toggleArrow() {
    if (_isArrowUp) {
      forward(0.5, 1);
    } else {
      forward(0, 0.5);
    }

    setState(() {
      _isArrowUp = !_isArrowUp;
    });
  }

  forward(double begin, double end) {
    _controller
      ..value = 0 // 重置动画的值
      ..animateTo(
        1,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 300),
      );
    _animation1 = Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: false,
          customButton: _defaultText(context),
          items: _dropdownItems(context),
          // value: selectedValue,
          onChanged: (String? value) {
            widget.selectedCallback?.call(value ?? "");
          },
          onMenuStateChange: (isOpen) {
            _toggleArrow();
          },
          menuItemStyleData: MenuItemStyleData(
            height: 35,
            selectedMenuItemBuilder: (context, child) {
              return Text(
                "",
                style: ExThemes.textstyle_hm_color1_12(context),
              );
            },
          ),
          dropdownStyleData: DropdownStyleData(
            width: 75,
            decoration: BoxDecoration(
              color: ExColors.special_2(context),
              borderRadius: const BorderRadius.all(
                Radius.circular(4),
              ),
              boxShadow: const [
                BoxShadow(color: Colors.transparent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _defaultText(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, bottom: 3),
      child: Container(
        decoration: BoxDecoration(
          color: ExColors.special_2(context),
          borderRadius: const BorderRadius.all(
            Radius.circular(2),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Row(
          children: [
            Text(
              widget.selectedValue!,
              style: ExThemes.textstyle_hm_color1_12(context),
            ),
            Gaps.hGap4,
            Transform.rotate(
              angle: _animation1.value * 2 * 3.1416, // 转换弧度
              child: Image.asset(
                "images/light/public_arrow_down.png",
                width: 10,
                height: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _dropdownItems(BuildContext context) {
    return widget.items!.map(
      (String item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item,
            style: item == widget.selectedValue
                ? ExThemes.textstyle_hm_color1_14(context)
                    .copyWith(color: ExColors.main_1(context))
                : ExThemes.textstyle_hm_color1_14(context),
          ),
        );
      },
    ).toList();
  }
}
