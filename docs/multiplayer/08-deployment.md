# Phase 8: Deployment and Monitoring

This document covers the deployment process, monitoring setup, and production considerations for the WortSpion multiplayer implementation.

## Prerequisites

- [ ] All development phases completed (1-7)
- [ ] Testing phase passed
- [ ] Production Supabase project created
- [ ] App store accounts ready
- [ ] Monitoring tools selected

## 1. Environment Configuration

### 1.1 Environment Variables

```dart
// lib/core/config/environment.dart
enum Environment { development, staging, production }

class EnvironmentConfig {
  static const Map<Environment, Map<String, String>> _config = {
    Environment.development: {
      'SUPABASE_URL': 'http://localhost:54321',
      'SUPABASE_ANON_KEY': 'dev-anon-key',
      'SENTRY_DSN': '',
      'ANALYTICS_KEY': '',
    },
    Environment.staging: {
      'SUPABASE_URL': 'https://staging-project.supabase.co',
      'SUPABASE_ANON_KEY': 'staging-anon-key',
      'SENTRY_DSN': 'https://staging.sentry.io/...',
      'ANALYTICS_KEY': 'staging-analytics-key',
    },
    Environment.production: {
      'SUPABASE_URL': 'https://prod-project.supabase.co',
      'SUPABASE_ANON_KEY': 'prod-anon-key',
      'SENTRY_DSN': 'https://prod.sentry.io/...',
      'ANALYTICS_KEY': 'prod-analytics-key',
    },
  };
  
  static late Environment _environment;
  
  static void initialize(Environment env) {
    _environment = env;
  }
  
  static String get(String key) {
    return _config[_environment]?[key] ?? '';
  }
  
  static bool get isProduction => _environment == Environment.production;
  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
}
```

### 1.2 Build Configuration

```yaml
# build_config.yaml
targets:
  development:
    dart_defines:
      - ENVIRONMENT=development
    
  staging:
    dart_defines:
      - ENVIRONMENT=staging
    obfuscate: true
    
  production:
    dart_defines:
      - ENVIRONMENT=production
    obfuscate: true
    split_debug_info: build/debug_info
```

## 2. Supabase Production Setup

### 2.1 Database Optimization

```sql
-- Performance indexes for production
CREATE INDEX CONCURRENTLY idx_game_rooms_active 
  ON game_rooms(room_code, is_active) 
  WHERE is_active = TRUE;

CREATE INDEX CONCURRENTLY idx_room_players_connected 
  ON room_players(room_id, is_connected) 
  WHERE is_connected = TRUE;

CREATE INDEX CONCURRENTLY idx_player_roles_round 
  ON player_roles(round_id, player_id);

CREATE INDEX CONCURRENTLY idx_votes_round 
  ON votes(round_id, voter_id);

-- Partitioning for game_events table
CREATE TABLE game_events_2024_01 PARTITION OF game_events
  FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

-- Create monthly partitions for the year
DO $$
DECLARE
  start_date date := '2024-01-01';
  end_date date;
BEGIN
  FOR i IN 0..11 LOOP
    end_date := start_date + interval '1 month';
    EXECUTE format(
      'CREATE TABLE IF NOT EXISTS game_events_%s PARTITION OF game_events
       FOR VALUES FROM (%L) TO (%L)',
      to_char(start_date, 'YYYY_MM'),
      start_date,
      end_date
    );
    start_date := end_date;
  END LOOP;
END $$;

-- Vacuum and analyze for query optimization
VACUUM ANALYZE game_rooms;
VACUUM ANALYZE room_players;
VACUUM ANALYZE player_roles;
```

### 2.2 Security Configuration

