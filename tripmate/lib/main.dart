import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────
//  TRIPMATE — explore destinations, save favourites, plan trips,
//  build itineraries, packing lists and track your budget.
//  All data is stored locally on the device.
// ─────────────────────────────────────────────────────────────

const String kCurrency = r'$';

const Color kInk = Color(0xFF0B3C49); // deep sea
const Color kAccent = Color(0xFFF2A33A); // marigold
const Color kSurface = Color(0xFFF4F7F7);
const Color kText = Color(0xFF16262B);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AppStore();
  await store.load();
  runApp(TripmateApp(store: store));
}

// ───────────────────────────── MODELS ─────────────────────────────

class Destination {
  final String id;
  final String name;
  final String country;
  final String category;
  final double rating;
  final int pricePerDay;
  final String bestTime;
  final String description;
  final List<String> highlights;

  const Destination({
    required this.id,
    required this.name,
    required this.country,
    required this.category,
    required this.rating,
    required this.pricePerDay,
    required this.bestTime,
    required this.description,
    required this.highlights,
  });

  String get image => 'assets/images/$id.jpg';
}

const List<String> kCategories = ['All', 'Beach', 'City', 'Culture', 'Adventure'];

const List<Destination> kDestinations = [
  Destination(
    id: 'paris',
    name: 'Paris',
    country: 'France',
    category: 'City',
    rating: 4.8,
    pricePerDay: 180,
    bestTime: 'Apr – Jun, Sep – Oct',
    description:
        'Cafés on every corner, river walks at dusk and some of the world\'s best museums. Paris rewards slow wandering as much as ticking off landmarks.',
    highlights: ['Eiffel Tower', 'Louvre Museum', 'Montmartre', 'Seine river cruise'],
  ),
  Destination(
    id: 'bali',
    name: 'Bali',
    country: 'Indonesia',
    category: 'Beach',
    rating: 4.7,
    pricePerDay: 70,
    bestTime: 'Apr – Oct',
    description:
        'Rice terraces, surf beaches and temples set among jungle. Base yourself in Ubud for culture and head to the coast for sunsets.',
    highlights: ['Tegallalang rice terraces', 'Uluwatu temple', 'Ubud monkey forest', 'Nusa Penida'],
  ),
  Destination(
    id: 'tokyo',
    name: 'Tokyo',
    country: 'Japan',
    category: 'City',
    rating: 4.9,
    pricePerDay: 150,
    bestTime: 'Mar – May, Oct – Nov',
    description:
        'Neon-lit streets next to quiet shrines. Tokyo is fast, spotless and endlessly interesting, with food worth planning a whole day around.',
    highlights: ['Shibuya Crossing', 'Senso-ji temple', 'Tsukiji outer market', 'Meiji Shrine'],
  ),
  Destination(
    id: 'santorini',
    name: 'Santorini',
    country: 'Greece',
    category: 'Beach',
    rating: 4.7,
    pricePerDay: 200,
    bestTime: 'May – Oct',
    description:
        'White-washed villages on the rim of a volcanic caldera. Come for sunsets in Oia and stay for the black-sand beaches and local wine.',
    highlights: ['Oia sunset', 'Red Beach', 'Caldera boat tour', 'Fira old town'],
  ),
  Destination(
    id: 'maldives',
    name: 'Maldives',
    country: 'Maldives',
    category: 'Beach',
    rating: 4.9,
    pricePerDay: 320,
    bestTime: 'Nov – Apr',
    description:
        'Clear lagoons, coral reefs and overwater villas. The place to switch off completely, snorkel with turtles and do very little else.',
    highlights: ['Snorkelling reefs', 'Sandbank picnic', 'Dolphin cruise', 'Overwater villa stay'],
  ),
  Destination(
    id: 'new_york',
    name: 'New York',
    country: 'United States',
    category: 'City',
    rating: 4.6,
    pricePerDay: 250,
    bestTime: 'Apr – Jun, Sep – Nov',
    description:
        'A city that never stops. Walk the High Line, catch a show on Broadway and eat your way across five boroughs.',
    highlights: ['Central Park', 'Brooklyn Bridge', 'Times Square', 'The Met'],
  ),
  Destination(
    id: 'jaipur',
    name: 'Jaipur',
    country: 'India',
    category: 'Culture',
    rating: 4.6,
    pricePerDay: 60,
    bestTime: 'Oct – Mar',
    description:
        'The Pink City is full of forts, palaces and bustling bazaars. Ideal for history, textiles, jewellery and rich Rajasthani food.',
    highlights: ['Amber Fort', 'Hawa Mahal', 'City Palace', 'Johari Bazaar'],
  ),
  Destination(
    id: 'swiss_alps',
    name: 'Swiss Alps',
    country: 'Switzerland',
    category: 'Adventure',
    rating: 4.8,
    pricePerDay: 280,
    bestTime: 'Jun – Sep (hiking), Dec – Mar (ski)',
    description:
        'Snow peaks, glacier lakes and scenic trains. Hike in summer, ski in winter and reward yourself with fondue either way.',
    highlights: ['Jungfraujoch', 'Interlaken', 'Glacier Express', 'Lauterbrunnen valley'],
  ),
  Destination(
    id: 'machu_picchu',
    name: 'Machu Picchu',
    country: 'Peru',
    category: 'Adventure',
    rating: 4.8,
    pricePerDay: 110,
    bestTime: 'May – Sep',
    description:
        'A 15th-century Inca citadel high in the Andes. Trek the Inca Trail or take the train, and arrive early to see the ruins clear of mist.',
    highlights: ['Inca Trail', 'Sun Gate at sunrise', 'Sacred Valley', 'Cusco old town'],
  ),
  Destination(
    id: 'rome',
    name: 'Rome',
    country: 'Italy',
    category: 'Culture',
    rating: 4.7,
    pricePerDay: 160,
    bestTime: 'Apr – Jun, Sep – Oct',
    description:
        'Two thousand years of history on every street. Explore ancient ruins in the morning and spend evenings over pasta in Trastevere.',
    highlights: ['Colosseum', 'Vatican Museums', 'Trevi Fountain', 'Trastevere'],
  ),
];

