import '../../../data/models/invoice_form.dart';


abstract class InvoiceEvent {}

class InvoiceStarted extends InvoiceEvent {}

class InvoiceCustomerSelected extends InvoiceEvent {
  final String customerId;
  final String customerName;
  final String customerAddress;
  InvoiceCustomerSelected(this.customerId, this.customerName, this.customerAddress);
}

class InvoiceDateChanged extends InvoiceEvent {
  final DateTime date;
  InvoiceDateChanged(this.date);
}

class InvoiceItemAdded extends InvoiceEvent {
  final LineItem item;
  InvoiceItemAdded(this.item);
}

class InvoiceItemUpdated extends InvoiceEvent {
  final int index;
  final LineItem item;
  InvoiceItemUpdated(this.index, this.item);
}

class InvoiceItemRemoved extends InvoiceEvent {
  final int index;
  InvoiceItemRemoved(this.index);
}

class InvoiceSubmitted extends InvoiceEvent {}
