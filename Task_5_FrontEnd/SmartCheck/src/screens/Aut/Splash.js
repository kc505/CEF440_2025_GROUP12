import React, { useState, useEffect, useRef } from 'react';
import { View, Text, Animated, StyleSheet, Easing } from 'react-native';

const SplashScreen = ({ navigation }) => {
  const [progress, setProgress] = useState(0);
  const [currentFeatureIndex, setCurrentFeatureIndex] = useState(0);
  const fadeAnim = useRef(new Animated.Value(0)).current;

  const features = [
    { title: "Facial Recognition", description: "Advanced AI-powered facial recognition for secure and accurate student identification" },
    { title: "Geofencing Technology", description: "Location-based attendance tracking ensures students are physically present in class" },
    { title: "Real-time Tracking", description: "Instant attendance updates with comprehensive reporting and analytics" },
    { title: "Class Management", description: "Effortlessly manage multiple classes and track student participation" },
    { title: "Smart Scheduling", description: "Automated attendance tracking based on class schedules and time slots" },
    { title: "Secure & Private", description: "Enterprise-grade security ensuring your data remains protected" },
  ];

  useEffect(() => {
    // Fade in animation
    Animated.timing(fadeAnim, {
      toValue: 1,
      duration: 1000,
      easing: Easing.ease,
      useNativeDriver: true,
    }).start();

    // Progress bar timer
    const progressTimer = setInterval(() => {
      setProgress(prev => {
        if (prev >= 100) {
          clearInterval(progressTimer);
          // Navigate to StudentHome after a short delay
          setTimeout(() => {
            navigation.replace('StudentHome');
          }, 500);
          return 100;
        }
        return prev + 0.5;
      });
    }, 80);

    // Feature carousel timer
    const carouselTimer = setInterval(() => {
      setCurrentFeatureIndex(prev => (prev + 1) % features.length);
    }, 2500);

    return () => {
      clearInterval(progressTimer);
      clearInterval(carouselTimer);
    };
  }, [fadeAnim, features.length, navigation]);

  const currentFeature = features[currentFeatureIndex];

  return (
    <View style={styles.container}>
      <Animated.View style={[styles.content, { opacity: fadeAnim }]}>
        {/* Logo Section */}
        <View style={styles.logoSection}>
          <View style={styles.logoContainer}>
            <View style={styles.logo}>
              <Text style={styles.logoIcon}>✓</Text>
            </View>
            <View style={styles.pulseIndicator} />
          </View>

          <Text style={styles.appTitle}>AttendEase</Text>
          <Text style={styles.appSubtitle}>Smart Attendance Management</Text>
        </View>

        {/* Feature Showcase */}
        <View style={styles.featureCard}>
          <View style={styles.featureIconContainer}>
            <Text style={styles.featureIcon}>🎯</Text>
          </View>
          <Text style={styles.featureTitle}>{currentFeature.title}</Text>
          <Text style={styles.featureDescription}>{currentFeature.description}</Text>
        </View>

        {/* Feature Indicators */}
        <View style={styles.indicatorContainer}>
          {features.map((_, index) => (
            <View
              key={`indicator-${index}`}
              style={[
                styles.indicator,
                index === currentFeatureIndex && styles.activeIndicator
              ]}
            />
          ))}
        </View>

        {/* Progress Section */}
        <View style={styles.progressSection}>
          <View style={styles.progressBar}>
            <Animated.View
              style={[
                styles.progressFill,
                {
                  width: `${progress}%`,
                  transform: [{
                    translateX: fadeAnim.interpolate({
                      inputRange: [0, 1],
                      outputRange: [-100, 0]
                    })
                  }]
                }
              ]}
            />
          </View>
          <Text style={styles.progressText}>
            Loading... {Math.round(progress)}%
          </Text>
        </View>

        {/* Bottom Features Preview */}
        <View style={styles.bottomFeatures}>
          {['Face', 'Location', 'Track'].map((feature, index) => (
            <View key={`feature-${index}`} style={styles.bottomFeatureItem}>
              <View style={styles.bottomFeatureIcon}>
                <Text style={styles.bottomFeatureIconText}>
                  {['👤', '📍', '⏱️'][index]}
                </Text>
              </View>
              <Text style={styles.bottomFeatureLabel}>{feature}</Text>
            </View>
          ))}
        </View>
      </Animated.View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f0f8ff',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
  },
  content: {
    width: '100%',
    maxWidth: 400,
    alignItems: 'center',
  },
  logoSection: {
    alignItems: 'center',
    marginBottom: 32,
  },
  logoContainer: {
    position: 'relative',
    marginBottom: 24,
  },
  logo: {
    width: 96,
    height: 96,
    backgroundColor: '#3b82f6',
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 8,
  },
  logoIcon: {
    fontSize: 48,
    color: '#ffffff',
    fontWeight: 'bold',
  },
  pulseIndicator: {
    position: 'absolute',
    top: -8,
    right: -8,
    width: 24,
    height: 24,
    backgroundColor: '#4ade80',
    borderRadius: 12,
  },
  appTitle: {
    fontSize: 30,
    fontWeight: 'bold',
    color: '#1f2937',
    marginBottom: 8,
  },
  appSubtitle: {
    fontSize: 18,
    color: '#4b5563',
  },
  featureCard: {
    backgroundColor: '#ffffff',
    borderRadius: 16,
    padding: 24,
    marginBottom: 32,
    minHeight: 200,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.1,
    shadowRadius: 16,
    elevation: 8,
    width: '100%',
  },
  featureIconContainer: {
    width: 64,
    height: 64,
    backgroundColor: '#eff6ff',
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 16,
  },
  featureIcon: {
    fontSize: 32,
  },
  featureTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#1f2937',
    marginBottom: 12,
    textAlign: 'center',
  },
  featureDescription: {
    color: '#4b5563',
    lineHeight: 24,
    textAlign: 'center',
  },
  indicatorContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginBottom: 32,
  },
  indicator: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#d1d5db',
    marginHorizontal: 4,
  },
  activeIndicator: {
    width: 24,
    backgroundColor: '#3b82f6',
  },
  progressSection: {
    width: '100%',
    marginBottom: 16,
  },
  progressBar: {
    width: '100%',
    height: 8,
    backgroundColor: '#e5e7eb',
    borderRadius: 4,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#3b82f6',
    borderRadius: 4,
  },
  progressText: {
    color: '#6b7280',
    fontSize: 14,
    fontWeight: '500',
    textAlign: 'center',
    marginTop: 16,
  },
  bottomFeatures: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    width: '100%',
    marginTop: 32,
  },
  bottomFeatureItem: {
    alignItems: 'center',
  },
  bottomFeatureIcon: {
    width: 40,
    height: 40,
    backgroundColor: '#eff6ff',
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 8,
  },
  bottomFeatureIconText: {
    fontSize: 20,
  },
  bottomFeatureLabel: {
    fontSize: 12,
    color: '#6b7280',
    fontWeight: '500',
  },
});

export default SplashScreen;
