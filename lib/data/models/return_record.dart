/// Models the body the server expects at `POST /api/returns`.
class ReturnLineItem {
  ReturnLineItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.reason,
    required this.addToStock,
    required this.unitPrice,
  });

  final String productId;
  final String productName;
  final double quantity;
  final String reason;
  final bool addToStock;
  final double unitPrice;

  double get lineRefund => quantity * unitPrice;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'reason': reason,
        'addToStock': addToStock,
        'unitPrice': unitPrice,
      };
}

class ReturnRecord {
  ReturnRecord({
    required this.id,
    required this.originalSaleId,
    required this.timestamp,
    required this.returnedItems,
    required this.subtotalAmount,
    required this.taxAmount,
    required this.refundAmount,
    required this.refundMethod,
  });

  final String id;
  final String originalSaleId;
  final String timestamp;
  final List<ReturnLineItem> returnedItems;
  final double subtotalAmount;
  final double taxAmount;
  final double refundAmount;
  final String refundMethod;

  Map<String, dynamic> toJson() => {
        'id': id,
        'originalSaleId': originalSaleId,
        'timestamp': timestamp,
        'returnedItems': returnedItems.map((e) => e.toJson()).toList(),
        'subtotalAmount': subtotalAmount,
        'taxAmount': taxAmount,
        'refundAmount': refundAmount,
        'refundMethod': refundMethod,
      };
}
