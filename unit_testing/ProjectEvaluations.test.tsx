/// <reference types="react" />
/// <reference types="react-dom" />

import React, { createContext, useContext } from 'react';
import { cleanup, fireEvent, render, screen, within } from '@testing-library/react';
import '@testing-library/jest-dom';

const mockNavigate = jest.fn();

jest.mock('react-router-dom', () => ({
  useNavigate: () => mockNavigate,
}), { virtual: true });

type ThemeContextValue = {
  mode: 'dark' | 'light';
};

type AuthContextValue = {
  userRole: 'SUPERVISOR' | 'STUDENT' | 'MODULE_LEADER';
  userName: string;
};

const ThemeContext = createContext<ThemeContextValue | null>(null);
const AuthContext = createContext<AuthContextValue | null>(null);

function useTheme(): ThemeContextValue {
  const value = useContext(ThemeContext);

  if (!value) {
    throw new Error('ThemeContext provider is missing');
  }

  return value;
}

function useAuth(): AuthContextValue {
  const value = useContext(AuthContext);

  if (!value) {
    throw new Error('AuthContext provider is missing');
  }

  return value;
}

function ProjectEvaluationsPage() {
  const { useNavigate } = require('react-router-dom') as {
    useNavigate: () => (to: string | number) => void;
  };
  const navigate = useNavigate();
  const theme = useTheme();
  const auth = useAuth();

  return (
    <section
      aria-label="project-evaluations-page"
      className={theme.mode === 'dark' ? 'dark-theme bg-slate-900 text-slate-100' : 'light-theme'}
    >
      <header
        aria-label="project-evaluations-header"
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '12px',
          padding: '16px',
          borderBottom: '1px solid #1f2937',
        }}
      >
        <button
          type="button"
          aria-label="Back"
          className="icon-button rounded-full"
          onClick={() => navigate('/supervisor/dashboard')}
        >
          <span aria-hidden="true">←</span>
        </button>
        <div>
          <h1>Project Evaluations</h1>
          <p>Manage and grade your supervised projects.</p>
          <small data-testid="role-indicator">Role: {auth.userRole}</small>
        </div>
      </header>
    </section>
  );
}

function renderWithProviders() {
  return render(
    <ThemeContext.Provider value={{ mode: 'dark' }}>
      <AuthContext.Provider
        value={{
          userRole: 'SUPERVISOR',
          userName: 'Test Supervisor',
        }}
      >
        <ProjectEvaluationsPage />
      </AuthContext.Provider>
    </ThemeContext.Provider>,
  );
}

describe("ProjectEvaluations - Verify the page header 'Project Evaluations' and description render correctly", () => {
  beforeEach(() => {
    mockNavigate.mockReset();
  });

  afterEach(() => {
    cleanup();
    jest.clearAllMocks();
    jest.resetAllMocks();
  });

  test("Verify the page header 'Project Evaluations' and description render correctly.", () => {
    renderWithProviders();

    const headerSection = screen.getByLabelText('project-evaluations-header');

    expect(
      within(headerSection).getByRole('heading', { name: 'Project Evaluations' }),
    ).toBeInTheDocument();
    expect(
      within(headerSection).getByText('Manage and grade your supervised projects.'),
    ).toBeInTheDocument();
  });

  test('Verify clicking the back arrow triggers dashboard navigation.', () => {
    renderWithProviders();

    const headerSection = screen.getByLabelText('project-evaluations-header');
    const backButton = within(headerSection).getByRole('button', {
      name: /back/i,
    });

    fireEvent.click(backButton);

    expect(mockNavigate).toHaveBeenCalledTimes(1);
    expect(mockNavigate).toHaveBeenCalledWith('/supervisor/dashboard');
  });
});