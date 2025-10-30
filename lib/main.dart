import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as acrylic;
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:google_fonts/google_fonts.dart';
import 'package:mirai_tv/api/anilist.dart';
import 'package:mirai_tv/pages/anime_details.dart';
import 'package:mirai_tv/pages/home.dart';
import 'package:mirai_tv/pages/search.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  // Initialize acrylic (Windows 11-style blur) - Windows only
  if (Platform.isWindows) {
    await acrylic.Window.initialize();
    await acrylic.Window.setEffect(
      effect: acrylic.WindowEffect.mica,
      dark: true,
    );
    doWhenWindowReady(() {
      const initialSize = Size(1200, 720);
      appWindow.minSize = initialSize;
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.title = "MiraiTV";
      appWindow.show();
    });
  }

  final prefs = await SharedPreferences.getInstance();
  final anilistApi = AnilistAPI(prefs);

  runApp(MyApp(anilistApi: anilistApi));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.anilistApi});

  final AnilistAPI anilistApi;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(textTheme: GoogleFonts.interTextTheme()),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0D0D0D),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      themeMode: ThemeMode.dark,
      home: _MainScreen(anilistApi: anilistApi),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _MainScreen extends StatefulWidget {
  const _MainScreen({required this.anilistApi});

  final AnilistAPI anilistApi;

  @override
  State<_MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<_MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  final _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _onTabSelected(int index) {
    if (_currentIndex == index) {
      _navigatorKeys[index].currentState!.popUntil((r) => r.isFirst);
    } else {
      setState(() => _currentIndex = index);
    }
  }

  Future<bool> _onWillPop() async {
    final currentNavigator = _navigatorKeys[_currentIndex].currentState!;
    if (currentNavigator.canPop()) {
      currentNavigator.pop();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            _buildOffstageNavigator(0, HomePage(anilistApi: widget.anilistApi)),
            _buildOffstageNavigator(
              1,
              SearchPage(anilistApi: widget.anilistApi),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF0D0D0D),
          selectedItemColor: Colors.redAccent,
          unselectedItemColor: Colors.grey[600],
          currentIndex: _currentIndex,
          onTap: _onTabSelected,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          ],
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(int index, Widget page) {
    return Offstage(
      offstage: _currentIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            return MaterialPageRoute(builder: (_) => page);
          }

          if (settings.name!.startsWith('/anime/')) {
            final animeId = settings.name!.replaceFirst('/anime/', '');
            return MaterialPageRoute(
              builder: (_) => AnimeDetailPage(
                animeId: int.parse(animeId),
                anilistApi: widget.anilistApi,
              ),
            );
          }

          return null;
        },
      ),
    );
  }
}
