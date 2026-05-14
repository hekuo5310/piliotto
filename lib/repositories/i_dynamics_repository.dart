import 'package:piliotto/ottohub/models/dynamics/result.dart';
import 'base_repository.dart';

abstract class IDynamicsRepository {
  Future<List<DynamicItemModel>> getUserDynamics({required String userId});
  Future<List<DynamicItemModel>> getMyDynamics();
  Future<Map<String, dynamic>> likeDynamic({required String dynamicId});
  Future<void> deleteDynamic({required String dynamicId});
}
