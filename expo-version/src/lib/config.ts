import Constants from 'expo-constants';

const expoExtra = Constants.expoConfig?.extra;
const envBackend = typeof process !== 'undefined' ? process.env.BACKEND_URL : undefined;

export const BACKEND_BASE_URL =
  (expoExtra as { BACKEND_URL?: string })?.BACKEND_URL ?? envBackend ?? 'https://example.com';

// Replace `https://example.com` with your actual backend URL in app.json under expo.extra.BACKEND_URL,
// or set the environment variable BACKEND_URL when building for web/native.

export const API_PATHS = {
  login: '/auth/login',
  signup: '/auth/signup',
};

export const ENDPOINTS = {
  login: `${BACKEND_BASE_URL}${API_PATHS.login}`,
  signup: `${BACKEND_BASE_URL}${API_PATHS.signup}`,
};
