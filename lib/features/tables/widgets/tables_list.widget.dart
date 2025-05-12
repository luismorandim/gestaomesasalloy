import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:teste_flutter/features/tables/widgets/table_card.widget.dart';
import 'package:teste_flutter/injection_container.dart';
import '../stores/tables_store.dart';

class TablesList extends StatelessWidget {
  const TablesList({super.key});

  @override
  Widget build(BuildContext context) {
    final tablesStore = sl<TablesStore>();

    return Observer(
      builder: (_) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: tablesStore.filteredTables
              .map(
                (tableStore) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TableCard(tableStore: tableStore),
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}
