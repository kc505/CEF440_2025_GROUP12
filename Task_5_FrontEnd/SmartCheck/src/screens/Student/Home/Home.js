import React, { useState } from 'react';
import {
  View,
  Text,
  SafeAreaView,
  FlatList,
  StyleSheet,
  TouchableOpacity,
} from 'react-native';
import Header from '../../../components/Header';
import Footer from '../../../components/Footer';

const Home = () => {
  const [activeTab, setActiveTab] = useState ('home');

  const menuItems = [
    { title: 'Attendance Login', screen: 'AttendanceLogin' },
    { title: 'Show Attendance', screen: 'AttendanceHistory' },
    { title: 'Create Dispute/Leave', screen: 'DisputeForm' },
    { title: 'View Course', screen: 'CourseList' },
  ];

  const handleNavigation = (screen) => {
   navigation.navigate(screen);
  };

  const renderItem = ({ item }) => (
    <TouchableOpacity
      style={styles.card}
      onPress={() => handleNavigation(item.screen)}
    >
      <Text style={styles.icon}>📘</Text>
      <Text style={styles.title}>{item.title}</Text>
    </TouchableOpacity>
  );

  return (

    <SafeAreaView style={styles.container}>
      <Header
        appName="SmartCheck"
        onNotificationPress={() => alert('You have new notifications!')}
        notificationCount={3}
      />

      <FlatList
        data={menuItems}
        keyExtractor={(item) => item.title}
        numColumns={2}
        columnWrapperStyle={{ justifyContent: 'space-between' }}
        contentContainerStyle={{ padding: 16, paddingBottom: 80 }}
        renderItem={renderItem}
      />

      <Footer activeTab={activeTab} onTabPress={setActiveTab} />
    </SafeAreaView>
  );
};

export default Home;

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
  card: {
    width: '48%',
    backgroundColor: '#f9f9f9',
    borderRadius: 12,
    paddingVertical: 24,
    paddingHorizontal: 8,
    alignItems: 'center',
    marginBottom: 16,
    elevation: 3,
  },
  icon: {
    fontSize: 28,
  },
  title: {
    fontSize: 14,
    fontWeight: '600',
    marginTop: 8,
    textAlign: 'center',
  },
});
