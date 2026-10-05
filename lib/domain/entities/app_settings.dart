/// User preferences (Settings screen).
class AppSettings {
  const AppSettings({
    required this.targetDirectory,
    this.tempDirectory,
    this.threads = 8,
    this.maxConcurrentDownloads = 2,
    this.autoVerifySha1 = true,
    this.autoDeviceLinks = true,
    this.globalSpeedLimitBytesPerSecond = 0,
    this.linkRefreshTimeout = const Duration(seconds: 30),
  });

  /// Repository folder downloads land in (e.g. `D:\Apple_Firmwares`).
  final String targetDirectory;

  /// Optional scratch folder for partial files; `null` = next to the target.
  final String? tempDirectory;
  final int threads;
  final int maxConcurrentDownloads;
  final bool autoVerifySha1;

  /// After a download, hardlink it as one file name per device it serves.
  final bool autoDeviceLinks;
  final int globalSpeedLimitBytesPerSecond;
  final Duration linkRefreshTimeout;

  AppSettings copyWith({
    String? targetDirectory,
    String? Function()? tempDirectory,
    int? threads,
    int? maxConcurrentDownloads,
    bool? autoVerifySha1,
    bool? autoDeviceLinks,
    int? globalSpeedLimitBytesPerSecond,
    Duration? linkRefreshTimeout,
  }) => AppSettings(
    targetDirectory: targetDirectory ?? this.targetDirectory,
    tempDirectory: tempDirectory != null ? tempDirectory() : this.tempDirectory,
    threads: threads ?? this.threads,
    maxConcurrentDownloads:
        maxConcurrentDownloads ?? this.maxConcurrentDownloads,
    autoVerifySha1: autoVerifySha1 ?? this.autoVerifySha1,
    autoDeviceLinks: autoDeviceLinks ?? this.autoDeviceLinks,
    globalSpeedLimitBytesPerSecond:
        globalSpeedLimitBytesPerSecond ?? this.globalSpeedLimitBytesPerSecond,
    linkRefreshTimeout: linkRefreshTimeout ?? this.linkRefreshTimeout,
  );

  factory AppSettings.fromJson(
    Map<String, dynamic> json, {
    required String fallbackTarget,
  }) => AppSettings(
    targetDirectory: json['targetDirectory'] as String? ?? fallbackTarget,
    tempDirectory: json['tempDirectory'] as String?,
    threads: ((json['threads'] as num?)?.toInt() ?? 8).clamp(2, 16),
    maxConcurrentDownloads:
        ((json['maxConcurrentDownloads'] as num?)?.toInt() ?? 2).clamp(1, 8),
    autoVerifySha1: json['autoVerifySha1'] as bool? ?? true,
    autoDeviceLinks: json['autoDeviceLinks'] as bool? ?? true,
    globalSpeedLimitBytesPerSecond:
        (json['globalSpeedLimitBytesPerSecond'] as num?)?.toInt() ?? 0,
    linkRefreshTimeout: Duration(
      seconds: (json['linkRefreshTimeoutSeconds'] as num?)?.toInt() ?? 30,
    ),
  );

  Map<String, dynamic> toJson() => {
    'targetDirectory': targetDirectory,
    'tempDirectory': tempDirectory,
    'threads': threads,
    'maxConcurrentDownloads': maxConcurrentDownloads,
    'autoVerifySha1': autoVerifySha1,
    'autoDeviceLinks': autoDeviceLinks,
    'globalSpeedLimitBytesPerSecond': globalSpeedLimitBytesPerSecond,
    'linkRefreshTimeoutSeconds': linkRefreshTimeout.inSeconds,
  };
}
