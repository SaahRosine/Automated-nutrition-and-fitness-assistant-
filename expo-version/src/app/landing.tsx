import { Link, useRouter } from 'expo-router';
import { Pressable, StyleSheet } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import { BottomTabInset, MaxContentWidth, Spacing } from '@/constants/theme';

export default function Landing() {
  const router = useRouter();

  return (
    <ThemedView style={styles.container}>
      <SafeAreaView style={styles.safeArea}>
        <ThemedView style={styles.hero}>
          <ThemedText type="title">Welcome</ThemedText>
          <ThemedText type="subtitle" style={styles.subtitle}>
            Automated Nutrition & Fitness Assistant
          </ThemedText>
        </ThemedView>

        <ThemedView style={styles.actions}>
          <Pressable onPress={() => router.push('/login')} style={styles.button}>
            <ThemedText type="smallBold">Log in</ThemedText>
          </Pressable>

          <Pressable onPress={() => router.push('/signup')} style={[styles.button, styles.whiteButton]}>
            <ThemedText type="smallBold">Sign up</ThemedText>
          </Pressable>

          <Link href="/" asChild>
            <Pressable style={styles.linkButton}>
              <ThemedText type="link">Continue as guest</ThemedText>
            </Pressable>
          </Link>
        </ThemedView>
      </SafeAreaView>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    flexDirection: 'row',
  },
  safeArea: {
    flex: 1,
    paddingHorizontal: Spacing.four,
    alignItems: 'center',
    paddingBottom: BottomTabInset + Spacing.three,
    maxWidth: MaxContentWidth,
  },
  hero: {
    alignItems: 'center',
    marginTop: Spacing.six,
    gap: Spacing.two,
  },
  subtitle: {
    textAlign: 'center',
  },
  actions: {
    marginTop: Spacing.six,
    width: '100%',
    alignItems: 'center',
    gap: Spacing.two,
  },
  button: {
    width: '100%',
    maxWidth: 420,
    paddingVertical: Spacing.two,
    borderRadius: Spacing.four,
    alignItems: 'center',
  },
  whiteButton: {},
  linkButton: {
    marginTop: Spacing.two,
  },
});