Destination destById(String id) =>
    kDestinations.firstWhere((d) => d.id == id, orElse: () => kDestinations.first);

class PlanItem {
  int day;
  String title;
  bool done;
  PlanItem({required this.day, required this.title, this.done = false});

  Map<String, dynamic> toJson() => {'day': day, 'title': title, 'done': done};
  factory PlanItem.fromJson(Map<String, dynamic> j) =>
      PlanItem(day: j['day'] as int, title: j['title'] as String, done: j['done'] as bool? ?? false);
}

class PackItem {
  String name;
  bool packed;
  PackItem({required this.name, this.packed = false});

  Map<String, dynamic> toJson() => {'name': name, 'packed': packed};
  factory PackItem.fromJson(Map<String, dynamic> j) =>
      PackItem(name: j['name'] as String, packed: j['packed'] as bool? ?? false);
}

class Expense {
  String title;
  double amount;
  Expense({required this.title, required this.amount});

  Map<String, dynamic> toJson() => {'title': title, 'amount': amount};
  factory Expense.fromJson(Map<String, dynamic> j) =>
      Expense(title: j['title'] as String, amount: (j['amount'] as num).toDouble());
}

class Trip {
  final String id;
  final String destId;
  DateTime start;
  DateTime end;
  double budget;
  List<PlanItem> plan;
  List<PackItem> packing;
  List<Expense> expenses;

  Trip({
    required this.id,
    required this.destId,
    required this.start,
    required this.end,
    required this.budget,
    List<PlanItem>? plan,
    List<PackItem>? packing,
    List<Expense>? expenses,
  })  : plan = plan ?? [],
        packing = packing ?? defaultPacking(),
        expenses = expenses ?? [];

  int get days => end.difference(start).inDays + 1;
  double get spent => expenses.fold(0.0, (s, e) => s + e.amount);

