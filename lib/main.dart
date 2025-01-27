import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(LoanApp());
}

class LoanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loan Application',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoanPage(),
    );
  }
}

class LoanPage extends StatefulWidget {
  @override
  _LoanPageState createState() => _LoanPageState();
}

class _LoanPageState extends State<LoanPage> {
  List<Map<String, dynamic>> financingOptionsData = [];
  double loanAmount = 60000;
  double annualRevenue = 250000;
  var repaymentFrequency = [];
  String repaymentDelay = "30 days";
  String fundUsage = "";
  final TextEditingController _controller = TextEditingController();
  double revenue_share_percent = 0;
  double revenueShare = 250000;
  int expectedTransfers = 0;
  int finalExpectedTransfers = 0;
  DateTime expectedCompletion = DateTime.now();
  DateTime finalDate = DateTime.now();
  int selectedOption = 1;
  var repayment_delay_options = [];
  var fund_usage_categories = [];
  // var rows;
  List<DataRow> rows = [];
  String fundDescription = "";
  String fundAmount = "";
  int count = 0;
  List<int> data = [];

  @override
  void initState() {
    super.initState();
    fetchConfig();
    calculateResults();
  }

  Future<void> fetchConfig() async {
    final response = await http.get(Uri.parse(
        'https://gist.githubusercontent.com/motgi/8fc373cbfccee534c820875ba20ae7b5/raw/7143758ff2caa773e651dc3576de57cc829339c0/config.json'));
    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      financingOptionsData = List<Map<String, dynamic>>.from(responseData);
      setState(() {
        _controller.text = '${financingOptionsData[3]['placeholder']}';
        repayment_delay_options =
            '${financingOptionsData[1]['value']}'.split("*");
        fund_usage_categories =
            '${financingOptionsData[6]['value']}'.split("*");
        fundUsage = fund_usage_categories[0];
        repaymentDelay = repayment_delay_options[0];
        repaymentFrequency = '${financingOptionsData[5]['value']}'.split("*");
      });
    } else {
      throw Exception('Failed to load configuration');
    }
  }

  void calculateResults() {
    setState(() {
      DateTime currentDate = DateTime.now();
      revenue_share_percent =
          (0.156 / 6.2055 / annualRevenue) * (loanAmount * 10);
      if (selectedOption == 1) {
        finalExpectedTransfers = (((loanAmount + (loanAmount / 2)) * 12) /
                (annualRevenue * revenue_share_percent))
            .ceil();
        expectedCompletion = DateTime(
          currentDate.year,
          currentDate.month + finalExpectedTransfers,
          currentDate.day,
        );
      } else {
        finalExpectedTransfers = (((loanAmount + (loanAmount / 2)) * 52) /
                (annualRevenue * revenue_share_percent))
            .ceil();
        expectedCompletion =
            currentDate.add(Duration(days: finalExpectedTransfers * 7));
      }
      RegExp regExp = RegExp(r'\d+');
      String? match = regExp.stringMatch(repaymentDelay!)!;
      int daysDelay = int.parse(match);
      finalDate = expectedCompletion.add(Duration(days: daysDelay));
    });
  }

  DataRow createRow(int index) {
    data.add(index);
    return DataRow(cells: [
      DataCell(
        SizedBox(
          width: 150,
          child: Text(
            fundUsage,
            softWrap: true,
            overflow: TextOverflow.clip,
          ),
        ),
      ),
      DataCell(
        SizedBox(
          width: 270,
          child: Text(
            fundDescription,
            softWrap: true,
            overflow: TextOverflow.clip,
          ),
        ),
      ),
      DataCell(
        SizedBox(
          width: 270,
          child: Text(
            fundAmount,
            softWrap: true,
            overflow: TextOverflow.clip,
          ),
        ),
      ),
      DataCell(
        IconButton(
          icon: Icon(Icons.delete, color: Colors.blue),
          onPressed: () => {
            setState(() {
              for (int i = data.length - 1; i >= 0; i--) {
                if (data[i] == index) {
                  rows.removeAt(i);
                  data.removeAt(i);
                }
              }
            })
          },
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: financingOptionsData.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text('Financing Options',
                                      style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 20),
                                  Text('What is your annual business revenue?',
                                      style: TextStyle(fontSize: 17)),
                                  SizedBox(height: 20),
                                  TextField(
                                    controller: _controller,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                    onSubmitted: (value) {
                                      final amount = double.tryParse(value);
                                      if (amount != null && amount > 60000) {
                                        setState(() {
                                          revenueShare =
                                              double.tryParse(value) ?? 0;
                                          annualRevenue = revenueShare;
                                        });
                                      }
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  Text('What is your desired loan amount?',
                                      style: TextStyle(fontSize: 17)),
                                  SizedBox(height: 20),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('\$50,000',
                                            style: TextStyle(fontSize: 17)),
                                        Text(
                                            '\$${(annualRevenue / 3).toStringAsFixed(0)}',
                                            style: TextStyle(fontSize: 17))
                                      ]),
                                  Slider(
                                    min: 50000,
                                    max: annualRevenue / 3,
                                    value: loanAmount,
                                    label: loanAmount.round().toString(),
                                    onChanged: (value) {
                                      setState(() {
                                        loanAmount = value;
                                      });
                                      calculateResults();
                                    },
                                  ),
                                  Text('\$${loanAmount.toStringAsFixed(0)}',
                                      style: TextStyle(fontSize: 17)),
                                  SizedBox(height: 20),
                                  Row(children: [
                                    Text('Revenue Share Percentage ',
                                        style: TextStyle(fontSize: 17)),
                                    Text(
                                        ' ${(revenue_share_percent * 100).toStringAsFixed(2)}%',
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold)),
                                  ]),
                                  SizedBox(height: 20),
                                  Row(
                                    children: <Widget>[
                                      Text('Revenue Shared Frequency',
                                          style: TextStyle(fontSize: 17)),
                                      Radio<int>(
                                        value: 1,
                                        groupValue: selectedOption,
                                        onChanged: (int? value) {
                                          setState(() {
                                            selectedOption = value!;
                                          });
                                          calculateResults();
                                        },
                                      ),
                                      Text(repaymentFrequency[0],
                                          style: TextStyle(fontSize: 17)),
                                      Radio<int>(
                                        value: 2,
                                        groupValue: selectedOption,
                                        onChanged: (int? value) {
                                          setState(() {
                                            selectedOption = value!;
                                          });
                                          calculateResults();
                                        },
                                      ),
                                      Text(repaymentFrequency[1],
                                          style: TextStyle(fontSize: 17)),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Row(children: [
                                    Text('Desired Repayment Delay ',
                                        style: TextStyle(fontSize: 17)),
                                    DropdownButton<String>(
                                      value: repaymentDelay,
                                      items: (repayment_delay_options)
                                          .map<DropdownMenuItem<String>>(
                                              (option) =>
                                                  DropdownMenuItem<String>(
                                                    value: option,
                                                    child: Text('$option'),
                                                  ))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          repaymentDelay = value!;
                                          calculateResults();
                                        });
                                      },
                                    ),
                                  ]),
                                  SizedBox(height: 15),
                                  Text('What will you use the funds for?',
                                      style: TextStyle(fontSize: 17)),
                                  SizedBox(height: 15),
                                  Row(children: [
                                    DropdownButton<String>(
                                      value: fundUsage,
                                      items: (fund_usage_categories)
                                          .map<DropdownMenuItem<String>>(
                                              (category) =>
                                                  DropdownMenuItem<String>(
                                                    value: category,
                                                    child: Text(category),
                                                  ))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          fundUsage = value!;
                                        });
                                      },
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 4,
                                      child: TextField(
                                        decoration: InputDecoration(
                                          labelText: "Description",
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            fundDescription = value;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      flex: 4,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        decoration: InputDecoration(
                                          labelText: "Amount",
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            fundAmount = value;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    IconButton(
                                      icon: Icon(Icons.add, color: Colors.blue),
                                      onPressed: () => {
                                        setState(() {
                                          rows.add(createRow(rows.length));
                                        })
                                      },
                                    ),
                                  ]),
                                  DataTable(
                                    border: null,
                                    columnSpacing: 20.0,
                                    columns: [
                                      DataColumn(
                                        label: SizedBox(
                                          width: 150,
                                        ),
                                      ),
                                      DataColumn(
                                        label: SizedBox(
                                          width: 150,
                                        ),
                                      ),
                                      DataColumn(
                                          label: SizedBox(
                                        width: 150,
                                      )),
                                      DataColumn(
                                          label: SizedBox(
                                        width: 150,
                                      )),
                                    ],
                                    rows: rows,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        elevation: 50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text('Results',
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 20),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Annual Business Revenue ',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        ' \$${revenueShare.toStringAsFixed(0)}',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                  ]),
                              SizedBox(height: 20),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Funding Amount ',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                    Text(' \$${loanAmount.toStringAsFixed(0)}',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                  ]),
                              SizedBox(height: 20),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Fees  ',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        '(50%) \$${(loanAmount / 2).toStringAsFixed(0)}',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                  ]),
                              SizedBox(height: 20),
                              Divider(),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total Revenue Share ',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        ' \$${(loanAmount + (loanAmount / 2)).toStringAsFixed(0)}',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                  ]),
                              SizedBox(height: 20),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Expected Transfers ',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                    Text('$finalExpectedTransfers',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                  ]),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Expected completion date ',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      ' ${DateFormat('MMMM dd, yyyy').format(finalDate)}',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
  }
}
