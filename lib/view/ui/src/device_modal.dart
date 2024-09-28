/*
  Copyright 2024 Srisoftwarez. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file.
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sri_kot/model/model.dart';
import 'package:sri_kot/view/ui/ui.dart';

class DeviceModal extends StatefulWidget {
  final DeviceModel deviceModel;
  const DeviceModal({super.key, required this.deviceModel});

  @override
  State<DeviceModal> createState() => _DeviceModalState();
}

class _DeviceModalState extends State<DeviceModal> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide.none,
      ),
      title: const SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Icon(
              CupertinoIcons.exclamationmark_square,
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              "User Device Details",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: double.infinity,
        child: widget.deviceModel.deviceName != null &&
                widget.deviceModel.deviceId != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Text("Device : ${widget.deviceModel.deviceName ?? ''}"),
                  const SizedBox(
                    height: 5,
                  ),
                  Text("Model Name : ${widget.deviceModel.modelName ?? ''}"),
                  const SizedBox(
                    height: 5,
                  ),
                  Text("Device Id : ${widget.deviceModel.deviceId ?? ''}"),
                ],
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text("No device found. May be user not logged yet"),
                ],
              ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (widget.deviceModel.deviceName != null &&
                      widget.deviceModel.deviceId != null) {
                    Navigator.pop(context, false);
                  } else {
                    showToast(
                      context,
                      content: "No device detected to delete",
                      isSuccess: false,
                      top: false,
                    );
                  }
                },
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xffF2F2F2),
                  ),
                  child: const Center(
                    child: Text(
                      "Delete",
                      style: TextStyle(
                        color: Color(0xff575757),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context, true);
                },
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: const Center(
                    child: Text(
                      "OK",
                      style: TextStyle(
                        color: Color(0xffF4F4F9),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
