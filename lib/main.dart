import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iOS Menu Free Fire - Full ESP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const IOSMenuOverlayScreen(),
    );
  }
}

enum TargetPart { head, neck, chest }
enum LineOrigin { bottom, center, top }

class SimulatedPlayer {
  String name;
  String weapon;
  double distance; // in meters
  Offset position; // Center position on screen
  Offset velocity;
  double hp; // 0.0 to 1.0
  double height;
  double width;

  SimulatedPlayer({
    required this.name,
    required this.weapon,
    required this.distance,
    required this.position,
    required this.velocity,
    required this.hp,
    this.height = 130.0,
    this.width = 55.0,
  });

  void update(Size bounds) {
    position += velocity;
    // Bounce off screen edges
    if (position.dx - width / 2 < 40 || position.dx + width / 2 > bounds.width - 40) {
      velocity = Offset(-velocity.dx, velocity.dy);
    }
    if (position.dy - height / 2 < 80 || position.dy + height / 2 > bounds.height - 100) {
      velocity = Offset(velocity.dx, -velocity.dy);
    }
  }

  Rect get box => Rect.fromCenter(center: position, width: width, height: height);
  Offset get head => Offset(position.dx, position.dy - height * 0.4);
  Offset get neck => Offset(position.dx, position.dy - height * 0.3);
  Offset get chest => Offset(position.dx, position.dy - height * 0.1);
  Offset get pelvis => Offset(position.dx, position.dy + height * 0.1);
  Offset get leftShoulder => Offset(position.dx - width * 0.45, position.dy - height * 0.28);
  Offset get rightShoulder => Offset(position.dx + width * 0.45, position.dy - height * 0.28);
  Offset get leftElbow => Offset(position.dx - width * 0.55, position.dy - height * 0.05);
  Offset get rightElbow => Offset(position.dx + width * 0.55, position.dy - height * 0.05);
  Offset get leftHand => Offset(position.dx - width * 0.45, position.dy + height * 0.15);
  Offset get rightHand => Offset(position.dx + width * 0.45, position.dy + height * 0.15);
  Offset get leftKnee => Offset(position.dx - width * 0.3, position.dy + height * 0.3);
  Offset get rightKnee => Offset(position.dx + width * 0.3, position.dy + height * 0.3);
  Offset get leftFoot => Offset(position.dx - width * 0.35, position.dy + height * 0.48);
  Offset get rightFoot => Offset(position.dx + width * 0.35, position.dy + height * 0.48);
}

class IOSMenuOverlayScreen extends StatefulWidget {
  const IOSMenuOverlayScreen({super.key});

  @override
  State<IOSMenuOverlayScreen> createState() => _IOSMenuOverlayScreenState();
}

class _IOSMenuOverlayScreenState extends State<IOSMenuOverlayScreen> with SingleTickerProviderStateMixin {
  // Menu Visibility & Position
  bool isMenuVisible = true;
  Offset menuPosition = const Offset(30, 70);
  Offset floatingIconPosition = const Offset(20, 180);

  // Menu Settings (matching user image + full ESP options)
  bool aimbotEnabled = true;
  TargetPart targetPart = TargetPart.head;
  double aimRadius = 66.47;
  bool espLineEnabled = true;
  bool espBoxEnabled = true;
  bool espHpEnabled = true;
  bool espNameEnabled = true;
  bool espSkeletonEnabled = true;
  bool espDistanceEnabled = true;
  bool animateTargets = true;
  bool showMemoryTestLog = true;
  LineOrigin lineOrigin = LineOrigin.bottom;


  // Simulated targets list
  late List<SimulatedPlayer> players;
  Timer? _simulationTimer;

  @override
  void initState() {
    super.initState();
    _initPlayers();
    _startAnimationLoop();
  }

  void _initPlayers() {
    players = [
      SimulatedPlayer(
        name: "Player_FF_VN",
        weapon: "AK47",
        distance: 14.5,
        position: const Offset(550, 260),
        velocity: const Offset(1.2, 0.8),
        hp: 0.88,
        height: 140,
        width: 60,
      ),
      SimulatedPlayer(
        name: "Pro_Sniper99",
        weapon: "AWM",
        distance: 38.2,
        position: const Offset(780, 320),
        velocity: const Offset(-1.0, 0.5),
        hp: 0.45,
        height: 110,
        width: 48,
      ),
      SimulatedPlayer(
        name: "Bot_Enemy_03",
        weapon: "MP40",
        distance: 62.0,
        position: const Offset(380, 420),
        velocity: const Offset(0.8, -1.1),
        hp: 0.95,
        height: 90,
        width: 40,
      ),
    ];
  }

