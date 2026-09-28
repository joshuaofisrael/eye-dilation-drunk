import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';

type Props = {
  onStart: () => void;
  onShowDisclaimer: () => void;
};

export function HomeScreen({ onStart, onShowDisclaimer }: Props) {
  return (
    <View style={styles.container}>
      <View style={styles.top}>
        <Text style={styles.eye}>👁️</Text>
        <Text style={styles.title}>Eye Dilation Drunk</Text>
        <Text style={styles.blurb}>
          A playful on-device pupil scan that invents a fun “drunk probability.”
          Not a real test.
        </Text>

        <View style={styles.card}>
          <Text style={styles.row}>📷  Rear / selfie camera + flashlight</Text>
          <Text style={styles.row}>📱  On-device only — nothing uploaded</Text>
          <Text style={styles.row}>🎲  Entertainment estimate 0–100%</Text>
        </View>
      </View>

      <View style={styles.bottom}>
        <TouchableOpacity style={styles.button} onPress={onStart}>
          <Text style={styles.buttonText}>Start scan</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={onShowDisclaimer}>
          <Text style={styles.link}>Read disclaimer again</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000',
    paddingHorizontal: 24,
    paddingBottom: 32,
    justifyContent: 'space-between',
  },
  top: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  eye: { fontSize: 64, marginBottom: 16 },
  title: {
    color: '#fff',
    fontSize: 28,
    fontWeight: '800',
    textAlign: 'center',
    marginBottom: 12,
  },
  blurb: {
    color: '#9ca3af',
    fontSize: 15,
    textAlign: 'center',
    lineHeight: 22,
    marginBottom: 28,
    paddingHorizontal: 8,
  },
  card: {
    alignSelf: 'stretch',
    backgroundColor: 'rgba(255,255,255,0.08)',
    borderRadius: 14,
    padding: 16,
    gap: 10,
  },
  row: { color: '#e5e7eb', fontSize: 14 },
  bottom: { gap: 16, alignItems: 'center' },
  button: {
    alignSelf: 'stretch',
    backgroundColor: '#f97316',
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
  },
  buttonText: { color: '#fff', fontSize: 17, fontWeight: '700' },
  link: { color: '#9ca3af', fontSize: 13 },
});
