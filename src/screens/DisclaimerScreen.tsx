import {
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';

type Props = {
  onAcknowledge: () => void;
};

const CARDS = [
  {
    emoji: '🎉',
    title: 'Entertainment only',
    body: 'Eye Dilation Drunk is a playful novelty app. Pupil estimates and “drunk probability” scores are for fun — they are not accurate alcohol measurements.',
  },
  {
    emoji: '🚗',
    title: 'Never drink and drive',
    body: 'This app does NOT authorize drinking then driving. Never operate a vehicle after drinking alcohol, regardless of any score shown here.',
  },
  {
    emoji: '🌬️',
    title: 'Use a real breathalyzer',
    body: 'For any real alcohol check, you must use a properly calibrated breathalyzer or other approved testing method — not this app.',
  },
  {
    emoji: '⚕️',
    title: 'Not medical, legal, or safety advice',
    body: 'Nothing in this app is medical, legal, or safety advice. Do not rely on it for health decisions, workplace tests, or law enforcement situations.',
  },
  {
    emoji: '🔒',
    title: 'Privacy — on-device only',
    body: 'Eye images are processed only on your phone. Nothing is uploaded. Frames are not stored or sent to any server.',
  },
];

export function DisclaimerScreen({ onAcknowledge }: Props) {
  return (
    <ScrollView
      style={styles.scroll}
      contentContainerStyle={styles.content}
      bounces
    >
      <View style={styles.header}>
        <Text style={styles.headerEmoji}>⚠️</Text>
        <View style={{ flex: 1 }}>
          <Text style={styles.title}>Before You Continue</Text>
          <Text style={styles.subtitle}>Required acknowledgment</Text>
        </View>
      </View>

      {CARDS.map((card) => (
        <View key={card.title} style={styles.card}>
          <Text style={styles.cardEmoji}>{card.emoji}</Text>
          <View style={{ flex: 1 }}>
            <Text style={styles.cardTitle}>{card.title}</Text>
            <Text style={styles.cardBody}>{card.body}</Text>
          </View>
        </View>
      ))}

      <TouchableOpacity
        style={styles.button}
        onPress={onAcknowledge}
        accessibilityRole="button"
      >
        <Text style={styles.buttonText}>
          I understand — for entertainment only
        </Text>
      </TouchableOpacity>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  scroll: { flex: 1, backgroundColor: '#000' },
  content: { padding: 24, paddingBottom: 40 },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    marginBottom: 20,
  },
  headerEmoji: { fontSize: 36 },
  title: { color: '#fff', fontSize: 22, fontWeight: '700' },
  subtitle: { color: '#9ca3af', fontSize: 14, marginTop: 2 },
  card: {
    flexDirection: 'row',
    gap: 14,
    backgroundColor: 'rgba(255,255,255,0.08)',
    borderRadius: 14,
    padding: 16,
    marginBottom: 12,
  },
  cardEmoji: { fontSize: 22, width: 28, textAlign: 'center' },
  cardTitle: { color: '#fff', fontSize: 16, fontWeight: '600', marginBottom: 6 },
  cardBody: { color: '#9ca3af', fontSize: 14, lineHeight: 20 },
  button: {
    backgroundColor: '#f97316',
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
    marginTop: 12,
  },
  buttonText: { color: '#fff', fontSize: 17, fontWeight: '700' },
});