  static List<PackItem> defaultPacking() => [
        'Passport / ID',
        'Tickets & bookings',
        'Phone charger',
        'Toiletries',
        'Clothes',
        'Medicines',
        'Cash & cards',
      ].map((n) => PackItem(name: n)).toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'destId': destId,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'budget': budget,
        'plan': plan.map((e) => e.toJson()).toList(),
        'packing': packing.map((e) => e.toJson()).toList(),
        'expenses': expenses.map((e) => e.toJson()).toList(),
      };

  factory Trip.fromJson(Map<String, dynamic> j) => Trip(
        id: j['id'] as String,
        destId: j['destId'] as String,
        start: DateTime.parse(j['start'] as String),
        end: DateTime.parse(j['end'] as String),
        budget: (j['budget'] as num).toDouble(),
        plan: (j['plan'] as List).map((e) => PlanItem.fromJson(e as Map<String, dynamic>)).toList(),
        packing: (j['packing'] as List).map((e) => PackItem.fromJson(e as Map<String, dynamic>)).toList(),
        expenses: (j['expenses'] as List).map((e) => Expense.fromJson(e as Map<String, dynamic>)).toList(),
      );
}

// ───────────────────────────── STORE ─────────────────────────────

class AppStore extends ChangeNotifier {
  Set<String> favorites = {};
  List<Trip> trips = [];

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      favorites = (prefs.getStringList('favorites') ?? []).toSet();
      final raw = prefs.getString('trips');
      if (raw != null) {
        trips = (jsonDecode(raw) as List).map((e) => Trip.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      favorites = {};
      trips = [];
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', favorites.toList());
    await prefs.setString('trips', jsonEncode(trips.map((t) => t.toJson()).toList()));
  }

  bool isFav(String id) => favorites.contains(id);

  void toggleFav(String id) {
    favorites.contains(id) ? favorites.remove(id) : favorites.add(id);
    changed();
  }

  void addTrip(Trip t) {
    trips.insert(0, t);
    changed();
  }

  void deleteTrip(Trip t) {
    trips.removeWhere((x) => x.id == t.id);
    changed();
  }

  /// Call after mutating anything inside a trip.
  void changed() {
    notifyListeners();
    _save();
  }
}

// ───────────────────────────── HELPERS ─────────────────────────────

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String fmtDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';
String fmtMoney(double v) => '$kCurrency${v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2)}';

class AppImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  const AppImage(this.path, {super.key, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFCFE3E6),
        alignment: Alignment.center,
        child: const Icon(Icons.landscape_rounded, size: 48, color: kInk),
      ),
    );
  }
}

class FieldSpec {
  final String label;
  final TextInputType type;
  const FieldSpec(this.label, [this.type = TextInputType.text]);
}

Future<List<String>?> showFormDialog(BuildContext context, String title, List<FieldSpec> fields,
    {String confirm = 'Add'}) {
  return showDialog<List<String>>(
    context: context,
    builder: (_) => _FormDialog(title: title, fields: fields, confirm: confirm),
  );
}

class _FormDialog extends StatefulWidget {
  final String title;
  final List<FieldSpec> fields;
  final String confirm;
  const _FormDialog({required this.title, required this.fields, required this.confirm});

  @override
  State<_FormDialog> createState() => _FormDialogState();
}

class _FormDialogState extends State<_FormDialog> {
  late final List<TextEditingController> _c =
      List.generate(widget.fields.length, (_) => TextEditingController());

  @override
  void dispose() {
    for (final c in _c) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final values = _c.map((c) => c.text.trim()).toList();
    if (values.any((v) => v.isEmpty)) return;
    Navigator.pop(context, values);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < widget.fields.length; i++)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextField(
                controller: _c[i],
                autofocus: i == 0,
                keyboardType: widget.fields[i].type,
                decoration: InputDecoration(
                  labelText: widget.fields[i].label,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => i == widget.fields.length - 1 ? _submit() : null,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: Text(widget.confirm)),
      ],
    );
  }
}

// ───────────────────────────── APP ─────────────────────────────

class TripmateApp extends StatelessWidget {
  final AppStore store;
  const TripmateApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: kInk, primary: kInk, secondary: kAccent);
    return MaterialApp(
      title: 'Tripmate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: kSurface,
        appBarTheme: const AppBarTheme(
          backgroundColor: kSurface,
          foregroundColor: kText,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: kAccent.withAlpha(90),
        ),
        chipTheme: ChipThemeData(
          selectedColor: kInk,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          side: BorderSide.none,
          backgroundColor: Colors.white,
        ),
      ),
      home: SplashPage(store: store),
    );
  }
}

