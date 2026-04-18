/// <reference types="react" />
/// <reference types="react-dom" />

import { ChangeEvent, FormEvent, useState } from 'react';
import {
  cleanup,
  fireEvent,
  render,
  screen,
  waitFor,
} from '@testing-library/react';
import '@testing-library/jest-dom';

type Credentials = {
  email: string;
  password: string;
};

type ModuleLeaderAuthResponse = {
  token: string;
  role: 'MODULE_LEADER';
  userId: string;
  redirectTo: string;
};

type ModuleLeaderLoginProps = {
  authenticateModuleLeader: (
    credentials: Credentials,
  ) => Promise<ModuleLeaderAuthResponse>;
  onRouteToDashboard: (path: string) => void;
};

function ModuleLeaderLogin({
  authenticateModuleLeader,
  onRouteToDashboard,
}: ModuleLeaderLoginProps) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [status, setStatus] = useState<'idle' | 'success' | 'error'>('idle');

  const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();

    try {
      const authResponse = await authenticateModuleLeader({ email, password });

      if (authResponse.role !== 'MODULE_LEADER') {
        throw new Error('Unauthorized role');
      }

      setStatus('success');
      onRouteToDashboard(authResponse.redirectTo);
    } catch {
      setStatus('error');
    }
  };

  return (
    <form onSubmit={handleSubmit} aria-label="module-leader-login-form">
      <label htmlFor="module-leader-email">Email</label>
      <input
        id="module-leader-email"
        type="email"
        value={email}
        onChange={(event: ChangeEvent<HTMLInputElement>) =>
          setEmail(event.target.value)
        }
      />

      <label htmlFor="module-leader-password">Password</label>
      <input
        id="module-leader-password"
        type="password"
        value={password}
        onChange={(event: ChangeEvent<HTMLInputElement>) =>
          setPassword(event.target.value)
        }
      />

      <button type="submit">Log In</button>

      {status === 'success' ? (
        <p role="status">Module Leader login successful</p>
      ) : null}
    </form>
  );
}

describe('ModuleLeaderLogin - Verify successful Module Leader login with valid credentials', () => {
  const validCredentials: Credentials = {
    email: 'leader@test.com',
    password: 'TestPass123!',
  };
  const moduleLeaderSuccessResponse: ModuleLeaderAuthResponse = {
    token: 'mock-module-leader-token',
    role: 'MODULE_LEADER',
    userId: 'module-leader-1',
    redirectTo: '/module-leader/dashboard',
  };

  let mockAuthenticateModuleLeader: jest.MockedFunction<
    (credentials: Credentials) => Promise<ModuleLeaderAuthResponse>
  >;
  let mockOnRouteToDashboard: jest.MockedFunction<(path: string) => void>;

  beforeEach(() => {
    mockAuthenticateModuleLeader = jest.fn(async (credentials: Credentials) => {
      if (
        credentials.email === validCredentials.email &&
        credentials.password === validCredentials.password
      ) {
        return moduleLeaderSuccessResponse;
      }

      throw new Error('Invalid credentials');
    });

    mockOnRouteToDashboard = jest.fn();
  });

  afterEach(() => {
    cleanup();
    jest.clearAllMocks();
    jest.resetAllMocks();
  });

  test('Verify successful Module Leader login with valid credentials', async () => {
    render(
      <ModuleLeaderLogin
        authenticateModuleLeader={mockAuthenticateModuleLeader}
        onRouteToDashboard={mockOnRouteToDashboard}
      />,
    );

    const emailInput = screen.getByLabelText(/email/i) as HTMLInputElement;
    const passwordInput = screen.getByLabelText(/password/i) as HTMLInputElement;
    const submitButton = screen.getByRole('button', { name: /log in/i });

    fireEvent.change(emailInput, { target: { value: validCredentials.email } });
    fireEvent.change(passwordInput, {
      target: { value: validCredentials.password },
    });

    expect(emailInput.value).toBe(validCredentials.email);
    expect(passwordInput.value).toBe(validCredentials.password);

    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(mockAuthenticateModuleLeader).toHaveBeenCalledTimes(1);
    });

    expect(mockAuthenticateModuleLeader).toHaveBeenCalledWith({
      email: 'leader@test.com',
      password: 'TestPass123!',
    });

    await waitFor(() => {
      expect(mockOnRouteToDashboard).toHaveBeenCalledTimes(1);
    });

    expect(mockOnRouteToDashboard).toHaveBeenCalledWith(
      '/module-leader/dashboard',
    );

    expect(await screen.findByRole('status')).toHaveTextContent(
      'Module Leader login successful',
    );
  });
});