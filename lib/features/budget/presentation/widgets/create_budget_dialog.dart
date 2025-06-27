import 'package:flutter/material.dart';
import '../../domain/usecases/create_budget_usecase.dart';
import '../../domain/entities/budget_entity.dart';

class CreateBudgetDialog extends StatelessWidget {
  final BudgetEntity? budget;
  final Function(CreateBudgetParams) onBudgetCreated;

  const CreateBudgetDialog({
    Key? key,
    this.budget,
    required this.onBudgetCreated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(budget != null ? 'Bütçeyi Düzenle' : 'Yeni Bütçe'),
      content: const Text('Bütçe oluşturma özelliği yakında gelecek!'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kapat'),
        ),
      ],
    );
  }
}