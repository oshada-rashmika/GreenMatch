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

type SupervisorAuthResponse = {
  token: string;
  role: 'SUPERVISOR';
  userId: string;
  redirectTo: string;
};

type SupervisorLoginProps = {
  authenticateSupervisor: (
    credentials: Credentials,
  ) => Promise<SupervisorAuthResponse>;
  onRouteToDashboard: (path: string) => void;
};

function SupervisorLogin({
  authenticateSupervisor,
  onRouteToDashboard,
}: SupervisorLoginProps) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [status, setStatus] = useState<'idle' | 'success' | 'error'>('idle');

  const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();

    try {
      const authResponse = await authenticateSupervisor({ email, password });

      if (authResponse.role !== 'SUPERVISOR') {
        throw new Error('Unauthorized role');
      }

      setStatus('success');
      onRouteToDashboard(authResponse.redirectTo);
    } catch {
      setStatus('error');
    }
  };

  return (
    <form onSubmit={handleSubmit} aria-label="supervisor-login-form">
      <label htmlFor="supervisor-email">Email</label>
      <input
        id="supervisor-email"
        type="email"
        value={email}
        onChange={(event: ChangeEvent<HTMLInputElement>) =>
          setEmail(event.target.value)
        }
      />

      <label htmlFor="supervisor-password">Password</label>
      <input
        id="supervisor-password"
        type="password"
        value={password}
        onChange={(event: ChangeEvent<HTMLInputElement>) =>
          setPassword(event.target.value)
        }
      />

      <button type="submit">Log In</button>

      {status === 'success' ? (
        <p role="status">Supervisor login successful</p>
      ) : null}

      {status === 'error' ? (
        <p role="alert">Invalid credentials</p>
      ) : null}
    </form>
  );
}

describe('SupervisorLogin - Verify successful Supervisor login with valid credentials', () => {
  const validCredentials: Credentials = {
    email: 'supervisor@test.com',
    password: 'TestPass123!',
  };
  const invalidCredentials: Credentials = {
    email: 'supervisor@test.com',
    password: 'WrongPass123!',
  };
  const supervisorSuccessResponse: SupervisorAuthResponse = {
    token: 'mock-supervisor-token',
    role: 'SUPERVISOR',
    userId: 'supervisor-1',
    redirectTo: '/supervisor/dashboard',
  };

  let mockAuthenticateSupervisor: jest.MockedFunction<
    (credentials: Credentials) => Promise<SupervisorAuthResponse>
  >;
  let mockOnRouteToDashboard: jest.MockedFunction<(path: string) => void>;

  beforeEach(() => {
    mockAuthenticateSupervisor = jest.fn(async (credentials: Credentials) => {
      if (
        credentials.email === validCredentials.email &&
        credentials.password === validCredentials.password
      ) {
        return supervisorSuccessResponse;
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

  test('Verify successful Supervisor login with valid credentials', async () => {
    render(
      <SupervisorLogin
        authenticateSupervisor={mockAuthenticateSupervisor}
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
      expect(mockAuthenticateSupervisor).toHaveBeenCalledTimes(1);
    });

    expect(mockAuthenticateSupervisor).toHaveBeenCalledWith({
      email: 'supervisor@test.com',
      password: 'TestPass123!',
    });

    await waitFor(() => {
      expect(mockOnRouteToDashboard).toHaveBeenCalledTimes(1);
    });

    expect(mockOnRouteToDashboard).toHaveBeenCalledWith(
      '/supervisor/dashboard',
    );

    expect(await screen.findByRole('status')).toHaveTextContent(
      'Supervisor login successful',
    );
  });

  test('Verify Supervisor login fails and rejects access when an invalid password is provided', async () => {
    mockAuthenticateSupervisor.mockImplementation(async (credentials: Credentials) => {
      if (
        credentials.email === invalidCredentials.email &&
        credentials.password === invalidCredentials.password
      ) {
        throw new Error('Invalid credentials');
      }

      return supervisorSuccessResponse;
    });

    render(
      <SupervisorLogin
        authenticateSupervisor={mockAuthenticateSupervisor}
        onRouteToDashboard={mockOnRouteToDashboard}
      />,
    );

    const emailInput = screen.getByLabelText(/email/i) as HTMLInputElement;
    const passwordInput = screen.getByLabelText(/password/i) as HTMLInputElement;
    const submitButton = screen.getByRole('button', { name: /log in/i });

    fireEvent.change(emailInput, { target: { value: invalidCredentials.email } });
    fireEvent.change(passwordInput, {
      target: { value: invalidCredentials.password },
    });

    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(mockAuthenticateSupervisor).toHaveBeenCalledTimes(1);
    });

    expect(mockAuthenticateSupervisor).toHaveBeenCalledWith({
      email: 'supervisor@test.com',
      password: 'WrongPass123!',
    });

    expect(mockOnRouteToDashboard).not.toHaveBeenCalled();

    expect(await screen.findByRole('alert')).toHaveTextContent(
      'Invalid credentials',
    );
  });
});