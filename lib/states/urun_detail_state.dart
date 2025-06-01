import 'package:equatable/equatable.dart';
import '../models/urun.dart';

enum UrunDetailStatus { initial, loading, success, failure }

class UrunDetailState extends Equatable {
  final Urun urun;
  final int adet;
  final int sepetAdeti;
  final bool isAdding;
  final UrunDetailStatus status;
  final String? errorMessage;

  const UrunDetailState({
    required this.urun,
    this.adet = 1,
    this.sepetAdeti = 0,
    this.isAdding = false,
    this.status = UrunDetailStatus.initial,
    this.errorMessage,
  });

  UrunDetailState copyWith({
    Urun? urun,
    int? adet,
    int? sepetAdeti,
    bool? isAdding,
    UrunDetailStatus? status,
    String? errorMessage,
  }) {
    return UrunDetailState(
      urun: urun ?? this.urun,
      adet: adet ?? this.adet,
      sepetAdeti: sepetAdeti ?? this.sepetAdeti,
      isAdding: isAdding ?? this.isAdding,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        urun,
        adet,
        sepetAdeti,
        isAdding,
        status,
        errorMessage,
      ];
}
