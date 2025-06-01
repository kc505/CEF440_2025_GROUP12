
import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet, StatusBar } from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';


const Footer = ({ 
  appName = "My App", 
  onNotificationPress,
  notificationCount = 0,
  backgroundColor = '#fff',
  textColor = '#333',
   activeTab,        // <<< ADD THIS LINE
  onTabPress        // <<< ADD THIS LINE
}) => {
  return (
    <>
      <StatusBar barStyle="dark-content" backgroundColor={backgroundColor} />
      <View style={[styles.header, { backgroundColor }]}>
        <View style={styles.leftSection}>
          <Text style={[styles.appName, { color: textColor }]}>{appName}</Text>
        </View>
        
        <View style={styles.rightSection}>
          <TouchableOpacity 
            style={styles.notificationContainer}
            onPress={onNotificationPress}
            activeOpacity={0.7}
          >
            <View style={styles.notificationButton}>
              <Ionicons 
                name="notifications-outline" 
                size={24} 
                color={textColor} 
              />
              
              {notificationCount > 0 && (
                <View style={styles.badge}>
                  <Text style={styles.badgeText}>
                    {notificationCount > 99 ? '99+' : notificationCount}
                  </Text>
                </View>
              )}
            </View>
            <Text style={[styles.notificationText, { color: textColor }]}>
              Notification
            </Text>
          </TouchableOpacity>
        </View>
      </View>
    </>
  );
};

const styles = StyleSheet.create({
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
    paddingTop: 16,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  leftSection: {
    flex: 1,
  },
  appName: {
    fontSize: 20,
    fontWeight: 'bold',
  },
  rightSection: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  notificationContainer: {
    alignItems: 'center',
  },
  notificationButton: {
    padding: 8,
    position: 'relative',
  },
  notificationText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#1C1C1E',
    marginTop: -4,
  },
  badge: {
    position: 'absolute',
    top: 4,
    right: 4,
    backgroundColor: '#FF3B30',
    borderRadius: 10,
    minWidth: 20,
    height: 20,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 4,
  },
  badgeText: {
    color: 'white',
    fontSize: 12,
    fontWeight: 'bold',
  },
});

export default Footer;