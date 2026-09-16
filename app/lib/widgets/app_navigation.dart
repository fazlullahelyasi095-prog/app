import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_controller.dart';
import '../core/app_router.dart';

/// The same five destinations as the mobile web navigation.
class AppNavigation extends StatelessWidget {
  const AppNavigation({
    super.key,
    required this.selectedIndex,
    required this.child,
  });
  final int selectedIndex;
  final Widget child;

  void _open(BuildContext context, int index) {
    if (index == selectedIndex) return;
    final navigator = Navigator.of(context);
    navigator.popUntil((route) => route.isFirst);
    if (index == 0) return;
    final routes = [
      AppRoutes.live,
      AppRoutes.createPost,
      AppRoutes.chat,
      AppRoutes.profile,
    ];
    navigator.pushNamed(
      routes[index - 1],
      arguments: index == 4 ? context.read<AuthController>().user?.id : null,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: child,
    resizeToAvoidBottomInset: false,
    bottomNavigationBar: MediaQuery.viewInsetsOf(context).bottom > 0
        ? null
        : DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.black,
              border: Border(top: BorderSide(color: Color(0xff242424))),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    for (var index = 0; index < 5; index++)
                      Expanded(
                        child: Semantics(
                          selected: selectedIndex == index,
                          child: InkWell(
                            onTap: () => _open(context, index),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (index == 2)
                                  Container(
                                    width: 46,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.black,
                                      size: 27,
                                    ),
                                  )
                                else
                                  Icon(
                                    [
                                      selectedIndex == 0
                                          ? Icons.home_filled
                                          : Icons.home_outlined,
                                      Icons.live_tv,
                                      Icons.add,
                                      Icons.inbox_outlined,
                                      selectedIndex == 4
                                          ? Icons.person
                                          : Icons.person_outline,
                                    ][index],
                                    size: 26,
                                    color: selectedIndex == index
                                        ? Colors.white
                                        : const Color(0xffa9a9b2),
                                  ),
                                const SizedBox(height: 3),
                                Text(
                                  [
                                    'Home',
                                    'Live',
                                    'Upload',
                                    'Inbox',
                                    'Profile',
                                  ][index],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: selectedIndex == index
                                        ? Colors.white
                                        : const Color(0xffa9a9b2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
  );
}
