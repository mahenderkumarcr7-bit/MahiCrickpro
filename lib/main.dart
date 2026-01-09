import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MahiCrickProApp());

// --- DATA MANAGER ---
class DataManager {
  static List<Map<String, dynamic>> savedTeams = [
    {
      "name": "Mahi XI",
      "players": <String>[],
      "color": 0xFF1E88E5,
      "icon": 0xe532
    },
    {
      "name": "Delhi Lions",
      "players": <String>[],
      "color": 0xFFFFC107,
      "icon": 0xe838
    }
  ];
  static List<Map<String, dynamic>> matchHistory = [];
  static void addMatch(Map<String, dynamic> match) {
    matchHistory.insert(0, match);
  }
}

// --- MAIN APP ---
class MahiCrickProApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mahi Crick Pro',
      theme: ThemeData(
        primaryColor: Color(0xFFD32F2F),
        scaffoldBackgroundColor: Colors.grey[50],
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          bodyMedium: TextStyle(
              fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
          titleLarge: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          filled: true,
          fillColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        )),
      ),
      home: HomeScreen(),
    );
  }
}

// --- HOME SCREEN ---
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [TeamSelectionScreen(), TeamsTab(), HistoryTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFD32F2F),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.sports_cricket), label: "Play"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Teams"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
      ),
    );
  }
}

// --- TAB 1: TEAM SELECTION ---
class TeamSelectionScreen extends StatefulWidget {
  @override
  _TeamSelectionScreenState createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> {
  final teamA = TextEditingController();
  final teamB = TextEditingController();
  List<String> teamAPlayers = [];
  List<String> teamBPlayers = [];

  void _selectSavedTeam(TextEditingController ctrl, bool isTeamA) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (c) => ListView(
              padding: EdgeInsets.all(20),
              children: [
                Text("Select Team",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Divider(),
                ...DataManager.savedTeams
                    .map((t) => ListTile(
                          leading: CircleAvatar(
                              backgroundColor: Color(t['color']),
                              child: Icon(
                                  IconData(t['icon'],
                                      fontFamily: 'MaterialIcons'),
                                  color: Colors.white)),
                          title:
                              Text(t['name'], style: TextStyle(fontSize: 18)),
                          onTap: () {
                            setState(() {
                              ctrl.text = t['name'];
                              if (isTeamA)
                                teamAPlayers = List<String>.from(t['players']);
                              else
                                teamBPlayers = List<String>.from(t['players']);
                            });
                            Navigator.pop(context);
                          },
                        ))
                    .toList()
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Start Match"),
          backgroundColor: Color(0xFFD32F2F),
          automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Select Teams",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () => _selectSavedTeam(teamA, true),
              child: AbsorbPointer(
                  child: TextField(
                      controller: teamA,
                      decoration: InputDecoration(
                          labelText: "Batting Team",
                          suffixIcon: Icon(Icons.arrow_drop_down)))),
            ),
            SizedBox(height: 20),
            CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: Text("VS",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black))),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () => _selectSavedTeam(teamB, false),
              child: AbsorbPointer(
                  child: TextField(
                      controller: teamB,
                      decoration: InputDecoration(
                          labelText: "Bowling Team",
                          suffixIcon: Icon(Icons.arrow_drop_down)))),
            ),
            SizedBox(height: 40),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    onPressed: () {
                      if (teamA.text.isNotEmpty && teamB.text.isNotEmpty)
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (c) => SquadEntryScreen(
                                    tA: teamA.text,
                                    tB: teamB.text,
                                    prefillA: teamAPlayers,
                                    prefillB: teamBPlayers)));
                    },
                    child: Text("Next", style: TextStyle(color: Colors.white))))
          ],
        ),
      ),
    );
  }
}

// --- STEP 3: SQUAD ENTRY ---
class SquadEntryScreen extends StatefulWidget {
  final String tA, tB;
  final List<String> prefillA, prefillB;
  SquadEntryScreen(
      {required this.tA,
      required this.tB,
      required this.prefillA,
      required this.prefillB});
  @override
  _SquadEntryScreenState createState() => _SquadEntryScreenState();
}

