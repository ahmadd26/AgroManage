class Expense {
  final String id;
  String title;
  String category;
  double amount;
  String date;
  String notes;

  Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.notes = '',
  });
}
