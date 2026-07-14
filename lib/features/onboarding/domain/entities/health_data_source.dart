// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

/// Health & Fitness data source integration.
///
/// Connects to external portals that expose health, fitness, or medical data:
/// - Strava (fitness/running data)
/// - Google Fit / Google Health Connect
/// - Apple HealthKit
/// - Garmin Connect
/// - Fitbit
/// - Oura Ring
/// - Whoop
///
/// Each source exposes an OAuth2 or API-key secured endpoint that
/// OrionHealth can poll for metrics (heart rate, steps, sleep, workouts, etc.).
///
/// Privacy: All data fetched is stored locally on-device. Credentials are
/// stored in flutter_secure_storage.

import 'package:flutter/material.dart';

/// A supported external health data source.
class HealthDataSource {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final HealthDataSourceCategory category;
  final String? connectUrl; // OAuth redirect if available
  final List<String> dataTypes;

  const HealthDataSource({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    this.connectUrl,
    this.dataTypes = const [],
  });
}

enum HealthDataSourceCategory {
  fitness,
  wearables,
  medical,
  nutrition,
  sleep,
  other,
}

/// Catalog of supported health data sources.
class HealthDataSourcesCatalog {
  HealthDataSourcesCatalog._();

  static List<HealthDataSource> get fitnessSources => [
    const HealthDataSource(
      id: 'strava',
      name: 'Strava',
      description: 'Running, cycling, and fitness tracking',
      icon: Icons.directions_run,
      category: HealthDataSourceCategory.fitness,
      dataTypes: ['workouts', 'heart_rate', 'distance', 'pace', 'calories'],
    ),
    const HealthDataSource(
      id: 'google_fit',
      name: 'Google Fit',
      description: 'Activity tracking, heart rate, sleep',
      icon: Icons.fitness_center,
      category: HealthDataSourceCategory.fitness,
      dataTypes: ['steps', 'heart_rate', 'calories', 'sleep', 'workouts'],
    ),
    const HealthDataSource(
      id: 'google_health_connect',
      name: 'Google Health Connect',
      description: 'Android health data platform (FHIR-compatible)',
      icon: Icons.health_and_safety,
      category: HealthDataSourceCategory.medical,
      dataTypes: ['steps', 'heart_rate', 'sleep', 'blood_pressure', 'glucose', 'weight'],
    ),
    const HealthDataSource(
      id: 'apple_health',
      name: 'Apple Health',
      description: 'iOS health & activity data (HealthKit)',
      icon: Icons.apple,
      category: HealthDataSourceCategory.medical,
      dataTypes: ['steps', 'heart_rate', 'sleep', 'workouts', 'blood_oxygen'],
    ),
    const HealthDataSource(
      id: 'garmin',
      name: 'Garmin Connect',
      description: 'Garmin watches and fitness devices',
      icon: Icons.watch,
      category: HealthDataSourceCategory.wearables,
      dataTypes: ['workouts', 'heart_rate', 'sleep', 'stress', 'body_battery'],
    ),
    const HealthDataSource(
      id: 'fitbit',
      name: 'Fitbit',
      description: 'Fitbit activity and sleep trackers',
      icon: Icons.monitor_heart,
      category: HealthDataSourceCategory.wearables,
      dataTypes: ['steps', 'heart_rate', 'sleep', 'calories', 'exercise'],
    ),
    const HealthDataSource(
      id: 'oura',
      name: 'Oura Ring',
      description: 'Sleep, readiness, and activity ring',
      icon: Icons.circle,
      category: HealthDataSourceCategory.sleep,
      dataTypes: ['sleep', 'readiness', 'heart_rate', 'temperature', 'hrv'],
    ),
    const HealthDataSource(
      id: 'whoop',
      name: 'Whoop',
      description: 'Strain, recovery, and sleep tracking',
      icon: Icons.bar_chart,
      category: HealthDataSourceCategory.fitness,
      dataTypes: ['strain', 'recovery', 'sleep', 'heart_rate', 'hrv'],
    ),
    const HealthDataSource(
      id: 'myfitnesspal',
      name: 'MyFitnessPal',
      description: 'Nutrition and calorie tracking',
      icon: Icons.restaurant,
      category: HealthDataSourceCategory.nutrition,
      dataTypes: ['calories', 'macros', 'weight', 'water'],
    ),
    const HealthDataSource(
      id: 'samsung_health',
      name: 'Samsung Health',
      description: 'Samsung health platform (Android)',
      icon: Icons.phone_android,
      category: HealthDataSourceCategory.fitness,
      dataTypes: ['steps', 'heart_rate', 'sleep', 'blood_pressure', 'weight'],
    ),
  ];

  static List<HealthDataSource> get all => fitnessSources;

  static HealthDataSource? byId(String id) {
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<HealthDataSource> byCategory(HealthDataSourceCategory cat) {
    return all.where((s) => s.category == cat).toList();
  }
}