class _SquadEntryScreenState extends State<SquadEntryScreen> {
  List<TextEditingController> teamAPlayers =
      List.generate(11, (i) => TextEditingController());
  List<TextEditingController> teamBPlayers =
      List.generate(11, (i) => TextEditingController());

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.prefillA.length && i < 11; i++)
      teamAPlayers[i].text = widget.prefillA[i];
    for (int i = 0; i < widget.prefillB.length && i < 11; i++)
      teamBPlayers[i].text = widget.prefillB[i];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("Playing 11"), backgroundColor: Color(0xFFD32F2F)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _teamHeader(widget.tA, Colors.blue),
            ...List.generate(
                11,
                (i) => Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: TextField(
                        controller: teamAPlayers[i],
                        decoration: InputDecoration(
                            hintText: "Player ${i + 1}", isDense: true)))),
            SizedBox(height: 20),
            _teamHeader(widget.tB, Colors.red),
            ...List.generate(
                11,
                (i) => Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: TextField(
                        controller: teamBPlayers[i],
                        decoration: InputDecoration(
                            hintText: "Player ${i + 1}", isDense: true)))),
            SizedBox(height: 20),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    onPressed: () {
                      List<String> sqA = teamAPlayers
                          .where((c) => c.text.isNotEmpty)
                          .map((c) => c.text)
                          .toList();
                      List<String> sqB = teamBPlayers
                          .where((c) => c.text.isNotEmpty)
                          .map((c) => c.text)
                          .toList();
                      if (sqA.length >= 2 && sqB.length >= 1)
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (c) => MatchSettingsScreen(
                                    tA: widget.tA,
                                    tB: widget.tB,
                                    sqA: sqA,
                                    sqB: sqB)));
                      else
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text("Enter at least 2 Batters & 1 Bowler!")));
                    },
                    child: Text("Next", style: TextStyle(color: Colors.white))))
          ],
        ),
      ),
    );
  }

  Widget _teamHeader(String name, Color c) => Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      color: c.withOpacity(0.1),
      child: Text("$name",
          style:
              TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c)));
}

// --- STEP 4-6: SETTINGS ---
class MatchSettingsScreen extends StatefulWidget {
  final String tA, tB;
  final List<String> sqA, sqB;
  MatchSettingsScreen(
      {required this.tA,
      required this.tB,
      required this.sqA,
      required this.sqB});
  @override
  _MatchSettingsScreenState createState() => _MatchSettingsScreenState();
}

class _MatchSettingsScreenState extends State<MatchSettingsScreen> {
  final oversCtrl = TextEditingController(text: "5");
  String winner = "";
  String decision = "";

  Widget _optionBtn(String txt, bool sel, VoidCallback tap) => Expanded(
      child: GestureDetector(
          onTap: tap,
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                  color: sel ? Colors.green : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sel ? Colors.green : Colors.grey)),
              child: Text(txt,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: sel ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)))));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Match Settings"), backgroundColor: Color(0xFFD32F2F)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
                controller: oversCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Overs", prefixIcon: Icon(Icons.timer))),
            SizedBox(height: 20),
            Text("Who Won Toss?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            SizedBox(height: 10),
            Row(children: [
              _optionBtn(widget.tA, winner == widget.tA,
                  () => setState(() => winner = widget.tA)),
              SizedBox(width: 10),
              _optionBtn(widget.tB, winner == widget.tB,
                  () => setState(() => winner = widget.tB))
            ]),
            SizedBox(height: 20),
            Text("Decision?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            SizedBox(height: 10),
            Row(children: [
              _optionBtn("Batting", decision == "Bat",
                  () => setState(() => decision = "Bat")),
              SizedBox(width: 10),
              _optionBtn("Bowling", decision == "Bowl",
                  () => setState(() => decision = "Bowl"))
            ]),
            SizedBox(height: 30),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    onPressed: () {
                      if (winner != "" && decision != "") {
                        int ov = int.tryParse(oversCtrl.text) ?? 5;
                        String batT = (decision == "Bat")
                            ? winner
                            : (winner == widget.tA ? widget.tB : widget.tA);
                        String bowlT =
                            (batT == widget.tA) ? widget.tB : widget.tA;
                        List<String> batS =
                            (batT == widget.tA) ? widget.sqA : widget.sqB;
                        List<String> bowlS =
                            (bowlT == widget.tA) ? widget.sqA : widget.sqB;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (c) => SelectOpenersScreen(
                                    batTeam: batT,
                                    bowlTeam: bowlT,
                                    batSq: batS,
                                    bowlSq: bowlS,
                                    totalOvers: ov)));
                      }
                    },
                    child: Text("Start Match",
                        style: TextStyle(color: Colors.white))))
          ],
        ),
      ),
    );
  }
}

