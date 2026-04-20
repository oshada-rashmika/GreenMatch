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

type RegistrationPayload = {
  fullName: string;
  studentId: string;
  degreeProgramme: string;
  email: string;
  password: string;
};

type RegistrationResponse = {
  userId: string;
  role: 'STUDENT';
  redirectTo: string;
};

type CreateAccountProps = {
  registerStudent: (
    payload: RegistrationPayload,
  ) => Promise<RegistrationResponse>;
  onRegistrationSuccess: (path: string) => void;
};

function CreateAccount({
  registerStudent,
  onRegistrationSuccess,
}: CreateAccountProps) {
  const [fullName, setFullName] = useState('');
  const [studentId, setStudentId] = useState('');
  const [degreeProgramme, setDegreeProgramme] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [status, setStatus] = useState<'idle' | 'success' | 'error'>('idle');

  const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();

    try {
      const response = await registerStudent({
        fullName,
        studentId,
        degreeProgramme,
        email,
        password,
      });

      if (response.role !== 'STUDENT') {
        throw new Error('Invalid role response');
      }

      setStatus('success');
      onRegistrationSuccess(response.redirectTo);
    } catch {
      setStatus('error');
    }
  };

  return (
    <form onSubmit={handleSubmit} aria-label="create-account-form">
      <label htmlFor="full-name">Full Name</label>
      <input
        id="full-name"
        type="text"
        value={fullName}
        onChange={(event: ChangeEvent<HTMLInputElement>) =>
          setFullName(event.target.value)
        }
      />

      <label htmlFor="student-id">Student ID</label>
      <input
        id="student-id"
        type="text"
        value={studentId}
        onChange={(event: ChangeEvent<HTMLInputElement>) =>
          setStudentId(event.target.value)
        }
      />

      <label htmlFor="degree-programme">Degree Programme</label>
      <input
        id="degree-programme"
        type="text"
        value={degreeProgramme}
        onChange={(event: ChangeEvent<HTMLInputElement>) =>
          setDegreeProgramme(event.target.value)
        }
      />

      <label htmlFor="email-address">Email Address</label>
      <input
        id="email-address"
        type="email"
        value={email}
        onChange={(event: ChangeEvent<HTMLInputElement>) =>
          setEmail(event.target.value)
        }
      />

      <label htmlFor="password">Password</label>
      <input
        id="password"
        type="password"
        value={password}
        onChange={(event: ChangeEvent<HTMLInputElement>) =>
          setPassword(event.target.value)
        }
      />

      <button type="submit">Create Account</button>

      {status === 'success' ? (
        <p role="status">Account created successfully</p>
      ) : null}
    </form>
  );
}

describe('CreateAccount - Verify successful Student account creation with valid details', () => {
  const validRegistrationPayload: RegistrationPayload = {
    fullName: 'Oshada Rashmika',
    studentId: 'NSBM001',
    degreeProgramme: 'Bsc Computer Science',
    email: 'oshada@test.com',
    password: 'TestPass123!',
  };

  const successResponse: RegistrationResponse = {
    userId: 'student-1',
    role: 'STUDENT',
    redirectTo: '/login',
  };

  let mockRegisterStudent: jest.MockedFunction<
    (payload: RegistrationPayload) => Promise<RegistrationResponse>
  >;
  let mockOnRegistrationSuccess: jest.MockedFunction<(path: string) => void>;

  beforeEach(() => {
    mockRegisterStudent = jest.fn(async (payload: RegistrationPayload) => {
      if (
        payload.fullName === validRegistrationPayload.fullName &&
        payload.studentId === validRegistrationPayload.studentId &&
        payload.degreeProgramme === validRegistrationPayload.degreeProgramme &&
        payload.email === validRegistrationPayload.email &&
        payload.password === validRegistrationPayload.password
      ) {
        return successResponse;
      }

      throw new Error('Invalid registration payload');
    });

    mockOnRegistrationSuccess = jest.fn();
  });

  afterEach(() => {
    cleanup();
    jest.clearAllMocks();
    jest.resetAllMocks();
  });

  test('Verify successful Student account creation with valid details', async () => {
    render(
      <CreateAccount
        registerStudent={mockRegisterStudent}
        onRegistrationSuccess={mockOnRegistrationSuccess}
      />,
    );

    const fullNameInput = screen.getByLabelText(/full name/i) as HTMLInputElement;
    const studentIdInput = screen.getByLabelText(/student id/i) as HTMLInputElement;
    const degreeProgrammeInput = screen.getByLabelText(/degree programme/i) as HTMLInputElement;
    const emailInput = screen.getByLabelText(/email address/i) as HTMLInputElement;
    const passwordInput = screen.getByLabelText(/password/i) as HTMLInputElement;
    const submitButton = screen.getByRole('button', { name: /create account/i });

    fireEvent.change(fullNameInput, {
      target: { value: validRegistrationPayload.fullName },
    });
    fireEvent.change(studentIdInput, {
      target: { value: validRegistrationPayload.studentId },
    });
    fireEvent.change(degreeProgrammeInput, {
      target: { value: validRegistrationPayload.degreeProgramme },
    });
    fireEvent.change(emailInput, {
      target: { value: validRegistrationPayload.email },
    });
    fireEvent.change(passwordInput, {
      target: { value: validRegistrationPayload.password },
    });

    expect(fullNameInput.value).toBe(validRegistrationPayload.fullName);
    expect(studentIdInput.value).toBe(validRegistrationPayload.studentId);
    expect(degreeProgrammeInput.value).toBe(validRegistrationPayload.degreeProgramme);
    expect(emailInput.value).toBe(validRegistrationPayload.email);
    expect(passwordInput.value).toBe(validRegistrationPayload.password);

    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(mockRegisterStudent).toHaveBeenCalledTimes(1);
    });

    expect(mockRegisterStudent).toHaveBeenCalledWith({
      fullName: 'Oshada Rashmika',
      studentId: 'NSBM001',
      degreeProgramme: 'Bsc Computer Science',
      email: 'oshada@test.com',
      password: 'TestPass123!',
    });

    await waitFor(() => {
      expect(mockOnRegistrationSuccess).toHaveBeenCalledTimes(1);
    });

    expect(mockOnRegistrationSuccess).toHaveBeenCalledWith('/login');

    expect(await screen.findByRole('status')).toHaveTextContent(
      'Account created successfully',
    );
  });
});