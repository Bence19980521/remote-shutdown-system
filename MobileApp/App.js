import React, { useState, useEffect } from 'react';
import { View, StyleSheet, Alert, ScrollView } from 'react-native';
import { 
  Provider as PaperProvider, 
  Appbar, 
  Card, 
  Title, 
  Paragraph, 
  Button, 
  List, 
  ActivityIndicator,
  Snackbar,
  TextInput,
  Dialog,
  Portal
} from 'react-native-paper';
import { HubConnectionBuilder, HubConnectionState } from '@microsoft/signalr';
import AsyncStorage from '@react-native-async-storage/async-storage';

const SIGNALR_URL = 'https://yourdomain.com/shutdownhub'; // Cloud SignalR Server - változtasd meg!
const SIGNALR_URL_LOCAL = 'http://localhost:5000/shutdownhub'; // Local fallback

export default function App() {
  const [connection, setConnection] = useState(null);
  const [connectionState, setConnectionState] = useState('Disconnected');
  const [devices, setDevices] = useState([]);
  const [loading, setLoading] = useState(false);
  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');
  const [serverUrlDialog, setServerUrlDialog] = useState(false);
  const [serverUrl, setServerUrl] = useState(SIGNALR_URL);

  useEffect(() => {
    loadServerUrl();
  }, []);

  useEffect(() => {
    if (serverUrl) {
      connectToSignalR();
    }
    
    return () => {
      if (connection) {
        connection.stop();
      }
    };
  }, [serverUrl]);

  const loadServerUrl = async () => {
    try {
      const savedUrl = await AsyncStorage.getItem('serverUrl');
      if (savedUrl) {
        setServerUrl(savedUrl);
      }
    } catch (error) {
      console.error('Failed to load server URL:', error);
    }
  };

  const saveServerUrl = async (url) => {
    try {
      await AsyncStorage.setItem('serverUrl', url);
      setServerUrl(url);
    } catch (error) {
      console.error('Failed to save server URL:', error);
    }
  };

  const connectToSignalR = async () => {
    try {
      setLoading(true);
      setConnectionState('Connecting...');

      const newConnection = new HubConnectionBuilder()
        .withUrl(serverUrl)
        .withAutomaticReconnect()
        .build();

      // Connection state change handlers
      newConnection.onclose(() => {
        setConnectionState('Disconnected');
        setDevices([]);
      });

      newConnection.onreconnecting(() => {
        setConnectionState('Reconnecting...');
      });

      newConnection.onreconnected(() => {
        setConnectionState('Connected');
        showMessage('Reconnected to server');
      });

      // Device management handlers
      newConnection.on('DeviceRegistered', (deviceId, deviceName) => {
        setDevices(prev => {
          const existing = prev.find(d => d.id === deviceId);
          if (existing) {
            return prev.map(d => d.id === deviceId ? { ...d, name: deviceName, status: 'Online' } : d);
          }
          return [...prev, { id: deviceId, name: deviceName, status: 'Online' }];
        });
        showMessage(`Device connected: ${deviceName}`);
      });

      newConnection.on('DeviceDisconnected', (deviceId) => {
        setDevices(prev => prev.map(d => d.id === deviceId ? { ...d, status: 'Offline' } : d));
        showMessage('Device disconnected');
      });

      newConnection.on('ShutdownConfirmation', (deviceId, message) => {
        showMessage(`Shutdown confirmed: ${message}`);
      });

      newConnection.on('RestartConfirmation', (deviceId, message) => {
        showMessage(`Restart confirmed: ${message}`);
      });

      newConnection.on('DeviceStatus', (deviceId, status) => {
        Alert.alert(
          'Device Status',
          `Machine: ${status.MachineName}\n` +
          `User: ${status.UserName}\n` +
          `OS: ${status.OSVersion}\n` +
          `CPU Usage: ${status.CPUUsage}%\n` +
          `Free Memory: ${(status.AvailableMemory / 1024 / 1024 / 1024).toFixed(2)} GB\n` +
          `Last Boot: ${new Date(status.LastBootTime).toLocaleString()}`
        );
      });

      await newConnection.start();
      setConnection(newConnection);
      setConnectionState('Connected');
      showMessage('Connected to server');

      // Request list of devices
      await newConnection.invoke('GetDevices');

    } catch (error) {
      console.error('Connection failed:', error);
      setConnectionState('Failed');
      showMessage('Connection failed: ' + error.message);
    } finally {
      setLoading(false);
    }
  };

  const showMessage = (message) => {
    setSnackbarMessage(message);
    setSnackbarVisible(true);
  };

  const shutdownDevice = async (deviceId, deviceName) => {
    Alert.alert(
      'Confirm Shutdown',
      `Are you sure you want to shutdown ${deviceName}?`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Shutdown',
          style: 'destructive',
          onPress: async () => {
            try {
              if (connection && connection.state === HubConnectionState.Connected) {
                await connection.invoke('Shutdown', deviceId);
                showMessage(`Shutdown command sent to ${deviceName}`);
              } else {
                showMessage('Not connected to server');
              }
            } catch (error) {
              showMessage('Failed to send shutdown command: ' + error.message);
            }
          }
        }
      ]
    );
  };

  const restartDevice = async (deviceId, deviceName) => {
    Alert.alert(
      'Confirm Restart',
      `Are you sure you want to restart ${deviceName}?`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Restart',
          style: 'destructive',
          onPress: async () => {
            try {
              if (connection && connection.state === HubConnectionState.Connected) {
                await connection.invoke('Restart', deviceId);
                showMessage(`Restart command sent to ${deviceName}`);
              } else {
                showMessage('Not connected to server');
              }
            } catch (error) {
              showMessage('Failed to send restart command: ' + error.message);
            }
          }
        }
      ]
    );
  };

  const getDeviceStatus = async (deviceId, deviceName) => {
    try {
      if (connection && connection.state === HubConnectionState.Connected) {
        await connection.invoke('GetStatus', deviceId);
      } else {
        showMessage('Not connected to server');
      }
    } catch (error) {
      showMessage('Failed to get device status: ' + error.message);
    }
  };

  const handleServerUrlSave = () => {
    saveServerUrl(serverUrl);
    setServerUrlDialog(false);
    connectToSignalR();
  };

  return (
    <PaperProvider>
      <View style={styles.container}>
        <Appbar.Header>
          <Appbar.Content title="Remote Shutdown" />
          <Appbar.Action 
            icon="cog" 
            onPress={() => setServerUrlDialog(true)} 
          />
          <Appbar.Action 
            icon="refresh" 
            onPress={connectToSignalR}
            disabled={loading}
          />
        </Appbar.Header>

        <ScrollView style={styles.content}>
          <Card style={styles.statusCard}>
            <Card.Content>
              <Title>Connection Status</Title>
              <Paragraph>
                Status: {connectionState}
                {loading && <ActivityIndicator size="small" style={styles.loader} />}
              </Paragraph>
              <Paragraph>Connected Devices: {devices.filter(d => d.status === 'Online').length}</Paragraph>
            </Card.Content>
          </Card>

          {devices.length === 0 ? (
            <Card style={styles.card}>
              <Card.Content>
                <Title>No Devices Found</Title>
                <Paragraph>
                  Make sure the Windows service is running on your computers and connected to the same server.
                </Paragraph>
              </Card.Content>
            </Card>
          ) : (
            devices.map((device) => (
              <Card key={device.id} style={styles.card}>
                <Card.Content>
                  <Title>{device.name}</Title>
                  <Paragraph>Status: {device.status}</Paragraph>
                  <Paragraph>ID: {device.id}</Paragraph>
                </Card.Content>
                <Card.Actions>
                  <Button 
                    mode="outlined" 
                    onPress={() => getDeviceStatus(device.id, device.name)}
                    disabled={device.status !== 'Online'}
                  >
                    Status
                  </Button>
                  <Button 
                    mode="outlined" 
                    onPress={() => restartDevice(device.id, device.name)}
                    disabled={device.status !== 'Online'}
                  >
                    Restart
                  </Button>
                  <Button 
                    mode="contained" 
                    onPress={() => shutdownDevice(device.id, device.name)}
                    disabled={device.status !== 'Online'}
                    buttonColor="#ff5252"
                  >
                    Shutdown
                  </Button>
                </Card.Actions>
              </Card>
            ))
          )}
        </ScrollView>

        <Portal>
          <Dialog visible={serverUrlDialog} onDismiss={() => setServerUrlDialog(false)}>
            <Dialog.Title>Server Configuration</Dialog.Title>
            <Dialog.Content>
              <TextInput
                label="SignalR Server URL"
                value={serverUrl}
                onChangeText={setServerUrl}
                mode="outlined"
                placeholder="https://your-signalr-hub.azurewebsites.net/shutdownhub"
              />
            </Dialog.Content>
            <Dialog.Actions>
              <Button onPress={() => setServerUrlDialog(false)}>Cancel</Button>
              <Button onPress={handleServerUrlSave}>Save</Button>
            </Dialog.Actions>
          </Dialog>
        </Portal>

        <Snackbar
          visible={snackbarVisible}
          onDismiss={() => setSnackbarVisible(false)}
          duration={3000}
        >
          {snackbarMessage}
        </Snackbar>
      </View>
    </PaperProvider>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  content: {
    flex: 1,
    padding: 16,
  },
  statusCard: {
    marginBottom: 16,
  },
  card: {
    marginBottom: 16,
  },
  loader: {
    marginLeft: 8,
  },
});