```sql
-- Additional RLS policies for production
CREATE POLICY "Rate limit room creation"
  ON game_rooms FOR INSERT
  WITH CHECK (
    (SELECT COUNT(*) FROM game_rooms 
     WHERE host_id = auth.uid() 
     AND created_at > NOW() - INTERVAL '1 hour') < 10
  );

CREATE POLICY "Prevent room spam"
  ON game_rooms FOR INSERT
  WITH CHECK (
    NOT EXISTS (
      SELECT 1 FROM game_rooms
      WHERE host_id = auth.uid()
      AND created_at > NOW() - INTERVAL '1 minute'
    )
  );

-- Function to validate and sanitize inputs
CREATE OR REPLACE FUNCTION sanitize_player_name(input_name TEXT)
RETURNS TEXT AS $$
BEGIN
  -- Remove HTML tags
  input_name := regexp_replace(input_name, '<[^>]+>', '', 'g');
  -- Trim whitespace
  input_name := TRIM(input_name);
  -- Limit length
  input_name := LEFT(input_name, 20);
  -- Ensure not empty
  IF LENGTH(input_name) = 0 THEN
    input_name := 'Spieler';
  END IF;
  RETURN input_name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 2.3 Edge Function Deployment

```bash
# Deploy all functions to production
supabase functions deploy --project-ref your-project-ref

# Set production secrets
supabase secrets set --project-ref your-project-ref \
  SMTP_HOST=smtp.sendgrid.net \
  SMTP_USER=apikey \
  SMTP_PASS=your-sendgrid-api-key \
  PUSH_NOTIFICATION_KEY=your-fcm-key
```

## 3. Flutter App Deployment

### 3.1 Android Release Build

```bash
# Generate keystore (one time)
keytool -genkey -v -keystore ~/wortspion-release.keystore \
  -alias wortspion -keyalg RSA -keysize 2048 -validity 10000

# Configure key.properties
cat > android/key.properties << EOF
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=wortspion
storeFile=/Users/username/wortspion-release.keystore
EOF

# Build release APK
flutter build apk --release --dart-define=ENVIRONMENT=production

# Build release App Bundle
flutter build appbundle --release --dart-define=ENVIRONMENT=production
```

### 3.2 iOS Release Build

```bash
# Configure signing in Xcode
open ios/Runner.xcworkspace

# Build release IPA
flutter build ipa --release --dart-define=ENVIRONMENT=production

# Or use Fastlane
cd ios && fastlane release
```

### 3.3 Release Configuration

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment
  const environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  EnvironmentConfig.initialize(
    Environment.values.firstWhere(
      (e) => e.name == environment,
      orElse: () => Environment.development,
    ),
  );
  
  // Initialize crash reporting
  if (EnvironmentConfig.isProduction) {
    await initializeCrashlytics();
    await initializeAnalytics();
  }
  
  // Initialize Supabase
  await Supabase.initialize(
    url: EnvironmentConfig.get('SUPABASE_URL'),
    anonKey: EnvironmentConfig.get('SUPABASE_ANON_KEY'),
  );
  
  // Setup dependency injection
  await setupLocator();
  
  // Run app with error handling
  runZonedGuarded(
    () => runApp(WortSpionApp()),
    (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack),
  );
}
```

## 4. Monitoring Setup

### 4.1 Application Monitoring

```dart
// lib/core/monitoring/monitoring_service.dart
class MonitoringService {
  static final _analytics = FirebaseAnalytics.instance;
  static final _crashlytics = FirebaseCrashlytics.instance;
  static final _performance = FirebasePerformance.instance;
  
  // Track custom events
  static Future<void> logEvent(String name, [Map<String, dynamic>? parameters]) async {
    if (EnvironmentConfig.isProduction) {
      await _analytics.logEvent(name: name, parameters: parameters);
    } else {
      print('Analytics Event: $name ${parameters ?? {}}');
    }
  }
  
  // Track screen views
  static Future<void> logScreenView(String screenName) async {
    await _analytics.setCurrentScreen(screenName: screenName);
  }
  
  // Track performance
  static Future<T> trackPerformance<T>(
    String name,
    Future<T> Function() operation,
  ) async {
    final trace = _performance.newTrace(name);
    await trace.start();
    
    try {
      final result = await operation();
      await trace.stop();
      return result;
    } catch (e) {
      trace.putAttribute('error', e.toString());
      await trace.stop();
      rethrow;
    }
  }
  
  // Track user properties
  static Future<void> setUserProperties(Map<String, String> properties) async {
    for (final entry in properties.entries) {
      await _analytics.setUserProperty(name: entry.key, value: entry.value);
    }
  }
  
  // Log errors
  static Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    Map<String, String>? extras,
  }) async {
    if (EnvironmentConfig.isProduction) {
      await _crashlytics.recordError(error, stackTrace, information: extras ?? {});
    } else {
      print('Error: $error\n$stackTrace');
    }
  }
}
```

