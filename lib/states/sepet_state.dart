import 'package:equatable/equatable.dart';
import '../models/urun.dart';

enum SepetStatus { initial, loading, success, failure }

class SepetState extends Equatable {
  final List<Urun> sepetUrunleri;
  final Map<int, int> adetMap;
  final int toplamTutar;
  final SepetStatus status;
  final String? errorMessage;
  final bool isProcessing;

  const SepetState({
    this.sepetUrunleri = const [],
    this.adetMap = const {},
    this.toplamTutar = 0,
    this.status = SepetStatus.initial,
    this.errorMessage,
    this.isProcessing = false,
  });

  SepetState copyWith({
    List<Urun>? sepetUrunleri,
    Map<int, int>? adetMap,
    int? toplamTutar,
    SepetStatus? status,
    String? errorMessage,
    bool? isProcessing,
  }) {
    return SepetState(
      sepetUrunleri: sepetUrunleri ?? this.sepetUrunleri,
      adetMap: adetMap ?? this.adetMap,
      toplamTutar: toplamTutar ?? this.toplamTutar,
      status: status ?? this.status,
      errorMessage: errorMessage,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  @override
  List<Object?> get props => [
        sepetUrunleri,
        adetMap,
        toplamTutar,
        status,
        errorMessage,
        isProcessing,
      ];
}
