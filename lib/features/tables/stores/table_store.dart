import 'package:mobx/mobx.dart';
import 'package:teste_flutter/features/customers/entities/customer.entity.dart';

part 'table_store.g.dart';

class TableStore = _TableStoreBase with _$TableStore;

abstract class _TableStoreBase with Store {
  final int id;

  _TableStoreBase({required this.id, required String identification, List<CustomerEntity>? customers}) {
    this.identification = identification;
    this.customers = ObservableList.of(customers ?? []);
  }

  @observable
  String identification = '';

  @observable
  ObservableList<CustomerEntity> customers = ObservableList<CustomerEntity>();

  @action
  void setIdentification(String value) {
    identification = value;
  }

  @action
  void addCustomer(CustomerEntity customer) {
    customers.add(customer);
  }

  @action
  void removeCustomerAt(int index) {
    customers.removeAt(index);
  }

  @computed
  int get customerCount => customers.length;
}