class SelectOpenersScreen extends StatefulWidget {
  final String batTeam, bowlTeam;
  final List<String> batSq, bowlSq;
  final int totalOvers;
  final int? target;
  final bool isSecondInnings;
  SelectOpenersScreen(
      {required this.batTeam,
      required this.bowlTeam,
      required this.batSq,
      required this.bowlSq,
      required this.totalOvers,
      this.target,
      this.isSecondInnings = false});
  @override
  _SelectOpenersScreenState createState() => _SelectOpenersScreenState();
}

class _SelectOpenersScreenState extends State<SelectOpenersScreen> {
  String? striker, nonStriker, bowler;
  @override
  void initState() {
    striker = widget.batSq.isNotEmpty ? widget.batSq[0] : null;
    nonStriker = widget.batSq.length > 1 ? widget.batSq[1] : null;
    bowler = widget.bowlSq.isNotEmpty ? widget.bowlSq[0] : null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              widget.isSecondInnings ? "Start 2nd Innings" : "Select Openers"),
          backgroundColor: Color(0xFFD32F2F)),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            if (widget.isSecondInnings)
              Text("Target: ${widget.target}",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
            SizedBox(height: 10),
            _dd("Striker", striker, widget.batSq,
                (v) => setState(() => striker = v)),
            SizedBox(height: 15),
            _dd("Non-Striker", nonStriker, widget.batSq,
                (v) => setState(() => nonStriker = v)),
            SizedBox(height: 15),
            _dd("Bowler", bowler, widget.bowlSq,
                (v) => setState(() => bowler = v)),
            Spacer(),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => MainScorerScreen(
                                batTeam: widget.batTeam,
                                bowlTeam: widget.bowlTeam,
                                batSq: widget.batSq,
                                bowlSq: widget.bowlSq,
                                str: striker!,
                                non: nonStriker!,
                                bowl: bowler!,
                                totalOvers: widget.totalOvers,
                                target: widget.target,
                                isSecondInnings: widget.isSecondInnings))),
                    child: Text("Start Scoring",
                        style: TextStyle(color: Colors.white))))
          ],
        ),
      ),
    );
  }

  Widget _dd(String l, String? v, List<String> i, Function(String?) c) =>
      DropdownButtonFormField<String>(
          value: v,
          items:
              i.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: c,
          decoration: InputDecoration(labelText: l));
}

// --- STEP 7: MAIN SCORER (SCROLL FIX APPLIED HERE) ---
class MainScorerScreen extends StatefulWidget {
  final String batTeam, bowlTeam, str, non, bowl;
  final List<String> batSq, bowlSq;
  final int totalOvers;
  final int? target;
  final bool isSecondInnings;
  MainScorerScreen(
      {required this.batTeam,
      required this.bowlTeam,
      required this.batSq,
      required this.bowlSq,
      required this.str,
      required this.non,
      required this.bowl,
      required this.totalOvers,
      this.target,
      this.isSecondInnings = false});
  @override
  _MainScorerScreenState createState() => _MainScorerScreenState();
}

