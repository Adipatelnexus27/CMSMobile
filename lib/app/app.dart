import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../core/storage/session_storage.dart';
import '../core/theme/app_theme.dart';
import '../core/navigation/app_router.dart';
import '../core/navigation/main_navigation.dart';
import '../features/assigned_claims/data/datasources/assigned_claims_remote_data_source.dart';
import '../features/assigned_claims/data/repositories/assigned_claims_repository_impl.dart';
import '../features/assigned_claims/domain/usecases/get_assigned_claims_usecase.dart';
import '../features/assigned_claims/presentation/bloc/assigned_claims_bloc.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/restore_session_usecase.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/documents/data/datasources/document_remote_data_source.dart';
import '../features/documents/data/repositories/document_repository_impl.dart';
import '../features/documents/domain/usecases/get_claim_documents_usecase.dart';
import '../features/documents/domain/usecases/upload_document_usecase.dart';
import '../features/documents/presentation/bloc/document_bloc.dart';
import '../features/investigation/data/datasources/investigation_remote_data_source.dart';
import '../features/investigation/data/repositories/investigation_repository_impl.dart';
import '../features/investigation/domain/usecases/add_investigation_note_usecase.dart';
import '../features/investigation/domain/usecases/get_investigation_usecase.dart';
import '../features/investigation/domain/usecases/update_investigation_progress_usecase.dart';
import '../features/investigation/domain/usecases/upload_investigation_document_usecase.dart';
import '../features/investigation/presentation/bloc/investigation_bloc.dart';

class CmsApp extends StatelessWidget {
  const CmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient(baseUrl: ApiConfig.baseApiUrl);
    final sessionStorage = SessionStorage();

    final authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSource(apiClient),
      sessionStorage: sessionStorage,
    );

    final assignedClaimsRepository = AssignedClaimsRepositoryImpl(
      AssignedClaimsRemoteDataSource(apiClient),
    );

    final investigationRepository = InvestigationRepositoryImpl(
      InvestigationRemoteDataSource(apiClient),
    );

    final documentRepository = DocumentRepositoryImpl(
      DocumentRemoteDataSource(apiClient),
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => LoginUseCase(authRepository)),
        RepositoryProvider(create: (_) => RestoreSessionUseCase(authRepository)),
        RepositoryProvider(create: (_) => LogoutUseCase(authRepository)),
        RepositoryProvider(create: (_) => GetAssignedClaimsUseCase(assignedClaimsRepository)),
        RepositoryProvider(create: (_) => GetInvestigationUseCase(investigationRepository)),
        RepositoryProvider(create: (_) => UpdateInvestigationProgressUseCase(investigationRepository)),
        RepositoryProvider(create: (_) => AddInvestigationNoteUseCase(investigationRepository)),
        RepositoryProvider(create: (_) => UploadInvestigationDocumentUseCase(investigationRepository)),
        RepositoryProvider(create: (_) => GetClaimDocumentsUseCase(documentRepository)),
        RepositoryProvider(create: (_) => UploadDocumentUseCase(documentRepository)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              loginUseCase: context.read<LoginUseCase>(),
              restoreSessionUseCase: context.read<RestoreSessionUseCase>(),
              logoutUseCase: context.read<LogoutUseCase>(),
            )..add(const AuthAppStarted()),
          ),
          BlocProvider(
            create: (context) => AssignedClaimsBloc(
              context.read<GetAssignedClaimsUseCase>(),
            ),
          ),
          BlocProvider(
            create: (context) => InvestigationBloc(
              getInvestigationUseCase: context.read<GetInvestigationUseCase>(),
              updateProgressUseCase: context.read<UpdateInvestigationProgressUseCase>(),
              addNoteUseCase: context.read<AddInvestigationNoteUseCase>(),
              uploadDocumentUseCase: context.read<UploadInvestigationDocumentUseCase>(),
            ),
          ),
          BlocProvider(
            create: (context) => DocumentBloc(
              getClaimDocumentsUseCase: context.read<GetClaimDocumentsUseCase>(),
              uploadDocumentUseCase: context.read<UploadDocumentUseCase>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'CMS Mobile',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: const _AuthGate(),
          onGenerateRoute: AppRouter.generateRoute,
          routes: AppRouter.routes,
        ),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.authenticated:
            return const MainNavigationPage();
          case AuthStatus.unauthenticated:
          case AuthStatus.failure:
            return const LoginPage();
          case AuthStatus.unknown:
          case AuthStatus.loading:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
        }
      },
    );
  }
}
