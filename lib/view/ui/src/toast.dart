import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

showToast(context,
    {required String content, required bool isSuccess, required bool top}) {
  return toastification.show(
    context: context,
    type: isSuccess ? ToastificationType.success : ToastificationType.error,
    style: ToastificationStyle.flat,
    autoCloseDuration: const Duration(seconds: 5),
    // title: Text(
    //   title,
    //   style: const TextStyle(color: Colors.white),
    // ),
    description: RichText(text: TextSpan(text: content)),
    alignment: top ? Alignment.topRight : Alignment.bottomCenter,
    animationDuration: const Duration(milliseconds: 300),
    animationBuilder: (context, animation, alignment, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    icon: isSuccess
        ? const Icon(
            Icons.check,
            color: Colors.white,
          )
        : const Icon(
            Icons.close,
            color: Colors.white,
          ),
    showIcon: true,
    // primaryColor: Colors.green,
    backgroundColor: isSuccess ? Colors.green : Colors.red,
    // foregroundColor: Colors.black,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Colors.transparent),
    // boxShadow: const [
    //   BoxShadow(
    //     color: Color(0x07000000),
    //     blurRadius: 16,
    //     offset: Offset(0, 16),
    //     spreadRadius: 0,
    //   )
    // ],
    showProgressBar: false,
    closeButtonShowType: CloseButtonShowType.onHover,
    closeOnClick: false,
    pauseOnHover: true,
    dragToClose: true,
    applyBlurEffect: false,
    // callbacks: ToastificationCallbacks(
    //   onTap: (toastItem) => print('Toast ${toastItem.id} tapped'),
    //   onCloseButtonTap: (toastItem) =>
    //       print('Toast ${toastItem.id} close button tapped'),
    //   onAutoCompleteCompleted: (toastItem) =>
    //       print('Toast ${toastItem.id} auto complete completed'),
    //   onDismissed: (toastItem) => print('Toast ${toastItem.id} dismissed'),
    // ),
  );
}
