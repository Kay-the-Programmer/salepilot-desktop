import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/db/app_database.dart';
import 'data/repositories/categories_repository.dart';
import 'data/repositories/customers_repository.dart';
import 'data/repositories/products_repository.dart';
import 'data/repositories/returns_repository.dart';
import 'data/repositories/sales_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/stock_take_repository.dart';
import 'data/services/ai_service.dart';
import 'data/sync/sync_engine.dart';
import 'features/auth/auth_controller.dart';

final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final Provider<ProductsRepository> productsRepositoryProvider =
    Provider<ProductsRepository>((ref) {
  return ProductsRepository(
    api: ref.watch(apiClientProvider),
    db: ref.watch(appDatabaseProvider),
  );
});

final Provider<CustomersRepository> customersRepositoryProvider =
    Provider<CustomersRepository>((ref) {
  return CustomersRepository(
    api: ref.watch(apiClientProvider),
    db: ref.watch(appDatabaseProvider),
  );
});

final Provider<CategoriesRepository> categoriesRepositoryProvider =
    Provider<CategoriesRepository>((ref) {
  return CategoriesRepository(
    api: ref.watch(apiClientProvider),
    db: ref.watch(appDatabaseProvider),
  );
});

final Provider<AiService> aiServiceProvider = Provider<AiService>((ref) {
  return AiService(api: ref.watch(apiClientProvider));
});

final Provider<StockTakeRepository> stockTakeRepositoryProvider =
    Provider<StockTakeRepository>((ref) {
  return StockTakeRepository(
    db: ref.watch(appDatabaseProvider),
    products: ref.watch(productsRepositoryProvider),
  );
});

final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>((ref) {
  return SettingsRepository(
    api: ref.watch(apiClientProvider),
    db: ref.watch(appDatabaseProvider),
  );
});

final Provider<SalesRepository> salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepository(
    api: ref.watch(apiClientProvider),
    db: ref.watch(appDatabaseProvider),
    products: ref.watch(productsRepositoryProvider),
  );
});

final Provider<ReturnsRepository> returnsRepositoryProvider = Provider<ReturnsRepository>((ref) {
  return ReturnsRepository(
    api: ref.watch(apiClientProvider),
    db: ref.watch(appDatabaseProvider),
    products: ref.watch(productsRepositoryProvider),
  );
});

final Provider<SyncEngine> syncEngineProvider = Provider<SyncEngine>((ref) {
  final engine = SyncEngine(
    db: ref.watch(appDatabaseProvider),
    sales: ref.watch(salesRepositoryProvider),
  );
  ref.onDispose(engine.dispose);
  return engine;
});

final StreamProvider<SyncStatus> syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.status;
});