// ───────────────────────────── SPLASH ─────────────────────────────

class SplashPage extends StatefulWidget {
  final AppStore store;
  const SplashPage({super.key, required this.store});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => LoginPage(store: widget.store),
          transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppImage('assets/images/splash.jpg'),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kInk.withAlpha(120), kInk.withAlpha(230)],
              ),
            ),
          ),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOut,
              builder: (_, v, child) => Opacity(opacity: v, child: child),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore_rounded, size: 72, color: kAccent),
                  SizedBox(height: 12),
                  Text('Tripmate',
                      style: TextStyle(
                          fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
                  SizedBox(height: 6),
                  Text('Plan it. Pack it. Go.', style: TextStyle(fontSize: 16, color: Colors.white70)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── LOGIN ─────────────────────────────

class LoginPage extends StatefulWidget {
  final AppStore store;
  const LoginPage({super.key, required this.store});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeShell(store: widget.store)),
    );
  }

  void _signIn() {
    if (_formKey.currentState!.validate()) _goHome();
  }

  InputDecoration _decoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withAlpha(235),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppImage('assets/images/splash.jpg'),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kInk.withAlpha(120), kInk.withAlpha(230)],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(Icons.explore_rounded, size: 64, color: kAccent),
                          const SizedBox(height: 8),
                          const Text('Tripmate',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 38, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
                          const SizedBox(height: 6),
                          const Text('Sign in to see your trips.',
                              textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: _decoration('Email', Icons.email_outlined),
                            validator: (v) {
                              final s = (v ?? '').trim();
                              if (s.isEmpty) return 'Enter your email.';
                              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)) {
                                return 'Enter a valid email address.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _password,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _signIn(),
                            decoration: _decoration(
                              'Password',
                              Icons.lock_outline,
                              suffix: IconButton(
                                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) {
                              if ((v ?? '').isEmpty) return 'Enter your password.';
                              if (v!.length < 6) return 'Use at least 6 characters.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 22),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: kAccent,
                              foregroundColor: kText,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: _signIn,
                            child: const Text('Sign in', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            style: TextButton.styleFrom(foregroundColor: Colors.white),
                            onPressed: _goHome,
                            child: const Text('Continue as guest'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── HOME SHELL ─────────────────────────────

class HomeShell extends StatefulWidget {
  final AppStore store;
  const HomeShell({super.key, required this.store});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      ExplorePage(store: widget.store),
      SavedPage(store: widget.store),
      TripsPage(store: widget.store),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Saved'),
          NavigationDestination(icon: Icon(Icons.luggage_outlined), selectedIcon: Icon(Icons.luggage), label: 'My trips'),
        ],
      ),
    );
  }
}

// ───────────────────────────── EXPLORE ─────────────────────────────

class ExplorePage extends StatefulWidget {
  final AppStore store;
  const ExplorePage({super.key, required this.store});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String _category = 'All';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final list = kDestinations.where((d) {
      final okCat = _category == 'All' || d.category == _category;
      final q = _query.toLowerCase();
      final okQ = q.isEmpty || d.name.toLowerCase().contains(q) || d.country.toLowerCase().contains(q);
      return okCat && okQ;
    }).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Text('Where to next?',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: kText)),
          const SizedBox(height: 4),
          const Text('Pick a place and turn it into a plan.', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 16),
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search city or country',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final c = kCategories[i];
                final selected = c == _category;
                return ChoiceChip(
                  label: Text(c, style: TextStyle(color: selected ? Colors.white : kText)),
                  selected: selected,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _category = c),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 60),
              child: Center(child: Text('No matches. Try another name or category.')),
            )
          else
            for (final d in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: DestinationCard(d: d, store: widget.store),
              ),
        ],
      ),
    );
  }
}

