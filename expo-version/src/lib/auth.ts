import { ENDPOINTS } from '@/lib/config';

export type AuthResult = {
  token: string;
  user: {
    id: string;
    email: string;
    name?: string;
  };
};

export async function login(email: string, password: string): Promise<AuthResult> {
  const response = await fetch(ENDPOINTS.login, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ email, password }),
  });

  return handleAuthResponse(response);
}

export async function signup(email: string, password: string): Promise<AuthResult> {
  const response = await fetch(ENDPOINTS.signup, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ email, password }),
  });

  return handleAuthResponse(response);
}

async function handleAuthResponse(response: Response): Promise<AuthResult> {
  const payload = await response.json().catch(() => null);

  if (!response.ok) {
    const message = payload?.message ?? 'Backend request failed. Please check your configuration.';
    throw new Error(message);
  }

  if (!payload?.token || !payload?.user) {
    throw new Error('Invalid server response. Expected token and user data.');
  }

  return payload as AuthResult;
}
