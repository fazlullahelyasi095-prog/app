import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tryhub_app/services/social_service.dart';
import 'package:tryhub_app/screens/comments/comments_sheet.dart';
import 'package:tryhub_app/widgets/app_navigation.dart';

class _Adapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  bool liked = false;
  int added = 0;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancel,
  ) async {
    requests.add(options);
    String response;
    if (options.path == '/likes/12' && options.method == 'POST') {
      liked = !liked;
      response = '{"isLiked":$liked}';
    } else if (options.path == '/likes/12/count') {
      response = '{"likes":"${liked ? 1 : 0}"}';
    } else if (options.path == '/likes/12/status') {
      response = '{"isLiked":$liked}';
    } else if (options.method == 'POST') {
      added++;
      response = '{"commentId":$added}';
    } else {
      response =
          '{"comments":[{"id":1,"comment":"Hello","username":"viewer"}]}';
    }
    return ResponseBody.fromString(
      response,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('comments and likes use the current Express API contracts', () async {
    final adapter = _Adapter();
    final api = Dio(BaseOptions(baseUrl: 'http://server.test/api'))
      ..httpClientAdapter = adapter;
    final service = SocialService(api: api);
    expect(await service.likeStatus(12), false);
    expect(await service.toggleLike(12), true);
    expect(await service.likeCount(12), 1);
    expect(await service.toggleLike(12), false);
    expect((await service.comments(12)).single.text, 'Hello');
    expect(await service.addComment(12, ' Hello '), 1);
    expect(adapter.requests.last.data, {'comment': 'Hello'});
    expect(adapter.requests.last.uri.path, '/api/comments/12');
    expect(adapter.requests.first.uri.path, '/api/likes/12/status');
  });

  testWidgets(
    'comment composer fits above keyboard and updates count before dismissal',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final adapter = _Adapter();
      final service = SocialService(api: Dio()..httpClientAdapter = adapter);
      var count = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => CommentsSheet(
                    videoId: 12,
                    service: service,
                    onAdded: () => count++,
                  ),
                ),
                child: const Text('Open comments'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open comments'));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 320);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.getBottomRight(find.byIcon(Icons.send)).dy, lessThan(524));
      await tester.enterText(find.byType(TextField), ' Hello ');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();
      expect(adapter.added, 1);
      expect(count, 1);
      // Count is delivered even if the user later dismisses with the system back button.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(count, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('mobile navigation exposes the same five web destinations', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppNavigation(selectedIndex: 0, child: SizedBox()),
      ),
    );
    for (final label in ['Home', 'Live', 'Upload', 'Inbox', 'Profile']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
