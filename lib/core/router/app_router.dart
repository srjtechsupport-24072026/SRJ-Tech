import 'package:go_router/go_router.dart';

import '../../models/company.dart';
import '../../pages/about_page.dart';
import '../../pages/contact_page.dart';
import '../../pages/home_page.dart';
import '../../pages/services_page.dart';
import '../../services/api_service.dart';
import '../../widgets/site_shell.dart';

GoRouter createRouter({
  required ApiService api,
  required Future<Company> companyFuture,
}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return SiteShell(
            companyFuture: companyFuture,
            currentPath: state.uri.path,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: HomePage(api: api),
            ),
          ),
          GoRoute(
            path: '/about',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: AboutPage(api: api),
            ),
          ),
          GoRoute(
            path: '/services',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: ServicesPage(api: api),
            ),
          ),
          GoRoute(
            path: '/contact',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: ContactPage(api: api),
            ),
          ),
        ],
      ),
    ],
  );
}