class DestinationCard extends StatelessWidget {
  final Destination d;
  final AppStore store;
  const DestinationCard({super.key, required this.d, required this.store});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DestinationPage(d: d, store: store)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: 210,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(tag: 'dest-${d.id}', child: AppImage(d.image)),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withAlpha(190)],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: ListenableBuilder(
                  listenable: store,
                  builder: (_, __) => CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(store.isFav(d.id) ? Icons.favorite : Icons.favorite_border,
                          color: store.isFav(d.id) ? Colors.redAccent : kText),
                      onPressed: () => store.toggleFav(d.id),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.name,
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                          Text(d.country, style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(children: [
                          const Icon(Icons.star_rounded, color: kAccent, size: 18),
                          const SizedBox(width: 2),
                          Text('${d.rating}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        ]),
                        Text('from $kCurrency${d.pricePerDay}/day', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── DESTINATION DETAIL ─────────────────────────────

class DestinationPage extends StatelessWidget {
  final Destination d;
  final AppStore store;
  const DestinationPage({super.key, required this.d, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: kInk,
            foregroundColor: Colors.white,
            actions: [
              ListenableBuilder(
                listenable: store,
                builder: (_, __) => IconButton(
                  icon: Icon(store.isFav(d.id) ? Icons.favorite : Icons.favorite_border,
                      color: store.isFav(d.id) ? Colors.redAccent : Colors.white),
                  onPressed: () => store.toggleFav(d.id),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.w800)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(tag: 'dest-${d.id}', child: AppImage(d.image)),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withAlpha(170)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.place, size: 18, color: kInk),
                    const SizedBox(width: 4),
                    Text(d.country, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    const Icon(Icons.star_rounded, color: kAccent),
                    Text(' ${d.rating}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    _InfoTile(icon: Icons.payments_outlined, label: 'Avg. per day', value: '$kCurrency${d.pricePerDay}'),
                    const SizedBox(width: 12),
                    _InfoTile(icon: Icons.wb_sunny_outlined, label: 'Best time', value: d.bestTime),
                  ]),
                  const SizedBox(height: 22),
                  const Text('About', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(d.description, style: const TextStyle(height: 1.5, fontSize: 15)),
                  const SizedBox(height: 22),
                  const Text('Highlights', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  for (final h in d.highlights)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        const Icon(Icons.check_circle, size: 20, color: kInk),
                        const SizedBox(width: 10),
                        Expanded(child: Text(h, style: const TextStyle(fontSize: 15))),
                      ]),
                    ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: kAccent,
              foregroundColor: kText,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.event_available),
            label: const Text('Plan this trip', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (_) => PlanSheet(d: d, store: store),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: kInk),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────── PLAN SHEET ─────────────────────────────

class PlanSheet extends StatefulWidget {
  final Destination d;
  final AppStore store;
  const PlanSheet({super.key, required this.d, required this.store});

  @override
  State<PlanSheet> createState() => _PlanSheetState();
}

class _PlanSheetState extends State<PlanSheet> {
  DateTimeRange? _range;
  late final TextEditingController _budget =
      TextEditingController(text: '${widget.d.pricePerDay * 5}');

  @override
  void dispose() {
    _budget.dispose();
    super.dispose();
  }

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final r = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
      initialDateRange: _range,
    );
    if (r != null) setState(() => _range = r);
  }

  void _create() {
    final budget = double.tryParse(_budget.text.trim());
    if (_range == null || budget == null || budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose your dates and enter a budget.')),
      );
      return;
    }
    widget.store.addTrip(Trip(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      destId: widget.d.id,
      start: _range!.start,
      end: _range!.end,
      budget: budget,
    ));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Trip to ${widget.d.name} added. Find it under My trips.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trip to ${widget.d.name}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickDates,
            icon: const Icon(Icons.date_range),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              alignment: Alignment.centerLeft,
            ),
            label: Text(_range == null
                ? 'Choose dates'
                : '${fmtDate(_range!.start)}  to  ${fmtDate(_range!.end)}'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _budget,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Total budget ($kCurrency)',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            onPressed: _create,
            child: const Text('Create trip'),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── SAVED ─────────────────────────────

class SavedPage extends StatelessWidget {
  final AppStore store;
  const SavedPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: store,
        builder: (_, __) {
          final saved = kDestinations.where((d) => store.isFav(d.id)).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Text('Saved places',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: kText)),
              const SizedBox(height: 16),
              if (saved.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Column(children: [
                    Icon(Icons.favorite_border, size: 64, color: Colors.black26),
                    SizedBox(height: 12),
                    Text('Nothing saved yet.\nTap the heart on any destination to keep it here.',
                        textAlign: TextAlign.center),
                  ]),
                )
              else
                for (final d in saved)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: DestinationCard(d: d, store: store),
                  ),
            ],
          );
        },
      ),
    );
  }
}

// ───────────────────────────── MY TRIPS ─────────────────────────────

class TripsPage extends StatelessWidget {
  final AppStore store;
  const TripsPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: store,
        builder: (_, __) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Text('My trips',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: kText)),
              const SizedBox(height: 16),
              if (store.trips.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Column(children: [
                    Icon(Icons.luggage_outlined, size: 64, color: Colors.black26),
                    SizedBox(height: 12),
                    Text('No trips yet.\nOpen a destination and tap Plan this trip.', textAlign: TextAlign.center),
                  ]),
                )
              else
                for (final t in store.trips)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _TripCard(trip: t, store: store),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Trip trip;
  final AppStore store;
  const _TripCard({required this.trip, required this.store});

  @override
  Widget build(BuildContext context) {
    final d = destById(trip.destId);
    final progress = trip.budget == 0 ? 0.0 : (trip.spent / trip.budget).clamp(0.0, 1.0);
    return Dismissible(
      key: ValueKey(trip.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('Delete trip to ${d.name}?'),
                content: const Text('Its itinerary, packing list and expenses will be removed.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')),
                  FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => store.deleteTrip(trip),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TripDetailPage(trip: trip, store: store)),
        ),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(width: 90, height: 90, child: AppImage(d.image)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text('${fmtDate(trip.start)} to ${fmtDate(trip.end)}',
                        style: const TextStyle(color: Colors.black54, fontSize: 12)),
                    Text('${trip.days} ${trip.days == 1 ? 'day' : 'days'}',
                        style: const TextStyle(color: Colors.black54, fontSize: 12)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(6),
                      color: progress >= 1 ? Colors.redAccent : kInk,
                      backgroundColor: const Color(0xFFE1EAEB),
                    ),
                    const SizedBox(height: 4),
                    Text('${fmtMoney(trip.spent)} of ${fmtMoney(trip.budget)} spent',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── TRIP DETAIL ─────────────────────────────

class TripDetailPage extends StatelessWidget {
  final Trip trip;
  final AppStore store;
  const TripDetailPage({super.key, required this.trip, required this.store});

  @override
  Widget build(BuildContext context) {
    final d = destById(trip.destId);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${d.name} trip', style: const TextStyle(fontWeight: FontWeight.w800)),
          bottom: const TabBar(
            indicatorColor: kAccent,
            labelColor: kInk,
            tabs: [
              Tab(icon: Icon(Icons.map_outlined), text: 'Itinerary'),
              Tab(icon: Icon(Icons.checklist), text: 'Packing'),
              Tab(icon: Icon(Icons.account_balance_wallet_outlined), text: 'Budget'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ItineraryTab(trip: trip, store: store),
            _PackingTab(trip: trip, store: store),
            _BudgetTab(trip: trip, store: store),
          ],
        ),
      ),
    );
  }
}

// ── Itinerary ──

class _ItineraryTab extends StatelessWidget {
  final Trip trip;
  final AppStore store;
  const _ItineraryTab({required this.trip, required this.store});

  Future<void> _add(BuildContext context) async {
    final v = await showFormDialog(
      context,
      'Add activity',
      [
        FieldSpec('Day (1 to ${trip.days})', TextInputType.number),
        const FieldSpec('What are you doing?'),
      ],
    );
    if (v == null) return;
    final day = int.tryParse(v[0]);
    if (day == null || day < 1 || day > trip.days) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Day must be between 1 and ${trip.days}.')),
        );
      }
      return;
    }
    trip.plan.add(PlanItem(day: day, title: v[1]));
    trip.plan.sort((a, b) => a.day.compareTo(b.day));
    store.changed();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (_, __) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: kAccent,
            foregroundColor: kText,
            onPressed: () => _add(context),
            icon: const Icon(Icons.add),
            label: const Text('Add activity'),
          ),
          body: trip.plan.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No activities yet.\nAdd what you want to do each day.', textAlign: TextAlign.center),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: trip.plan.length,
                  itemBuilder: (_, i) {
                    final item = trip.plan[i];
                    final showHeader = i == 0 || trip.plan[i - 1].day != item.day;
                    final date = trip.start.add(Duration(days: item.day - 1));
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader)
                          Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 6),
                            child: Text('Day ${item.day}  ·  ${fmtDate(date)}',
                                style: const TextStyle(fontWeight: FontWeight.w800, color: kInk)),
                          ),
                        Card(
                          margin: const EdgeInsets.only(bottom: 6),
                          elevation: 0,
                          color: Colors.white,
                          child: CheckboxListTile(
                            value: item.done,
                            onChanged: (v) {
                              item.done = v ?? false;
                              store.changed();
                            },
                            title: Text(item.title,
                                style: TextStyle(decoration: item.done ? TextDecoration.lineThrough : null)),
                            secondary: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                trip.plan.remove(item);
                                store.changed();
                              },
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                      ],
                    );
                  },
                ),
        );
      },
    );
  }
}

