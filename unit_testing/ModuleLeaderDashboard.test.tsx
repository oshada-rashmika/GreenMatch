/// <reference types="react" />
/// <reference types="react-dom" />

import { useEffect, useState } from 'react';
import { render, screen, waitFor, within, fireEvent, act } from '@testing-library/react';
import '@testing-library/jest-dom';

const mockNavigate = jest.fn();

jest.mock('react-router-dom', () => ({
  useNavigate: () => mockNavigate,
}), { virtual: true });

type ModuleLeaderTag = {
  id: string;
  name: string;
};

type ModuleLeaderProject = {
  id: string;
  title: string;
  status: 'PENDING' | 'MATCHED';
  moduleCode: string;
  moduleName: string;
  supervisorName: string | null;
  groupName: string;
};

type ModuleLeaderAcademicModule = {
  id: string;
  moduleCode: string;
  moduleName: string;
  academicYear: string;
  batch: string;
  assignedSupervisors: Array<{
    id: string;
    fullName: string;
    email: string;
  }>;
};

type Guideline = {
  id: string;
  title: string;
  moduleCode: string;
  publishedDate: string;
  content?: string;
};

type ModuleLeaderOverviewStatistics = {
  totalProjects: number;
  pendingBlindMatches: number;
  ghostedMissedMeetings: number;
};

type ModuleLeaderDashboardProps = {
  fetchOverviewStatistics: () => Promise<ModuleLeaderOverviewStatistics>;
  fetchTags: () => Promise<ModuleLeaderTag[]>;
  fetchProjects: () => Promise<ModuleLeaderProject[]>;
  fetchAcademicModules: () => Promise<ModuleLeaderAcademicModule[]>;
  fetchGuidelines: () => Promise<Guideline[]>;
  onCreateTag?: (name: string) => Promise<void>;
  onCreateModule?: (data: any) => Promise<void>;
};

enum ModuleLeaderSection {
  Overview = 'overview',
  ResearchAreas = 'researchAreas',
  ProjectAllocations = 'projectAllocations',
  AcademicModules = 'academicModules',
  Guidelines = 'guidelines',
}

