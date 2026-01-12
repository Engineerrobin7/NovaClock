import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nova_clock/services/focus_service.dart';
import 'package:nova_clock/widgets/glass_container.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusState = ref.watch(focusProvider);
    final currentPlanet = focusState.planets.firstWhere((p) => p.id == focusState.currentPlanetId, orElse: () => focusState.planets.first);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Nova Focus',
                          style: Theme.of(context).textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        
                        // Planet Display
                        Expanded(
                          flex: 3,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Planet Image
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                                      blurRadius: 60,
                                      spreadRadius: -10,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  currentPlanet.assetPath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => 
                                    Icon(Icons.public, size: 200, color: Theme.of(context).primaryColor),
                                ),
                              ),
                              if (focusState.isFocusing)
                                const Positioned(
                                  bottom: 0,
                                  child: Text("Traveling...", style: TextStyle(color: Colors.white70)),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Timer Display
                        GlassContainer(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Text(
                                _formatTime(focusState.remainingSeconds),
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontFeatures: [const FontFeature.tabularFigures()],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                focusState.isFocusing 
                                  ? "Focus to reach the next planet!" 
                                  : "Ready to launch?",
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: focusState.isFocusing
                                    ? () => ref.read(focusProvider.notifier).stopFocus()
                                    : () => ref.read(focusProvider.notifier).startFocus(25),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 56),
                                  backgroundColor: focusState.isFocusing ? Colors.redAccent : Theme.of(context).primaryColor,
                                ),
                                child: Text(focusState.isFocusing ? 'Abort Mission' : 'Launch Mission (25m)'),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Unlocked Planets List
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: focusState.planets.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final planet = focusState.planets[index];
                              return GestureDetector(
                                onTap: () {
                                  if (planet.isUnlocked) {
                                    ref.read(focusProvider.notifier).selectPlanet(planet.id);
                                  }
                                },
                                child: Opacity(
                                  opacity: planet.isUnlocked ? 1.0 : 0.3,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: planet.id == currentPlanet.id 
                                              ? Theme.of(context).primaryColor 
                                              : Colors.transparent,
                                            width: 2,
                                          ),
                                          boxShadow: planet.id == currentPlanet.id ? [
                                            BoxShadow(
                                              color: Theme.of(context).primaryColor.withOpacity(0.5),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            )
                                          ] : [],
                                          image: DecorationImage(
                                            image: AssetImage(planet.assetPath),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        planet.name,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: planet.id == currentPlanet.id 
                                            ? Theme.of(context).primaryColor 
                                            : Colors.white70,
                                          fontWeight: planet.id == currentPlanet.id 
                                            ? FontWeight.bold 
                                            : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
