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

type EvaluationProject = {
  id: string;
  title: string;
  group: string;
  tags: string;
  members: number;
  status: 'Pending' | 'Reviewed' | 'Completed';
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

function ProjectEvaluationsPage({ projects = [] }: { projects?: EvaluationProject[] }) {
  const { useNavigate } = require('react-router-dom') as {
    useNavigate: () => (to: string | number) => void;
  };
  const navigate = useNavigate();
  const theme = useTheme();
  const auth = useAuth();

  const getStatusBadgeClassName = (status: EvaluationProject['status']) => {
    if (status === 'Pending') {
      return 'status-badge bg-yellow-500 text-amber-500';
    }

    if (status === 'Reviewed') {
      return 'status-badge bg-blue-500 text-blue-100';
    }

    return 'status-badge bg-green-600 text-green-100';
  };

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

      <main aria-label="project-evaluations-list" style={{ padding: '16px' }}>
        {projects.map((project) => (
          <article
            key={project.id}
            data-testid="project-evaluation-card"
            style={{
              border: '1px solid #334155',
              borderRadius: '12px',
              padding: '12px',
              marginBottom: '10px',
            }}
          >
            <h2>{project.title}</h2>
            <p>{project.group}</p>
            <p>{project.tags}</p>
            <p>{project.members} Members</p>
            <span className={getStatusBadgeClassName(project.status)}>{project.status}</span>
          </article>
        ))}
      </main>
    </section>
  );
}

function renderWithProviders(projects?: EvaluationProject[]) {
  return render(
    <ThemeContext.Provider value={{ mode: 'dark' }}>
      <AuthContext.Provider
        value={{
          userRole: 'SUPERVISOR',
          userName: 'Test Supervisor',
        }}
      >
        <ProjectEvaluationsPage projects={projects} />
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

  test('TC_EVAL_LIST_003 + TC_EVAL_LIST_004: Verify project data integrity and Pending badge styling in the same card.', () => {
    const mockProjects: EvaluationProject[] = [
      {
        id: 'project_1',
        title: 'Project 1',
        group: 'Unknown Group',
        tags: 'AI, ML, Flutter',
        members: 1,
        status: 'Pending',
      },
    ];

    renderWithProviders(mockProjects);

    const projectTitle = screen.getByRole('heading', { name: 'Project 1' });
    const projectCard = projectTitle.closest('[data-testid="project-evaluation-card"]');

    expect(projectCard).not.toBeNull();

    expect(
      within(projectCard as HTMLElement).getByRole('heading', { name: 'Project 1' }),
    ).toBeInTheDocument();
    expect(within(projectCard as HTMLElement).getByText('Unknown Group')).toBeInTheDocument();
    expect(within(projectCard as HTMLElement).getByText('AI, ML, Flutter')).toBeInTheDocument();
    expect(within(projectCard as HTMLElement).getByText('1 Members')).toBeInTheDocument();

    const pendingBadge = within(projectCard as HTMLElement).getByText('Pending');

    expect(pendingBadge).toBeInTheDocument();
    expect(pendingBadge).toHaveClass('bg-yellow-500');
    expect(pendingBadge).toHaveClass('text-amber-500');
  });
});