// ── Packing ──

class _PackingTab extends StatelessWidget {
  final Trip trip;
  final AppStore store;
  const _PackingTab({required this.trip, required this.store});

  Future<void> _add(BuildContext context) async {
    final v = await showFormDialog(context, 'Add item', [const FieldSpec('Item')]);
    if (v == null) return;
    trip.packing.add(PackItem(name: v[0]));
    store.changed();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (_, __) {
        final packed = trip.packing.where((p) => p.packed).length;
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: kAccent,
            foregroundColor: kText,
            onPressed: () => _add(context),
            icon: const Icon(Icons.add),
            label: const Text('Add item'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              Text('$packed of ${trip.packing.length} packed',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: trip.packing.isEmpty ? 0 : packed / trip.packing.length,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
                color: kInk,
                backgroundColor: const Color(0xFFE1EAEB),
              ),
              const SizedBox(height: 12),
              for (final item in List<PackItem>.from(trip.packing))
                Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  elevation: 0,
                  color: Colors.white,
                  child: CheckboxListTile(
                    value: item.packed,
                    onChanged: (v) {
                      item.packed = v ?? false;
                      store.changed();
                    },
                    title: Text(item.name,
                        style: TextStyle(decoration: item.packed ? TextDecoration.lineThrough : null)),
                    secondary: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        trip.packing.remove(item);
                        store.changed();
                      },
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── Budget ──

class _BudgetTab extends StatelessWidget {
  final Trip trip;
  final AppStore store;
  const _BudgetTab({required this.trip, required this.store});

  Future<void> _add(BuildContext context) async {
    final v = await showFormDialog(
      context,
      'Add expense',
      [const FieldSpec('What was it for?'), FieldSpec('Amount ($kCurrency)', const TextInputType.numberWithOptions(decimal: true))],
    );
    if (v == null) return;
    final amount = double.tryParse(v[1]);
    if (amount == null || amount <= 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount.')));
      }
      return;
    }
    trip.expenses.insert(0, Expense(title: v[0], amount: amount));
    store.changed();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (_, __) {
        final remaining = trip.budget - trip.spent;
        final over = remaining < 0;
        final progress = trip.budget == 0 ? 0.0 : (trip.spent / trip.budget).clamp(0.0, 1.0);
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: kAccent,
            foregroundColor: kText,
            onPressed: () => _add(context),
            icon: const Icon(Icons.add),
            label: const Text('Add expense'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: kInk, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(over ? 'Over budget by' : 'Left to spend',
                        style: const TextStyle(color: Colors.white70)),
                    Text(fmtMoney(remaining.abs()),
                        style: TextStyle(
                            color: over ? Colors.redAccent.shade100 : Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(8),
                      color: over ? Colors.redAccent : kAccent,
                      backgroundColor: Colors.white24,
                    ),
                    const SizedBox(height: 8),
                    Text('${fmtMoney(trip.spent)} spent of ${fmtMoney(trip.budget)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (trip.expenses.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No expenses logged yet.', textAlign: TextAlign.center),
                )
              else
                for (final e in List<Expense>.from(trip.expenses))
                  Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    elevation: 0,
                    color: Colors.white,
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE1EAEB),
                        child: Icon(Icons.receipt_long, color: kInk),
                      ),
                      title: Text(e.title),
                      subtitle: Text(fmtMoney(e.amount)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          trip.expenses.remove(e);
                          store.changed();
                        },
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}