import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:teste_flutter/features/customers/entities/customer.entity.dart';
import 'package:teste_flutter/features/customers/stores/customers.store.dart';
import 'package:teste_flutter/features/tables/stores/table_store.dart';
import 'package:teste_flutter/injection_container.dart';
import 'package:teste_flutter/shared/widgets/modal.widget.dart';
import 'package:teste_flutter/shared/widgets/primary_button.widget.dart';
import 'package:teste_flutter/shared/widgets/secondary_button.widget.dart';
import '../../customers/widgets/edit_customer_modal.widget.dart';

class TableModalWidget extends StatefulWidget {
  final TableStore tableStore;
  final VoidCallback onConfirm;

  const TableModalWidget({
    super.key,
    required this.tableStore,
    required this.onConfirm,
  });

  @override
  State<TableModalWidget> createState() => _TableModalWidgetState();
}

class _TableModalWidgetState extends State<TableModalWidget> {
  late final TextEditingController _controller;
  final customersStore = sl<CustomersStore>();
  final TextEditingController _searchController = TextEditingController();
  List<CustomerEntity> filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.tableStore.identification);
    filteredCustomers = customersStore.customers;
  }

  void handleSearch(String query) {
    final lower = query.toLowerCase();
    setState(() {
      filteredCustomers = customersStore.customers.where((c) {
        return c.name.toLowerCase().contains(lower) ||
            c.phone.toLowerCase().contains(lower);
      }).toList();
    });
  }

  void handleAddCustomer(int index) async {
    final before = customersStore.customers.length;

    await showDialog(
      context: context,
      builder: (_) => const EditCustomerModal(),
    );

    if (customersStore.customers.length > before) {
      final newCustomer = customersStore.customers.last;
      setState(() {
        widget.tableStore.customers[index] = newCustomer;
      });
    }
  }

  void openCustomerSelectionDialog(int index) {
    _searchController.clear();
    handleSearch('');

    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Pesquise por nome ou telefone',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: handleSearch,
                ),
              ),
              const Divider(height: 1),
              SizedBox(
                height: 300,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_add, color: Colors.green),
                      title: const Text('Novo cliente'),
                      onTap: () {
                        Navigator.of(context).pop();
                        handleAddCustomer(index);
                      },
                    ),
                    ...filteredCustomers.map((c) => ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(c.name),
                      subtitle: Text(c.phone),
                      onTap: () {
                        setState(() {
                          widget.tableStore.customers[index] = c;
                        });
                        Navigator.of(context).pop();
                      },
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Modal(
      title: 'Editar informações da ${widget.tableStore.identification}',
      width: 400,
      contentCrossAxisAlignment: CrossAxisAlignment.start,
      content: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Identificação da mesa'),
              onChanged: widget.tableStore.setIdentification,
            ),
            const SizedBox(height: 4),
            Text(
              'Informação temporária para ajudar na identificação do cliente.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            const Text('Clientes nesta conta'),
            const SizedBox(height: 4),
            Text(
              'Associe os clientes aos pedidos para salvar o pedido no histórico do cliente, pontuar na fidelidade e fazer pagamentos no fiado.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quantidade de pessoas'),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (widget.tableStore.customers.isNotEmpty) {
                          widget.tableStore.removeCustomerAt(widget.tableStore.customers.length - 1);
                        }
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    Observer(builder: (_) => Text('${widget.tableStore.customerCount}')),
                    IconButton(
                      onPressed: () {
                        widget.tableStore.addCustomer(const CustomerEntity.empty(''));
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Observer(
              builder: (_) => Column(
                children: List.generate(widget.tableStore.customers.length, (index) {
                  final customer = widget.tableStore.customers[index];

                  if (customer.name.isEmpty) {
                    return ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('[Nome]', style: TextStyle(color: Colors.grey)),
                      subtitle: const Text('[telefone]', style: TextStyle(color: Colors.grey)),
                      trailing: const Icon(Icons.search),
                      onTap: () => openCustomerSelectionDialog(index),
                    );
                  } else {
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(customer.name),
                      subtitle: Text(customer.phone),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            widget.tableStore.customers[index] = const CustomerEntity.empty('');
                          });
                        },
                      ),
                    );
                  }
                }),
              ),
            ),
          ],
        )
      ],
      actions: [
        SecondaryButton(
          text: 'Voltar',
          onPressed: () => Navigator.of(context).pop(),
        ),
        PrimaryButton(
          text: 'Salvar',
          onPressed: () {
            Navigator.of(context).pop();
            widget.onConfirm();
          },
        ),
      ],
    );
  }
}
