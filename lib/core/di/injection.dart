import 'package:ez/core/ApiClient/ApiService.dart';
import 'package:ez/repositories/http_workflow_repository.dart';
import 'package:ez/repositories/workflow_repository.dart';

import 'package:ez/features/workflowinitiate/repository/repo_impl.dart';
import 'package:ez/features/workflowinitiate/repository/repository.dart';
import 'package:ez/features/workflowinitiate/viewmodel/viewmodel.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

final sl = GetIt.asNewInstance();

setupLazySingleton() {
  GetIt.instance.registerLazySingleton<WorkflowRepository>(() => HttpWorkflowRepository());

  //Workflow Component
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<FileManager>(() => FileManager(sl()));
  sl.registerLazySingleton<ApiManager>(() => ApiManager(sl()));
  sl.registerLazySingleton<WorkflowInitiateRepo>(() => WorkflowInitiateRepoImpl(sl()));
  sl.registerLazySingleton<WorkflowInitiateViewModel>(() => WorkflowInitiateViewModel(sl()));
}
