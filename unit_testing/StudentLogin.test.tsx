type Credentials = {
  email: string;
  password: string;
};

type StudentLoginDependencies = {
  authenticateStudent: (credentials: Credentials) => Promise<{ token: string }>;
  onLoginSuccess: () => void;
};

type StudentLoginStatus = 'idle' | 'success';

type StudentLoginState = {
  email: string;
  password: string;
  status: StudentLoginStatus;
  errorMessage: string | null;
};

function createStudentLoginController({
  authenticateStudent,
  onLoginSuccess,
}: StudentLoginDependencies) {
  const state: StudentLoginState = {
    email: '',
    password: '',
    status: 'idle',
    errorMessage: null,
  };

  return (
    {
      setEmail: (email: string) => {
        state.email = email;
      },
      setPassword: (password: string) => {
        state.password = password;
      },
      submit: async () => {
        try {
          await authenticateStudent({
            email: state.email,
            password: state.password,
          });
          state.status = 'success';
          state.errorMessage = null;
          onLoginSuccess();
        } catch (error) {
          state.status = 'idle';
          state.errorMessage =
            error instanceof Error ? error.message : 'Invalid credentials';
        }
      },
      getState: (): StudentLoginState => ({ ...state }),
    }
  );
}

describe('StudentLogin - Verify successful Student login with valid credentials', () => {
  const validCredentials: Credentials = {
    email: 'student@test.com',
    password: 'TestPass123!',
  };
  const invalidCredentials: Credentials = {
    email: 'student@test.com',
    password: 'WrongPassword123!',
  };

  let mockAuthenticateStudent: jest.MockedFunction<
    (credentials: Credentials) => Promise<{ token: string }>
  >;
  let mockOnLoginSuccess: jest.MockedFunction<() => void>;

  beforeEach(() => {
    mockAuthenticateStudent = jest.fn(async (credentials: Credentials) => {
      if (
        credentials.email === validCredentials.email &&
        credentials.password === validCredentials.password
      ) {
        return { token: 'mock-token' };
      }

      throw new Error('Invalid credentials');
    });

    mockOnLoginSuccess = jest.fn();
  });

  afterEach(() => {
    jest.clearAllMocks();
    jest.resetAllMocks();
  });

  test('calls auth once with correct payload and triggers success state/routing callback', async () => {
    const studentLogin = createStudentLoginController({
      authenticateStudent: mockAuthenticateStudent,
      onLoginSuccess: mockOnLoginSuccess,
    });

    studentLogin.setEmail(validCredentials.email);
    studentLogin.setPassword(validCredentials.password);

    expect(studentLogin.getState().email).toBe(validCredentials.email);
    expect(studentLogin.getState().password).toBe(validCredentials.password);

    await studentLogin.submit();

    expect(mockAuthenticateStudent).toHaveBeenCalledTimes(1);

    expect(mockAuthenticateStudent).toHaveBeenCalledWith({
      email: validCredentials.email,
      password: validCredentials.password,
    });

    expect(mockOnLoginSuccess).toHaveBeenCalledTimes(1);
    expect(studentLogin.getState().status).toBe('success');
    expect(studentLogin.getState().errorMessage).toBeNull();
  });

  test('rejects access when invalid password is provided and exposes error UI state', async () => {
    mockAuthenticateStudent.mockImplementation(async (credentials: Credentials) => {
      if (
        credentials.email === invalidCredentials.email &&
        credentials.password === invalidCredentials.password
      ) {
        throw new Error('Invalid credentials');
      }

      return { token: 'mock-token' };
    });

    const studentLogin = createStudentLoginController({
      authenticateStudent: mockAuthenticateStudent,
      onLoginSuccess: mockOnLoginSuccess,
    });

    studentLogin.setEmail(invalidCredentials.email);
    studentLogin.setPassword(invalidCredentials.password);

    await studentLogin.submit();

    expect(mockAuthenticateStudent).toHaveBeenCalledTimes(1);
    expect(mockAuthenticateStudent).toHaveBeenCalledWith({
      email: 'student@test.com',
      password: 'WrongPassword123!',
    });

    expect(mockOnLoginSuccess).not.toHaveBeenCalled();

    expect(studentLogin.getState().status).toBe('idle');
    expect(studentLogin.getState().errorMessage).toBe('Invalid credentials');
  });
});
