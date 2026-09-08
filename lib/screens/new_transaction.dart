import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:daily_spending/models/transaction.dart';
import 'package:daily_spending/models/categories.dart';

class NewTransaction extends StatefulWidget {
  static const routeName = '/new-transaction';
  @override
  _NewTransactionState createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  final inputTitleController = TextEditingController();
  final inputAmountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  late Transactions transactions;
  String dropdownValue = 'Other';

  void chooseDate() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((value) {
      if (value == null) {
        return;
      }
      setState(() {
        _selectedDate = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    transactions = Provider.of<Transactions>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Add Transaction",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Colors.white10,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            right: 20,
            left: 20,
            top: 30,
            bottom: (MediaQuery.of(context).viewInsets.bottom) + 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Title"),
                //onChanged: (value) => inputTitle = value,
                controller: inputTitleController,
              ),
              SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: "Amount",
                ),
                //onChanged: (value) => inputAmount = value,
                controller: inputAmountController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              dropDownToSelectMonth(context),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  InkWell(
                    onTap: () => chooseDate(),
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        "Choose Date",
                        style: TextStyle(),
                      ),
                    ),
                  ),
                  Text(
                    DateFormat.yMMMd().format(_selectedDate),
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              ElevatedButton(
                child: const Text("Add"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA80852),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  final enteredAmount = int.tryParse(inputAmountController.text);
                  if (inputTitleController.text.trim().isNotEmpty &&
                      enteredAmount != null &&
                      enteredAmount >= 0) {
                    final enteredTitle = inputTitleController.text.trim();

                    transactions.addTransactions(
                      Transaction(
                        id: DateTime.now().toString(),
                        title: enteredTitle,
                        amount: enteredAmount,
                        date: _selectedDate,
                        category: dropdownValue,
                      ),
                    );
                    //Navigator.of(context).pop();
                    inputTitleController.clear();
                    inputAmountController.clear();
                    setState(() {
                      // _selectedDate = DateTime.now();
                      dropdownValue = 'Other';
                    });
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Theme.of(context).primaryColorLight,
                        content: Text(
                          "Data added Succesfully!",
                          style: Theme.of(context).textTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        content: Text(
                          "Fields can't be empty!",
                          style: Theme.of(context).textTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget dropDownToSelectMonth(BuildContext context) {
    return Consumer<Categories>(
      builder: (context, categoryProvider, child) {
        final available = categoryProvider.categories;
        final selected = available.contains(dropdownValue)
            ? dropdownValue
            : (available.isNotEmpty ? available.first : null);

        if (selected != null && selected != dropdownValue) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => dropdownValue = selected);
            }
          });
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Category'),
            if (available.isEmpty)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              DropdownButton<String>(
                value: selected,
                icon: const Icon(Icons.expand_more),
                elevation: 16,
                style: TextStyle(color: Theme.of(context).primaryColorDark),
                underline: Container(
                  height: 2,
                  color: Theme.of(context).primaryColor,
                ),
                onChanged: (String? newValue) {
                  if (newValue == null) return;
                  setState(() => dropdownValue = newValue);
                },
                items: available.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }
}
