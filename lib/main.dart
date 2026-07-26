import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'models/company.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SrjTechApp());
}

class SrjTechApp extends StatefulWidget {
  const SrjTechApp({super.key});

  @override
  State<SrjTechApp> createState() => _SrjTechAppState();
}

class _SrjTechAppState extends State<SrjTechApp> {
  final _api = ApiService();
  late final Future<Company> _companyFuture = _api.fetchCompany();
  late final _router = createRouter(
    api: _api,
    companyFuture: _companyFuture,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SRJ Tech',
      debugShowCheckedModeBanner: false,
      theme: buildSrjTheme(),
      routerConfig: _router,
    );
  }
}