### 4.2 Game Analytics Events

```dart
// lib/core/monitoring/game_analytics.dart
class GameAnalytics {
  // Game lifecycle events
  static Future<void> logGameCreated({
    required int playerCount,
    required int impostorCount,
    required int roundCount,
  }) async {
    await MonitoringService.logEvent('game_created', {
      'player_count': playerCount,
      'impostor_count': impostorCount,
      'round_count': roundCount,
    });
  }
  
  static Future<void> logGameJoined({
    required String joinMethod,
  }) async {
    await MonitoringService.logEvent('game_joined', {
      'join_method': joinMethod, // 'code' or 'qr'
    });
  }
  
  static Future<void> logGameStarted({
    required String gameId,
    required int actualPlayerCount,
  }) async {
    await MonitoringService.logEvent('game_started', {
      'game_id': gameId,
      'actual_player_count': actualPlayerCount,
    });
  }
  
  static Future<void> logRoundCompleted({
    required String gameId,
    required int roundNumber,
    required bool impostorsWon,
    required Duration roundDuration,
  }) async {
    await MonitoringService.logEvent('round_completed', {
      'game_id': gameId,
      'round_number': roundNumber,
      'impostors_won': impostorsWon,
      'duration_seconds': roundDuration.inSeconds,
    });
  }
  
  static Future<void> logGameCompleted({
    required String gameId,
    required String winnerId,
    required Duration gameDuration,
  }) async {
    await MonitoringService.logEvent('game_completed', {
      'game_id': gameId,
      'winner_id': winnerId,
      'duration_minutes': gameDuration.inMinutes,
    });
  }
  
  // Player actions
  static Future<void> logVoteSubmitted({
    required String gameId,
    required int timeRemaining,
  }) async {
    await MonitoringService.logEvent('vote_submitted', {
      'game_id': gameId,
      'time_remaining_seconds': timeRemaining,
    });
  }
  
  // Connection events
  static Future<void> logConnectionLost({
    required String reason,
  }) async {
    await MonitoringService.logEvent('connection_lost', {
      'reason': reason,
    });
  }
  
  static Future<void> logReconnected({
    required Duration disconnectDuration,
  }) async {
    await MonitoringService.logEvent('reconnected', {
      'disconnect_duration_seconds': disconnectDuration.inSeconds,
    });
  }
}
```

### 4.3 Supabase Monitoring

