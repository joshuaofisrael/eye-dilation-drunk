import { StatusBar } from 'expo-status-bar';
import { useState } from 'react';
import { SafeAreaView, StyleSheet } from 'react-native';
import type { ScanResult } from './src/lib/scanResult';
import { DisclaimerScreen } from './src/screens/DisclaimerScreen';
import { HomeScreen } from './src/screens/HomeScreen';
import { ResultScreen } from './src/screens/ResultScreen';
import { ScanScreen } from './src/screens/ScanScreen';

type Screen =
  | { name: 'disclaimer' }
  | { name: 'home' }
  | { name: 'scan' }
  | { name: 'result'; result: ScanResult };

export default function App() {
  const [screen, setScreen] = useState<Screen>({ name: 'disclaimer' });

  return (
    <SafeAreaView style={styles.root}>
      <StatusBar style="light" />
      {screen.name === 'disclaimer' && (
        <DisclaimerScreen onAcknowledge={() => setScreen({ name: 'home' })} />
      )}
      {screen.name === 'home' && (
        <HomeScreen
          onStart={() => setScreen({ name: 'scan' })}
          onShowDisclaimer={() => setScreen({ name: 'disclaimer' })}
        />
      )}
      {screen.name === 'scan' && (
        <ScanScreen
          onResult={(result) => setScreen({ name: 'result', result })}
          onCancel={() => setScreen({ name: 'home' })}
        />
      )}
      {screen.name === 'result' && (
        <ResultScreen
          result={screen.result}
          onScanAgain={() => setScreen({ name: 'scan' })}
          onDone={() => setScreen({ name: 'home' })}
        />
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: '#000' },
});
