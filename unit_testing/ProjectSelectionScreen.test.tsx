/// <reference types="react" />
/// <reference types="react-dom" />

import { useEffect, useState } from 'react';
import { render, screen, waitFor, within, fireEvent } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

type SupervisedProject = {
  id: string;
  title: string;
  status: 'MATCHED' | 'UNDER_REVIEW' | 'PENDING';
  groupName?: string;
};

type SupervisorProfile = {
  id: string;
  fullName: string;
  email: string;
  supervisedProjects: SupervisedProject[];
};

type ProjectSelectionScreenProps = {
  supervisorId: string;
  fetchSupervisorProfile: (supervisorId: string) => Promise<SupervisorProfile>;
  onProjectSelect: (projectId: string, projectTitle: string) => void;
};

function ProjectSelectionScreen({
  supervisorId,
  fetchSupervisorProfile,
  onProjectSelect,
}: ProjectSelectionScreenProps) {
  const [profile, setProfile] = useState<SupervisorProfile | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;

    const loadProfile = async () => {
      try {
        const data = await fetchSupervisorProfile(supervisorId);
        if (isMounted) {
          setProfile(data);
          setError(null);
        }
      } catch (err) {
        if (isMounted) {
          setError(err instanceof Error ? err.message : 'Failed to load projects');
        }
      } finally {
        if (isMounted) {
          setIsLoading(false);
        }
      }
    };

    void loadProfile();

    return () => {
      isMounted = false;
    };
  }, [supervisorId, fetchSupervisorProfile]);

  const handleRetry = () => {
    setIsLoading(true);
    setError(null);
  };

  const getStatusColor = (status: string): string => {
    switch (status) {
      case 'MATCHED':
        return '#22c55e';
      case 'UNDER_REVIEW':
        return '#f97316';
      case 'PENDING':
        return '#3b82f6';
      default:
        return '#9ca3af';
    }
  };

  if (isLoading) {
    return (
      <div data-testid="loading-state" role="status" aria-label="Loading projects">
        <div>Loading projects...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div data-testid="error-state" role="alert">
        <h2>Failed to Load Projects</h2>
        <p>{error}</p>
        <button data-testid="retry-button" onClick={handleRetry}>
          Retry
        </button>
      </div>
    );
  }

  if (!profile) {
    return (
      <div data-testid="no-data-state">
        No profile data available
      </div>
    );
  }

  // Filter projects with MATCHED status (active projects)
  const activeProjects = profile.supervisedProjects.filter(
    (p) => p.status === 'MATCHED',
  );

  if (activeProjects.length === 0) {
    return (
      <div data-testid="empty-state" className="empty-state">
        <h2>No Active Projects</h2>
        <p>You have no matched projects to chat about yet.</p>
      </div>
    );
  }

  return (
    <div data-testid="project-selection-screen" className="project-selection">
      <header data-testid="header" className="header">
        <h1>Select Project to Chat</h1>
      </header>

      <main data-testid="projects-list" className="projects-list">
        {activeProjects.map((project) => (
          <div
            key={project.id}
            data-testid={`project-card-${project.id}`}
            className="project-card"
            onClick={() => onProjectSelect(project.id, project.title)}
            role="button"
            tabIndex={0}
            onKeyDown={(e) => {
              if (e.key === 'Enter' || e.key === ' ') {
                onProjectSelect(project.id, project.title);
              }
            }}
          >
            <div className="project-content">
              <h3 data-testid={`project-title-${project.id}`} className="project-title">
                {project.title}
              </h3>

              <div className="project-meta">
                {project.groupName && (
                  <span data-testid={`project-group-${project.id}`} className="project-group">
                    {project.groupName}
                  </span>
                )}

                <div
                  data-testid={`project-status-${project.id}`}
                  className="status-badge"
                  style={{ backgroundColor: `${getStatusColor(project.status)}20` }}
                >
                  <span style={{ color: getStatusColor(project.status) }}>
                    {project.status}
                  </span>
                </div>
              </div>

              <div className="project-footer">
                <span className="tap-hint">Tap to chat</span>
                <span className="arrow">→</span>
              </div>
            </div>
          </div>
        ))}
      </main>
    </div>
  );
}

