import React from 'react';
import { View, TouchableOpacity, Text, StyleSheet, Platform } from 'react-native';
import Icon from 'react-native-vector-icons/Ionicons';

const Footer = ({
  activeTab = 'home',
  onTabPress,
  backgroundColor = '#fff'
}) => {
  const tabs = [
    {
      id: 'home',
      label: 'Home',
      icon: 'home-outline',
      activeIcon: 'home'
    },
    {
      id: 'dashboard',
      label: 'Dashboard',
      icon: 'grid-outline',
      activeIcon: 'grid'
    },
    {
      id: 'profile',
      label: 'Profile',
      icon: 'person-outline',
      activeIcon: 'person'
    },
    {
      id: 'dispute',
      label: 'Dispute',
      icon: 'alert-circle-outline',
      activeIcon: 'alert-circle'
    }
  ];

  return (
    <View style={[styles.footer, { backgroundColor }]}>
      {tabs.map((tab) => {
        const isActive = activeTab === tab.id;
        return (
          <TouchableOpacity
            key={tab.id}
            style={styles.tabButton}
            onPress={() => onTabPress && onTabPress(tab.id)}
            activeOpacity={0.7}
          >
            <Icon
              name={isActive ? tab.activeIcon : tab.icon}
              size={24}
              color={isActive ? '#007AFF' : '#666'}
            />
            <Text style={[
              styles.tabLabel,
              { color: isActive ? '#007AFF' : '#666' }
            ]}>
              {tab.label}
            </Text>
          </TouchableOpacity>
        );
      })}
    </View>
  );
};

const styles = StyleSheet.create({
  footer: {
    flexDirection: 'row',
    paddingVertical: 8,
    paddingBottom: Platform.OS === 'ios' ? 20 : 12,
    borderTopWidth: 1,
    borderTopColor: '#E5E5E5',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: -2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 8,
  },
  tabButton: {
    flex: 1,
    alignItems: 'center',
    paddingVertical: 8,
  },
  tabLabel: {
    fontSize: 12,
    fontWeight: '500',
    marginTop: 4,
  },
});

export default Footer;