class _MainScorerScreenState extends State<MainScorerScreen> {
  int runs = 0, wickets = 0, balls = 0;
  List<String> thisOver = [];
  late String striker, nonStriker, bowler;
  Map<String, dynamic> batterRuns = {};
  Map<String, dynamic> batterBalls = {};
  Map<String, dynamic> bowlerStats = {};
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    striker = widget.str;
    nonStriker = widget.non;
    bowler = widget.bowl;
    if (!batterRuns.containsKey(striker)) {
      batterRuns[striker] = 0;
      batterBalls[striker] = 0;
    }
    if (!batterRuns.containsKey(nonStriker)) {
      batterRuns[nonStriker] = 0;
      batterBalls[nonStriker] = 0;
    }
    _initBowler(bowler);
    super.initState();
  }

  void _initBowler(String b) {
    if (!bowlerStats.containsKey(b))
      bowlerStats[b] = {'runs': 0, 'balls': 0, 'wickets': 0};
  }

  void saveState() {
    history.add({
      'runs': runs,
      'wickets': wickets,
      'balls': balls,
      'thisOver': List<String>.from(thisOver),
      'striker': striker,
      'nonStriker': nonStriker,
      'bowler': bowler,
      'batterRuns': Map<String, dynamic>.from(batterRuns),
      'batterBalls': Map<String, dynamic>.from(batterBalls)
    });
  }

  void undoLastAction() {
    if (history.isNotEmpty) {
      var last = history.removeLast();
      setState(() {
        runs = last['runs'];
        wickets = last['wickets'];
        balls = last['balls'];
        thisOver = List<String>.from(last['thisOver']);
        striker = last['striker'];
        nonStriker = last['nonStriker'];
        bowler = last['bowler'];
        batterRuns = Map<String, dynamic>.from(last['batterRuns']);
        batterBalls = Map<String, dynamic>.from(last['batterBalls']);
      });
    }
  }

  void addScore(int r,
      {bool isLegal = true, String extraType = "", bool isBye = false}) {
    saveState();
    setState(() {
      runs += r;
      if (!isBye && extraType.isEmpty)
        bowlerStats[bowler]!['runs'] += r;
      else if (extraType.isNotEmpty && !isBye) {
        bowlerStats[bowler]!['runs'] += (1 + r);
        runs += 1;
      }

      if (isLegal) {
        balls++;
        thisOver.add(isBye ? "${extraType}$r" : "$r");
        if (!isBye && extraType.isEmpty) {
          batterRuns[striker] = (batterRuns[striker] ?? 0) + r;
          batterBalls[striker] = (batterBalls[striker] ?? 0) + 1;
        } else if (isBye) {
          batterBalls[striker] = (batterBalls[striker] ?? 0) + 1;
        }
        bowlerStats[bowler]!['balls'] += 1;
      } else {
        thisOver.add(extraType + (r > 0 ? "+$r" : ""));
      }

      if (isLegal && r % 2 != 0) _swapStriker();

      if (widget.isSecondInnings &&
          widget.target != null &&
          runs >= widget.target!) {
        _declareWinner(widget.batTeam);
        return;
      }

      if (balls % 6 == 0 && isLegal) {
        _swapStriker();
        thisOver.clear();
        if (balls ~/ 6 == widget.totalOvers)
          _endInnings();
        else
          Future.delayed(
              Duration(milliseconds: 300), () => showNextBowlerDialog());
      }
    });
  }

  void _swapStriker() {
    setState(() {
      var t = striker;
      striker = nonStriker;
      nonStriker = t;
    });
  }

  void _endInnings() {
    if (widget.isSecondInnings) {
      if (runs < widget.target!)
        _declareWinner(widget.bowlTeam);
      else
        _declareWinner("DRAW");
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => AlertDialog(
                  title: Text("Innings Break"),
                  content: Text("Target: ${runs + 1}"),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => SelectOpenersScreen(
                                      batTeam: widget.bowlTeam,
                                      bowlTeam: widget.batTeam,
                                      batSq: widget.bowlSq,
                                      bowlSq: widget.batSq,
                                      totalOvers: widget.totalOvers,
                                      target: runs + 1,
                                      isSecondInnings: true)));
                        },
                        child: Text("Start 2nd Innings"))
                  ]));
    }
  }

  void _declareWinner(String w) {
    String r = w == "DRAW" ? "Tie" : "$w Won";
    DataManager.addMatch({
      'teamA': widget.batTeam,
      'scoreA': "$runs/$wickets",
      'teamB': widget.bowlTeam,
      'scoreB': "Target: ${widget.target ?? '-'}",
      'winner': r,
      'batters': Map<String, dynamic>.from(batterRuns).map((key, value) =>
          MapEntry(key, {'runs': value, 'balls': batterBalls[key]})),
      'bowlers': Map<String, dynamic>.from(bowlerStats)
    });
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) =>
            AlertDialog(title: Text("MATCH OVER"), content: Text(r), actions: [
              ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (c) => HomeScreen()),
                      (r) => false),
                  child: Text("Home"))
            ]));
  }

  String getBowlerFigures(String b) {
    if (!bowlerStats.containsKey(b)) return "0.0-0-0";
    int bb = bowlerStats[b]!['balls'];
    return "${bb ~/ 6}.${bb % 6}-${bowlerStats[b]!['runs']}-${bowlerStats[b]!['wickets']}";
  }

  void showNextBowlerDialog() {
    showModalBottomSheet(
        context: context,
        isDismissible: false,
        builder: (c) => Container(
            padding: EdgeInsets.all(20),
            height: 400,
            child: Column(children: [
              Text("Next Bowler",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Expanded(
                  child: ListView.builder(
                      itemCount: widget.bowlSq.length,
                      itemBuilder: (c, i) => ListTile(
                          title: Text(widget.bowlSq[i]),
                          onTap: () {
                            if (widget.bowlSq[i] != bowler) {
                              setState(() {
                                bowler = widget.bowlSq[i];
                                _initBowler(bowler);
                              });
                              Navigator.pop(context);
                            }
                          })))
            ])));
  }

  void showExtraMenu(String t) {
    showModalBottomSheet(
        context: context,
        builder: (c) => Container(
            padding: EdgeInsets.all(20),
            height: 300,
            child: Wrap(
                spacing: 10,
                children: [0, 1, 2, 3, 4, 6]
                    .map((e) => ElevatedButton(
                        onPressed: () {
                          addScore(e, isLegal: false, extraType: t);
                          Navigator.pop(context);
                        },
                        child: Text("+$e")))
                    .toList())));
  }

  void showByeMenu(String t) {
    showModalBottomSheet(
        context: context,
        builder: (c) => Container(
            padding: EdgeInsets.all(20),
            height: 300,
            child: Wrap(
                spacing: 10,
                children: [1, 2, 3, 4]
                    .map((e) => ElevatedButton(
                        onPressed: () {
                          addScore(e, isLegal: true, isBye: true, extraType: t);
                          Navigator.pop(context);
                        },
                        child: Text("$e")))
                    .toList())));
  }

  void showCustomRuns() {
    TextEditingController _c = TextEditingController();
    showDialog(
        context: context,
        builder: (c) => AlertDialog(
                title: Text("Custom Runs"),
                content: TextField(
                    controller: _c, keyboardType: TextInputType.number),
                actions: [
                  TextButton(
                      onPressed: () {
                        if (_c.text.isNotEmpty) {
                          addScore(int.parse(_c.text));
                        }
                        Navigator.pop(context);
                      },
                      child: Text("ADD"))
                ]));
  }

  void showScorecardDialog({bool isMatchEnd = false}) {
    showDialog(
        context: context,
        barrierDismissible: !isMatchEnd,
        builder: (context) => AlertDialog(
                title: Text("Scorecard"),
                content: SingleChildScrollView(
                    child: Text(
                        "${widget.batTeam}: $runs/$wickets\n\nBatters: $batterRuns\nBowlers: $bowlerStats")),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Close"))
                ]));
  }

  void showSettingsMenu() {
    showModalBottomSheet(
        context: context,
        builder: (c) => ListView(padding: EdgeInsets.all(20), children: [
              Text("Settings",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Divider(),
              ListTile(
                  leading: Icon(Icons.edit), title: Text("Edit Scorecard")),
              ListTile(leading: Icon(Icons.timer), title: Text("Change Overs")),
              ListTile(
                  leading: Icon(Icons.flag, color: Colors.red),
                  title: Text("End Match"),
                  onTap: () => _declareWinner(widget.bowlTeam))
            ]));
  }

  void copyLink() {
    Clipboard.setData(ClipboardData(text: "https://mahicrickpro.com/live"));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Link Copied!")));
  }

  void triggerWicket() {
    saveState();
    setState(() {
      wickets++;
      balls++;
      thisOver.add("W");
      bowlerStats[bowler]!['wickets'] += 1;
      bowlerStats[bowler]!['balls'] += 1;
    });
    Navigator.pop(context);
    if (wickets == 10) {
      _endInnings();
      return;
    }
    showModalBottomSheet(
        context: context,
        isDismissible: false,
        builder: (context) => Container(
            padding: EdgeInsets.all(20),
            child: Column(children: [
              Text("New Batter",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Expanded(
                  child: ListView(
                      children: widget.batSq
                          .where((p) => p != striker && p != nonStriker)
                          .map((p) => ListTile(
                              title: Text(p),
                              onTap: () {
                                setState(() {
                                  striker = p;
                                  batterRuns[p] = 0;
                                  batterBalls[p] = 0;
                                });
                                Navigator.pop(context);
                              }))
                          .toList()))
            ])));
  }

  void showWicketMenu() {
    showModalBottomSheet(
        context: context,
        builder: (c) => GridView.count(
            crossAxisCount: 3,
            children: ["Bowled", "Caught", "Run Out"]
                .map((t) => InkWell(
                    onTap: triggerWicket,
                    child: Card(child: Center(child: Text(t)))))
                .toList()));
  }

  Color getBallColor(String b) {
    if (b.contains("W") && !b.contains("WD")) return Colors.red;
    if (b == "4") return Colors.green;
    if (b == "6") return Colors.purple;
    if (b.contains("WD") || b.contains("NB")) return Colors.orange;
    if (b == "0") return Colors.grey;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          title: Text(widget.batTeam, style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
                icon: Icon(Icons.bar_chart, color: Colors.white),
                onPressed: () => showScorecardDialog()),
            IconButton(
                icon: Icon(Icons.share, color: Colors.white),
                onPressed: copyLink),
            IconButton(
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: showSettingsMenu)
          ]),
      // --- ADDED SINGLE CHILD SCROLL VIEW TO FIX OVERFLOW ---
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
              padding: EdgeInsets.all(20),
              height: 150,
              width: double.infinity,
              child: Column(children: [
                Expanded(
                    child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text("$runs/$wickets",
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.yellowAccent)))),
                Text(
                    "Over: ${balls ~/ 6}.${balls % 6} | Target: ${widget.target ?? '-'}",
                    style: TextStyle(fontSize: 18, color: Colors.white70))
              ])),
          Container(
              color: Colors.grey[900],
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Row(children: [
                Expanded(
                    child: InkWell(
                        onTap: _swapStriker,
                        child: _playerTile(striker, true))),
                IconButton(
                    icon: Icon(Icons.swap_horiz, color: Colors.tealAccent),
                    onPressed: _swapStriker),
                Expanded(
                    child: InkWell(
                        onTap: _swapStriker,
                        child: _playerTile(nonStriker, false)))
              ])),
          Padding(
              padding: EdgeInsets.all(12),
              child: Row(children: [
                Icon(Icons.sports_baseball, color: Colors.white),
                SizedBox(width: 10),
                Text(bowler,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Spacer(),
                Text(getBowlerFigures(bowler),
                    style: TextStyle(color: Colors.yellow, fontSize: 16))
              ])),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: 50,
              child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: thisOver
                      .map((b) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          width: 38,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: getBallColor(b),
                              border:
                                  Border.all(color: Colors.white, width: 2)),
                          child: Center(
                              child: Text(b,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)))))
                      .toList())),
          SizedBox(height: 10), // Small spacer
          Container(
              color: Colors.white,
              child: Column(children: [
                Row(children: [
                  _key("0", () => addScore(0)),
                  _key("1", () => addScore(1)),
                  _key("2", () => addScore(2)),
                  _key("UNDO", () => undoLastAction(), color: Colors.teal)
                ]),
                Row(children: [
                  _key("3", () => addScore(3)),
                  _key("4", () => addScore(4), color: Colors.teal),
                  _key("6", () => addScore(6), color: Colors.teal),
                  _key("5,7", () => showCustomRuns())
                ]),
                Row(children: [
                  _key("WD", () => showExtraMenu("WD")),
                  _key("NB", () => showExtraMenu("NB")),
                  _key("BYE", () => showByeMenu("BYE")),
                  _key("OUT", showWicketMenu, color: Colors.red)
                ]),
                Row(children: [
                  _key("LB", () => showByeMenu("LB")),
                  Expanded(flex: 3, child: SizedBox(height: 58))
                ]), // Adjusted height
              ]))
        ]),
      ),
    );
  }

  Widget _playerTile(String n, bool s) => Column(children: [
        Text(n,
            style: TextStyle(
                color: s ? Colors.tealAccent : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        Text("${batterRuns[n] ?? 0}(${batterBalls[n] ?? 0})",
            style: TextStyle(color: Colors.grey, fontSize: 16)),
        if (s) Text("🏏", style: TextStyle(fontSize: 14))
      ]);
  // REDUCED BUTTON HEIGHT FROM 75 -> 58
  Widget _key(String t, VoidCallback tap,
          {Color color = Colors.black}) =>
      Expanded(
          child: Container(
              height: 58,
              decoration:
                  BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!, width: 1)),
              child: TextButton(
                  onPressed: tap,
                  child: Text(
                      t,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color)))));
}

