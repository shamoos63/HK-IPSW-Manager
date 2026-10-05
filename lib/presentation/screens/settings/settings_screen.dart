import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/branding.dart';
import '../../../core/theme/hud_theme.dart';
import '../../../core/utils/byte_format.dart';
import '../../../domain/entities/app_settings.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/core_providers.dart';
import '../../widgets/hud_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    void update(AppSettings Function(AppSettings) f) =>
        ref.read(settingsProvider.notifier).update(f);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 24),
      children: [
        const _AboutSection(),
        const SizedBox(height: 16),
        _Section(
          title: 'Storage',
          icon: Icons.folder_rounded,
          children: [
            _FolderRow(
              label: 'Repository folder',
              help: 'Finished IPSW files land here. The Repository scanner audits this folder.',
              path: s.targetDirectory,
              onPick: (p) => update((x) => x.copyWith(targetDirectory: p)),
            ),
            _FolderRow(
              label: 'Temp folder',
              help:
                  'Optional scratch location for partial .hkdl files (e.g. a fast SSD). '
                  'Same volume as the repository avoids a 10 GB copy at the end.',
              path: s.tempDirectory,
              placeholder: 'Same as repository folder',
              onPick: (p) => update((x) => x.copyWith(tempDirectory: () => p)),
              onClear: s.tempDirectory == null
                  ? null
                  : () => update((x) => x.copyWith(tempDirectory: () => null)),
            ),
            _SwitchRow(
              label: 'Per-device hardlinks',
              help:
                  'After a download, add "By Device/<identifier>_<version>_<build>_Restore.ipsw" '
                  'hardlinks for every device the payload serves. Uses no extra disk space.',
              value: s.autoDeviceLinks,
              onChanged: (v) => update((x) => x.copyWith(autoDeviceLinks: v)),
            ),
          ],
        ),
        _Section(
          title: 'Download engine',
          icon: Icons.bolt_rounded,
          children: [
            _SliderRow(
              label: 'Threads per download',
              help: 'Parallel HTTP range connections. Idle threads split the largest remaining chunk.',
              value: s.threads,
              min: 2,
              max: 16,
              display: '${s.threads}',
              onChanged: (v) => update((x) => x.copyWith(threads: v)),
            ),
            _SliderRow(
              label: 'Concurrent downloads',
              help: 'Files transferring at the same time; the rest wait in queue order.',
              value: s.maxConcurrentDownloads,
              min: 1,
              max: 6,
              display: '${s.maxConcurrentDownloads}',
              onChanged: (v) =>
                  update((x) => x.copyWith(maxConcurrentDownloads: v)),
            ),
            _SliderRow(
              label: 'Global speed cap',
              help:
                  'Shared across all threads of all downloads. 0 = unlimited.',
              value: s.globalSpeedLimitBytesPerSecond ~/ (1024 * 1024),
              min: 0,
              max: 200,
              divisions: 40,
              display: s.globalSpeedLimitBytesPerSecond == 0
                  ? 'Unlimited'
                  : formatRate(s.globalSpeedLimitBytesPerSecond),
              onChanged: (v) => update(
                (x) =>
                    x.copyWith(globalSpeedLimitBytesPerSecond: v * 1024 * 1024),
              ),
            ),
            _SliderRow(
              label: 'Link refresh timeout',
              help: 'How long to wait for IPSW.me when an expired Apple CDN link is re-resolved.',
              value: s.linkRefreshTimeout.inSeconds,
              min: 10,
              max: 120,
              divisions: 22,
              display: '${s.linkRefreshTimeout.inSeconds}s',
              onChanged: (v) => update(
                (x) => x.copyWith(linkRefreshTimeout: Duration(seconds: v)),
              ),
            ),
            _SwitchRow(
              label: 'Verify SHA1 after download',
              help: 'Hashes the file on a background isolate and compares with IPSW.me.',
              value: s.autoVerifySha1,
              onChanged: (v) => update((x) => x.copyWith(autoVerifySha1: v)),
            ),
          ],
        ),
        const _CatalogSection(),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: GlassPanel(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: HudColors.cyan),
              const SizedBox(width: 8),
              HudLabel(title, color: HudColors.cyan),
            ],
          ),
          const SizedBox(height: 8),
          for (final (i, c) in children.indexed) ...[
            if (i > 0)
              Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
            c,
          ],
        ],
      ),
    ),
  );
}

class _RowShell extends StatelessWidget {
  const _RowShell({
    required this.label,
    required this.help,
    required this.trailing,
  });

