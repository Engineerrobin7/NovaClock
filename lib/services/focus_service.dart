import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Models
class Planet {
  final String id;
  final String name;
  final String assetPath;
  final bool isUnlocked;
  final String description;

  Planet({
    required this.id,
    required this.name,
    required this.assetPath,
    this.isUnlocked = false,
    required this.description,
  });

  Planet copyWith({bool? isUnlocked}) {
    return Planet(
      id: id,
      name: name,
      assetPath: assetPath,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      description: description,
    );
  }
}

// State
class FocusState {
  final bool isFocusing;
  final int remainingSeconds;
  final int totalSeconds;
  final List<Planet> planets;
  final String currentPlanetId;

  FocusState({
    this.isFocusing = false,
    this.remainingSeconds = 1500, // 25 mins
    this.totalSeconds = 1500,
    required this.planets,
    this.currentPlanetId = 'earth',
  });

  FocusState copyWith({
    bool? isFocusing,
    int? remainingSeconds,
    int? totalSeconds,
    List<Planet>? planets,
    String? currentPlanetId,
  }) {
    return FocusState(
      isFocusing: isFocusing ?? this.isFocusing,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      planets: planets ?? this.planets,
      currentPlanetId: currentPlanetId ?? this.currentPlanetId,
    );
  }
}

// Provider
final focusProvider = StateNotifierProvider<FocusNotifier, FocusState>((ref) {
  return FocusNotifier();
});

class FocusNotifier extends StateNotifier<FocusState> {
  Timer? _timer;
  static const String _storageKey = 'unlocked_planets';

  FocusNotifier()
      : super(FocusState(planets: [
          Planet(id: 'earth', name: 'Terra Nova', assetPath: 'assets/planets/earth.png', isUnlocked: true, description: 'Home Base'),
          Planet(id: 'mars', name: 'Red Horizon', assetPath: 'assets/planets/mars.png', description: 'Unlock by focusing for 25 mins'),
          Planet(id: 'jupiter', name: 'Gas Giant', assetPath: 'assets/planets/jupiter.png', description: 'Unlock by focusing for 50 mins'),
          Planet(id: 'neptune', name: 'Ice Realm', assetPath: 'assets/planets/neptune.png', description: 'Unlock by focusing for 100 mins'),
        ])) {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedIds = prefs.getStringList(_storageKey) ?? ['earth'];
    
    final updatedPlanets = state.planets.map((p) {
      return unlockedIds.contains(p.id) ? p.copyWith(isUnlocked: true) : p;
    }).toList();

    state = state.copyWith(planets: updatedPlanets);
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedIds = state.planets.where((p) => p.isUnlocked).map((p) => p.id).toList();
    await prefs.setStringList(_storageKey, unlockedIds);
  }

  void startFocus(int minutes) {
    if (state.isFocusing) return;

    state = state.copyWith(
      isFocusing: true,
      totalSeconds: minutes * 60,
      remainingSeconds: minutes * 60,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _completeSession();
      }
    });
  }

  void stopFocus() {
    _timer?.cancel();
    state = state.copyWith(isFocusing: false, remainingSeconds: state.totalSeconds);
  }

  void _completeSession() {
    _timer?.cancel();
    state = state.copyWith(isFocusing: false);
    _unlockNextPlanet();
  }

  void _unlockNextPlanet() {
    // Simple logic: unlock the first locked planet
    final lockedPlanetIndex = state.planets.indexWhere((p) => !p.isUnlocked);
    if (lockedPlanetIndex != -1) {
      final updatedPlanets = List<Planet>.from(state.planets);
      updatedPlanets[lockedPlanetIndex] = updatedPlanets[lockedPlanetIndex].copyWith(isUnlocked: true);
      state = state.copyWith(planets: updatedPlanets);
      _saveProgress();
    }
  }
  
  void selectPlanet(String planetId) {
    final planet = state.planets.firstWhere((p) => p.id == planetId, orElse: () => state.planets.first);
    if (planet.isUnlocked) {
      state = state.copyWith(currentPlanetId: planetId);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
