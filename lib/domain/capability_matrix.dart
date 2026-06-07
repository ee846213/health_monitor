enum CapabilitySupport {
  supported,
  limited,
  unsupported,
}

class PlatformCapabilitySet {
  const PlatformCapabilitySet({
    required this.activityRecognition,
    required this.postureSignals,
    required this.locationSummary,
    required this.noiseLevel,
    required this.screenUsageSummary,
    required this.appCategoryUsage,
  });

  final CapabilitySupport activityRecognition;
  final CapabilitySupport postureSignals;
  final CapabilitySupport locationSummary;
  final CapabilitySupport noiseLevel;
  final CapabilitySupport screenUsageSummary;
  final CapabilitySupport appCategoryUsage;
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
        activityRecognition: CapabilitySupport.supported,
        postureSignals: CapabilitySupport.supported,
        locationSummary: CapabilitySupport.supported,
        noiseLevel: CapabilitySupport.supported,
        screenUsageSummary: CapabilitySupport.limited,
        appCategoryUsage: CapabilitySupport.unsupported,
      ),
      android: PlatformCapabilitySet(
        activityRecognition: CapabilitySupport.supported,
        postureSignals: CapabilitySupport.supported,
        locationSummary: CapabilitySupport.supported,
        noiseLevel: CapabilitySupport.supported,
        screenUsageSummary: CapabilitySupport.supported,
        appCategoryUsage: CapabilitySupport.supported,
      ),
    );
  }
}
