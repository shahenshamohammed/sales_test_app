abstract class SalesReportGroupedEvent {}

class SRGStarted extends SalesReportGroupedEvent {
  final DateTime start;
  final DateTime end;
  SRGStarted(this.start, this.end);
}

class SRGRangeChanged extends SalesReportGroupedEvent {
  final DateTime start;
  final DateTime end;
  SRGRangeChanged(this.start, this.end);
}

class SRGRefreshed extends SalesReportGroupedEvent {}
