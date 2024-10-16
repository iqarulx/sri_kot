import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '/constants/constants.dart';
import '/model/model.dart';

class ViewAllProductsInv extends StatefulWidget {
  final List<InvoiceProductModel> cart;
  final bool taxType;
  const ViewAllProductsInv(
      {super.key, required this.cart, required this.taxType});

  @override
  State<ViewAllProductsInv> createState() => _ViewAllProductsInvState();
}

class _ViewAllProductsInvState extends State<ViewAllProductsInv> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 15, bottom: 15, right: 15),
        primary: false,
        shrinkWrap: true,
        itemCount: widget.cart.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.all(5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.cart[index].productType == ProductType.netRated
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Banner(
                          message: "Net Rate",
                          location: BannerLocation.topStart,
                          child: CachedNetworkImage(
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            imageUrl: Strings.productImg,
                            fit: BoxFit.cover,
                            height: 80.0,
                            width: 80.0,
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Banner(
                          message: "${widget.cart[index].discount ?? 0}%",
                          color: Colors.green,
                          location: BannerLocation.topStart,
                          child: CachedNetworkImage(
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            imageUrl: Strings.productImg,
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            fit: BoxFit.cover,
                            height: 80.0,
                            width: 80.0,
                          ),
                        ),
                      ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.cart[index].productName ?? "",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  // height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      width: 0.5,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (widget.cart[index].productType ==
                                            ProductType.netRated)
                                          Expanded(
                                            child: Text(
                                              "${(widget.cart[index].rate)!.toStringAsFixed(2)} X ${widget.cart[index].qty} = ${(widget.cart[index].rate! * widget.cart[index].qty!).toStringAsFixed(2)}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium!
                                                  .copyWith(
                                                    color: Colors.grey,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        else
                                          Expanded(
                                            child: Text(
                                              "${(widget.cart[index].rate! - ((widget.cart[index].rate! * widget.cart[index].discount!) / 100)).toStringAsFixed(2)} X ${widget.cart[index].qty} = ${((widget.cart[index].rate! * widget.cart[index].qty!) - (((widget.cart[index].rate! * widget.cart[index].qty!) * widget.cart[index].discount!) / 100)).toStringAsFixed(2)}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium!
                                                  .copyWith(
                                                    color: Colors.grey,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: widget.taxType,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Tax : ${widget.cart[index].taxValue}",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            "HSN : ${widget.cart[index].hsnCode}",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          if (widget.cart[index].productType ==
                              ProductType.netRated)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "\u{20B9}${(widget.cart[index].rate! * widget.cart[index].qty!).toStringAsFixed(2)}",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            )
                          else
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "\u{20B9}${(widget.cart[index].rate! * widget.cart[index].qty!).toStringAsFixed(2)}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.grey),
                                ),
                                Text(
                                  "\u{20B9}${((widget.cart[index].rate! * widget.cart[index].qty!) - (((widget.cart[index].rate! * widget.cart[index].qty!) * widget.cart[index].discount!) / 100)).toStringAsFixed(2)}",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