```sql
-- Create monitoring views
CREATE VIEW game_metrics AS
SELECT 
  DATE(created_at) as date,
  COUNT(*) as games_created,
  AVG(player_count) as avg_players,
  COUNT(DISTINCT host_id) as unique_hosts
FROM game_rooms
GROUP BY DATE(created_at);

CREATE VIEW player_metrics AS
SELECT 
  DATE(joined_at) as date,
  COUNT(*) as players_joined,
  AVG(CASE WHEN is_connected THEN 1 ELSE 0 END) as connection_rate
FROM room_players
GROUP BY DATE(joined_at);

-- Create monitoring functions
CREATE OR REPLACE FUNCTION get_active_games()
RETURNS TABLE(
  room_count INTEGER,
  player_count INTEGER,
  avg_players_per_room NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(DISTINCT r.id)::INTEGER,
    COUNT(p.id)::INTEGER,
    AVG(player_counts.count)::NUMERIC
  FROM game_rooms r
  LEFT JOIN room_players p ON p.room_id = r.id AND p.is_connected = TRUE
  LEFT JOIN LATERAL (
    SELECT COUNT(*) as count 
    FROM room_players 
    WHERE room_id = r.id AND is_connected = TRUE
  ) player_counts ON TRUE
  WHERE r.is_active = TRUE
  AND r.created_at > NOW() - INTERVAL '24 hours';
END;
$$ LANGUAGE plpgsql;

-- Create alerts
CREATE OR REPLACE FUNCTION check_system_health()
RETURNS TABLE(
  metric TEXT,
  value NUMERIC,
  status TEXT
) AS $$
BEGIN
  -- Check active connections
  RETURN QUERY
  SELECT 
    'active_connections'::TEXT,
    COUNT(*)::NUMERIC,
    CASE 
      WHEN COUNT(*) > 1000 THEN 'critical'
      WHEN COUNT(*) > 800 THEN 'warning'
      ELSE 'ok'
    END
  FROM pg_stat_activity;
  
  -- Check error rate
  RETURN QUERY
  SELECT 
    'error_rate'::TEXT,
    (COUNT(*) FILTER (WHERE event_data->>'error' IS NOT NULL) * 100.0 / NULLIF(COUNT(*), 0))::NUMERIC,
    CASE 
      WHEN COUNT(*) FILTER (WHERE event_data->>'error' IS NOT NULL) * 100.0 / NULLIF(COUNT(*), 0) > 5 THEN 'critical'
      WHEN COUNT(*) FILTER (WHERE event_data->>'error' IS NOT NULL) * 100.0 / NULLIF(COUNT(*), 0) > 2 THEN 'warning'
      ELSE 'ok'
    END
  FROM game_events
  WHERE created_at > NOW() - INTERVAL '1 hour';
END;
$$ LANGUAGE plpgsql;
```

## 5. Performance Optimization

### 5.1 App Performance

```dart
// lib/core/performance/performance_optimizer.dart
class PerformanceOptimizer {
  // Image caching
  static void precacheGameImages(BuildContext context) {
    const imagePaths = [
      'assets/images/logo.png',
      'assets/images/spy_icon.png',
      'assets/images/team_icon.png',
    ];
    
    for (final path in imagePaths) {
      precacheImage(AssetImage(path), context);
    }
  }
  
  // Widget optimization
  static Widget optimizedList({
    required List<dynamic> items,
    required Widget Function(dynamic) itemBuilder,
  }) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => itemBuilder(items[index]),
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
    );
  }
  
  // Debouncing for real-time updates
  static Function debounce(
    Function function,
    Duration duration,
  ) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(duration, () => function());
    };
  }
}
```

### 5.2 Network Optimization

```dart
// lib/core/network/network_optimizer.dart
class NetworkOptimizer {
  static final _cache = <String, CachedResponse>{};
  
  // Response caching
  static Future<T> cachedRequest<T>({
    required String key,
    required Future<T> Function() request,
    Duration cacheDuration = const Duration(minutes: 5),
  }) async {
    final cached = _cache[key];
    
    if (cached != null && !cached.isExpired) {
      return cached.data as T;
    }
    
    final result = await request();
    _cache[key] = CachedResponse(
      data: result,
      expiry: DateTime.now().add(cacheDuration),
    );
    
    return result;
  }
  
  // Batch requests
  static Future<List<T>> batchRequests<T>(
    List<Future<T> Function()> requests,
    {int batchSize = 3}
  ) async {
    final results = <T>[];
    
    for (int i = 0; i < requests.length; i += batchSize) {
      final batch = requests.skip(i).take(batchSize);
      final batchResults = await Future.wait(
        batch.map((r) => r()),
      );
      results.addAll(batchResults);
    }
    
    return results;
  }
}
```