// --- TEAMS TAB ---
class TeamsTab extends StatefulWidget {
  @override
  _TeamsTabState createState() => _TeamsTabState();
}

class _TeamsTabState extends State<TeamsTab> {
  TextEditingController _teamCtrl = TextEditingController();
  int _selectedColor = 0xFF1E88E5;
  IconData _selectedIcon = Icons.sports_cricket;
  final List<IconData> _logos = [
    Icons.sports_cricket,
    Icons.shield,
    Icons.star,
    Icons.emoji_events,
    Icons.bolt
  ];
  final List<int> _colors = [0xFF1E88E5, 0xFFD32F2F, 0xFF43A047, 0xFFFFC107];
  void _addTeam() {
    showDialog(
        context: context,
        builder: (c) => StatefulBuilder(
            builder: (dialogContext, setDialogState) => AlertDialog(
                    title: Text("Create Team"),
                    content: SingleChildScrollView(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                      TextField(
                          controller: _teamCtrl,
                          decoration: InputDecoration(hintText: "Name")),
                      SizedBox(height: 15),
                      Wrap(
                          spacing: 15,
                          children: _logos
                              .map((icon) => GestureDetector(
                                  onTap: () => setDialogState(
                                      () => _selectedIcon = icon),
                                  child: Icon(icon,
                                      size: 30,
                                      color: _selectedIcon == icon
                                          ? Colors.black
                                          : Colors.grey)))
                              .toList()),
                      SizedBox(height: 15),
                      Wrap(
                          spacing: 15,
                          children: _colors
                              .map((color) => GestureDetector(
                                  onTap: () => setDialogState(
                                      () => _selectedColor = color),
                                  child: CircleAvatar(
                                      backgroundColor: Color(color),
                                      child: _selectedColor == color
                                          ? Icon(Icons.check,
                                              color: Colors.white)
                                          : null)))
                              .toList())
                    ])),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text("Cancel")),
                      ElevatedButton(
                          onPressed: () {
                            if (_teamCtrl.text.isNotEmpty) {
                              setState(() => DataManager.savedTeams.add({
                                    "name": _teamCtrl.text,
                                    "players": <String>[],
                                    "color": _selectedColor,
                                    "icon": _selectedIcon.codePoint
                                  }));
                              _teamCtrl.clear();
                              Navigator.pop(dialogContext);
                            }
                          },
                          child: Text("Save"))
                    ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            AppBar(title: Text("My Teams"), backgroundColor: Color(0xFFD32F2F)),
        body: ListView.builder(
            itemCount: DataManager.savedTeams.length,
            itemBuilder: (c, i) => ListTile(
                title: Text(DataManager.savedTeams[i]['name']),
                leading: CircleAvatar(
                    backgroundColor: Color(DataManager.savedTeams[i]['color']),
                    child: Icon(
                        IconData(DataManager.savedTeams[i]['icon'],
                            fontFamily: 'MaterialIcons'),
                        color: Colors.white)),
                trailing: Icon(Icons.edit),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (c) => TeamDetailScreen(teamIndex: i))))),
        floatingActionButton:
            FloatingActionButton(onPressed: _addTeam, child: Icon(Icons.add)));
  }
}

