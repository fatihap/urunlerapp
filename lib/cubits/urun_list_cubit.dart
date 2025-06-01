import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/urun.dart';
import '../services/urun_service.dart';
import '../states/urun_list_state.dart';

class UrunListCubit extends Cubit<UrunListState> {
  final UrunService _urunService;

  UrunListCubit({UrunService? urunService})
      : _urunService = urunService ?? UrunService(),
        super(const UrunListState());

  Future<void> fetchUrunler() async {
    emit(state.copyWith(status: UrunListStatus.loading));
    
    try {
      final urunler = await _urunService.urunleriGetir();
      emit(state.copyWith(
        urunler: urunler,
        status: UrunListStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UrunListStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(arama: query));
  }

  void updateSelectedCategory(String category) {
    emit(state.copyWith(seciliKategori: category));
  }
}