## 6. Deployment Pipeline

### 6.1 CI/CD Configuration

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy-supabase:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Supabase CLI
        uses: supabase/setup-cli@v1
        
      - name: Deploy Database Migrations
        run: |
          supabase db push --project-ref ${{ secrets.SUPABASE_PROJECT_REF }}
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
          
      - name: Deploy Edge Functions
        run: |
          supabase functions deploy --project-ref ${{ secrets.SUPABASE_PROJECT_REF }}
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
  
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      
      - name: Decode Keystore
        run: |
          echo "${{ secrets.ANDROID_KEYSTORE }}" | base64 --decode > android/app/keystore.jks
          
      - name: Create key.properties
        run: |
          echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" > android/key.properties
          echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
          echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
          echo "storeFile=keystore.jks" >> android/key.properties
          
      - name: Build App Bundle
        run: flutter build appbundle --release --dart-define=ENVIRONMENT=production
        
      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_SERVICE_ACCOUNT }}
          packageName: com.example.wortspion
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: production
  
  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      
      - name: Install Certificates
        uses: apple-actions/import-codesign-certs@v1
        with:
          p12-file-base64: ${{ secrets.IOS_CERTIFICATES }}
          p12-password: ${{ secrets.IOS_CERTIFICATES_PASSWORD }}
          
      - name: Install Provisioning Profile
        uses: akiojin/install-provisioning-profile-github-action@v1
        with:
          base64: ${{ secrets.IOS_PROVISIONING_PROFILE }}
          
      - name: Build IPA
        run: flutter build ipa --release --dart-define=ENVIRONMENT=production
        
      - name: Upload to TestFlight
        uses: apple-actions/upload-testflight-build@v1
        with:
          app-path: build/ios/ipa/wortspion.ipa
          issuer-id: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
          api-key-id: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
          api-private-key: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
```

### 6.2 Release Process

```bash
# scripts/release.sh
#!/bin/bash

# Get version from pubspec.yaml
VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //')

echo "Releasing version $VERSION"

# Run tests
echo "Running tests..."
flutter test

# Build for all platforms
echo "Building Android..."
flutter build appbundle --release --dart-define=ENVIRONMENT=production

echo "Building iOS..."
flutter build ipa --release --dart-define=ENVIRONMENT=production

# Create git tag
git tag -a "v$VERSION" -m "Release version $VERSION"
git push origin "v$VERSION"

echo "Release complete! CI/CD will handle deployment."
```

## 7. Post-Deployment

### 7.1 Health Checks

```dart
// lib/core/health/health_check_service.dart
class HealthCheckService {
  static Future<HealthStatus> checkSystemHealth() async {
    final checks = <String, bool>{};
    
    // Check Supabase connection
    try {
      await Supabase.instance.client
          .from('categories')
          .select()
          .limit(1);
      checks['supabase'] = true;
    } catch (e) {
      checks['supabase'] = false;
    }
    
    // Check realtime connection
    try {
      final channel = Supabase.instance.client.channel('health-check');
      await channel.subscribe();
      channel.unsubscribe();
      checks['realtime'] = true;
    } catch (e) {
      checks['realtime'] = false;
    }
    
    // Check edge functions
    try {
      await Supabase.instance.client.functions.invoke(
        'health-check',
        body: {'timestamp': DateTime.now().toIso8601String()},
      );
      checks['functions'] = true;
    } catch (e) {
      checks['functions'] = false;
    }
    
    return HealthStatus(
      isHealthy: checks.values.every((v) => v),
      checks: checks,
      timestamp: DateTime.now(),
    );
  }
}
```

### 7.2 Rollback Plan

```yaml
# rollback_plan.yaml
rollback_procedures:
  database:
    - Identify the last working migration
    - Run: supabase db reset --project-ref <ref>
    - Apply migrations up to the last working version
    
  edge_functions:
    - List function versions: supabase functions list
    - Deploy previous version: supabase functions deploy <function> --version <previous>
    
  mobile_apps:
    android:
      - Go to Play Console
      - Select the app
      - Go to Release > Production
      - Create new release with previous APK/AAB
      
    ios:
      - Go to App Store Connect
      - Remove current version from sale
      - Expedite review for previous version