class TeamDetailScreen extends StatefulWidget {
  final int teamIndex;
  TeamDetailScreen({required this.teamIndex});
  @override
  _TeamDetailScreenState createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  TextEditingController _pCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var t = DataManager.savedTeams[widget.teamIndex];
    return Scaffold(
        appBar:
            AppBar(title: Text(t['name']), backgroundColor: Color(t['color'])),
        body: Column(children: [
          Padding(
              padding: EdgeInsets.all(10),
              child: Row(children: [
                Expanded(
                    child: TextField(
                        controller: _pCtrl,
                        decoration: InputDecoration(hintText: "Add Player"))),
                IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      if (_pCtrl.text.isNotEmpty)
                        setState(() {
                          t['players'].add(_pCtrl.text);
                          _pCtrl.clear();
                        });
                    })
              ])),
          Expanded(
              child: ListView.builder(
                  itemCount: t['players'].length,
                  itemBuilder: (c, i) => ListTile(
                      title: Text(t['players'][i]),
                      trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () =>
                              setState(() => t['players'].removeAt(i))))))
        ]));
  }
}

// --- HISTORY TAB (DETAILED CLICKABLE SCORECARD) ---
class HistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Match History"),
          backgroundColor: Color(0xFFD32F2F),
          automaticallyImplyLeading: false),
      body: DataManager.matchHistory.isEmpty
          ? Center(child: Text("No matches yet"))
          : ListView.builder(
              itemCount: DataManager.matchHistory.length,
              itemBuilder: (c, i) {
                var m = DataManager.matchHistory[i];
                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 3,
                  child: ListTile(
                    title: Text("${m['winner']}",
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    subtitle: Text(
                        "${m['teamA']} vs ${m['teamB']}\nScore: ${m['scoreA']}"),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Open Detailed Summary
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => MatchDetailScreen(matchData: m)));
                    },
                  ),
                );
              }),
    );
  }
}

// --- NEW MATCH DETAIL SCREEN ---
class MatchDetailScreen extends StatelessWidget {
  final Map<String, dynamic> matchData;
  MatchDetailScreen({required this.matchData});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> batters = matchData['batters'] ?? {};
    Map<String, dynamic> bowlers = matchData['bowlers'] ?? {};

    return Scaffold(
      appBar: AppBar(
          title: Text("Match Summary"), backgroundColor: Color(0xFFD32F2F)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
              child: Column(children: [
            Text(matchData['winner'],
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
            Text("Score: ${matchData['scoreA']}",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          ])),
          Divider(),
          Text("Batting",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue)),
          ...batters.entries
              .map((e) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key),
                        Text("${e.value['runs']}(${e.value['balls']})")
                      ]))
              .toList(),
          Divider(),
          Text("Bowling",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
          ...bowlers.entries
              .map((e) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key),
                        Text(
                            "${e.value['runs']} Runs - ${e.value['wickets']} Wkts")
                      ]))
              .toList(),
        ]),
      ),
    );
  }
}
