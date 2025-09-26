import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum TransactionType { income, expense }
enum ExpenseCategory { food, transport, shopping, accommodation, entertainment, other }

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final List<Transaction> _transactions = [];
  final DateFormat _dateFormatter = DateFormat('MM/dd HH:mm');
  final NumberFormat _currencyFormatter = NumberFormat.currency(symbol: '₩', decimalDigits: 0);

  double get _totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get _totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get _balance => _totalIncome - _totalExpense;

  void _addTransaction(Transaction transaction) {
    setState(() {
      _transactions.insert(0, transaction);
    });
  }

  void _updateTransaction(int index, Transaction newTransaction) {
    setState(() {
      _transactions[index] = newTransaction;
    });
  }

  void _deleteTransaction(int index) {
    setState(() {
      _transactions.removeAt(index);
    });
  }

  void _showTransactionSheet({Transaction? transaction, int? index}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => TransactionFormSheet(
        transaction: transaction,
        onSave: (newTransaction) {
          if (transaction == null) {
            _addTransaction(newTransaction);
          } else {
            _updateTransaction(index!, newTransaction);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('旅行記帳'),
        backgroundColor: Colors.blue.shade50,
      ),
      body: Column(
        children: [
          // 總覽卡片
          Container(
            margin: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      '餘額',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currencyFormatter.format(_balance),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: _balance >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '收入',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              _currencyFormatter.format(_totalIncome),
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 30,
                          width: 1,
                          color: Colors.grey.shade300,
                        ),
                        Column(
                          children: [
                            Text(
                              '支出',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              _currencyFormatter.format(_totalExpense),
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 交易列表
          Expanded(
            child: _transactions.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('尚無記錄，點擊下方按鈕開始記帳'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (ctx, index) {
                      final transaction = _transactions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: transaction.type == TransactionType.income
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            child: Icon(
                              _getCategoryIcon(transaction.category),
                              color: transaction.type == TransactionType.income
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          title: Text(transaction.description),
                          subtitle: Text(
                            '${_getCategoryName(transaction.category)} • ${_dateFormatter.format(transaction.date)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${transaction.type == TransactionType.income ? '+' : '-'}${_currencyFormatter.format(transaction.amount)}',
                                style: TextStyle(
                                  color: transaction.type == TransactionType.income
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => _deleteTransaction(index),
                              ),
                            ],
                          ),
                          onTap: () => _showTransactionSheet(transaction: transaction, index: index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionSheet(),
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getCategoryIcon(ExpenseCategory? category) {
    switch (category) {
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.transport:
        return Icons.directions_bus;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.accommodation:
        return Icons.hotel;
      case ExpenseCategory.entertainment:
        return Icons.movie;
      case ExpenseCategory.other:
      case null:
        return Icons.payment;
    }
  }

  String _getCategoryName(ExpenseCategory? category) {
    switch (category) {
      case ExpenseCategory.food:
        return '餐飲';
      case ExpenseCategory.transport:
        return '交通';
      case ExpenseCategory.shopping:
        return '購物';
      case ExpenseCategory.accommodation:
        return '住宿';
      case ExpenseCategory.entertainment:
        return '娛樂';
      case ExpenseCategory.other:
      case null:
        return '其他';
    }
  }
}

class TransactionFormSheet extends StatefulWidget {
  final Transaction? transaction;
  final Function(Transaction) onSave;

  const TransactionFormSheet({
    super.key,
    this.transaction,
    required this.onSave,
  });

  @override
  State<TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  TransactionType _type = TransactionType.expense;
  ExpenseCategory _category = ExpenseCategory.food;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _type = widget.transaction!.type;
      _category = widget.transaction!.category ?? ExpenseCategory.other;
      _selectedDate = widget.transaction!.date;
      _amountController.text = widget.transaction!.amount.toString();
      _descriptionController.text = widget.transaction!.description;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final transaction = Transaction(
        type: _type,
        amount: double.parse(_amountController.text),
        description: _descriptionController.text,
        category: _type == TransactionType.expense ? _category : null,
        date: _selectedDate,
      );
      
      widget.onSave(transaction);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.transaction == null ? '新增記錄' : '編輯記錄',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
                // 收入/支出選擇
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('支出'),
                      icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('收入'),
                      icon: Icon(Icons.add_circle_outline, color: Colors.green),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (values) {
                    setState(() {
                      _type = values.first;
                    });
                  },
                ),
                const SizedBox(height: 20),
                
                // 金額輸入
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: '金額',
                    prefixText: '₩ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '請輸入金額';
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return '請輸入有效金額';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // 描述輸入
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: '描述',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '請輸入描述';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // 類別選擇（只在支出時顯示）
                if (_type == TransactionType.expense)
                  DropdownButtonFormField<ExpenseCategory>(
                    value: _category,
                    decoration: const InputDecoration(
                      labelText: '類別',
                      border: OutlineInputBorder(),
                    ),
                    items: ExpenseCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Icon(_getCategoryIcon(category)),
                            const SizedBox(width: 8),
                            Text(_getCategoryName(category)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _category = value!;
                      });
                    },
                  ),
                if (_type == TransactionType.expense) const SizedBox(height: 16),
                
                // 日期時間選擇
                OutlinedButton.icon(
                  onPressed: _selectDateTime,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(DateFormat('yyyy/MM/dd HH:mm').format(_selectedDate)),
                ),
                const SizedBox(height: 24),
                
                // 保存按鈕
                ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(widget.transaction == null ? '新增' : '更新'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.transport:
        return Icons.directions_bus;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.accommodation:
        return Icons.hotel;
      case ExpenseCategory.entertainment:
        return Icons.movie;
      case ExpenseCategory.other:
        return Icons.payment;
    }
  }

  String _getCategoryName(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return '餐飲';
      case ExpenseCategory.transport:
        return '交通';
      case ExpenseCategory.shopping:
        return '購物';
      case ExpenseCategory.accommodation:
        return '住宿';
      case ExpenseCategory.entertainment:
        return '娛樂';
      case ExpenseCategory.other:
        return '其他';
    }
  }
}

class Transaction {
  final TransactionType type;
  final double amount;
  final String description;
  final ExpenseCategory? category;
  final DateTime date;

  Transaction({
    required this.type,
    required this.amount,
    required this.description,
    this.category,
    required this.date,
  });
}