import { CameraView, useCameraPermissions } from 'expo-camera';
import { useEffect, useRef, useState } from 'react';
import {
  ActivityIndicator,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { analyzeBase64Jpeg } from '../lib/pupilAnalyzer';
import type { ScanResult } from '../lib/scanResult';

type Props = {
  onResult: (result: ScanResult) => void;
  onCancel: () => void;
};

export function ScanScreen({ onResult, onCancel }: Props) {
  const cameraRef = useRef<CameraView>(null);
  const [permission, requestPermission] = useCameraPermissions();
  const [cameraReady, setCameraReady] = useState(false);
  const [torchOn, setTorchOn] = useState(false);
  const [scanning, setScanning] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    return () => {
      setTorchOn(false);
    };
  }, []);

  if (!permission) {
    return <View style={styles.container} />;
  }

  if (!permission.granted) {
    return (
      <View style={styles.permissionBox}>
        <Text style={styles.permissionTitle}>Camera access needed</Text>
        <Text style={styles.permissionBody}>
          This entertainment scan uses your camera and flashlight on-device.
          Eye images are never uploaded.
        </Text>
        <TouchableOpacity style={styles.button} onPress={requestPermission}>
          <Text style={styles.buttonText}>Allow camera</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={onCancel}>
          <Text style={styles.link}>Cancel</Text>
        </TouchableOpacity>
      </View>
    );
  }

  async function startScan() {
    if (!cameraRef.current || !cameraReady || scanning) return;
    setError(null);
    setScanning(true);
    setTorchOn(true);

    try {
      // Brief pause so torch is on before capture
      await new Promise((r) => setTimeout(r, 450));
      const photo = await cameraRef.current.takePictureAsync({
        quality: 0.55,
        base64: true,
        skipProcessing: false,
        shutterSound: false,
      });
      setTorchOn(false);

      if (!photo?.base64) {
        throw new Error('Could not capture a frame. Try again.');
      }

      const result = analyzeBase64Jpeg(photo.base64);
      onResult(result);
    } catch (e) {
      setTorchOn(false);
      const message =
        e instanceof Error
          ? e.message
          : 'Scan failed. Hold steady and try again.';
      setError(message);
    } finally {
      setScanning(false);
    }
  }

  return (
    <View style={styles.container}>
      <CameraView
        ref={cameraRef}
        style={StyleSheet.absoluteFill}
        facing="back"
        enableTorch={torchOn}
        mode="picture"
        onCameraReady={() => setCameraReady(true)}
        onMountError={() =>
          setError('Camera failed to start. Close other camera apps and retry.')
        }
      />

      <View style={styles.overlay} pointerEvents="box-none">
        <View style={styles.topBar}>
          <TouchableOpacity onPress={onCancel} disabled={scanning}>
            <Text style={styles.cancel}>Cancel</Text>
          </TouchableOpacity>
          <Text style={styles.privacy}>On-device only · nothing uploaded</Text>
        </View>

        <View style={styles.reticleWrap}>
          <View style={styles.reticle} />
          <Text style={styles.hint}>
            Align one eye in the ring. Torch turns on for the entertainment scan.
          </Text>
        </View>

        {error ? <Text style={styles.error}>{error}</Text> : null}

        <View style={styles.bottomBar}>
          <TouchableOpacity
            style={[styles.button, (!cameraReady || scanning) && styles.buttonDisabled]}
            onPress={startScan}
            disabled={!cameraReady || scanning}
          >
            {scanning ? (
              <ActivityIndicator color="#fff" />
            ) : (
              <Text style={styles.buttonText}>Start entertainment scan</Text>
            )}
          </TouchableOpacity>
          <Text style={styles.disclaimerMini}>
            For fun only · not a breathalyzer · never drink & drive
          </Text>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#000' },
  overlay: { flex: 1, justifyContent: 'space-between' },
  topBar: {
    paddingTop: 56,
    paddingHorizontal: 20,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  cancel: { color: '#fff', fontSize: 16, fontWeight: '600' },
  privacy: { color: '#fbbf24', fontSize: 12, fontWeight: '600' },
  reticleWrap: { alignItems: 'center', gap: 16 },
  reticle: {
    width: 180,
    height: 180,
    borderRadius: 90,
    borderWidth: 3,
    borderColor: 'rgba(249,115,22,0.9)',
    backgroundColor: 'transparent',
  },
  hint: {
    color: '#e5e7eb',
    textAlign: 'center',
    paddingHorizontal: 32,
    fontSize: 14,
    lineHeight: 20,
  },
  error: {
    color: '#fca5a5',
    textAlign: 'center',
    paddingHorizontal: 24,
    marginBottom: 8,
  },
  bottomBar: {
    paddingHorizontal: 24,
    paddingBottom: 40,
    gap: 12,
    alignItems: 'center',
  },
  button: {
    alignSelf: 'stretch',
    backgroundColor: '#f97316',
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
  },
  buttonDisabled: { opacity: 0.55 },
  buttonText: { color: '#fff', fontSize: 17, fontWeight: '700' },
  disclaimerMini: { color: '#9ca3af', fontSize: 12, textAlign: 'center' },
  permissionBox: {
    flex: 1,
    backgroundColor: '#000',
    justifyContent: 'center',
    padding: 28,
    gap: 16,
  },
  permissionTitle: {
    color: '#fff',
    fontSize: 22,
    fontWeight: '700',
    textAlign: 'center',
  },
  permissionBody: {
    color: '#9ca3af',
    fontSize: 15,
    textAlign: 'center',
    lineHeight: 22,
  },
  link: { color: '#9ca3af', textAlign: 'center', marginTop: 8 },
});
