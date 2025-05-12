import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:teste_flutter/features/customers/entities/customer.entity.dart';
import 'package:teste_flutter/features/customers/stores/customers.store.dart';
import 'package:teste_flutter/features/tables/stores/table_store.dart';
import 'package:teste_flutter/injection_container.dart';
import 'package:teste_flutter/shared/widgets/modal.widget.dart';
import 'package:teste_flutter/shared/widgets/primary_button.widget.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.tableStore.identification);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersStore = sl<CustomersStore>();

    return Modal(
      title: 'Editar Mesa',
      width: 400,
      contentCrossAxisAlignment: CrossAxisAlignment.start,
      content: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(labelText: 'Identificação da mesa'),
          onChanged: widget.tableStore.setIdentification,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Quantidade de Pessoas'),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (widget.tableStore.customers.isNotEmpty) {
                      widget.tableStore.removeCustomerAt(
                        widget.tableStore.customers.length - 1,
                      );
                    }
                  },
                  icon: const Icon(Icons.remove),
                ),
                Observer(
                  builder: (_) =>
                      Text('${widget.tableStore.customerCount}'),
                ),
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
        const SizedBox(height: 16),
        Observer(
          builder: (_) => Column(
            children: List.generate(widget.tableStore.customers.length, (index) {
              final customer = widget.tableStore.customers[index];

              if (customer.name.isEmpty) {
                return Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<CustomerEntity>(
                        hint: Text('Cliente ${index + 1}'),
                        value: null,
                        items: customersStore.customers.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text('${c.name} (${c.phone})'),
                          );
                        }).toList(),
                        onChanged: (selected) {
                          if (selected != null) {
                            setState(() {
                              widget.tableStore.customers[index] = selected;
                            });
                          }
                        },
                      ),
                    ),
                    IconButton(
                      tooltip: 'Novo cliente',
                      icon: const Icon(Icons.person_add),
                      onPressed: () async {
                        final previousLength = sl<CustomersStore>().customers.length;

                        await showDialog(
                          context: context,
                          builder: (_) => const EditCustomerModal(),
                        );

                        final customers = sl<CustomersStore>().customers;
                        if (customers.length > previousLength) {
                          final newCustomer = customers.last;

                          setState(() {
                            widget.tableStore.customers[index] = newCustomer;
                          });
                        }
                      },
                    )
                  ],
                );
              } else {
                return ListTile(
                  title: Text(customer.name),
                  subtitle: Text(customer.phone),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        widget.tableStore.customers[index] =
                        const CustomerEntity.empty('');
                      });
                    },
                  ),
                );
              }
            }),
          ),
        ),
      ],
      actions: [
        PrimaryButton(
          text: 'Confirmar',
          onPressed: () {
            Navigator.of(context).pop();
            widget.onConfirm();
          },
        ),
      ],
    );
  }
}
