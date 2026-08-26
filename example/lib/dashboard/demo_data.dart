import 'package:flutter/widgets.dart' show IconData;
import 'package:octo_ui/octo_ui.dart';

/// Health of a monitored service.
enum ServiceHealth {
  /// Meeting its SLO.
  healthy('Healthy', OctoStateLabelVariant.open),

  /// Serving, but breaching a latency or error budget.
  degraded('Degraded', OctoStateLabelVariant.attention),

  /// Failing its health check.
  down('Down', OctoStateLabelVariant.closed),

  /// Taken out of rotation on purpose.
  maintenance('Maintenance', OctoStateLabelVariant.draft);

  const ServiceHealth(this.label, this.badge);

  /// Human-readable name shown in the table.
  final String label;

  /// State-label variant that carries this health visually.
  final OctoStateLabelVariant badge;
}

/// Deployment environment a service instance runs in.
enum Environment {
  /// Customer-facing.
  production('Production'),

  /// Pre-production verification.
  staging('Staging'),

  /// Developer sandbox.
  development('Development');

  const Environment(this.label);

  /// Human-readable name.
  final String label;
}

/// One row of the service table.
class ServiceRow {
  /// Service name, e.g. `checkout-api`.
  final String name;

  /// Team accountable for the service.
  final String team;

  /// Where this instance runs.
  final Environment environment;

  /// Current health.
  final ServiceHealth health;

  /// 95th-percentile latency in milliseconds.
  final int p95Ms;

  /// Share of failing requests, as a fraction (0.004 = 0.4%).
  final double errorRate;

  /// On-call engineers, rendered as an avatar stack.
  final List<OctoAvatar> owners;

  /// Creates a service row.
  const ServiceRow({
    required this.name,
    required this.team,
    required this.environment,
    required this.health,
    required this.p95Ms,
    required this.errorRate,
    required this.owners,
  });
}

const _ann = OctoAvatar(
    initials: 'AK', size: OctoAvatarSize.sm, semanticLabel: 'Ann Kim');
const _bob = OctoAvatar(
    initials: 'BR', size: OctoAvatarSize.sm, semanticLabel: 'Bo Reyes');
const _cleo = OctoAvatar(
    initials: 'CN', size: OctoAvatarSize.sm, semanticLabel: 'Cleo Nunes');
const _dev = OctoAvatar(
    initials: 'DV', size: OctoAvatarSize.sm, semanticLabel: 'Dev Patel');
const _eli = OctoAvatar(
    initials: 'EL', size: OctoAvatarSize.sm, semanticLabel: 'Eli S.');

/// Services shown on the dashboard.
const List<ServiceRow> demoServices = [
  ServiceRow(
    name: 'checkout-api',
    team: 'Payments',
    environment: Environment.production,
    health: ServiceHealth.degraded,
    p95Ms: 812,
    errorRate: 0.0214,
    owners: [_ann, _bob, _cleo],
  ),
  ServiceRow(
    name: 'ledger-worker',
    team: 'Payments',
    environment: Environment.production,
    health: ServiceHealth.healthy,
    p95Ms: 143,
    errorRate: 0.0004,
    owners: [_bob, _dev],
  ),
  ServiceRow(
    name: 'search-indexer',
    team: 'Discovery',
    environment: Environment.production,
    health: ServiceHealth.down,
    p95Ms: 0,
    errorRate: 1,
    owners: [_cleo, _eli, _ann, _dev],
  ),
  ServiceRow(
    name: 'media-transcoder',
    team: 'Content',
    environment: Environment.production,
    health: ServiceHealth.healthy,
    p95Ms: 2140,
    errorRate: 0.0011,
    owners: [_dev],
  ),
  ServiceRow(
    name: 'notification-relay',
    team: 'Platform',
    environment: Environment.staging,
    health: ServiceHealth.maintenance,
    p95Ms: 96,
    errorRate: 0,
    owners: [_eli, _ann],
  ),
  ServiceRow(
    name: 'auth-gateway',
    team: 'Platform',
    environment: Environment.production,
    health: ServiceHealth.healthy,
    p95Ms: 61,
    errorRate: 0.0002,
    owners: [_ann, _eli, _bob, _cleo, _dev],
  ),
  ServiceRow(
    name: 'billing-reconciler',
    team: 'Payments',
    environment: Environment.staging,
    health: ServiceHealth.degraded,
    p95Ms: 1580,
    errorRate: 0.0091,
    owners: [_bob],
  ),
  ServiceRow(
    name: 'feature-flags',
    team: 'Platform',
    environment: Environment.development,
    health: ServiceHealth.healthy,
    p95Ms: 38,
    errorRate: 0,
    owners: [_dev, _cleo],
  ),
];

/// One entry in the incident feed.
class IncidentEvent {
  /// Headline, e.g. "Error budget burn on checkout-api".
  final String title;

  /// When it happened, phrased relatively.
  final String when;

  /// Longer explanation shown under the title.
  final String detail;

  /// Timeline colouring for the rail dot.
  final OctoTimelineVariant variant;

  /// Rail glyph.
  final IconData icon;

  /// Creates an incident entry.
  const IncidentEvent({
    required this.title,
    required this.when,
    required this.detail,
    required this.variant,
    required this.icon,
  });
}

/// Incident feed shown beside the service table.
const List<IncidentEvent> demoIncidents = [
  IncidentEvent(
    title: 'search-indexer stopped responding',
    when: '4 minutes ago',
    detail: 'Health checks failing in eu-west-1. Auto-rollback in progress.',
    variant: OctoTimelineVariant.danger,
    icon: OctIcons.alert_16,
  ),
  IncidentEvent(
    title: 'Error budget burn on checkout-api',
    when: '38 minutes ago',
    detail:
        'p95 latency above 800 ms for 30 minutes; 2.1% of requests failing.',
    variant: OctoTimelineVariant.attention,
    icon: OctIcons.graph_16,
  ),
  IncidentEvent(
    title: 'notification-relay entered maintenance',
    when: '2 hours ago',
    detail: 'Planned queue migration. Traffic drained to the standby cluster.',
    variant: OctoTimelineVariant.standard,
    icon: OctIcons.tools_16,
  ),
  IncidentEvent(
    title: 'ledger-worker recovered',
    when: '5 hours ago',
    detail: 'Backlog drained after the connection-pool fix shipped.',
    variant: OctoTimelineVariant.success,
    icon: OctIcons.check_circle_16,
  ),
];
