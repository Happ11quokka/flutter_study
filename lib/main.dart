import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_flutter/Screen/sub_screen.dart';
import 'package:study_flutter/provider/counter_provider.dart';
import 'package:study_flutter/provider/theme_provider.dart';
import 'package:study_flutter/provider/user_provider.dart';
import 'Screen/main_screen.dart';
import 'Screen/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CounterProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Flutter Demo',
      theme: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/main': (context) => const MyHomePage(title: 'Provider Counter'),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/sub') {
          if (settings.arguments is String) {
            final msg = settings.arguments as String;
            return MaterialPageRoute(builder: (context) => SubScreen(msg: msg));
          }
        }
        return null;
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final userAge = context.select<UserProvider, int>((user) => user.age);
    final userName = context.select<UserProvider, String>((user) => user.name);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.person), text: 'Profile'),
              Tab(icon: Icon(Icons.settings), text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMainContent(context, userName, userAge),
            const Center(child: Text('프로필 탭')),
            const Center(child: Text('설정 탭')),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.read<CounterProvider>().increment(),
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, String userName, int userAge) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('You have pushed the button this many times:'),
          Consumer<CounterProvider>(
            builder: (context, value, child) => Text(
              '${value.count}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Consumer<ThemeProvider>(
            builder: (context, value, child) => Switch(
              value: value.isDarkMode,
              onChanged: (_) => value.toggleTheme(),
            ),
          ),
          const SizedBox(height: 20),
          Text('Name: $userName'),
          Text('Age: $userAge'),
          ElevatedButton(
            onPressed: () => context.read<UserProvider>().updateName('lim'),
            child: const Text('Update Name'),
          ),
          ElevatedButton(
            onPressed: () => context.read<UserProvider>().updateAge(10),
            child: const Text('Update Age'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/sub', arguments: 'hello');
            },
            child: const Text('서브화면으로 이동'),
          ),
        ],
      ),
    );
  }
}