function ModuleLeaderDashboard({
  fetchOverviewStatistics,
  fetchTags,
  fetchProjects,
  fetchAcademicModules,
  fetchGuidelines,
  onCreateTag,
  onCreateModule,
}: ModuleLeaderDashboardProps) {
  const [selectedSection, setSelectedSection] = useState<ModuleLeaderSection>(
    ModuleLeaderSection.Overview,
  );
  const [statistics, setStatistics] = useState<ModuleLeaderOverviewStatistics | null>(null);
  const [tags, setTags] = useState<ModuleLeaderTag[]>([]);
  const [projects, setProjects] = useState<ModuleLeaderProject[]>([]);
  const [modules, setModules] = useState<ModuleLeaderAcademicModule[]>([]);
  const [guidelines, setGuidelines] = useState<Guideline[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    let isMounted = true;

    const loadData = async () => {
      try {
        const [statsData, tagsData, projectsData, modulesData, guidelinesData] = await Promise.all([
          fetchOverviewStatistics(),
          fetchTags(),
          fetchProjects(),
          fetchAcademicModules(),
          fetchGuidelines(),
        ]);

        if (isMounted) {
          setStatistics(statsData);
          setTags(tagsData);
          setProjects(projectsData);
          setModules(modulesData);
          setGuidelines(guidelinesData);
          setIsLoading(false);
        }
      } catch (error) {
        if (isMounted) {
          setIsLoading(false);
        }
      }
    };

    void loadData();

    return () => {
      isMounted = false;
    };
  }, [fetchOverviewStatistics, fetchTags, fetchProjects, fetchAcademicModules, fetchGuidelines]);

  return (
    <div data-testid="module-leader-dashboard" className="dashboard-container">
      <header data-testid="dashboard-header" className="dashboard-header">
        <h1>Module Leader Dashboard</h1>
        <nav className="section-tabs">
          {Object.values(ModuleLeaderSection).map((section) => (
            <button
              key={section}
              data-testid={`tab-${section}`}
              className={`tab-button ${selectedSection === section ? 'active' : ''}`}
              onClick={() => setSelectedSection(section)}
            >
              {section === ModuleLeaderSection.Overview && 'Overview'}
              {section === ModuleLeaderSection.ResearchAreas && 'Research Areas'}
              {section === ModuleLeaderSection.ProjectAllocations && 'Project Allocations'}
              {section === ModuleLeaderSection.AcademicModules && 'Academic Modules'}
              {section === ModuleLeaderSection.Guidelines && 'Guidelines'}
            </button>
          ))}
        </nav>
      </header>

      <main data-testid="dashboard-content" className="dashboard-content">
        {isLoading ? (
          <div data-testid="dashboard-loading" role="status" aria-label="Loading dashboard">
            Loading dashboard...
          </div>
        ) : (
          <>
            {selectedSection === ModuleLeaderSection.Overview && (
              <section data-testid="overview-section">
                <h2>Overview</h2>
                {statistics && (
                  <div data-testid="statistics-cards" className="statistics-grid">
                    <div data-testid="total-projects-card" className="stat-card">
                      <h3>Total Projects</h3>
                      <p className="stat-value">{statistics.totalProjects}</p>
                    </div>
                    <div data-testid="pending-matches-card" className="stat-card">
                      <h3>Pending Blind Matches</h3>
                      <p className="stat-value">{statistics.pendingBlindMatches}</p>
                    </div>
                    <div data-testid="missed-meetings-card" className="stat-card">
                      <h3>Missed Meetings</h3>
                      <p className="stat-value">{statistics.ghostedMissedMeetings}</p>
                    </div>
                  </div>
                )}
              </section>
            )}

            {selectedSection === ModuleLeaderSection.ResearchAreas && (
              <section data-testid="research-areas-section">
                <h2>Research Areas</h2>
                {tags.length === 0 ? (
                  <p data-testid="no-tags-message" className="empty-state">
                    No tags available. Create your first tag to begin.
                  </p>
                ) : (
                  <div data-testid="tags-grid" className="tags-grid">
                    {tags.map((tag) => (
                      <div key={tag.id} data-testid={`tag-${tag.id}`} className="tag-chip">
                        {tag.name}
                      </div>
                    ))}
                  </div>
                )}
              </section>
            )}

            {selectedSection === ModuleLeaderSection.ProjectAllocations && (
              <section data-testid="project-allocations-section">
                <h2>Project Allocations</h2>
                {projects.length === 0 ? (
                  <p data-testid="no-projects-message" className="empty-state">
                    No projects available.
                  </p>
                ) : (
                  <div data-testid="projects-list" className="projects-list">
                    {projects.map((project) => (
                      <div key={project.id} data-testid={`project-${project.id}`} className="project-item">
                        <h3>{project.title}</h3>
                        <p>Status: {project.status}</p>
                        <p>Module: {project.moduleCode}</p>
                        <p>Group: {project.groupName}</p>
                        {project.supervisorName && <p>Supervisor: {project.supervisorName}</p>}
                      </div>
                    ))}
                  </div>
                )}
              </section>
            )}

            {selectedSection === ModuleLeaderSection.AcademicModules && (
              <section data-testid="academic-modules-section">
                <h2>Academic Modules</h2>
                {modules.length === 0 ? (
                  <p data-testid="no-modules-message" className="empty-state">
                    No modules available. Create your first module to begin.
                  </p>
                ) : (
                  <div data-testid="modules-list" className="modules-list">
                    {modules.map((module) => (
                      <div key={module.id} data-testid={`module-${module.id}`} className="module-item">
                        <h3>{module.moduleCode}</h3>
                        <p>{module.moduleName}</p>
                        <p>Year: {module.academicYear}</p>
                        <p>Batch: {module.batch}</p>
                        <p>Assigned Supervisors: {module.assignedSupervisors.length}</p>
                      </div>
                    ))}
                  </div>
                )}
              </section>
            )}

            {selectedSection === ModuleLeaderSection.Guidelines && (
              <section data-testid="guidelines-section">
                <h2>Guidelines</h2>
                {guidelines.length === 0 ? (
                  <p data-testid="no-guidelines-message" className="empty-state">
                    No guidelines available.
                  </p>
                ) : (
                  <div data-testid="guidelines-list" className="guidelines-list">
                    {guidelines.map((guideline) => (
                      <div key={guideline.id} data-testid={`guideline-${guideline.id}`} className="guideline-item">
                        <h3>{guideline.title}</h3>
                        <p>Module: {guideline.moduleCode}</p>
                        <p>Published: {guideline.publishedDate}</p>
                      </div>
                    ))}
                  </div>
                )}
              </section>
            )}
          </>
        )}
      </main>
    </div>
  );
}

