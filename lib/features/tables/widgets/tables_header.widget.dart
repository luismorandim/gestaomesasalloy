import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:teste_flutter/features/tables/widgets/customers_counter.widget.dart';
import 'package:teste_flutter/features/tables/widgets/table_modal.widget.dart';
import 'package:teste_flutter/shared/widgets/search_input.widget.dart';
import 'package:teste_flutter/utils/extension_methos/material_extensions_methods.dart';
import 'package:teste_flutter/injection_container.dart';

import '../stores/table_store.dart';
import '../stores/tables_store.dart';

class TablesHeader extends StatelessWidget {
  const TablesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final tablesStore = sl<TablesStore>();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Row(
          children: [
            Text(
              'Mesas',
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(width: 20),
            SearchInput(
              onChanged: (value) {
                sl<TablesStore>().setSearch(value!);
              },
            ),
            const SizedBox(width: 20),
            Observer(
              builder: (_) {
                final totalCustomers = tablesStore.tables
                    .fold(0, (sum, table) => sum + table.customers.length);
                return CustomersCounter(label: '$totalCustomers');
              },
            ),
            const SizedBox(width: 20),
            FloatingActionButton(
              onPressed: () {
                final newTable = TableStore(
                  id: DateTime.now().millisecondsSinceEpoch,
                  identification: 'Mesa ${tablesStore.tables.length + 1}',
                  customers: [],
                );

                showDialog(
                  context: context,
                  builder: (_) => TableModalWidget(
                    tableStore: newTable,
                    onConfirm: () {
                      tablesStore.addTable(newTable);
                    },
                  ),
                );
              },
              tooltip: 'Criar nova mesa',
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