  void _startAnimationLoop() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      if (animateTargets && mounted) {
        final size = MediaQuery.of(context).size;
        setState(() {
          for (var p in players) {
            p.update(size.width > 0 ? size : const Size(1000, 600));
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F18),
      body: Stack(
        children: [
          // 1. Background Interactive ESP Game View Simulation
          Positioned.fill(
            child: CustomPaint(
              painter: GameSimulationPainter(
                players: players,
                aimbotEnabled: aimbotEnabled,
                targetPart: targetPart,
                aimRadius: aimRadius,
                espLineEnabled: espLineEnabled,
                espBoxEnabled: espBoxEnabled,
                espHpEnabled: espHpEnabled,
                espNameEnabled: espNameEnabled,
                espSkeletonEnabled: espSkeletonEnabled,
                espDistanceEnabled: espDistanceEnabled,
                lineOrigin: lineOrigin,
              ),
            ),
          ),

          // Top Info Status Banner
          Positioned(
            top: 40,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xB3000000),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00FF00), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00FF00),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "iOS ESP & Aimbot Overlay • Simulated 60 FPS",
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // 2. Floating Icon (FF Badge)
          Positioned(
            left: floatingIconPosition.dx,
            top: floatingIconPosition.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  floatingIconPosition += details.delta;
                });
              },
              onTap: () {
                setState(() {
                  isMenuVisible = !isMenuVisible;
                });
              },
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0000),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x99000000),
                      blurRadius: 12,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Center(
                  child: isMenuVisible
                      ? const Icon(Icons.close, color: Colors.white, size: 28)
                      : const Text(
                          "FF",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            letterSpacing: 1.0,
                          ),
                        ),
                ),
              ),
            ),
          ),

          // 3. iOS Floating Menu Container (Exact Pixel Replica of Screenshot)
          if (isMenuVisible)
            Positioned(
              left: menuPosition.dx,
              top: menuPosition.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    menuPosition += details.delta;
                  });
                },
                child: Material(
                  elevation: 16,
                  color: Colors.transparent,
                  child: Container(
                    width: 290,
                    constraints: BoxConstraints(
                      maxHeight: screenSize.height - 100,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0000FF), // Pure Vibrant Blue
                      borderRadius: BorderRadius.circular(0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xB3000000),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // --- HEADER BAR (RED) ---
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            color: const Color(0xFFFF0000), // Bright red header
                            child: const Center(
                              child: Text(
                                "FREE FIRE",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.5,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ),

                          _buildDivider(),

                          // 1. AIMBOT
                          _buildToggleItem(
                            title: "AIMBOT",
                            value: aimbotEnabled,
                            onTap: () {
                              setState(() {
                                aimbotEnabled = !aimbotEnabled;
                              });
                            },
                          ),
                          _buildDivider(),

                          // 2. ĐẦU
                          _buildToggleItem(
                            title: "ĐẦU",
                            value: targetPart == TargetPart.head,
                            onTap: () {
                              setState(() {
                                targetPart = TargetPart.head;
                              });
                            },
                          ),
                          _buildDivider(),

                          // 3. CỔ
                          _buildToggleItem(
                            title: "CỔ",
                            value: targetPart == TargetPart.neck,
                            onTap: () {
                              setState(() {
                                targetPart = TargetPart.neck;
                              });
                            },
                          ),
                          _buildDivider(),

                          // 4. AIM RADIUS SLIDER ROW
                          Container(
                            width: double.infinity,
                            color: const Color(0xFF0000FF),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            child: Column(
                              children: [
                                Text(
                                  "AIM RADIUS ${aimRadius.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    // Minus (-) Button
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          aimRadius = (aimRadius - 1.0).clamp(0.0, 250.0);
                                        });
                                      },
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        color: const Color(0xFFFF0000),
                                        child: const Center(
                                          child: Text(
                                            "-",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),

                                    // White Slider Track + Green Thumb
                                    Expanded(
                                      child: SliderTheme(
                                        data: const SliderThemeData(
                                          trackHeight: 3.0,
                                          activeTrackColor: Colors.white,
                                          inactiveTrackColor: Colors.white,
                                          thumbColor: Color(0xFF00FF00),
                                          thumbShape: RoundSliderThumbShape(
                                            enabledThumbRadius: 11.0,
                                          ),
                                          overlayColor: Color(0x3300FF00),
                                        ),
                                        child: Slider(
                                          value: aimRadius,
                                          min: 0.0,
                                          max: 250.0,
                                          onChanged: (val) {
                                            setState(() {
                                              aimRadius = val;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),

                                    // Plus (+) Button
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          aimRadius = (aimRadius + 1.0).clamp(0.0, 250.0);
                                        });
                                      },
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        color: const Color(0xFFFF0000),
                                        child: const Center(
                                          child: Text(
                                            "+",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _buildDivider(),

                          // 5. ESP LINE
                          _buildToggleItem(
                            title: "ESP LINE",
                            value: espLineEnabled,
                            onTap: () {
                              setState(() {
                                espLineEnabled = !espLineEnabled;
                              });
                            },
                          ),
                          _buildDivider(),

                          // 6. ESP Box
                          _buildToggleItem(
                            title: "ESP Box",
                            value: espBoxEnabled,
                            onTap: () {
                              setState(() {
                                espBoxEnabled = !espBoxEnabled;
                              });
                            },
                          ),
                          _buildDivider(),

                          // 7. ESP HP
                          _buildToggleItem(
                            title: "ESP HP",
                            value: espHpEnabled,
                            onTap: () {
                              setState(() {
                                espHpEnabled = !espHpEnabled;
                              });
                            },
                          ),
                          _buildDivider(),

                          // 8. ESP TÊN
                          _buildToggleItem(
                            title: "ESP TÊN",
                            value: espNameEnabled,
                            onTap: () {
                              setState(() {
                                espNameEnabled = !espNameEnabled;
                              });
                            },
                          ),
                          _buildDivider(),

                          // 9. ESP SKELETON (KHUNG XƯƠNG)
                          _buildToggleItem(
                            title: "ESP KHUNG XƯƠNG",
                            value: espSkeletonEnabled,
                            onTap: () {
                              setState(() {
                                espSkeletonEnabled = !espSkeletonEnabled;
                              });
                            },
                          ),
                          _buildDivider(),

                          // 10. ESP DISTANCE (KHOẢNG CÁCH)
                          _buildToggleItem(
                            title: "ESP KHOẢNG CÁCH",
                            value: espDistanceEnabled,
                            onTap: () {
                              setState(() {
                                espDistanceEnabled = !espDistanceEnabled;
                              });
                            },
                          ),
                          _buildDivider(),

                          // 11. ANIMATION TOGGLE
                          _buildToggleItem(
                            title: "DI CHUYỂN MÔ PHỎNG",
                            value: animateTargets,
                            onTap: () {
                              setState(() {
                                animateTargets = !animateTargets;
                              });
                            },
                          ),
                          _buildDivider(),

                          // 12. TEST LOG BỘ NHỚ OVERLAY ON PHONE SCREEN
                          _buildToggleItem(
                            title: "🧪 TEST LOG BỘ NHỚ",
                            value: showMemoryTestLog,
                            onTap: () {
                              setState(() {
                                showMemoryTestLog = !showMemoryTestLog;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // 4. Memory Test Console Overlay Box on Phone Screen
          if (showMemoryTestLog)
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xEC0B0E14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF00FF00), width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.terminal, color: Color(0xFF00FF00), size: 16),
                            SizedBox(width: 6),
                            Text(
                              "MEMORY LOG TEST",
                              style: TextStyle(
                                color: Color(0xFF00FF00),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => setState(() => showMemoryTestLog = false),
                          child: const Icon(Icons.close, color: Colors.white70, size: 16),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 12),
                    const Text(
                      "[+] PID: 8888 • Status: ATTACHED\n"
                      "[+] proc_kaddr  : 0xFFFF000012345678\n"
                      "[+] vm_map_kaddr: 0xFFFF0000ABCDEF00\n"
                      "------------------------------------\n"
                      "├── [u8] HP State  : 1 (FULL)\n"
                      "├── [u32] Player ID: 998877\n"
                      "├── [float] Health : 88.50 / 100.0\n"
                      "├── [Vector3] Pos  : X:154.2, Y:25.8, Z:620.1\n"
                      "└── [String] Name  : \"Player_FF_VN\"",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: 'monospace',
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 1.0,
      color: const Color(0xE6FFFFFF),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required bool value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
        color: const Color(0xFF0000FF),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (value)
              Container(
                margin: const EdgeInsets.only(right: 8),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF00FF00),
                  shape: BoxShape.circle,
                ),
              ),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    color: value ? Colors.white : Colors.white70,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Painter drawing the full interactive ESP Overlays (Lines, Boxes, Skeleton, HP, Name, Aimbot Circle)
class GameSimulationPainter extends CustomPainter {
  final List<SimulatedPlayer> players;
  final bool aimbotEnabled;
  final TargetPart targetPart;
  final double aimRadius;
  final bool espLineEnabled;
  final bool espBoxEnabled;
  final bool espHpEnabled;
  final bool espNameEnabled;
  final bool espSkeletonEnabled;
  final bool espDistanceEnabled;
  final LineOrigin lineOrigin;

  GameSimulationPainter({
    required this.players,
    required this.aimbotEnabled,
    required this.targetPart,
    required this.aimRadius,
    required this.espLineEnabled,
    required this.espBoxEnabled,
    required this.espHpEnabled,
    required this.espNameEnabled,
    required this.espSkeletonEnabled,
    required this.espDistanceEnabled,
    required this.lineOrigin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final screenCenter = Offset(size.width * 0.62, size.height * 0.5);

    // Draw Background Simulation Grid
    final gridPaint = Paint()
      ..color = const Color(0x0EFFFFFF)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Determine ESP Line origin point
    Offset originPoint;
    switch (lineOrigin) {
      case LineOrigin.bottom:
        originPoint = Offset(size.width * 0.5, size.height);
        break;
      case LineOrigin.center:
        originPoint = screenCenter;
        break;
      case LineOrigin.top:
        originPoint = Offset(size.width * 0.5, 0);
        break;
    }

    // 1. Draw Aim Radius FOV Circle & Crosshair
    if (aimbotEnabled) {
      final fovPaint = Paint()
        ..color = const Color(0x4D00FF00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;

      canvas.drawCircle(screenCenter, aimRadius * 1.5, fovPaint);

      // Center Crosshair lines
      final crosshairPaint = Paint()
        ..color = const Color(0xFFFF0000)
        ..strokeWidth = 2.0;

      canvas.drawLine(Offset(screenCenter.dx - 10, screenCenter.dy), Offset(screenCenter.dx + 10, screenCenter.dy), crosshairPaint);
      canvas.drawLine(Offset(screenCenter.dx, screenCenter.dy - 10), Offset(screenCenter.dx, screenCenter.dy + 10), crosshairPaint);
    }

    // 2. Draw ESP Overlays for each simulated player
    for (var player in players) {
      final box = player.box;
      final headPos = player.head;
      final targetPos = targetPart == TargetPart.head
          ? player.head
          : (targetPart == TargetPart.neck ? player.neck : player.chest);

      // Check if target is inside Aimbot FOV
      final isInsideFov = (targetPos - screenCenter).distance <= (aimRadius * 1.5);
      final Color espColor = isInsideFov ? const Color(0xFFFF0000) : const Color(0xFF00FF00);

      // A. ESP LINE
      if (espLineEnabled) {
        final linePaint = Paint()
          ..color = espColor.withValues(alpha: 0.85)
          ..strokeWidth = isInsideFov ? 2.0 : 1.2;
        canvas.drawLine(originPoint, targetPos, linePaint);
      }

      // B. ESP BOX (2D Box + Corner Indicators)
      if (espBoxEnabled) {
        final boxPaint = Paint()
          ..color = espColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8;
        canvas.drawRect(box, boxPaint);

        // Corner accents
        final accentPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2.5;

        double len = 10;
        // Top-Left
        canvas.drawLine(box.topLeft, Offset(box.left + len, box.top), accentPaint);
        canvas.drawLine(box.topLeft, Offset(box.left, box.top + len), accentPaint);
        // Top-Right
        canvas.drawLine(box.topRight, Offset(box.right - len, box.top), accentPaint);
        canvas.drawLine(box.topRight, Offset(box.right, box.top + len), accentPaint);
        // Bottom-Left
        canvas.drawLine(box.bottomLeft, Offset(box.left + len, box.bottom), accentPaint);
        canvas.drawLine(box.bottomLeft, Offset(box.left, box.bottom - len), accentPaint);
        // Bottom-Right
        canvas.drawLine(box.bottomRight, Offset(box.right - len, box.bottom), accentPaint);
        canvas.drawLine(box.bottomRight, Offset(box.right, box.bottom - len), accentPaint);
      }

      // C. ESP SKELETON (Bones)
      if (espSkeletonEnabled) {
        final bonePaint = Paint()
          ..color = Colors.cyanAccent.withValues(alpha: 0.9)
          ..strokeWidth = 1.6;

        // Head circle
        canvas.drawCircle(headPos, 6.0, bonePaint);

        // Spine: Head -> Neck -> Chest -> Pelvis
        canvas.drawLine(headPos, player.neck, bonePaint);
        canvas.drawLine(player.neck, player.chest, bonePaint);
        canvas.drawLine(player.chest, player.pelvis, bonePaint);

        // Left Arm: Chest -> LeftShoulder -> LeftElbow -> LeftHand
        canvas.drawLine(player.chest, player.leftShoulder, bonePaint);
        canvas.drawLine(player.leftShoulder, player.leftElbow, bonePaint);
        canvas.drawLine(player.leftElbow, player.leftHand, bonePaint);

        // Right Arm: Chest -> RightShoulder -> RightElbow -> RightHand
        canvas.drawLine(player.chest, player.rightShoulder, bonePaint);
        canvas.drawLine(player.rightShoulder, player.rightElbow, bonePaint);
        canvas.drawLine(player.rightElbow, player.rightHand, bonePaint);

        // Left Leg: Pelvis -> LeftKnee -> LeftFoot
        canvas.drawLine(player.pelvis, player.leftKnee, bonePaint);
        canvas.drawLine(player.leftKnee, player.leftFoot, bonePaint);

        // Right Leg: Pelvis -> RightKnee -> RightFoot
        canvas.drawLine(player.pelvis, player.rightKnee, bonePaint);
        canvas.drawLine(player.rightKnee, player.rightFoot, bonePaint);
      }

      // D. ESP HP BAR
      if (espHpEnabled) {
        final hpBgPaint = Paint()..color = const Color(0x99000000);
        final hpBarPaint = Paint()
          ..color = player.hp > 0.5 ? const Color(0xFF00FF00) : const Color(0xFFFF0000);

        final hpRectBg = Rect.fromLTWH(box.left - 8, box.top, 4, box.height);
        final hpRectFill = Rect.fromLTWH(
          box.left - 8,
          box.bottom - (box.height * player.hp),
          4,
          box.height * player.hp,
        );

        canvas.drawRect(hpRectBg, hpBgPaint);
        canvas.drawRect(hpRectFill, hpBarPaint);

        // HP percentage text
        final hpText = TextPainter(
          text: TextSpan(
            text: "${(player.hp * 100).toInt()}%",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        hpText.layout();
        hpText.paint(canvas, Offset(box.left - 30, box.bottom - (box.height * player.hp) - 5));
      }

      // E. ESP NAME & DISTANCE
      if (espNameEnabled || espDistanceEnabled) {
        String label = "";
        if (espNameEnabled) label += player.name;
        if (espDistanceEnabled) label += " [${player.distance.toStringAsFixed(1)}m]";
        if (player.weapon.isNotEmpty) label += "\n🔫 ${player.weapon}";

        final textPainter = TextPainter(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: Colors.black, blurRadius: 4),
                Shadow(color: Colors.black, blurRadius: 8),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(box.center.dx - (textPainter.width / 2), box.top - textPainter.height - 4),
        );
      }

      // Target lock point dot
      final targetDotPaint = Paint()..color = const Color(0xFFFF0000);
      canvas.drawCircle(targetPos, 4.0, targetDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GameSimulationPainter oldDelegate) {
    return true; // Always repaint for 60fps simulation
  }
}
