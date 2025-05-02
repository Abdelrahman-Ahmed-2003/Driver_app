import 'package:dirver/features/passenger/presentation/provider/tripProvider.dart';
import 'package:flutter/material.dart';
import 'package:dirver/core/models/driver.dart';
import 'package:dirver/core/utils/colors_app.dart';
import 'package:provider/provider.dart';

class DriverCard extends StatefulWidget {
  final Driver driver;

  const DriverCard({
    super.key,
    required this.driver,
  });

  @override
  State<DriverCard> createState() => _DriverCardState();
}

class _DriverCardState extends State<DriverCard> {
  late TextEditingController priceController;
  String buttonText = 'Select Driver';

  @override
  void initState() {
    super.initState();
    priceController = TextEditingController();
  }

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TripProvider>(context, listen: false);
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.greyColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Info Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Name + Avatar
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: widget.driver.imageUrl != null
                          ? NetworkImage(widget.driver.imageUrl!)
                          : null,
                      child: widget.driver.imageUrl == null
                          ? Text(widget.driver.email[0].toUpperCase())
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.driver.name ?? widget.driver.email,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Rating if available
                if (widget.driver.rating != null)
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      Text(widget.driver.rating!),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Vehicle Info
            if (widget.driver.vehicleType != null)
              Text("Vehicle: ${widget.driver.vehicleType!}"),

            const SizedBox(height: 12),

            // Input field for price
            TextFormField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Propose Price',
                filled: true,
                fillColor: Color(0XFFC1CDCB),
                suffixText: 'EGP',
                suffixStyle: TextStyle(color: Color.fromARGB(255, 131, 18, 18)),
              ),
              onChanged: (value) {
                setState(() {
                  buttonText = 'Update price';
                });
              },
            ),

            const SizedBox(height: 12),

            // Button to accept/select driver
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.grenColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () async {
                  if(buttonText == 'Update price'&& provider.priceController.text != priceController.text.trim()){
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a price')),
                    );
                    return;
                  }
                  else if(buttonText == 'Select Driver') {
                    provider.updateSelectedDriver(widget.driver.email);
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(content: Text('Please enter a price')),
                    // );
                    return;
                  }
                },
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
