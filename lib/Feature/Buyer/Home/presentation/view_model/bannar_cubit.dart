import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../../Product/Data/Models/ProductModel.dart';
import '../../Data/repo/BannerRepository.dart';
part 'bannar_state.dart';

class BannerCubit extends Cubit<BannerState> {
  final BannerRepository repo;
  BannerCubit({required this.repo}) : super(const BannerInitial());

  Future<void> loadBanners() async {
    try {
      emit(const BannerLoading());
      final model = await repo.fetchHomeBanners();
      emit(BannerLoaded(
        banners: model.banners,
        tawqalProducts: model.tawqalProducts,
        suggestedProducts: model.suggestedProducts,
      ));
    } catch (e) {
      emit(BannerError(e.toString()));
    }
  }
}
