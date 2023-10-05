import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomMarkingsLayout extends StatefulWidget {

  final List<Widget> children;

  const CustomMarkingsLayout({
    super.key,
    required this.children,
  });

  @override
  State<StatefulWidget> createState() {
    return CustomMarkingsLayoutState();
  }

}

/// Max children is 12
/// Decide layout individually based on count
class CustomMarkingsLayoutState extends State<CustomMarkingsLayout> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.children.length) {
      case 1:
        return _buildSizeOneLayout();
      case 2:
        return _buildSizeTwoLayout();
      case 3:
        return _buildSizeThreeLayout();
      case 4:
        return _buildSizeFourLayout();
      case 5:
        return _buildSizeFiveLayout();
      case 6:
        return _buildSizeSixLayout();
      case 7:
        return _buildSizeSevenToNineLayout();
      case 8:
        return _buildSizeSevenToNineLayout();
      case 9:
        return _buildSizeSevenToNineLayout();
      case 10:
        return _buildMaxSizeLayout();
      case 11:
        return _buildMaxSizeLayout();
      case 12:
        return _buildMaxSizeLayout();
      default:
        return _buildMaxSizeLayout();
    }
  }

  _buildSizeOneLayout() {
    return Center(
      child: SizedBox(
        width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble()  *2,
        child: widget.children[0],
      ),
    );
  }

  _buildSizeTwoLayout() {
    return Center(
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
              child: widget.children[0],
            ),
          ),
          Expanded(
            child: SizedBox(
              width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
              child: widget.children[1],
            ),
          )
        ],
      ),
    );
  }

  _buildSizeThreeLayout() {
    return Center(
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
              child: widget.children[0],
            ),
          ),
          Expanded(
            child: SizedBox(
              width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
              child: widget.children[1],
            ),
          ),
          Expanded(
            child: SizedBox(
              width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
              child: widget.children[2],
            ),
          )
        ],
      ),
    );
  }

  _buildSizeFourLayout() {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[0],
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[1],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[2],
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[3],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildSizeFiveLayout() {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[0],
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[1],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[2],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[3],
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[4],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildSizeSixLayout() {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[0],
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[1],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[2],
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[3],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[4],
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[5],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildSizeSevenToNineLayout() {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[0],
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[1],
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[2],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[3],
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[4],
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[5],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: widget.children.skip(6).map((e) => Expanded(
                child: SizedBox(
                  width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                  child: e,
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  _buildMaxSizeLayout() {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[0],
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[1],
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[2],
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[3],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[4],
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[5],
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[6],
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                    child: widget.children[7],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: widget.children.skip(8).map((e) => Expanded(
                child: SizedBox(
                  width: ConstantUtils.TICK_CROSS_DIAMETER.toDouble(),
                  child: e,
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}