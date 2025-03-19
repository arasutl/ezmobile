
import 'package:flutter/material.dart';
import 'package:get/get.dart';
/*import 'package:flutterappnew/components/MultiSelect.dart';
import 'package:flutterappnew/config/global_config.dart';
import 'package:flutterappnew/request/plastic_banl_request.dart';
import 'package:flutterappnew/utils/controller.dart';*/

import '../../controllers/MultiSelectMainController.dart';
import 'MultiSelect.dart';

class MultiSelectMain extends StatefulWidget {
  const MultiSelectMain({super.key});

  @override
  _MultiSelectMainState createState() => _MultiSelectMainState();
}

class _MultiSelectMainState extends State<MultiSelectMain> {
  List<String> _selectedItems = [];
  List<String> _selectedItemsId = [];
  late Future<dynamic> fStaffs;

  final controller = Get.put(MultiSelectMainController());

  @override
  void initState() {
    super.initState();

    controller.fetchStaff().then((value) => {print('fetchStaff')});
  }

  void _showMultiSelect() async {
    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(items: controller.items, itemsid: controller.itemsId);
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        _selectedItems = results;

        _selectedItemsId = [];
        controller.sSelectedmemberIds = "";
        for (int i = 0; i < controller.items.length; i++) {
          for (int j = 0; j < _selectedItems.length; j++) {
            if (controller.items[i].toString().trim() == _selectedItems[j].toString().trim()) {
              if (controller.sSelectedmemberIds.length.toString().trim().isNotEmpty) {
                controller.sSelectedmemberIds = "${controller.sSelectedmemberIds},${controller.itemsId[i]}";
              } else {
                controller.sSelectedmemberIds = controller.itemsId[i].toString().toString();
              }
              _selectedItemsId.add(controller.itemsId[i].toString());
            }
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        //padding: const EdgeInsets.only(right: 5, left: 5, top: 10, bottom: 10),
        padding: const EdgeInsets.only(right: 0, left: 0, top: 0, bottom: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // use this button to open the multi-select dialog
            ElevatedButton(
              onPressed: _showMultiSelect,
              child: const Text('Forward'),
            ),
            const Divider(
              height: 1,
            ),
            // display selected items
            Wrap(
              children: _selectedItems
                  .map((e) => Chip(
                        label: Text(e),
                      ))
                  .toList(),
            )
          ],
        ),
      ),
    );
  }
}
