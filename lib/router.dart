import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'data/models.dart';
import 'state/session.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/register_screen.dart';
import 'ui/screens/cameras/add_camera_screen.dart';
import 'ui/screens/cameras/camera_detail_screen.dart';
import 'ui/screens/cameras/cameras_screen.dart';
import 'ui/screens/cameras/edit_camera_screen.dart';
import 'ui/screens/events/event_detail_screen.dart';
import 'ui/screens/events/events_screen.dart';
import 'ui/screens/home_shell.dart';
import 'ui/screens/overview/overview_screen.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/team/change_password_screen.dart';
import 'ui/screens/team/team_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();

GoRouter buildRouter(Session session) => GoRouter(
      navigatorKey: _rootKey,
      initialLocation: '/overview',
      refreshListenable: session,
      redirect: (context, state) {
        final loc = state.matchedLocation;
        final onAuth = loc == '/login' || loc == '/register';
        switch (session.status) {
          case SessionStatus.unknown:
            return loc == '/splash' ? null : '/splash';
          case SessionStatus.signedOut:
            return onAuth ? null : '/login';
          case SessionStatus.signedIn:
            if (onAuth || loc == '/splash') return '/overview';
            if (loc.startsWith('/team') && !session.can(Permissions.usersRead)) return '/overview';
            if (loc == '/cameras/new' && !session.can(Permissions.camerasWrite)) return '/cameras';
            return null;
        }
      },
      routes: [
        GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
        GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
        StatefulShellRoute.indexedStack(
          builder: (_, _, shell) => HomeShell(shell: shell),
          branches: [
            StatefulShellBranch(routes: [GoRoute(path: '/overview', builder: (_, _) => const OverviewScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/cameras', builder: (_, _) => const CamerasScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/events', builder: (_, _) => const EventsScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/team', builder: (_, _) => const TeamScreen())]),
          ],
        ),
        // Вложенные экраны — поверх вкладок, без нижней навигации.
        // `/cameras/new` раньше `/cameras/:id`, иначе «new» примется за id.
        GoRoute(path: '/cameras/new', parentNavigatorKey: _rootKey, builder: (_, _) => const AddCameraScreen()),
        GoRoute(
          path: '/cameras/:id/edit',
          parentNavigatorKey: _rootKey,
          builder: (_, s) => EditCameraScreen(cameraId: int.tryParse(s.pathParameters['id']!) ?? -1),
        ),
        GoRoute(path: '/password', parentNavigatorKey: _rootKey, builder: (_, _) => const ChangePasswordScreen()),
        GoRoute(
          path: '/cameras/:id',
          parentNavigatorKey: _rootKey,
          builder: (_, s) => CameraDetailScreen(cameraId: int.tryParse(s.pathParameters['id']!) ?? -1),
        ),
        GoRoute(
          path: '/events/:id',
          parentNavigatorKey: _rootKey,
          builder: (_, s) => EventDetailScreen(eventId: s.pathParameters['id']!),
        ),
      ],
    );
