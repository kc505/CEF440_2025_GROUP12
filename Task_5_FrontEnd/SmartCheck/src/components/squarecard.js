// components/SquareCard.js
import React from 'react';
import { TouchableOpacity, View, Text, StyleSheet } from 'react-native';

const SquareCard = ({ 
  title,
  subtitle,
  icon,
  onPress,
  backgroundColor = '#fff',
  iconColor = '#007AFF',
  textColor = '#333',
  disabled = false,
  style
}) => {
  const renderIcon = (iconType) => {
    const color = disabled ? '#ccc' : iconColor;
    
    switch (iconType) {
      case 'checkin':
        return (
          <View style={styles.iconContainer}>
            <View style={[styles.checkinIcon, { borderColor: color }]}>
              <View style={[styles.checkMark, { borderColor: color }]} />
            </View>
          </View>
        );
        
      case 'attendance':
        return (
          <View style={styles.iconContainer}>
            <View style={[styles.attendanceIcon, { borderColor: color }]}>
              <View style={[styles.clockHand1, { backgroundColor: color }]} />
              <View style={[styles.clockHand2, { backgroundColor: color }]} />
              <View style={[styles.clockCenter, { backgroundColor: color }]} />
            </View>
          </View>
        );
        
      case 'course':
        return (
          <View style={styles.iconContainer}>
            <View style={[styles.courseIcon, { borderColor: color }]}>
              <View style={[styles.courseLine1, { backgroundColor: color }]} />
              <View style={[styles.courseLine2, { backgroundColor: color }]} />
              <View style={[styles.courseLine3, { backgroundColor: color }]} />
            </View>
          </View>
        );
        
      case 'view':
        return (
          <View style={styles.iconContainer}>
            <View style={[styles.viewIcon, { borderColor: color }]}>
              <View style={[styles.eyePupil, { backgroundColor: color }]} />
            </View>
          </View>
        );
        
      case 'calendar':
        return (
          <View style={styles.iconContainer}>
            <View style={[styles.calendarIcon, { borderColor: color }]}>
              <View style={[styles.calendarTop, { backgroundColor: color }]} />
              <View style={styles.calendarGrid}>
                <View style={[styles.calendarDot, { backgroundColor: color }]} />
                <View style={[styles.calendarDot, { backgroundColor: color }]} />
                <View style={[styles.calendarDot, { backgroundColor: color }]} />
                <View style={[styles.calendarDot, { backgroundColor: color }]} />
              </View>
            </View>
          </View>
        );
        
      case 'report':
        return (
          <View style={styles.iconContainer}>
            <View style={[styles.reportIcon, { borderColor: color }]}>
              <View style={[styles.reportBar1, { backgroundColor: color }]} />
              <View style={[styles.reportBar2, { backgroundColor: color }]} />
              <View style={[styles.reportBar3, { backgroundColor: color }]} />
            </View>
          </View>
        );
        
      default:
        return (
          <View style={styles.iconContainer}>
            <View style={[styles.defaultIcon, { backgroundColor: color }]} />
          </View>
        );
    }
  };

  return (
    <TouchableOpacity
      style={[
        styles.card,
        { backgroundColor },
        disabled && styles.cardDisabled,
        style
      ]}
      onPress={onPress}
      disabled={disabled}
      activeOpacity={0.7}
    >
      {renderIcon(icon)}
      
      <View style={styles.textContainer}>
        <Text style={[
          styles.title,
          { color: disabled ? '#ccc' : textColor }
        ]}>
          {title}
        </Text>
        
        {subtitle && (
          <Text style={[
            styles.subtitle,
            { color: disabled ? '#ccc' : '#666' }
          ]}>
            {subtitle}
          </Text>
        )}
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  card: {
    width: 150,
    height: 150,
    borderRadius: 12,
    padding: 16,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
    margin: 8,
  },
  cardDisabled: {
    opacity: 0.6,
  },
  iconContainer: {
    width: 48,
    height: 48,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 12,
  },
  textContainer: {
    alignItems: 'center',
  },
  title: {
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 12,
    textAlign: 'center',
    lineHeight: 16,
  },
  
  // Check-in icon styles
  checkinIcon: {
    width: 40,
    height: 40,
    borderRadius: 20,
    borderWidth: 3,
    alignItems: 'center',
    justifyContent: 'center',
  },
  checkMark: {
    width: 12,
    height: 6,
    borderLeftWidth: 3,
    borderBottomWidth: 3,
    borderLeftColor: 'currentColor',
    borderBottomColor: 'currentColor',
    transform: [{ rotate: '-45deg' }],
    marginTop: -4,
  },
  

  attendanceIcon: {
    width: 40,
    height: 40,
    borderRadius: 20,
    borderWidth: 3,
    alignItems: 'center',
    justifyContent: 'center',
    position: 'relative',
  },
  clockHand1: {
    position: 'absolute',
    width: 2,
    height: 10,
    top: 8,
  },
  clockHand2: {
    position: 'absolute',
    width: 2,
    height: 6,
    right: 11,
    top: 13,
  },
  clockCenter: {
    width: 4,
    height: 4,
    borderRadius: 2,
  },
  
  // Course (book) icon styles
  courseIcon: {
    width: 36,
    height: 40,
    borderWidth: 3,
    borderRadius: 4,
    alignItems: 'center',
    justifyContent: 'center',
  },
  courseLine1: {
    width: 20,
    height: 2,
    marginBottom: 4,
  },
  courseLine2: {
    width: 16,
    height: 2,
    marginBottom: 4,
  },
  courseLine3: {
    width: 12,
    height: 2,
  },
  
  // View (eye) icon styles
  viewIcon: {
    width: 44,
    height: 28,
    borderWidth: 3,
    borderRadius: 22,
    alignItems: 'center',
    justifyContent: 'center',
  },
  eyePupil: {
    width: 12,
    height: 12,
    borderRadius: 6,
  },
  
  // Calendar icon styles
  calendarIcon: {
    width: 36,
    height: 40,
    borderWidth: 3,
    borderRadius: 4,
    position: 'relative',
  },
  calendarTop: {
    position: 'absolute',
    top: -3,
    left: -3,
    right: -3,
    height: 8,
    borderTopLeftRadius: 4,
    borderTopRightRadius: 4,
  },
  calendarGrid: {
    flex: 1,
    flexDirection: 'row',
    flexWrap: 'wrap',
    alignItems: 'center',
    justifyContent: 'space-around',
    paddingTop: 8,
  },
  calendarDot: {
    width: 4,
    height: 4,
    borderRadius: 2,
    margin: 2,
  },
  
  // Report (chart) icon styles
  reportIcon: {
    width: 40,
    height: 40,
    borderWidth: 3,
    borderRadius: 4,
    alignItems: 'flex-end',
    justifyContent: 'flex-end',
    paddingBottom: 4,
    paddingRight: 4,
    flexDirection: 'row',
  },
  reportBar1: {
    width: 4,
    height: 12,
    marginRight: 2,
  },
  reportBar2: {
    width: 4,
    height: 20,
    marginRight: 2,
  },
  reportBar3: {
    width: 4,
    height: 16,
  },
  
  // Default icon
  defaultIcon: {
    width: 24,
    height: 24,
    borderRadius: 12,
  },
});

export default SquareCard;