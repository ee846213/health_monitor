enum PermissionType {
  motion,
  location,
  microphone,
  notification,
  usageAccess,
  healthConnect,
  backgroundCapture,
}

enum PermissionAvailability {
  crossPlatform,
  androidOnly,
  iosOnly,
  crossPlatformLimited,
}

class PermissionDescriptor {
  const PermissionDescriptor({
    required this.type,
    required this.title,
    required this.whyNeeded,
    required this.analysisUsage,
    required this.missingImpact,
    required this.degradeBehavior,
    required this.availability,
    required this.required,
    required this.isHighFriction,
    this.prerequisites = const <PermissionType>[],
  });

  final PermissionType type;
  final String title;
  final String whyNeeded;
  final String analysisUsage;
  final String missingImpact;
  final String degradeBehavior;
  final PermissionAvailability availability;
  final bool required;
  final bool isHighFriction;
  final List<PermissionType> prerequisites;

  static List<PermissionDescriptor> defaults() {
    return const <PermissionDescriptor>[
      PermissionDescriptor(
        type: PermissionType.motion,
        title: '运动与传感器权限',
        whyNeeded: '用于识别活动状态、姿势变化和基础移动强度。',
        analysisUsage: '用于生成活动识别、姿势风险和久坐相关分析。',
        missingImpact: '不开启后，将失去活动识别、姿势风险和部分提醒能力。',
        degradeBehavior: '拒绝后降级为仅展示手动可见页面，不生成基于运动的洞察。',
        availability: PermissionAvailability.crossPlatform,
        required: false,
        isHighFriction: false,
      ),
      PermissionDescriptor(
        type: PermissionType.location,
        title: '位置权限',
        whyNeeded: '用于生成位置摘要、通勤线索和场景稳定性判断。',
        analysisUsage: '用于结合活动结果分析出行状态、活动切换和位置摘要。',
        missingImpact: '不开启后，将失去位置摘要、通勤相关洞察和部分后台连续性能力。',
        degradeBehavior: '拒绝后降级为不输出位置相关结果，仅保留无位置依赖的分析。',
        availability: PermissionAvailability.crossPlatform,
        required: false,
        isHighFriction: false,
      ),
      PermissionDescriptor(
        type: PermissionType.microphone,
        title: '麦克风权限',
        whyNeeded: '用于采集环境噪音等级，不保存原始音频。',
        analysisUsage: '用于生成环境噪音等级、安静/嘈杂场景判断与相关提醒。',
        missingImpact: '不开启后，将失去环境噪音等级和噪音相关提醒能力。',
        degradeBehavior: '拒绝后降级为不输出环境噪音洞察，并继续运行其他能力。',
        availability: PermissionAvailability.crossPlatform,
        required: false,
        isHighFriction: true,
      ),
      PermissionDescriptor(
        type: PermissionType.notification,
        title: '通知权限',
        whyNeeded: '用于向用户发送提醒、风险提示和每日简报通知。',
        analysisUsage: '用于承载规则触发后的提醒分发，不参与原始数据分析。',
        missingImpact: '不开启后，将失去系统通知触达，但仍可在应用内查看结果。',
        degradeBehavior: '拒绝后降级为仅保留应用内提醒记录和页面提示，不发送系统通知。',
        availability: PermissionAvailability.crossPlatform,
        required: false,
        isHighFriction: false,
      ),
      PermissionDescriptor(
        type: PermissionType.usageAccess,
        title: 'Usage Access 权限',
        whyNeeded: '用于读取 Android 端数字生活习惯摘要与应用类别使用线索。',
        analysisUsage: '用于生成查看频率、深夜活跃和应用类别偏好等数字生活分析。',
        missingImpact: '不开启后，Android 端将失去完整数字生活分析，仅保留替代指标。',
        degradeBehavior: '拒绝后降级为只输出基础用机频率或 iPhone 同等级替代指标。',
        availability: PermissionAvailability.androidOnly,
        required: false,
        isHighFriction: true,
      ),
      PermissionDescriptor(
        type: PermissionType.healthConnect,
        title: 'Health Connect 步数',
        whyNeeded: '用于在晚开 App 时按小时还原今日步数分布，支撑节奏轴活动节点。',
        analysisUsage: '读取系统健康数据中的小时步数桶，定位活动集中时段。',
        missingImpact: '不开启后，晚开 App 时只能看到当日总步数，节奏轴可能缺少活动时刻。',
        degradeBehavior: '拒绝后降级为仅使用 App 运行期间的实时计步增量。',
        availability: PermissionAvailability.androidOnly,
        required: false,
        isHighFriction: true,
      ),
      PermissionDescriptor(
        type: PermissionType.backgroundCapture,
        title: '后台采集能力',
        whyNeeded: '用于在不打扰用户的情况下持续积累活动与位置等有效样本。',
        analysisUsage: '用于支撑后台被动采集、连续趋势判断和提醒触发时机。',
        missingImpact: '不开启后，将失去后台连续采集能力，数据主要依赖前台打开应用时产生。',
        degradeBehavior: '拒绝后降级为以前台采集为主，并提示后台能力受限。',
        availability: PermissionAvailability.crossPlatformLimited,
        required: false,
        isHighFriction: true,
        prerequisites: <PermissionType>[
          PermissionType.motion,
          PermissionType.location,
        ],
      ),
    ];
  }
}
