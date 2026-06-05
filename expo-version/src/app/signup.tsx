import { Link, useRouter } from 'expo-router';
import React from 'react';
import { Pressable, StyleSheet, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import { BottomTabInset, MaxContentWidth, Spacing } from '@/constants/theme';
import { signup } from '@/lib/auth';

export default function Signup() {
  const router = useRouter();
  const [email, setEmail] = React.useState('');
  const [password, setPassword] = React.useState('');
  const [error, setError] = React.useState('');
  const [loading, setLoading] = React.useState(false);

  async function onSubmit() {
    setLoading(true);
    setError('');

    try {
      await signup(email, password);
      router.replace('/');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Signup failed.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <ThemedView style={styles.container}>
      <SafeAreaView style={styles.safeArea}>
        <ThemedText type="title">Create account</ThemedText>

        <View style={styles.form}>
          <TextInput
            placeholder="Email"
            value={email}
            onChangeText={setEmail}
            keyboardType="email-address"
            autoCapitalize="none"
            style={styles.input}
          />
          <TextInput
            placeholder="Password"
            value={password}
            onChangeText={setPassword}
            secureTextEntry
            style={styles.input}
          />

          {error ? <ThemedText style={styles.error}>{error}</ThemedText> : null}

          <Pressable onPress={onSubmit} style={({ pressed }) => [
            styles.button,
            !(email && password) && styles.buttonDisabled,
            loading && styles.buttonDisabled,
            pressed && styles.buttonPressed,
          ]} disabled={!email || !password || loading}>
            <ThemedText type="smallBold">{loading ? 'Creating account…' : 'Create account'}</ThemedText>
          </Pressable>

          <Link href="/login" asChild>
            <Pressable style={styles.linkRow}>
              <ThemedText type="small">Already have an account? <ThemedText type="linkPrimary">Sign in</ThemedText></ThemedText>
            </Pressable>
          </Link>
        </View>
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
  form: {
    width: '100%',
    maxWidth: 420,
    gap: Spacing.two,
    marginTop: Spacing.four,
  },
  input: {
    paddingVertical: Spacing.two,
    paddingHorizontal: Spacing.three,
    borderRadius: Spacing.two,
    borderWidth: 1,
  },
  button: {
    paddingVertical: Spacing.two,
    alignItems: 'center',
    borderRadius: Spacing.four,
  },
  buttonDisabled: {
    opacity: 0.5,
  },
  buttonPressed: {
    opacity: 0.9,
  },
  linkRow: {
    alignItems: 'center',
    marginTop: Spacing.two,
  },
  error: {
    color: '#B00020',
    marginTop: Spacing.one,
  },
});