```

## 8. Monitoring Dashboard

### 8.1 Key Metrics

```typescript
// monitoring/dashboard_config.ts
export const dashboardConfig = {
  metrics: [
    {
      name: 'Active Games',
      query: 'SELECT COUNT(*) FROM game_rooms WHERE is_active = true',
      threshold: { warning: 100, critical: 200 },
      refreshInterval: 30,
    },
    {
      name: 'Connected Players',
      query: 'SELECT COUNT(*) FROM room_players WHERE is_connected = true',
      threshold: { warning: 500, critical: 1000 },
      refreshInterval: 30,
    },
    {
      name: 'Error Rate',
      query: `
        SELECT 
          COUNT(*) FILTER (WHERE event_type = 'error') * 100.0 / COUNT(*)
        FROM game_events 
        WHERE created_at > NOW() - INTERVAL '5 minutes'
      `,
      threshold: { warning: 2, critical: 5 },
      refreshInterval: 60,
    },
    {
      name: 'Average Game Duration',
      query: `
        SELECT AVG(EXTRACT(EPOCH FROM (finished_at - started_at)) / 60)
        FROM game_rooms 
        WHERE finished_at IS NOT NULL 
        AND finished_at > NOW() - INTERVAL '1 hour'
      `,
      unit: 'minutes',
      refreshInterval: 300,
    },
  ],
  
  alerts: [
    {
      name: 'High Error Rate',
      condition: 'error_rate > 5',
      action: 'email',
      recipients: ['dev-team@example.com'],
    },
    {
      name: 'Database Connection Pool Exhausted',
      condition: 'connection_count > 90',
      action: 'slack',
      channel: '#alerts',
    },
  ],
};
```

## 9. Documentation

### 9.1 Operations Manual

```markdown
# WortSpion Operations Manual

## Daily Tasks
- [ ] Check monitoring dashboard
- [ ] Review error logs
- [ ] Check active game count
- [ ] Verify backup completion

## Weekly Tasks
- [ ] Review performance metrics
- [ ] Check user feedback
- [ ] Update dependency versions
- [ ] Run security scan

## Incident Response
1. Identify the issue through monitoring/alerts
2. Check recent deployments
3. Review error logs
4. Implement fix or rollback
5. Notify users if necessary
6. Post-mortem analysis

## Common Issues

### High Memory Usage
- Check for memory leaks in realtime subscriptions
- Review concurrent game count
- Scale up Supabase instance if needed

### Slow Response Times
- Check database query performance
- Review edge function cold starts
- Enable connection pooling

### Connection Issues
- Verify Supabase status
- Check SSL certificates
- Review firewall rules
```

## 10. Deployment Checklist

### Pre-Deployment
- [ ] All tests passing
- [ ] Security scan completed
- [ ] Performance benchmarks met
- [ ] Documentation updated
- [ ] Release notes prepared

### Deployment
- [ ] Database migrations applied
- [ ] Edge functions deployed
- [ ] Environment variables set
- [ ] Mobile apps built
- [ ] Version tags created

### Post-Deployment
- [ ] Health checks passing
- [ ] Monitoring active
- [ ] Error rates normal
- [ ] User reports monitored
- [ ] Rollback plan ready

### Communication
- [ ] Team notified
- [ ] Status page updated
- [ ] App store descriptions updated
- [ ] Social media announcement
- [ ] Support team briefed

## Next Steps

1. Set up monitoring dashboards
2. Configure alerting rules
3. Create runbooks for common issues
4. Proceed to [Migration Checklist](./09-migration-checklist.md)