describe('ModuleLeaderDashboard - Verify all dashboard sections render correctly', () => {
  const mockStatistics: ModuleLeaderOverviewStatistics = {
    totalProjects: 24,
    pendingBlindMatches: 7,
    ghostedMissedMeetings: 3,
  };

  const mockTags: ModuleLeaderTag[] = [
    { id: 'tag_001', name: 'Next.js' },
    { id: 'tag_002', name: 'Machine Learning' },
    { id: 'tag_003', name: 'Flutter' },
  ];

  const mockProjects: ModuleLeaderProject[] = [
    {
      id: 'proj_001',
      title: 'AI-Based Student Support',
      status: 'PENDING',
      moduleCode: 'PUSL2020',
      moduleName: 'Software Development Tools',
      supervisorName: null,
      groupName: 'Group Atlas',
    },
    {
      id: 'proj_002',
      title: 'Green Campus Analytics',
      status: 'MATCHED',
      moduleCode: 'PUSL3022',
      moduleName: 'Enterprise Applications',
      supervisorName: 'Dr. Fernando',
      groupName: 'Group Verde',
    },
  ];

  const mockModules: ModuleLeaderAcademicModule[] = [
    {
      id: 'mod_001',
      moduleCode: 'PUSL2020',
      moduleName: 'Software Development Tools',
      academicYear: '2026/2027',
      batch: 'Batch 24',
      assignedSupervisors: [
        { id: 'sup_1', fullName: 'Dr. Perera', email: 'perera@nsbm.edu' },
      ],
    },
  ];

  const mockGuidelines: Guideline[] = [
    {
      id: 'guide_1',
      title: 'Final Year Project Guidelines',
      moduleCode: 'PUSL2030',
      publishedDate: 'Apr 29, 2026',
    },
  ];

  let mockFetchOverviewStatistics: jest.MockedFunction<
    () => Promise<ModuleLeaderOverviewStatistics>
  >;
  let mockFetchTags: jest.MockedFunction<() => Promise<ModuleLeaderTag[]>>;
  let mockFetchProjects: jest.MockedFunction<() => Promise<ModuleLeaderProject[]>>;
  let mockFetchAcademicModules: jest.MockedFunction<
    () => Promise<ModuleLeaderAcademicModule[]>
  >;
  let mockFetchGuidelines: jest.MockedFunction<() => Promise<Guideline[]>>;

  beforeEach(() => {
    mockFetchOverviewStatistics = jest.fn(async () => mockStatistics);
    mockFetchTags = jest.fn(async () => mockTags);
    mockFetchProjects = jest.fn(async () => mockProjects);
    mockFetchAcademicModules = jest.fn(async () => mockModules);
    mockFetchGuidelines = jest.fn(async () => mockGuidelines);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  test('renders dashboard header and navigation tabs', async () => {
    render(
      <ModuleLeaderDashboard
        fetchOverviewStatistics={mockFetchOverviewStatistics}
        fetchTags={mockFetchTags}
        fetchProjects={mockFetchProjects}
        fetchAcademicModules={mockFetchAcademicModules}
        fetchGuidelines={mockFetchGuidelines}
      />,
    );

    expect(screen.getByRole('heading', { name: /module leader dashboard/i })).toBeInTheDocument();
    expect(screen.getByTestId('tab-overview')).toBeInTheDocument();
    expect(screen.getByTestId('tab-researchAreas')).toBeInTheDocument();
    expect(screen.getByTestId('tab-projectAllocations')).toBeInTheDocument();
    expect(screen.getByTestId('tab-academicModules')).toBeInTheDocument();
    expect(screen.getByTestId('tab-guidelines')).toBeInTheDocument();
  });

  test('loads and displays overview statistics on initial render', async () => {
    render(
      <ModuleLeaderDashboard
        fetchOverviewStatistics={mockFetchOverviewStatistics}
        fetchTags={mockFetchTags}
        fetchProjects={mockFetchProjects}
        fetchAcademicModules={mockFetchAcademicModules}
        fetchGuidelines={mockFetchGuidelines}
      />,
    );

    expect(screen.getByTestId('dashboard-loading')).toBeInTheDocument();

    await waitFor(() => {
      expect(mockFetchOverviewStatistics).toHaveBeenCalledTimes(1);
    });

    await waitFor(() => {
      expect(screen.queryByTestId('dashboard-loading')).not.toBeInTheDocument();
    });

    const statisticsCards = screen.getByTestId('statistics-cards');
    expect(within(statisticsCards).getByTestId('total-projects-card')).toBeInTheDocument();
    expect(within(statisticsCards).getByText('24')).toBeInTheDocument();
    expect(within(statisticsCards).getByText('7')).toBeInTheDocument();
    expect(within(statisticsCards).getByText('3')).toBeInTheDocument();
  });

  test('switches to Research Areas section and displays tags', async () => {
    render(
      <ModuleLeaderDashboard
        fetchOverviewStatistics={mockFetchOverviewStatistics}
        fetchTags={mockFetchTags}
        fetchProjects={mockFetchProjects}
        fetchAcademicModules={mockFetchAcademicModules}
        fetchGuidelines={mockFetchGuidelines}
      />,
    );

    await waitFor(() => {
      expect(screen.queryByTestId('dashboard-loading')).not.toBeInTheDocument();
    });

    const researchAreasTab = screen.getByTestId('tab-researchAreas');
    fireEvent.click(researchAreasTab);

    await waitFor(() => {
      expect(screen.getByTestId('research-areas-section')).toBeInTheDocument();
    });

    expect(screen.getByTestId('tags-grid')).toBeInTheDocument();
    expect(screen.getByTestId('tag-tag_001')).toHaveTextContent('Next.js');
    expect(screen.getByTestId('tag-tag_002')).toHaveTextContent('Machine Learning');
    expect(screen.getByTestId('tag-tag_003')).toHaveTextContent('Flutter');
  });

  test('switches to Project Allocations section and displays projects', async () => {
    render(
      <ModuleLeaderDashboard
        fetchOverviewStatistics={mockFetchOverviewStatistics}
        fetchTags={mockFetchTags}
        fetchProjects={mockFetchProjects}
        fetchAcademicModules={mockFetchAcademicModules}
        fetchGuidelines={mockFetchGuidelines}
      />,
    );

    await waitFor(() => {
      expect(screen.queryByTestId('dashboard-loading')).not.toBeInTheDocument();
    });

    const projectsTab = screen.getByTestId('tab-projectAllocations');
    fireEvent.click(projectsTab);

    await waitFor(() => {
      expect(screen.getByTestId('project-allocations-section')).toBeInTheDocument();
    });

    expect(screen.getByTestId('projects-list')).toBeInTheDocument();
    expect(screen.getByTestId('project-proj_001')).toHaveTextContent('AI-Based Student Support');
    expect(screen.getByTestId('project-proj_002')).toHaveTextContent('Green Campus Analytics');
    expect(within(screen.getByTestId('project-proj_001')).getByText(/PENDING/)).toBeInTheDocument();
    expect(within(screen.getByTestId('project-proj_002')).getByText(/MATCHED/)).toBeInTheDocument();
  });

  test('switches to Academic Modules section and displays modules', async () => {
    render(
      <ModuleLeaderDashboard
        fetchOverviewStatistics={mockFetchOverviewStatistics}
        fetchTags={mockFetchTags}
        fetchProjects={mockFetchProjects}
        fetchAcademicModules={mockFetchAcademicModules}
        fetchGuidelines={mockFetchGuidelines}
      />,
    );

    await waitFor(() => {
      expect(screen.queryByTestId('dashboard-loading')).not.toBeInTheDocument();
    });

    const modulesTab = screen.getByTestId('tab-academicModules');
    fireEvent.click(modulesTab);

    await waitFor(() => {
      expect(screen.getByTestId('academic-modules-section')).toBeInTheDocument();
    });

    expect(screen.getByTestId('modules-list')).toBeInTheDocument();
    expect(screen.getByTestId('module-mod_001')).toHaveTextContent('PUSL2020');
    expect(screen.getByText('Software Development Tools')).toBeInTheDocument();
    expect(screen.getByText(/2026\/2027/)).toBeInTheDocument();
  });

  test('switches to Guidelines section and displays guidelines', async () => {
    render(
      <ModuleLeaderDashboard
        fetchOverviewStatistics={mockFetchOverviewStatistics}
        fetchTags={mockFetchTags}
        fetchProjects={mockFetchProjects}
        fetchAcademicModules={mockFetchAcademicModules}
        fetchGuidelines={mockFetchGuidelines}
      />,
    );

    await waitFor(() => {
      expect(screen.queryByTestId('dashboard-loading')).not.toBeInTheDocument();
    });

    const guidelinesTab = screen.getByTestId('tab-guidelines');
    fireEvent.click(guidelinesTab);

    await waitFor(() => {
      expect(screen.getByTestId('guidelines-section')).toBeInTheDocument();
    });

    expect(screen.getByTestId('guidelines-list')).toBeInTheDocument();
    expect(screen.getByTestId('guideline-guide_1')).toHaveTextContent('Final Year Project Guidelines');
    expect(within(screen.getByTestId('guideline-guide_1')).getByText(/PUSL2030/)).toBeInTheDocument();
  });

  test('displays empty state when Research Areas has no tags', async () => {
    mockFetchTags.mockImplementation(async () => []);

    render(
      <ModuleLeaderDashboard
        fetchOverviewStatistics={mockFetchOverviewStatistics}
        fetchTags={mockFetchTags}
        fetchProjects={mockFetchProjects}
        fetchAcademicModules={mockFetchAcademicModules}
        fetchGuidelines={mockFetchGuidelines}
      />,
    );

    await waitFor(() => {
      expect(screen.queryByTestId('dashboard-loading')).not.toBeInTheDocument();
    });

    const researchAreasTab = screen.getByTestId('tab-researchAreas');
    fireEvent.click(researchAreasTab);

    await waitFor(() => {
      expect(screen.getByTestId('no-tags-message')).toHaveTextContent(
        'No tags available. Create your first tag to begin.',
      );
    });
  });

  test('displays empty state when Project Allocations has no projects', async () => {
    mockFetchProjects.mockImplementation(async () => []);

    render(
      <ModuleLeaderDashboard
        fetchOverviewStatistics={mockFetchOverviewStatistics}
        fetchTags={mockFetchTags}
        fetchProjects={mockFetchProjects}
        fetchAcademicModules={mockFetchAcademicModules}
        fetchGuidelines={mockFetchGuidelines}
      />,
    );

    await waitFor(() => {
      expect(screen.queryByTestId('dashboard-loading')).not.toBeInTheDocument();
    });

    const projectsTab = screen.getByTestId('tab-projectAllocations');
    fireEvent.click(projectsTab);

    await waitFor(() => {
      expect(screen.getByTestId('no-projects-message')).toHaveTextContent('No projects available.');
    });
  });

  test('displays empty state when Academic Modules has no modules', async () => {
    mockFetchAcademicModules.mockImplementation(async () => []);

    render(
      <ModuleLeaderDashboard
        fetchOverviewStatistics={mockFetchOverviewStatistics}
        fetchTags={mockFetchTags}
        fetchProjects={mockFetchProjects}
        fetchAcademicModules={mockFetchAcademicModules}
        fetchGuidelines={mockFetchGuidelines}
      />,
    );

    await waitFor(() => {
      expect(screen.queryByTestId('dashboard-loading')).not.toBeInTheDocument();
    });

    const modulesTab = screen.getByTestId('tab-academicModules');
    fireEvent.click(modulesTab);

    await waitFor(() => {
      expect(screen.getByTestId('no-modules-message')).toHaveTextContent(
        'No modules available. Create your first module to begin.',
      );
    });
  });

  test('displays empty state when Guidelines has no guidelines', async () => {
    mockFetchGuidelines.mockImplementation(async () => []);

    render(
      <ModuleLeaderDashboard
        fetchOverviewStatistics={mockFetchOverviewStatistics}
        fetchTags={mockFetchTags}
        fetchProjects={mockFetchProjects}
        fetchAcademicModules={mockFetchAcademicModules}
        fetchGuidelines={mockFetchGuidelines}
      />,
    );

    await waitFor(() => {
      expect(screen.queryByTestId('dashboard-loading')).not.toBeInTheDocument();
    });

    const guidelinesTab = screen.getByTestId('tab-guidelines');
    fireEvent.click(guidelinesTab);

    await waitFor(() => {
      expect(screen.getByTestId('no-guidelines-message')).toHaveTextContent('No guidelines available.');
    });
  });

  test('loads all data in parallel on initial render', async () => {
    render(
      <ModuleLeaderDashboard
        fetchOverviewStatistics={mockFetchOverviewStatistics}
        fetchTags={mockFetchTags}
        fetchProjects={mockFetchProjects}
        fetchAcademicModules={mockFetchAcademicModules}
        fetchGuidelines={mockFetchGuidelines}
      />,
    );

    await waitFor(() => {
      expect(mockFetchOverviewStatistics).toHaveBeenCalledTimes(1);
      expect(mockFetchTags).toHaveBeenCalledTimes(1);
      expect(mockFetchProjects).toHaveBeenCalledTimes(1);
      expect(mockFetchAcademicModules).toHaveBeenCalledTimes(1);
      expect(mockFetchGuidelines).toHaveBeenCalledTimes(1);
    });
  });
});
