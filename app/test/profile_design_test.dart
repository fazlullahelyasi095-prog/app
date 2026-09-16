import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tryhub_app/api/api_client.dart';
import 'package:tryhub_app/auth/auth_controller.dart';
import 'package:tryhub_app/core/app_theme.dart';
import 'package:tryhub_app/models/user.dart';
import 'package:tryhub_app/screens/profile/profile_screen.dart';
import 'package:tryhub_app/widgets/app_navigation.dart';
import 'package:tryhub_app/wallet/wallet_screen.dart';

class _ProfileAdapter implements HttpClientAdapter {
  final posts = <Map<String, Object>>[
    {'id': 11, 'caption': 'First post', 'likes': '42', 'comments': 3},
    {'id': 12, 'caption': 'Second post', 'likes': 8, 'comments': 1},
  ];
  final deleted = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancel,
  ) async {
    Object response;
    if (options.method == 'DELETE') {
      deleted.add(options.path);
      posts.removeWhere((post) => options.path == '/videos/${post['id']}');
      response = {'success': true};
    } else if (options.path == '/wallet/me') {
      response = {
        'cash_balance': '12.34',
        'coin_balance': 25,
        'pending_cash_balance': '1.50',
      };
    } else if (options.path == '/transactions/me') {
      response = {
        'data': [],
        'pagination': {'hasNext': false},
      };
    } else if (options.path == '/user/7') {
      response = {
        'user': {
          'id': 7,
          'username': 'creator',
          'followers': 12,
          'following': 4,
        },
        'videos': posts,
      };
    } else {
      response = {
        'isFollowing': false,
        'isBlocked': false,
        'isBlockedBy': false,
      };
    }
    return ResponseBody.fromString(
      jsonEncode(response),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<void> capturePreview(WidgetTester tester, String name) async {
  if (const bool.fromEnvironment('CAPTURE_DESIGN')) {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('design-preview')),
    );
    await tester.runAsync(() async {
      final image = await boundary.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final directory = Directory('../.tools/design-preview')
        ..createSync(recursive: true);
      File(
        '${directory.path}/$name.png',
      ).writeAsBytesSync(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }
}

void main() {
  setUpAll(() async {
    const directory = String.fromEnvironment('DESIGN_FONT_DIR');
    if (directory.isNotEmpty) {
      for (final font in [
        ('Roboto', 'roboto-regular.ttf'),
        ('Ahem', 'roboto-regular.ttf'),
        ('MaterialIcons', 'MaterialIcons-Regular.otf'),
      ]) {
        final loader = FontLoader(font.$1)
          ..addFont(
            File(
              '$directory/${font.$2}',
            ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
          );
        await loader.load();
      }
    }
  });
  late _ProfileAdapter adapter;
  late AuthController auth;
  final api = ApiClient.instance.dio;
  late HttpClientAdapter oldAdapter;
  late List<Interceptor> interceptors;

  setUp(() {
    oldAdapter = api.httpClientAdapter;
    interceptors = api.interceptors.toList();
    api.interceptors.clear();
    adapter = _ProfileAdapter();
    api.httpClientAdapter = adapter;
    auth = AuthController()..user = const User(id: 7, username: 'creator');
  });
  tearDown(() {
    api.httpClientAdapter = oldAdapter;
    api.interceptors.addAll(interceptors);
    ApiClient.instance.onUnauthorized = null;
    auth.dispose();
  });

  Future<void> showProfile(WidgetTester tester, {bool owner = true}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    if (!owner) auth.user = const User(id: 9, username: 'viewer');
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: RepaintBoundary(
          key: const ValueKey('design-preview'),
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const AppNavigation(
              selectedIndex: 4,
              child: ProfileScreen(userId: 7),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await capturePreview(tester, owner ? 'profile' : 'visitor');
  }

  testWidgets(
    'profile totals real post likes and refreshes after confirmed deletion',
    (tester) async {
      await showProfile(tester);
      expect(find.text('50'), findsOneWidget);
      expect(find.text('Likes'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Menu'));
      await tester.pumpAndSettle();
      expect(find.text('Balance'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await capturePreview(tester, 'menu');
      await tester.tap(find.byTooltip('Close menu'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Delete post').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(adapter.deleted, isEmpty);
      expect(find.text('50'), findsOneWidget);

      await tester.tap(find.byTooltip('Delete post').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(adapter.deleted, ['/videos/11']);
      expect(
        find.text('8'),
        findsOneWidget,
        reason: tester
            .widgetList<Text>(find.byType(Text))
            .map((text) => text.data)
            .join(' | '),
      );
      expect(find.text('1 posts'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'empty visitor profile shows zero likes and preserves social controls',
    (tester) async {
      adapter.posts.clear();
      await showProfile(tester, owner: false);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('No posts yet'), findsOneWidget);
      expect(find.text('Follow'), findsOneWidget);
      expect(find.text('Report'), findsOneWidget);
      expect(find.byTooltip('Message'), findsOneWidget);
      expect(find.byTooltip('Delete post'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('balance design keeps server amounts and history pagination', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const RepaintBoundary(
          key: ValueKey('design-preview'),
          child: WalletScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('12.34'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
    expect(find.text('1.50'), findsOneWidget);
    expect(find.text('Page 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await capturePreview(tester, 'balance');
  });
}
