import { ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import type { ScanResult } from '../lib/scanResult';

type Props = {
  result: ScanResult;
  onScanAgain: () => void;
  onDone: () => void;
};

const REMINDERS = [
  '🎉  For fun and entertainment only',
  '🚗  Does NOT authorize drinking then driving',
  '🌬️  Use a breathalyzer for any real alcohol check',
  '⚕️  Not medical, legal, or safety advice',
  '🔒  Processed on-device — nothing uploaded',
];

export function ResultScreen({ result, onScanAgain, onDone }: Props) {
  return (
    <ScrollView
      style={styles.scroll}
      contentContainerStyle={styles.content}
    >
      <Text style={styles.kicker}>Entertainment result</Text>

      <View style={styles.gaugeWrap}>
        <View style={styles.gaugeOuter}>
          <Text style={styles.percent}>{result.drunkProbability}%</Text>
          <Text style={styles.funScore}>fun score</Text>
        </View>
      </View>

      <Text style={styles.label}>{result.funLabel}</Text>
      <Text style={styles.ratio}>
        Approx. pupil÷iris ratio: {result.pupilIrisRatio.toFixed(2)}
      </Text>

      <View style={styles.card}>
        {REMINDERS.map((line) => (
          <Text key={line} style={styles.reminder}>
            {line}
          </Text>
        ))}
      </View>

      <Text style={styles.footnote}>
        This percentage is a playful mapping of an approximate pupil estimate.
        Lighting, eye color, contacts, and medication can change pupils — none
        of that equals intoxication measurement.
      </Text>

      <View style={styles.actions}>
        <TouchableOpacity style={styles.secondary} onPress={onScanAgain}>
          <Text style={styles.secondaryText}>Scan again</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.primary} onPress={onDone}>
          <Text style={styles.primaryText}>Done</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  scroll: { flex: 1, backgroundColor: '#000' },
  content: { padding: 24, paddingBottom: 40, alignItems: 'center' },
  kicker: {
    color: '#f97316',
    fontSize: 12,
    fontWeight: '800',
    letterSpacing: 1,
    textTransform: 'uppercase',
    marginTop: 8,
  },
  gaugeWrap: { marginVertical: 24 },
  gaugeOuter: {
    width: 200,
    height: 200,
    borderRadius: 100,
    borderWidth: 14,
    borderColor: 'rgba(255,255,255,0.12)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  percent: {
    color: '#fff',
    fontSize: 52,
    fontWeight: '800',
  },
  funScore: { color: '#9ca3af', fontSize: 12, marginTop: 4 },
  label: {
    color: '#fff',
    fontSize: 20,
    fontWeight: '700',
    textAlign: 'center',
    marginBottom: 8,
  },
  ratio: { color: '#9ca3af', fontSize: 13, marginBottom: 20 },
  card: {
    alignSelf: 'stretch',
    backgroundColor: 'rgba(249,115,22,0.15)',
    borderRadius: 14,
    padding: 16,
    gap: 10,
    marginBottom: 16,
  },
  reminder: { color: '#f3f4f6', fontSize: 14, lineHeight: 20 },
  footnote: {
    color: '#9ca3af',
    fontSize: 12,
    lineHeight: 18,
    textAlign: 'left',
    alignSelf: 'stretch',
    marginBottom: 24,
  },
  actions: {
    flexDirection: 'row',
    gap: 12,
    alignSelf: 'stretch',
  },
  secondary: {
    flex: 1,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.25)',
    borderRadius: 12,
    paddingVertical: 14,
    alignItems: 'center',
  },
  secondaryText: { color: '#fff', fontWeight: '600' },
  primary: {
    flex: 1,
    backgroundColor: '#f97316',
    borderRadius: 12,
    paddingVertical: 14,
    alignItems: 'center',
  },
  primaryText: { color: '#fff', fontWeight: '700' },
});
