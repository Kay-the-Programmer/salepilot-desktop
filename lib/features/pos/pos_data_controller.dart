import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../data/models/customer.dart';
import '../../data/models/product.dart';
import '../../data/models/store_settings.dart';

class PosDataState {
  const PosDataState({
    this.loading = true,
    this.error,
    this.products = const [],
    this.customers = const [],
    this.settings,
  });

  final bool loading;
  final String? error;
  final List<Product> products;
  final List<Customer> customers;
  final StoreSettings? settings;
}

class PosDataController extends StateNotifier<PosDataState> {
  PosDataController(this.ref) : super(const PosDataState());

  final Ref ref;

  Future<void> initialize() async {
    state = const PosDataState(loading: true);
    final productsRepo = ref.read(productsRepositoryProvider);
    final customersRepo = ref.read(customersRepositoryProvider);
    final settingsRepo = ref.read(settingsRepositoryProvider);

    // Start watching local DB immediately.
    productsRepo.watchActive().listen((products) {
      state = PosDataState(
        loading: false,
        products: products,
        customers: state.customers,
        settings: state.settings,
        error: state.error,
      );
    });
    customersRepo.watchAll().listen((customers) {
      state = PosDataState(
        loading: state.loading,
        products: state.products,
        customers: customers,
        settings: state.settings,
        error: state.error,
      );
    });

    // Pull from server (best-effort — if offline, we run on cached data).
    try {
      final results = await Future.wait([
        productsRepo.pullFromServer(),
        customersRepo.pullFromServer().catchError((_) => 0),
        settingsRepo.pullFromServer(),
      ]);
      final settings = results[2] as StoreSettings;
      state = PosDataState(
        loading: false,
        products: state.products,
        customers: state.customers,
        settings: settings,
      );
    } catch (e) {
      // Load cached settings even on failure
      final settings = await settingsRepo.load();
      state = PosDataState(
        loading: false,
        products: state.products,
        customers: state.customers,
        settings: settings,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    final productsRepo = ref.read(productsRepositoryProvider);
    final customersRepo = ref.read(customersRepositoryProvider);
    final settingsRepo = ref.read(settingsRepositoryProvider);
    try {
      await productsRepo.pullFromServer();
      await customersRepo.pullFromServer().catchError((_) => 0);
      final settings = await settingsRepo.pullFromServer();
      state = PosDataState(
        loading: false,
        products: state.products,
        customers: state.customers,
        settings: settings,
      );
    } catch (e) {
      state = PosDataState(
        loading: false,
        products: state.products,
        customers: state.customers,
        settings: state.settings,
        error: e.toString(),
      );
    }
  }
}

final StateNotifierProvider<PosDataController, PosDataState> posDataProvider =
    StateNotifierProvider<PosDataController, PosDataState>((ref) {
  return PosDataController(ref);
});
