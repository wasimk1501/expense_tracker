import 'package:expense_tracker/components/expense_summary.dart';
import 'package:expense_tracker/components/expense_tile.dart';
import 'package:expense_tracker/data/expense_data.dart';
import 'package:expense_tracker/models/expense_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final addNewExpenseNameController = TextEditingController();
  final addNewExpenseRupeeController = TextEditingController();
  final addNewExpensePaiseController = TextEditingController();

  @override
  void initState() {
    //prepare data on startup
    Provider.of<ExpenseData>(context, listen: false).prepareData();
    super.initState();
  }

  //add new expense
  void addExpense() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add new expense"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          //expense name
          TextField(
            controller: addNewExpenseNameController,
            decoration: InputDecoration(hintText: "Expense Name"),
          ),
          //expense amount
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: addNewExpenseRupeeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: "Rupee"),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: addNewExpensePaiseController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: "Paise"),
                ),
              ),
            ],
          ),
        ]),
        actions: [
          MaterialButton(onPressed: save, child: const Text('Save')),
          MaterialButton(onPressed: cancel, child: const Text('Cancel'))
        ],
      ),
    );
  }

// delete the expense
  void deleteExpense(ExpenseItem expense) {
    Provider.of<ExpenseData>(context, listen: false).deleteExpense(expense);
  }

  void save() {
    //only save data when all fields are filled
    if (addNewExpenseNameController.text.isNotEmpty &&
        addNewExpenseRupeeController.text.isNotEmpty &&
        addNewExpensePaiseController.text.isNotEmpty) {
      String amount =
          "${addNewExpenseRupeeController.text}.${addNewExpensePaiseController.text}";
      //create expense item
      ExpenseItem expenseItem = ExpenseItem(
          name: addNewExpenseNameController.text,
          amount: amount,
          dateTime: DateTime.now());
      //add new expense item
      Provider.of<ExpenseData>(context, listen: false)
          .addNewExpense(expenseItem);
    }
    Navigator.pop(context);
    clear();
  }

  void cancel() {
    Navigator.pop(context);
    clear();
  }

  void clear() {
    addNewExpenseRupeeController.clear();
    addNewExpensePaiseController.clear();
    addNewExpenseNameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseData>(
      builder: (context, value, child) {
        return SafeArea(
          child: Scaffold(
              appBar: AppBar(
                title: const Text("Expense Tracker"),
                backgroundColor: Colors.black,
                centerTitle: true,
              ),
              backgroundColor: Colors.grey[300],
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.black,
                onPressed: addExpense,
                child: const Icon(Icons.add),
              ),
              body: ListView(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  //weekly summary
                  ExpenseSummary(startOfWeek: value.startOfWeekDate()),

                  const SizedBox(
                    height: 20,
                  ),
                  //weekly list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: value.getAllExpenseList().length,
                    itemBuilder: (context, index) => ExpenseTile(
                      name: value.getAllExpenseList()[index].name,
                      amount: value.getAllExpenseList()[index].amount,
                      dateTime: value.getAllExpenseList()[index].dateTime,
                      deleteTapped: (p0) =>
                          deleteExpense(value.getAllExpenseList()[index]),
                    ),
                  ),
                ],
              )),
        );
      },
    );
  }
}