describe('ProjectSelectionScreen - Verify project list and navigation', () => {
  const mockProfile: SupervisorProfile = {
    id: 'sup_1',
    fullName: 'Dr. Perera',
    email: 'perera@nsbm.edu',
    supervisedProjects: [
      {
        id: 'proj_001',
        title: 'AI-Based Student Support',
        status: 'MATCHED',
        groupName: 'Group Atlas',
      },
      {
        id: 'proj_002',
        title: 'Green Campus Analytics',
        status: 'MATCHED',
        groupName: 'Group Verde',
      },
      {
        id: 'proj_003',
        title: 'Secure Campus Access',
        status: 'UNDER_REVIEW',
        groupName: 'Group Nova',
      },
      {
        id: 'proj_004',
        title: 'Mobile Learning App',
        status: 'PENDING',
      },
    ],
  };

  let mockFetchSupervisorProfile: jest.MockedFunction<
    (supervisorId: string) => Promise<SupervisorProfile>
  >;
  let mockOnProjectSelect: jest.MockedFunction<(projectId: string, projectTitle: string) => void>;

  beforeEach(() => {
    mockFetchSupervisorProfile = jest.fn(async () => mockProfile);
    mockOnProjectSelect = jest.fn();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  test('renders loading state initially', () => {
    render(
      <ProjectSelectionScreen
        supervisorId="sup_1"
        fetchSupervisorProfile={mockFetchSupervisorProfile}
        onProjectSelect={mockOnProjectSelect}
      />,
    );

    expect(screen.getByTestId('loading-state')).toBeInTheDocument();
  });

  test('loads profile and displays header', async () => {
    render(
      <ProjectSelectionScreen
        supervisorId="sup_1"
        fetchSupervisorProfile={mockFetchSupervisorProfile}
        onProjectSelect={mockOnProjectSelect}
      />,
    );

    await waitFor(() => {
      expect(mockFetchSupervisorProfile).toHaveBeenCalledWith('sup_1');
    });

    await waitFor(() => {
      expect(screen.getByTestId('header')).toBeInTheDocument();
    });

    expect(screen.getByRole('heading', { name: /select project to chat/i })).toBeInTheDocument();
  });

  test('filters and displays only MATCHED status projects', async () => {
    render(
      <ProjectSelectionScreen
        supervisorId="sup_1"
        fetchSupervisorProfile={mockFetchSupervisorProfile}
        onProjectSelect={mockOnProjectSelect}
      />,
    );

    await waitFor(() => {
      expect(screen.getByTestId('projects-list')).toBeInTheDocument();
    });

    // Should show only MATCHED projects
    expect(screen.getByTestId('project-card-proj_001')).toBeInTheDocument();
    expect(screen.getByTestId('project-card-proj_002')).toBeInTheDocument();

    // Should NOT show non-MATCHED projects
    expect(screen.queryByTestId('project-card-proj_003')).not.toBeInTheDocument();
    expect(screen.queryByTestId('project-card-proj_004')).not.toBeInTheDocument();
  });

  test('displays project titles and group names correctly', async () => {
    render(
      <ProjectSelectionScreen
        supervisorId="sup_1"
        fetchSupervisorProfile={mockFetchSupervisorProfile}
        onProjectSelect={mockOnProjectSelect}
      />,
    );

    await waitFor(() => {
      expect(screen.getByTestId('projects-list')).toBeInTheDocument();
    });

    expect(screen.getByTestId('project-title-proj_001')).toHaveTextContent('AI-Based Student Support');
    expect(screen.getByTestId('project-group-proj_001')).toHaveTextContent('Group Atlas');

    expect(screen.getByTestId('project-title-proj_002')).toHaveTextContent('Green Campus Analytics');
    expect(screen.getByTestId('project-group-proj_002')).toHaveTextContent('Group Verde');
  });

  test('displays status badges for projects', async () => {
    render(
      <ProjectSelectionScreen
        supervisorId="sup_1"
        fetchSupervisorProfile={mockFetchSupervisorProfile}
        onProjectSelect={mockOnProjectSelect}
      />,
    );

    await waitFor(() => {
      expect(screen.getByTestId('projects-list')).toBeInTheDocument();
    });

    expect(screen.getByTestId('project-status-proj_001')).toHaveTextContent('MATCHED');
    expect(screen.getByTestId('project-status-proj_002')).toHaveTextContent('MATCHED');
  });

  test('calls onProjectSelect when project card is clicked', async () => {
    const user = userEvent.setup();

    render(
      <ProjectSelectionScreen
        supervisorId="sup_1"
        fetchSupervisorProfile={mockFetchSupervisorProfile}
        onProjectSelect={mockOnProjectSelect}
      />,
    );

    await waitFor(() => {
      expect(screen.getByTestId('projects-list')).toBeInTheDocument();
    });

    const projectCard = screen.getByTestId('project-card-proj_001');
    await user.click(projectCard);

    expect(mockOnProjectSelect).toHaveBeenCalledWith('proj_001', 'AI-Based Student Support');
  });

  test('navigates to correct project when multiple projects exist', async () => {
    const user = userEvent.setup();

    render(
      <ProjectSelectionScreen
        supervisorId="sup_1"
        fetchSupervisorProfile={mockFetchSupervisorProfile}
        onProjectSelect={mockOnProjectSelect}
      />,
    );

    await waitFor(() => {
      expect(screen.getByTestId('projects-list')).toBeInTheDocument();
    });

    const projectCard2 = screen.getByTestId('project-card-proj_002');
    await user.click(projectCard2);

    expect(mockOnProjectSelect).toHaveBeenCalledWith('proj_002', 'Green Campus Analytics');
  });

  test('displays error state when profile fetch fails', async () => {
    mockFetchSupervisorProfile.mockRejectedValueOnce(new Error('Network error'));

    render(
      <ProjectSelectionScreen
        supervisorId="sup_1"
        fetchSupervisorProfile={mockFetchSupervisorProfile}
        onProjectSelect={mockOnProjectSelect}
      />,
    );

    await waitFor(() => {
      expect(screen.getByTestId('error-state')).toBeInTheDocument();
    });

    expect(screen.getByRole('heading', { name: /failed to load projects/i })).toBeInTheDocument();
    expect(screen.getByText(/Network error/)).toBeInTheDocument();
  });

  test('provides retry button in error state', async () => {
    const user = userEvent.setup();

    mockFetchSupervisorProfile.mockRejectedValueOnce(new Error('Network error'));

    render(
      <ProjectSelectionScreen
        supervisorId="sup_1"
        fetchSupervisorProfile={mockFetchSupervisorProfile}
        onProjectSelect={mockOnProjectSelect}
      />,
    );

    await waitFor(() => {
      expect(screen.getByTestId('error-state')).toBeInTheDocument();
    });

    const retryButton = screen.getByTestId('retry-button');
    expect(retryButton).toBeInTheDocument();

    await user.click(retryButton);

    // Should show loading state again
    expect(screen.getByTestId('loading-state')).toBeInTheDocument();
  });

  test('displays empty state when no active projects exist', async () => {
    const emptyProfile: SupervisorProfile = {
      ...mockProfile,
      supervisedProjects: [
        {
          id: 'proj_005',
          title: 'Archived Project',
          status: 'PENDING',
        },
      ],
    };

    mockFetchSupervisorProfile.mockImplementationOnce(async () => emptyProfile);

    render(
      <ProjectSelectionScreen
        supervisorId="sup_1"
        fetchSupervisorProfile={mockFetchSupervisorProfile}
        onProjectSelect={mockOnProjectSelect}
      />,
    );

    await waitFor(() => {
      expect(screen.getByTestId('empty-state')).toBeInTheDocument();
    });

    expect(screen.getByRole('heading', { name: /no active projects/i })).toBeInTheDocument();
    expect(screen.getByText(/no matched projects to chat/i)).toBeInTheDocument();
  });

  test('handles null profile gracefully', async () => {
    mockFetchSupervisorProfile.mockImplementationOnce(async () => ({
      id: 'sup_1',
      fullName: 'Dr. Perera',
      email: 'perera@nsbm.edu',
      supervisedProjects: [],
    }));

    render(
      <ProjectSelectionScreen
        supervisorId="sup_1"
        fetchSupervisorProfile={mockFetchSupervisorProfile}
        onProjectSelect={mockOnProjectSelect}
      />,
    );

    await waitFor(() => {
      expect(screen.getByTestId('empty-state')).toBeInTheDocument();
    });
  });

  test('displays correct number of project cards', async () => {
    render(
      <ProjectSelectionScreen
        supervisorId="sup_1"
        fetchSupervisorProfile={mockFetchSupervisorProfile}
        onProjectSelect={mockOnProjectSelect}
      />,
    );

    await waitFor(() => {
      expect(screen.getByTestId('projects-list')).toBeInTheDocument();
    });

    const projectCards = screen.getAllByTestId(/^project-card-/);
    expect(projectCards).toHaveLength(2); // Only 2 MATCHED projects
  });

  test('supports keyboard navigation on project cards', async () => {
    const user = userEvent.setup();

    render(
      <ProjectSelectionScreen
        supervisorId="sup_1"
        fetchSupervisorProfile={mockFetchSupervisorProfile}
        onProjectSelect={mockOnProjectSelect}
      />,
    );

    await waitFor(() => {
      expect(screen.getByTestId('projects-list')).toBeInTheDocument();
    });

    const projectCard = screen.getByTestId('project-card-proj_001');

    // Simulate pressing Enter key
    fireEvent.keyDown(projectCard, { key: 'Enter', code: 'Enter' });

    expect(mockOnProjectSelect).toHaveBeenCalledWith('proj_001', 'AI-Based Student Support');
  });

  test('calls fetch with correct supervisor ID', async () => {
    render(
      <ProjectSelectionScreen
        supervisorId="sup_2"
        fetchSupervisorProfile={mockFetchSupervisorProfile}
        onProjectSelect={mockOnProjectSelect}
      />,
    );

    await waitFor(() => {
      expect(mockFetchSupervisorProfile).toHaveBeenCalledWith('sup_2');
    });
  });
});
