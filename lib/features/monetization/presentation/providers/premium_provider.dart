import 'package:flutter_riverpod/flutter_riverpod.dart';

class PremiumState {
  final bool isPremium;

  const PremiumState({
    required this.isPremium,
  });
}

final premiumProvider = NotifierProvider<PremiumNotifier, PremiumState>(PremiumNotifier.new);

class PremiumNotifier extends Notifier<PremiumState> {
  @override
  PremiumState build() {
    return const PremiumState(isPremium: false);
  }

  void upgradeToPremium() {
    state = const PremiumState(isPremium: true);
  }
}