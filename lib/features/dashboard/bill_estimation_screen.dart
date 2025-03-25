import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class BillEstimationScreen extends StatefulWidget {
  const BillEstimationScreen({super.key});

  @override
  _BillEstimationScreenState createState() => _BillEstimationScreenState();
}

class _BillEstimationScreenState extends State<BillEstimationScreen> {
  final TextEditingController _energyController = TextEditingController();
  String? _selectedMonth;
  String? _selectedMeterType;
  double? _estimatedBill;
  Map<String, dynamic>? _billDetails;
  bool _isLoading = false;

  // Function to estimate the bill
  void calculateBill() async {
    final energyUsage = double.tryParse(_energyController.text);

    if (_selectedMonth == null || _selectedMeterType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a month and meter type")),
      );
      return;
    }

    if (energyUsage == null || energyUsage <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid energy usage (kWh)")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Payload structure
    final payload = {
      "energy_usage": energyUsage,
      "month": _selectedMonth,
      "meter_type": _selectedMeterType,
    };

    // Call the API
    final result = await ApiService.estimateBill(payload);

    setState(() {
      _isLoading = false;
    });

    // Handle the API response
    if (result['success'] == true) {
      setState(() {
        _estimatedBill = result['data']['total'];
        _billDetails = result['data']['breakdown'];
        _billDetails!['recommendations'] =
            getRecommendations(energyUsage, _selectedMeterType!);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Error estimating bill')),
      );
    }
  }

  // Function to generate recommendations
  List<String> getRecommendations(double energyUsage, String meterType) {
    List<String> recommendations = [];

    if (energyUsage > 100) {
      recommendations.add("Consider using energy-efficient appliances.");
      recommendations.add("Switch off devices when not in use.");
    }

    if (meterType == "Postpayment") {
      recommendations.add("Shift to prepayment to monitor energy usage closely.");
    }

    recommendations.add("Use LED lighting to reduce energy consumption.");
    recommendations.add("Schedule energy-intensive tasks during off-peak hours.");

    return recommendations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bill Simulation',
          style: TextStyle(
            color: Colors.white
          ),
          ),
        backgroundColor: Colors.blue.shade900,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Month and Meter Type:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'November 2024', child: Text('November 2024')),
                DropdownMenuItem(value: 'December 2024', child: Text('December 2024')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedMonth = value;
                });
              },
              value: _selectedMonth,
              hint: const Text('Month'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Prepayment', child: Text('Prepayment Small-Non Domestic')),
                DropdownMenuItem(value: 'Postpayment', child: Text('Postpayment Small-Domestic')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedMeterType = value;
                });
              },
              value: _selectedMeterType,
              hint: const Text('Meter Type'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter Active Energy (kWh):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _energyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g., 45.5',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : calculateBill,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                minimumSize: const Size(double.infinity, 50),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,  // Set to zero for a rectangular button
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                  : const Text(
                    'Send',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                    ),
            ),
            const SizedBox(height: 20),
            if (_billDetails != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RESULT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    title: const Text('Consumption'),
                    trailing: Text('${_billDetails!["consumption"]} KWh'),
                  ),
                  ListTile(
                    title: const Text('Fuel Energy Cost'),
                    trailing: Text('${_billDetails!["fuel_energy_cost"]}'),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Forex Exchange Adj.'),
                    trailing: Text('${_billDetails!["forex_adj"]}'),
                  ),
                  ListTile(
                    title: const Text('Inflation Adj. (INFA)'),
                    trailing: Text('${_billDetails!["inflation_adj"]}'),
                  ),
                  ListTile(
                    title: const Text('ERC Levy'),
                    trailing: Text('${_billDetails!["erc_levy"]}'),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('VAT'),
                    trailing: Text('${_billDetails!["vat"]}'),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    color: Colors.yellow,
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL AMOUNT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'KSH ${_estimatedBill?.toStringAsFixed(2) ?? ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Recommendations to Reduce Costs:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...?_billDetails!['recommendations']?.map<Widget>((recommendation) {
                    return ListTile(
                      leading: const Icon(Icons.lightbulb, color: Colors.amber),
                      title: Text(recommendation),
                    );
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
