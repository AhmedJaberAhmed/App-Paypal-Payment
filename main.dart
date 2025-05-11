import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'apiKeys.dart';
import 'models/Amount.dart';
import 'models/AmountDetails.dart';
import 'models/item.dart';
import 'models/itemList.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PaymentSuccessScreen(),
    );
  }
}

class PaymentSuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A50),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.card_travel_outlined, color: Colors.white, size: 100),
              const SizedBox(height: 20),
              const Text(
                " GO Payment Success!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Hooray! Your payment process has\nbeen completed successfully.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Receipt",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildReceiptOption(Icons.email, "Email"),
                  _buildReceiptOption(Icons.sms, "SMS"),
                  _buildReceiptOption(Icons.print, "Print"),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  var transactions = getTransactionsData();

                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => PaypalCheckoutView(
                      sandboxMode: true,
                      clientId: ApiKeys.clientSectret,
                      secretKey: ApiKeys.paypalSecret,
                      transactions: [
                        {
                          "amount": transactions["amount"].toJson(),
                          "description": "The payment transaction description.",
                          "item_list": transactions["itemList"].toJson(),
                        }
                      ],
                      note: "Contact us for any questions on your order.",
                      onSuccess: (Map params) async {
                        Navigator.pop(context);

                        print("onSuccess: $params");
                      },
                      onError: (error) {
                        print("onError: $error");
                        Navigator.pop(context);
                      },
                      onCancel: () {
                        print('cancelled:');
                      },
                    ),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Pay with PayPal",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptOption(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
Map<String, dynamic> getTransactionsData() {
  List<Item> orders = [
    Item(name: "Apple", quantity: 5, price: "4", currency: "USD"),
    Item(name: "Banana", quantity: 10, price: "3", currency: "USD"),
  ];

  // Calculate subtotal
  double subtotal = orders.fold(0, (sum, item) => sum + (double.parse(item.price) * item.quantity));

  // Define amount details
  var amount = Amount(
    total: subtotal.toStringAsFixed(2), // Make sure total matches
    currency: "USD",
    details: AmountDetails(
      shipping: "0",         // No shipping cost
      shippingDiscount: 0,   // No discount
      subtotal: subtotal.toStringAsFixed(2), // Ensure this matches item total
    ),
  );

  var itemList = ItemList(items: orders);

  return {
    "amount": amount,
    "itemList": itemList,
  };
}
