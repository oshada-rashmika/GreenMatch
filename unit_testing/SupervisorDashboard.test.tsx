/// <reference types="react" />
/// <reference types="react-dom" />

import { useEffect, useState } from 'react';
import { cleanup, fireEvent, render, screen, waitFor, within } from '@testing-library/react';
import '@testing-library/jest-dom';

type ProjectStatus = 'AVAILABLE' | 'SUPERVISED' | 'EVALUATED';
type ProjectCategory = 'Algorithms' | 'Cloud Computing';

type Project = {
  id: string;
  title: string;
  status: ProjectStatus;
  category: ProjectCategory;
  description: string;
};

type SupervisorDashboardProps = {
  fetchProjects: () => Promise<Project[]>;
  onConfirmMatch: (projectId: string) => Promise<void>;
};

function SupervisorDashboard({ fetchProjects, onConfirmMatch }: SupervisorDashboardProps) {
  const [activeTab, setActiveTab] = useState<'available' | 'supervised' | 'evaluated'>('available');
  const [activeCategory, setActiveCategory] = useState<'All' | ProjectCategory>('All');
  const [projects, setProjects] = useState<Project[]>([]);
  const [matchingProjectId, setMatchingProjectId] = useState<string | null>(null);
  const [matchedProjectId, setMatchedProjectId] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;

    const loadProjects = async () => {
      const projectData = await fetchProjects();

      if (isMounted) {
        setProjects(projectData);
      }
    };

    void loadProjects();

    return () => {
      isMounted = false;
    };
  }, [activeTab, fetchProjects]);

  const statusByTab: Record<'available' | 'supervised' | 'evaluated', ProjectStatus> = {
    available: 'AVAILABLE',
    supervised: 'SUPERVISED',
    evaluated: 'EVALUATED',
  };

  const visibleProjects = projects.filter(
    (project) =>
      project.status === statusByTab[activeTab] &&
      (activeCategory === 'All' || project.category === activeCategory),
  );

  const handleConfirmMatch = async (projectId: string) => {
    setMatchingProjectId(projectId);
    await onConfirmMatch(projectId);
    setMatchedProjectId(projectId);
    setMatchingProjectId(null);
  };

  return (
    <section aria-label="supervisor-dashboard-blind-review">
      <div role="tablist" aria-label="project-tabs" style={{ display: 'flex', gap: '8px' }}>
        <button
          type="button"
          role="tab"
          aria-selected={activeTab === 'available'}
          className={activeTab === 'available' ? 'tab tab-active bg-blue-600 text-white' : 'tab tab-inactive bg-gray-100 text-gray-600'}
          onClick={() => setActiveTab('available')}
        >
          Available Projects
        </button>
        <button
          type="button"
          role="tab"
          aria-selected={activeTab === 'supervised'}
          className={activeTab === 'supervised' ? 'tab tab-active bg-blue-600 text-white' : 'tab tab-inactive bg-gray-100 text-gray-600'}
          onClick={() => setActiveTab('supervised')}
        >
          Supervised
        </button>
        <button
          type="button"
          role="tab"
          aria-selected={activeTab === 'evaluated'}
          className={activeTab === 'evaluated' ? 'tab tab-active bg-blue-600 text-white' : 'tab tab-inactive bg-gray-100 text-gray-600'}
          onClick={() => setActiveTab('evaluated')}
        >
          Evaluated
        </button>
      </div>

      <div
        role="group"
        aria-label="project-category-filters"
        style={{ display: 'flex', gap: '8px', marginTop: '12px' }}
      >
        {(['All', 'Algorithms', 'Cloud Computing'] as const).map((chip) => (
          <button
            key={chip}
            type="button"
            aria-pressed={activeCategory === chip}
            className={
              activeCategory === chip
                ? 'filter-chip chip-active bg-sky-100 text-sky-900'
                : 'filter-chip chip-inactive bg-gray-100 text-gray-700'
            }
            onClick={() => setActiveCategory(chip)}
          >
            {chip}
          </button>
        ))}
      </div>

      <div aria-label="project-cards" style={{ marginTop: '16px' }}>
        {visibleProjects.length === 0 ? (
          <p role="note">No projects available</p>
        ) : (
          visibleProjects.map((project) => (
            <article
              key={project.id}
              data-testid="project-card"
              data-status={project.status}
              style={{ border: '1px solid #ddd', borderRadius: '8px', padding: '12px', marginBottom: '10px' }}
            >
              <h3>{project.title}</h3>
              <p>Status: {project.status}</p>
              <span className="project-tag-chip">{project.category}</span>
              <p>{project.description}</p>
              <span aria-label="progress-indicator">0%</span>
              <button type="button" aria-label={`Bookmark ${project.title}`}>
                Bookmark
              </button>
              <button
                type="button"
                onClick={() => {
                  void handleConfirmMatch(project.id);
                }}
                disabled={matchingProjectId === project.id}
              >
                {matchingProjectId === project.id ? 'Matching...' : 'Confirm Match'}
              </button>
              {matchedProjectId === project.id ? (
                <p role="status">Match confirmed</p>
              ) : null}
            </article>
          ))
        )}
      </div>
    </section>
  );
}

