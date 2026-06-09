enum CapabilitySupport {
  supported,
  limited,
  unsupported,
}

enum PlatformCapabilityTier {
  full,
  limitedOfficial,
}

enum CapabilityKey {
  activityRecognition,
  postureSignals,
  locationSummary,
  environmentNoise,
  screenUsageSummary,
  appCategoryUsage,
  digitalUsageAlternative,
  backgroundCapture,
}

class PlatformCapabilitySet {
  const PlatformCapabilitySet({
    required this.tier,
    required this.activityRecognition,
    required this.postureSignals,
    required this.locationSummary,
    required this.environmentNoise,
    required this.screenUsageSummary,
    required this.appCategoryUsage,
    required this.digitalUsageAlternative,
    required this.backgroundCapture,
  });

  final PlatformCapabilityTier tier;
  final CapabilitySupport activityRecognition;
  final CapabilitySupport postureSignals;
  final CapabilitySupport locationSummary;
  final CapabilitySupport environmentNoise;
  final CapabilitySupport screenUsageSummary;
  final CapabilitySupport appCategoryUsage;
  final CapabilitySupport digitalUsageAlternative;
  final CapabilitySupport backgroundCapture;

  bool get hasLimitedCapabilities {
    return supportFor(CapabilityKey.activityRecognition) == CapabilitySupport.limited ||
        supportFor(CapabilityKey.postureSignals) == CapabilitySupport.limited ||
        supportFor(CapabilityKey.locationSummary) == CapabilitySupport.limited ||
        supportFor(CapabilityKey.environmentNoise) == CapabilitySupport.limited ||
        supportFor(CapabilityKey.screenUsageSummary) == CapabilitySupport.limited ||
        supportFor(CapabilityKey.appCategoryUsage) == CapabilitySupport.limited ||
        supportFor(CapabilityKey.digitalUsageAlternative) == CapabilitySupport.limited ||
        supportFor(CapabilityKey.backgroundCapture) == CapabilitySupport.limited;
  }

  CapabilitySupport supportFor(CapabilityKey key) {
    switch (key) {
      case CapabilityKey.activityRecognition:
        return activityRecognition;
      case CapabilityKey.postureSignals:
        return postureSignals;
      case CapabilityKey.locationSummary:
        return locationSummary;
      case CapabilityKey.environmentNoise:
        return environmentNoise;
      case CapabilityKey.screenUsageSummary:
        return screenUsageSummary;
      case CapabilityKey.appCategoryUsage:
        return appCategoryUsage;
      case CapabilityKey.digitalUsageAlternative:
        return digitalUsageAlternative;
      case CapabilityKey.backgroundCapture:
        return backgroundCapture;
    }
  }
}

class CapabilityMatrix {
  const CapabilityMatrix({
    required this.ios,
    required this.android,
  });

  final PlatformCapabilitySet ios;
  final PlatformCapabilitySet android;

  factory CapabilityMatrix.defaultMatrix() {
    return const CapabilityMatrix(
      ios: PlatformCapabilitySet(
        tier: PlatformCapabilityTier.limitedOfficial,
        activityRecognition: CapabilitySupport.supported,
        postureSignals: CapabilitySupport.supported,
        locationSummary: CapabilitySupport.supported,
        environmentNoise: CapabilitySupport.supported,
        screenUsageSummary: CapabilitySupport.limited,
        appCategoryUsage: CapabilitySupport.unsupported,
        digitalUsageAlternative: CapabilitySupport.supported,
        backgroundCapture: CapabilitySupport.limited,
      ),
      android: PlatformCapabilitySet(
        tier: PlatformCapabilityTier.full,
        activityRecognition: CapabilitySupport.supported,
        postureSignals: CapabilitySupport.supported,
        locationSummary: CapabilitySupport.supported,
        environmentNoise: CapabilitySupport.supported,
        screenUsageSummary: CapabilitySupport.supported,
        appCategoryUsage: CapabilitySupport.supported,
        digitalUsageAlternative: CapabilitySupport.supported,
        backgroundCapture: CapabilitySupport.supported,
      ),
    );
  }
}
