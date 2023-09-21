import 'package:cluein_app/src/utils/constant_utils.dart';
import 'package:flutter/material.dart';

class WidgetUtils {
  static Widget spacer(double allPadding) => Padding(padding: EdgeInsets.all(allPadding));

  static List<T> skipNulls<T>(List<T?> items) {
    return items.whereType<T>().toList();
  }

  static Widget viewUnderDismissibleListTile() {
    return Container(
      color: Colors.redAccent,
      child: const Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 5,
              child: Center(
                  child: Text(
                    "Remove",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                    ),
                  )
              )
          ),
          Expanded(
              flex: 1,
              child: Icon(Icons.remove_circle, color: Colors.white,)
          ),
        ],
      ),
    );
  }

  static Widget progressIndicator() => const Center(child: CircularProgressIndicator(color: ConstantUtils.primaryAppColor,),);
}