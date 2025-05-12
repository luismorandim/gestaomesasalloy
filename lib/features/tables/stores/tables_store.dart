import 'package:mobx/mobx.dart';
import 'table_store.dart';

part 'tables_store.g.dart';

class TablesStore = _TablesStoreBase with _$TablesStore;

abstract class _TablesStoreBase with Store {
  @observable
  ObservableList<TableStore> tables = ObservableList<TableStore>();

  @observable
  String search = '';

  @action
  void addTable(TableStore table) {
    tables.add(table);
  }

  @action
  void removeTable(TableStore table) {
    tables.remove(table);
  }

  @action
  void setSearch(String value) {
    search = value.toLowerCase();
  }

  @computed
  int get totalTables => tables.length;

  @computed
  List<TableStore> get filteredTables {
    if (search.isEmpty) return tables;

    return tables.where((table) {
      final idMatch =
      table.identification.toLowerCase().contains(search);
      final customerMatch = table.customers.any((customer) =>
      customer.name.toLowerCase().contains(search) ||
          customer.phone.toLowerCase().contains(search));

      return idMatch || customerMatch;
    }).toList();
  }
}
