import 'package:flutter/material.dart';

void main() {
  runApp(const BudgetApp());
}

class BudgetApp extends StatelessWidget {
  const BudgetApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Presupuesto(),
    );
  }
}

class Presupuesto extends StatefulWidget {
  const Presupuesto({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BudgetHomePageState createState() => _BudgetHomePageState();
}

class _BudgetHomePageState extends State<Presupuesto> {
  List<Transaction> transactions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presupuesto App'),
      ),
      body: Column(
        children: [
          // Widget para agregar nuevas transacciones
          TransactionForm(onSubmit: _addTransaction),
          // Lista de transacciones
          TransactionList(transactions: transactions),
        ],
      ),
    );
  }

  // Función para agregar una nueva transacción
  void _addTransaction(String title, double amount) {
    setState(() {
      transactions.add(Transaction(title: title, amount: amount));
    });
  }
}

class TransactionForm extends StatefulWidget {
  final Function(String, double) onSubmit;

  const TransactionForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Concepto'),
              ),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  final title = _titleController.text;
                  final amount = double.tryParse(_amountController.text) ?? 0.0;
                  widget.onSubmit(title, amount);

                  _titleController.clear();
                  _amountController.clear();
                },
                child: const Text('Agregar Transacción'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionList({Key? key, required this.transactions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              leading: const Icon(Icons.attach_money),
              title: Text(transactions[index].title),
              subtitle:
                  Text('\$${transactions[index].amount.toStringAsFixed(2)}'),
            ),
          );
        },
      ),
    );
  }
}

class Transaction {
  final String title;
  final double amount;

  Transaction({required this.title, required this.amount});
}
