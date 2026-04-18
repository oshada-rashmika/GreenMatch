/// <reference types="react" />
/// <reference types="react-dom" />

import { useEffect, useState } from 'react';
import { cleanup, fireEvent, render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';

type ProjectStatus = 'AVAILABLE' | 'SUPERVISED' | 'EVALUATED';

type Project = {
  id: string;
  title: string;
  status: ProjectStatus;
};

type SupervisorDashboardProps = {
  fetchProjects: () => Promise<Project[]>;
};

function SupervisorDashboard({ fetchProjects }: SupervisorDashboardProps) {
  const [activeTab, setActiveTab] = useState<'available' | 'supervised' | 'evaluated'>('available');
  const [projects, setProjects] = useState<Project[]>([]);

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
    (project) => project.status === statusByTab[activeTab],
  );

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

      <div aria-label="project-cards" style={{ marginTop: '16px' }}>
        {visibleProjects.map((project) => (
          <article
            key={project.id}
            data-testid="project-card"
            data-status={project.status}
            style={{ border: '1px solid #ddd', borderRadius: '8px', padding: '12px', marginBottom: '10px' }}
          >
            <h3>{project.title}</h3>
            <p>Status: {project.status}</p>
          </article>
        ))}
      </div>
    </section>
  );
}

describe("SupervisorDashboard - Verify the component renders the 'Available Projects' tab by default", () => {
  const mockProjects: Project[] = [
    { id: 'p1', title: 'AI Attendance System', status: 'AVAILABLE' },
    { id: 'p2', title: 'Smart Campus Navigator', status: 'AVAILABLE' },
    { id: 'p3', title: 'Cloud Timetable Optimizer', status: 'SUPERVISED' },
    { id: 'p4', title: 'Automated Marking Assistant', status: 'EVALUATED' },
  ];

  let mockFetchProjects: jest.MockedFunction<() => Promise<Project[]>>;

  beforeEach(() => {
    mockFetchProjects = jest.fn(async () => mockProjects);
  });

  afterEach(() => {
    cleanup();
    jest.clearAllMocks();
    jest.resetAllMocks();
  });

  test("Verify the component renders the 'Available Projects' tab by default", async () => {
    render(<SupervisorDashboard fetchProjects={mockFetchProjects} />);

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
    render(<SupervisorDashboard fetchProjects={mockFetchProjects} />);

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
});