describe("SupervisorDashboard - Verify the component renders the 'Available Projects' tab by default", () => {
  const mockProjects: Project[] = [
    {
      id: 'p1',
      title: 'AI Attendance System',
      status: 'AVAILABLE',
      category: 'Algorithms',
      description: 'Vision-based attendance with model tracking.',
    },
    {
      id: 'p2',
      title: 'Smart Campus Navigator',
      status: 'AVAILABLE',
      category: 'Cloud Computing',
      description: 'Path optimization for campus wayfinding.',
    },
    {
      id: 'p3',
      title: 'Cloud Timetable Optimizer',
      status: 'SUPERVISED',
      category: 'Cloud Computing',
      description: 'Resource-aware schedule optimization.',
    },
    {
      id: 'p4',
      title: 'Automated Marking Assistant',
      status: 'EVALUATED',
      category: 'Algorithms',
      description: 'Auto-grading and rubric scoring engine.',
    },
  ];

  let mockFetchProjects: jest.MockedFunction<() => Promise<Project[]>>;
  let mockOnConfirmMatch: jest.MockedFunction<(projectId: string) => Promise<void>>;

  beforeEach(() => {
    mockFetchProjects = jest.fn(async () => mockProjects);
    mockOnConfirmMatch = jest.fn(async () => {});
  });

  afterEach(() => {
    cleanup();
    jest.clearAllMocks();
    jest.resetAllMocks();
  });

  test("Verify the component renders the 'Available Projects' tab by default", async () => {
    render(
      <SupervisorDashboard
        fetchProjects={mockFetchProjects}
        onConfirmMatch={mockOnConfirmMatch}
      />,
    );

    const availableTab = screen.getByRole('tab', { name: /available projects/i });
    const supervisedTab = screen.getByRole('tab', { name: /supervised/i });
    const evaluatedTab = screen.getByRole('tab', { name: /evaluated/i });

    expect(availableTab).toBeInTheDocument();
    expect(supervisedTab).toBeInTheDocument();
    expect(evaluatedTab).toBeInTheDocument();

    expect(availableTab).toHaveAttribute('aria-selected', 'true');
    expect(availableTab).toHaveClass('tab-active');

    expect(supervisedTab).toHaveAttribute('aria-selected', 'false');
    expect(supervisedTab).toHaveClass('tab-inactive');
    expect(evaluatedTab).toHaveAttribute('aria-selected', 'false');
    expect(evaluatedTab).toHaveClass('tab-inactive');

    await waitFor(() => {
      expect(mockFetchProjects).toHaveBeenCalledTimes(1);
    });

    const visibleCards = await screen.findAllByTestId('project-card');

    expect(visibleCards).toHaveLength(2);
    expect(screen.getByText('AI Attendance System')).toBeInTheDocument();
    expect(screen.getByText('Smart Campus Navigator')).toBeInTheDocument();

    visibleCards.forEach((card) => {
      expect(card).toHaveAttribute('data-status', 'AVAILABLE');
    });

    expect(screen.queryByText('Cloud Timetable Optimizer')).not.toBeInTheDocument();
    expect(screen.queryByText('Automated Marking Assistant')).not.toBeInTheDocument();
  });

  test("Verify clicking the 'Supervised' tab updates the UI and filters projects correctly.", async () => {
    render(
      <SupervisorDashboard
        fetchProjects={mockFetchProjects}
        onConfirmMatch={mockOnConfirmMatch}
      />,
    );

    const availableTab = screen.getByRole('tab', { name: /available projects/i });
    const supervisedTab = screen.getByRole('tab', { name: /supervised/i });
    const evaluatedTab = screen.getByRole('tab', { name: /evaluated/i });

    await waitFor(() => {
      expect(mockFetchProjects).toHaveBeenCalledTimes(1);
    });

    fireEvent.click(supervisedTab);

    await waitFor(() => {
      expect(supervisedTab).toHaveAttribute('aria-selected', 'true');
    });

    expect(supervisedTab).toHaveClass('tab-active');
    expect(availableTab).toHaveAttribute('aria-selected', 'false');
    expect(availableTab).toHaveClass('tab-inactive');
    expect(evaluatedTab).toHaveAttribute('aria-selected', 'false');
    expect(evaluatedTab).toHaveClass('tab-inactive');

    await waitFor(() => {
      expect(mockFetchProjects).toHaveBeenCalledTimes(2);
    });

    const visibleCards = await screen.findAllByTestId('project-card');

    expect(visibleCards).toHaveLength(1);
    expect(screen.getByText('Cloud Timetable Optimizer')).toBeInTheDocument();

    visibleCards.forEach((card) => {
      expect(card).toHaveAttribute('data-status', 'SUPERVISED');
    });

    expect(screen.queryByText('AI Attendance System')).not.toBeInTheDocument();
    expect(screen.queryByText('Smart Campus Navigator')).not.toBeInTheDocument();
  });

  test("Verify that clicking the 'Algorithms' category chip filters the project list correctly.", async () => {
    const categoryFilterProjects: Project[] = [
      {
        id: 'a1',
        title: 'Evalora | Edu',
        status: 'AVAILABLE',
        category: 'Algorithms',
        description: 'Algorithm-first rubric assistant.',
      },
      {
        id: 'c1',
        title: 'CeylonDash Mobile App',
        status: 'AVAILABLE',
        category: 'Cloud Computing',
        description: 'Cloud-native student dashboard app.',
      },
      {
        id: 's1',
        title: 'Marked Attendance Engine',
        status: 'SUPERVISED',
        category: 'Algorithms',
        description: 'Attendance anomaly detection pipeline.',
      },
    ];

    mockFetchProjects.mockImplementation(async () => categoryFilterProjects);

    render(
      <SupervisorDashboard
        fetchProjects={mockFetchProjects}
        onConfirmMatch={mockOnConfirmMatch}
      />,
    );

    const filterGroup = screen.getByRole('group', {
      name: /project-category-filters/i,
    });
    const allChip = within(filterGroup).getByRole('button', { name: /^all$/i });
    const algorithmsChip = within(filterGroup).getByRole('button', {
      name: /algorithms/i,
    });

    await waitFor(() => {
      expect(mockFetchProjects).toHaveBeenCalledTimes(1);
    });

    expect(await screen.findByText('Evalora | Edu')).toBeInTheDocument();
    expect(await screen.findByText('CeylonDash Mobile App')).toBeInTheDocument();

    fireEvent.click(algorithmsChip);

    await waitFor(() => {
      expect(algorithmsChip).toHaveClass('chip-active');
    });

    expect(algorithmsChip).toHaveAttribute('aria-pressed', 'true');
    expect(allChip).toHaveClass('chip-inactive');
    expect(allChip).toHaveAttribute('aria-pressed', 'false');

    expect(await screen.findByText('Evalora | Edu')).toBeInTheDocument();
    expect(screen.queryByText('CeylonDash Mobile App')).not.toBeInTheDocument();

    fireEvent.click(allChip);

    await waitFor(() => {
      expect(allChip).toHaveClass('chip-active');
    });

    expect(await screen.findByText('Evalora | Edu')).toBeInTheDocument();
    expect(await screen.findByText('CeylonDash Mobile App')).toBeInTheDocument();
  });

  test("Verify that clicking 'Confirm Match' triggers the correct action with the specific project ID.", async () => {
    const confirmMatchProjects: Project[] = [
      {
        id: 'proj_123',
        title: 'GreenMatch',
        status: 'AVAILABLE',
        category: 'Algorithms',
        description: 'OOP',
      },
      {
        id: 'proj_777',
        title: 'CeylonDash Mobile App',
        status: 'AVAILABLE',
        category: 'Cloud Computing',
        description: 'Flutter, iOS',
      },
    ];

    mockFetchProjects.mockImplementation(async () => confirmMatchProjects);

    render(
      <SupervisorDashboard
        fetchProjects={mockFetchProjects}
        onConfirmMatch={mockOnConfirmMatch}
      />,
    );

    const greenMatchHeading = await screen.findByText('GreenMatch');
    const greenMatchCard = greenMatchHeading.closest('[data-testid="project-card"]');

    expect(greenMatchCard).not.toBeNull();

    const confirmButton = within(greenMatchCard as HTMLElement).getByRole('button', {
      name: /confirm match/i,
    });

    fireEvent.click(confirmButton);

    await waitFor(() => {
      expect(mockOnConfirmMatch).toHaveBeenCalledTimes(1);
    });

    expect(mockOnConfirmMatch).toHaveBeenCalledWith('proj_123');
    expect(await within(greenMatchCard as HTMLElement).findByRole('status')).toHaveTextContent(
      'Match confirmed',
    );
  });

  test('Verify that project cards correctly display unique content (Title, Tags, Description).', async () => {
    const contentProjects: Project[] = [
      {
        id: 'proj_123',
        title: 'GreenMatch',
        status: 'AVAILABLE',
        category: 'Algorithms',
        description: 'OOP',
      },
      {
        id: 'proj_777',
        title: 'CeylonDash Mobile App',
        status: 'AVAILABLE',
        category: 'Cloud Computing',
        description: 'Flutter, iOS',
      },
    ];

    mockFetchProjects.mockImplementation(async () => contentProjects);

    render(
      <SupervisorDashboard
        fetchProjects={mockFetchProjects}
        onConfirmMatch={mockOnConfirmMatch}
      />,
    );

    const greenMatchTitle = await screen.findByRole('heading', {
      name: 'GreenMatch',
    });
    const greenMatchCard = greenMatchTitle.closest('[data-testid="project-card"]');
    expect(greenMatchCard).not.toBeNull();

    expect(
      within(greenMatchCard as HTMLElement).getByRole('heading', {
        name: 'GreenMatch',
      }),
    ).toBeInTheDocument();
    expect(within(greenMatchCard as HTMLElement).getByText('Algorithms')).toBeInTheDocument();
    expect(within(greenMatchCard as HTMLElement).getByText('OOP')).toBeInTheDocument();

    const ceylonDashTitle = await screen.findByRole('heading', {
      name: 'CeylonDash Mobile App',
    });
    const ceylonDashCard = ceylonDashTitle.closest('[data-testid="project-card"]');
    expect(ceylonDashCard).not.toBeNull();

    expect(
      within(ceylonDashCard as HTMLElement).getByRole('heading', {
        name: 'CeylonDash Mobile App',
      }),
    ).toBeInTheDocument();
    expect(
      within(ceylonDashCard as HTMLElement).getByText('Cloud Computing'),
    ).toBeInTheDocument();
    expect(within(ceylonDashCard as HTMLElement).getByText('Flutter, iOS')).toBeInTheDocument();
  });

  test("Verify that a 'No projects available' message appears if the project array is empty.", async () => {
    mockFetchProjects.mockImplementation(async () => []);

    render(
      <SupervisorDashboard
        fetchProjects={mockFetchProjects}
        onConfirmMatch={mockOnConfirmMatch}
      />,
    );

    await waitFor(() => {
      expect(mockFetchProjects).toHaveBeenCalledTimes(1);
    });

    expect(
      screen.getByRole('tab', { name: /available projects/i }),
    ).toBeInTheDocument();
    expect(screen.getByRole('tab', { name: /supervised/i })).toBeInTheDocument();
    expect(screen.getByRole('tab', { name: /evaluated/i })).toBeInTheDocument();

    expect(await screen.findByRole('note')).toHaveTextContent('No projects available');

    expect(screen.queryByTestId('project-card')).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /confirm match/i })).not.toBeInTheDocument();
    expect(screen.queryByText('0%')).not.toBeInTheDocument();
  });
});