  final String label;
  final String help;
  final Widget trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                help,
                style: const TextStyle(
                  fontSize: 12,
                  color: HudColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        trailing,
      ],
    ),
  );
}

class _FolderRow extends StatelessWidget {
  const _FolderRow({
    required this.label,
    required this.help,
    required this.path,
    required this.onPick,
    this.placeholder = '',
    this.onClear,
  });

  final String label;
  final String help;
  final String? path;
  final String placeholder;
  final ValueChanged<String> onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) => _RowShell(
    label: label,
    help: help,
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 340,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.black.withValues(alpha: 0.3),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Text(
            path ?? placeholder,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: HudTheme.telemetry(
              size: 12,
              color: path == null ? HudColors.textMuted : HudColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (onClear != null) ...[
          HudIconButton(
            icon: Icons.close_rounded,
            tooltip: 'Clear',
            onPressed: onClear,
          ),
          const SizedBox(width: 4),
        ],
        NeonButton(
          label: 'Choose',
          icon: Icons.folder_open_rounded,
          variant: NeonVariant.ghost,
          compact: true,
          onPressed: () async {
            final picked = await getDirectoryPath(
              initialDirectory: path,
              confirmButtonText: 'Use folder',
            );
            if (picked != null) onPick(picked);
          },
        ),
      ],
    ),
  );
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.help,
    required this.value,
    required this.min,
    required this.max,
    required this.display,
    required this.onChanged,
    this.divisions,
  });

  final String label;
  final String help;
  final int value;
  final int min;
  final int max;
  final int? divisions;
  final String display;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => _RowShell(
    label: label,
    help: help,
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 300,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: HudColors.cyan,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
              thumbColor: HudColors.cyan,
              overlayColor: HudColors.cyan.withValues(alpha: 0.15),
              trackHeight: 3,
            ),
            child: Slider(
              value: value.clamp(min, max).toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: divisions ?? (max - min),
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ),
        SizedBox(
          width: 92,
          child: Text(
            display,
            textAlign: TextAlign.right,
            style: HudTheme.telemetry(size: 13),
          ),
        ),
      ],
    ),
  );
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.help,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String help;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => _RowShell(
    label: label,
    help: help,
    trailing: Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: HudColors.cyan,
      activeTrackColor: HudColors.cyan.withValues(alpha: 0.3),
    ),
  );
}

class _CatalogSection extends ConsumerWidget {
  const _CatalogSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogProvider).value;
    return _Section(
      title: 'Catalog cache',
      icon: Icons.cloud_sync_rounded,
      children: [
        _RowShell(
          label: 'IPSW.me index',
          help: state == null
              ? 'Loading…'
              : '${state.index.devices.length} devices · ${state.index.payloadCount} unique payloads · '
                    '${state.index.signedPayloadCount} signed. Device lists refresh every 24 h, firmware every 6 h.',
          trailing: Row(
            children: [
              NeonButton(
                label: 'Clear cache',
                variant: NeonVariant.danger,
                compact: true,
                onPressed: () async {
                  await ref.read(catalogRepositoryProvider).clearCache();
                  ref.invalidate(catalogProvider);
                },
              ),
              const SizedBox(width: 10),
              NeonButton(
                label: state?.syncing ?? false ? 'Syncing…' : 'Resync now',
                icon: Icons.sync_rounded,
                compact: true,
                onPressed: state?.syncing ?? true
                    ? null
                    : () =>
                          ref.read(catalogProvider.notifier).sync(force: true),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      glow: true,
      borderColor: HudColors.purple.withValues(alpha: 0.4),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: HudColors.cyan.withValues(alpha: 0.25),
                  blurRadius: 28,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                Branding.logo,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HudLabel('About', color: HudColors.cyan),
                const SizedBox(height: 8),
                Text(
                  Branding.appName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Version ${Branding.version}',
                  style: HudTheme.telemetry(
                    size: 12,
                    color: HudColors.textMuted,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  Branding.credit,
                  style: TextStyle(fontSize: 14, color: HudColors.textPrimary),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    NeonButton(
                      label: 'Telegram: ${Branding.telegramLabel}',
                      icon: Icons.send_rounded,
                      variant: NeonVariant.ghost,
                      compact: true,
                      onPressed: () => Branding.open(Branding.telegramUrl),
                    ),
                    NeonButton(
                      label: 'Website: ${Branding.websiteLabel}',
                      icon: Icons.language_rounded,
                      variant: NeonVariant.ghost,
                      compact: true,
                      onPressed: () => Branding.open(Branding.websiteUrl),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
