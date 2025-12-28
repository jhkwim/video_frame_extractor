import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failure.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/home_view_model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../l10n/generated/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);

    // Listen for state changes to navigate
    ref.listen(homeViewModelProvider, (previous, next) {
      if (next.selectedVideo != null && !next.isLoading && next.error == null) {
        // Navigate to Player and pass the video
        // We might want to clear the selection in VM after navigation on Resume,
        // but for now simple push is fine.
        context.push('/player', extra: next.selectedVideo);
      }

      if (next.error != null) {
        String message = next.error!.message;
        if (next.error is VideoPickFailure) {
          message = AppLocalizations.of(context)!.videoPickError;
        } else if (next.error is UserCanceledFailure) {
          return; // Ignore cancel
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/icon/icon.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ).animate().fade(duration: 500.ms).scale(),
                const Gap(20),
                Text(
                  AppLocalizations.of(context)!.appName,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 200.ms).moveY(begin: 10, end: 0),
                const Gap(10),
                Text(
                  AppLocalizations.of(context)!.homeTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                ).animate().fadeIn(delay: 400.ms),
                const Gap(50),
                if (homeState.isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(homeViewModelProvider.notifier).pickVideo();
                    },
                    icon: const Icon(Icons.add_a_photo),
                    label: Text(
                      AppLocalizations.of(context)!.pickVideoButtonLabel,
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ).animate().scale(delay: 600.ms, curve: Curves.elasticOut),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      '${AppLocalizations.of(context)!.version} ${snapshot.data!.version} (${snapshot.data!.buildNumber})',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
