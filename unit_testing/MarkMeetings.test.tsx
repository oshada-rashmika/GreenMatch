/// <reference types="react" />
/// <reference types="react-dom" />

import { useEffect, useState } from 'react';
import { render, screen, waitFor, within, fireEvent } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

type SupervisedProject = {
  id: string;
  groupId: string;
  title: string;
  groupName: string;
  status: 'MATCHED' | 'PENDING' | 'UNDER_REVIEW';
  teamMembers: Array<{ id: string; name: string }>;
};

type MeetingMark = {
  meetingNumber: number;
  scheduledDate: Date;
  groupId: string;
};

type MarkMeetingsProjectListProps = {
  fetchProjects: () => Promise<SupervisedProject[]>;
  onProjectSelect: (project: SupervisedProject) => void;
};

type MeetingDaysGridProps = {
  project: SupervisedProject;
  fetchMeetingMarks: (groupId: string) => Promise<MeetingMark[]>;
  markMeetingDay: (groupId: string, meetingNumber: number, date: Date) => Promise<void>;
  unmarkMeetingDay: (groupId: string, meetingNumber: number) => Promise<void>;
};

function MarkMeetingsProjectListScreen({
  fetchProjects,
  onProjectSelect,
}: MarkMeetingsProjectListProps) {
  const [projects, setProjects] = useState<SupervisedProject[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;

    const loadProjects = async () => {
      try {
        const data = await fetchProjects();
        if (isMounted) {
          // Filter only MATCHED projects
          const matchedProjects = data.filter((p) => p.status === 'MATCHED');
          setProjects(matchedProjects);
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

    void loadProjects();

    return () => {
      isMounted = false;
    };
  }, [fetchProjects]);

  const handleRefresh = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const data = await fetchProjects();
      const matchedProjects = data.filter((p) => p.status === 'MATCHED');
      setProjects(matchedProjects);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load projects');
    } finally {
      setIsLoading(false);
    }
  };

  if (isLoading) {
    return (
      <div data-testid="projects-loading" role="status" aria-label="Loading projects">
        Loading your projects...
      </div>
    );
  }

  if (error) {
    return (
      <div data-testid="projects-error" role="alert">
        <h2>Failed to load projects</h2>
        <p>{error}</p>
        <button data-testid="projects-retry-button" onClick={handleRefresh}>
          Retry
        </button>
      </div>
    );
  }

  if (projects.length === 0) {
    return (
      <div data-testid="projects-empty-state">
        <h2>No Active Projects</h2>
        <p>You have no matched projects to mark meetings for.</p>
      </div>
    );
  }

  return (
    <div data-testid="projects-list-container" className="projects-container">
      <header data-testid="projects-header" className="header">
        <h1>Mark Meetings</h1>
        <p>SELECT A PROJECT</p>
        <p>Choose a project to mark meeting days</p>
        <p>At least 7 meetings must be marked per project</p>
      </header>

      <main data-testid="projects-list" className="projects-list">
        {projects.map((project) => (
          <div
            key={project.id}
            data-testid={`project-card-${project.id}`}
            className="project-card"
            onClick={() => onProjectSelect(project)}
            role="button"
            tabIndex={0}
            onKeyDown={(e) => {
              if (e.key === 'Enter') {
                onProjectSelect(project);
              }
            }}
          >
            <div className="project-icon">📋</div>
            <div className="project-content">
              <h3 data-testid={`project-group-${project.id}`} className="project-group">
                {project.groupName}
              </h3>
              <p data-testid={`project-title-${project.id}`} className="project-title">
                {project.title}
              </p>
              <div className="project-meta">
                <span data-testid={`project-members-${project.id}`}>
                  {project.teamMembers.length} members
                </span>
                <span
                  data-testid={`project-status-${project.id}`}
                  className="status-badge"
                >
                  {project.status}
                </span>
              </div>
            </div>
            <div className="project-arrow">→</div>
          </div>
        ))}
      </main>
    </div>
  );
}

function MeetingDaysGridScreen({
  project,
  fetchMeetingMarks,
  markMeetingDay,
  unmarkMeetingDay,
}: MeetingDaysGridProps) {
  const [markedMeetings, setMarkedMeetings] = useState<Map<number, MeetingMark>>(new Map());
  const [isLoading, setIsLoading] = useState(true);
  const [selectedMeeting, setSelectedMeeting] = useState<number | null>(null);
  const [selectedDate, setSelectedDate] = useState(new Date());

  const TOTAL_MEETINGS = 21;

  useEffect(() => {
    let isMounted = true;

    const loadMarks = async () => {
      try {
        const marks = await fetchMeetingMarks(project.groupId);
        if (isMounted) {
          const marksMap = new Map(marks.map((m) => [m.meetingNumber, m]));
          setMarkedMeetings(marksMap);
        }
      } finally {
        if (isMounted) {
          setIsLoading(false);
        }
      }
    };

    void loadMarks();

    return () => {
      isMounted = false;
    };
  }, [project.groupId, fetchMeetingMarks]);

  const handleMarkMeeting = async (meetingNumber: number) => {
    try {
      await markMeetingDay(project.groupId, meetingNumber, selectedDate);
      const updatedMarks = new Map(markedMeetings);
      updatedMarks.set(meetingNumber, {
        meetingNumber,
        scheduledDate: selectedDate,
        groupId: project.groupId,
      });
      setMarkedMeetings(updatedMarks);
      setSelectedMeeting(null);
    } catch (error) {
      console.error('Failed to mark meeting:', error);
    }
  };

  const handleUnmarkMeeting = async (meetingNumber: number) => {
    try {
      await unmarkMeetingDay(project.groupId, meetingNumber);
      const updatedMarks = new Map(markedMeetings);
      updatedMarks.delete(meetingNumber);
      setMarkedMeetings(updatedMarks);
      setSelectedMeeting(null);
    } catch (error) {
      console.error('Failed to unmark meeting:', error);
    }
  };

  if (isLoading) {
    return (
      <div data-testid="grid-loading" role="status">
        Loading meeting marks...
      </div>
    );
  }

  const markedCount = markedMeetings.size;
  const progress = markedCount / TOTAL_MEETINGS;

  return (
    <div data-testid="meeting-grid-container" className="grid-container">
      <header data-testid="grid-header" className="header">
        <h1>Meeting Days</h1>
        <p data-testid="project-group-name">{project.groupName}</p>
      </header>

      <section data-testid="progress-section" className="progress-section">
        <h3 data-testid="project-title-info">{project.title}</h3>
        <div data-testid="progress-bar" className="progress-bar">
          <div style={{ width: `${progress * 100}%` }} className="progress-fill" />
        </div>
        <p data-testid="progress-text" className="progress-text">
          {markedCount} / {TOTAL_MEETINGS}
        </p>
      </section>

      <section data-testid="meetings-grid" className="meetings-grid">
        {Array.from({ length: TOTAL_MEETINGS }).map((_, index) => {
          const meetingNumber = index + 1;
          const isMarked = markedMeetings.has(meetingNumber);
          const mark = markedMeetings.get(meetingNumber);

          return (
            <div
              key={meetingNumber}
              data-testid={`meeting-day-${meetingNumber}`}
              className={`meeting-day ${isMarked ? 'marked' : 'unmarked'}`}
              onClick={() => setSelectedMeeting(meetingNumber)}
              role="button"
              tabIndex={0}
              onKeyDown={(e) => {
                if (e.key === 'Enter') {
                  setSelectedMeeting(meetingNumber);
                }
              }}
            >
              <span className="meeting-number">{meetingNumber}</span>
              {isMarked && mark && (
                <div data-testid={`meeting-date-${meetingNumber}`} className="meeting-date">
                  {new Date(mark.scheduledDate).toLocaleDateString('en-US', {
                    month: 'short',
                    day: 'numeric',
                  })}
                </div>
              )}
              <span className="meeting-icon">{isMarked ? '✓' : '+'}</span>
            </div>
          );
        })}
      </section>

      {selectedMeeting && (
        <div data-testid="meeting-dialog" className="dialog-overlay">
          <div className="dialog-content">
            <h2>Meeting Day {selectedMeeting}</h2>
            <p>{project.title}</p>

            {markedMeetings.has(selectedMeeting) ? (
              <div data-testid="marked-info">
                <p>
                  Marked on:{' '}
                  {markedMeetings.get(selectedMeeting)?.scheduledDate.toLocaleDateString()}
                </p>
                <button
                  data-testid="unmark-button"
                  onClick={() => handleUnmarkMeeting(selectedMeeting)}
                >
                  Unmark Meeting
                </button>
              </div>
            ) : (
              <div data-testid="mark-form">
                <input
                  data-testid="date-input"
                  type="date"
                  value={selectedDate.toISOString().split('T')[0]}
                  onChange={(e) => setSelectedDate(new Date(e.target.value))}
                />
                <button
                  data-testid="mark-button"
                  onClick={() => handleMarkMeeting(selectedMeeting)}
                >
                  Mark Meeting Day
                </button>
              </div>
            )}

            <button
              data-testid="close-dialog"
              onClick={() => setSelectedMeeting(null)}
              className="close-button"
            >
              Close
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

describe('MarkMeetingsProjectList - Verify project selection for marking meetings', () => {
  const mockProjects: SupervisedProject[] = [
    {
      id: 'proj_001',
      groupId: 'grp_001',
      title: 'AI-Based Student Support',
      groupName: 'Group Atlas',
      status: 'MATCHED',
      teamMembers: [
        { id: 'user_1', name: 'John' },
        { id: 'user_2', name: 'Jane' },
      ],
    },
    {
      id: 'proj_002',
      groupId: 'grp_002',
      title: 'Green Campus Analytics',
      groupName: 'Group Verde',
      status: 'MATCHED',
      teamMembers: [
        { id: 'user_3', name: 'Bob' },
        { id: 'user_4', name: 'Alice' },
        { id: 'user_5', name: 'Charlie' },
      ],
    },
    {
      id: 'proj_003',
      groupId: 'grp_003',
      title: 'Pending Project',
      groupName: 'Group Pending',
      status: 'PENDING',
      teamMembers: [{ id: 'user_6', name: 'David' }],
    },
  ];

  let mockFetchProjects: jest.MockedFunction<() => Promise<SupervisedProject[]>>;
  let mockOnProjectSelect: jest.MockedFunction<(project: SupervisedProject) => void>;
  let mockFetchMeetingMarks: jest.MockedFunction<(groupId: string) => Promise<MeetingMark[]>>;
  let mockMarkMeetingDay: jest.MockedFunction<
    (groupId: string, meetingNumber: number, date: Date) => Promise<void>
  >;
  let mockUnmarkMeetingDay: jest.MockedFunction<
    (groupId: string, meetingNumber: number) => Promise<void>
  >;

  beforeEach(() => {
    mockFetchProjects = jest.fn(async () => mockProjects);
    mockOnProjectSelect = jest.fn();
    mockFetchMeetingMarks = jest.fn(async () => []);
    mockMarkMeetingDay = jest.fn(async () => {});
    mockUnmarkMeetingDay = jest.fn(async () => {});
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('MarkMeetingsProjectList', () => {
    test('renders loading state initially', () => {
      render(
        <MarkMeetingsProjectListScreen
          fetchProjects={mockFetchProjects}
          onProjectSelect={mockOnProjectSelect}
        />,
      );

      expect(screen.getByTestId('projects-loading')).toBeInTheDocument();
    });

    test('loads and displays header', async () => {
      render(
        <MarkMeetingsProjectListScreen
          fetchProjects={mockFetchProjects}
          onProjectSelect={mockOnProjectSelect}
        />,
      );

      await waitFor(() => {
        expect(screen.getByTestId('projects-header')).toBeInTheDocument();
      });

      expect(screen.getByRole('heading', { name: /mark meetings/i })).toBeInTheDocument();
    });

    test('filters and displays only MATCHED status projects', async () => {
      render(
        <MarkMeetingsProjectListScreen
          fetchProjects={mockFetchProjects}
          onProjectSelect={mockOnProjectSelect}
        />,
      );

      await waitFor(() => {
        expect(screen.getByTestId('projects-list')).toBeInTheDocument();
      });

      // Should show only MATCHED projects
      expect(screen.getByTestId('project-card-proj_001')).toBeInTheDocument();
      expect(screen.getByTestId('project-card-proj_002')).toBeInTheDocument();

      // Should NOT show PENDING project
      expect(screen.queryByTestId('project-card-proj_003')).not.toBeInTheDocument();
    });

    test('displays project details correctly', async () => {
      render(
        <MarkMeetingsProjectListScreen
          fetchProjects={mockFetchProjects}
          onProjectSelect={mockOnProjectSelect}
        />,
      );

      await waitFor(() => {
        expect(screen.getByTestId('projects-list')).toBeInTheDocument();
      });

      expect(screen.getByTestId('project-group-proj_001')).toHaveTextContent('Group Atlas');
      expect(screen.getByTestId('project-title-proj_001')).toHaveTextContent(
        'AI-Based Student Support',
      );
      expect(screen.getByTestId('project-members-proj_001')).toHaveTextContent('2 members');
      expect(screen.getByTestId('project-status-proj_001')).toHaveTextContent('MATCHED');
    });

    test('calls onProjectSelect when project card is clicked', async () => {
      const user = userEvent.setup();

      render(
        <MarkMeetingsProjectListScreen
          fetchProjects={mockFetchProjects}
          onProjectSelect={mockOnProjectSelect}
        />,
      );

      await waitFor(() => {
        expect(screen.getByTestId('projects-list')).toBeInTheDocument();
      });

      const projectCard = screen.getByTestId('project-card-proj_001');
      await user.click(projectCard);

      expect(mockOnProjectSelect).toHaveBeenCalledWith(expect.objectContaining({
        id: 'proj_001',
        groupName: 'Group Atlas',
      }));
    });

    test('displays error state when fetch fails', async () => {
      mockFetchProjects.mockRejectedValueOnce(new Error('Network error'));

      render(
        <MarkMeetingsProjectListScreen
          fetchProjects={mockFetchProjects}
          onProjectSelect={mockOnProjectSelect}
        />,
      );

      await waitFor(() => {
        expect(screen.getByTestId('projects-error')).toBeInTheDocument();
      });

      expect(screen.getByText(/Network error/)).toBeInTheDocument();
    });

    test('provides retry button in error state', async () => {
      const user = userEvent.setup();

      mockFetchProjects.mockRejectedValueOnce(new Error('Network error'));

      render(
        <MarkMeetingsProjectListScreen
          fetchProjects={mockFetchProjects}
          onProjectSelect={mockOnProjectSelect}
        />,
      );

      await waitFor(() => {
        expect(screen.getByTestId('projects-error')).toBeInTheDocument();
      });

      const retryButton = screen.getByTestId('projects-retry-button');
      expect(retryButton).toBeInTheDocument();

      // Mock success for retry
      mockFetchProjects.mockImplementationOnce(async () => mockProjects);

      await user.click(retryButton);

      await waitFor(() => {
        expect(screen.getByTestId('projects-list')).toBeInTheDocument();
      });
    });

    test('displays empty state when no MATCHED projects exist', async () => {
      mockFetchProjects.mockImplementationOnce(async () => [
        {
          id: 'proj_004',
          groupId: 'grp_004',
          title: 'Pending Project',
          groupName: 'Group Pending',
          status: 'PENDING',
          teamMembers: [{ id: 'user_7', name: 'Eve' }],
        },
      ]);

      render(
        <MarkMeetingsProjectListScreen
          fetchProjects={mockFetchProjects}
          onProjectSelect={mockOnProjectSelect}
        />,
      );

      await waitFor(() => {
        expect(screen.getByTestId('projects-empty-state')).toBeInTheDocument();
      });

      expect(screen.getByRole('heading', { name: /no active projects/i })).toBeInTheDocument();
    });
  });

  describe('MeetingDaysGrid', () => {
    test('renders loading state initially', () => {
      render(
        <MeetingDaysGridScreen
          project={mockProjects[0]}
          fetchMeetingMarks={mockFetchMeetingMarks}
          markMeetingDay={mockMarkMeetingDay}
          unmarkMeetingDay={mockUnmarkMeetingDay}
        />,
      );

      expect(screen.getByTestId('grid-loading')).toBeInTheDocument();
    });

    test('displays project header and title', async () => {
      render(
        <MeetingDaysGridScreen
          project={mockProjects[0]}
          fetchMeetingMarks={mockFetchMeetingMarks}
          markMeetingDay={mockMarkMeetingDay}
          unmarkMeetingDay={mockUnmarkMeetingDay}
        />,
      );

      await waitFor(() => {
        expect(screen.getByTestId('grid-header')).toBeInTheDocument();
      });

      expect(screen.getByTestId('project-group-name')).toHaveTextContent('Group Atlas');
      expect(screen.getByTestId('project-title-info')).toHaveTextContent(
        'AI-Based Student Support',
      );
    });

    test('renders 21 meeting day boxes', async () => {
      render(
        <MeetingDaysGridScreen
          project={mockProjects[0]}
          fetchMeetingMarks={mockFetchMeetingMarks}
          markMeetingDay={mockMarkMeetingDay}
          unmarkMeetingDay={mockUnmarkMeetingDay}
        />,
      );

      await waitFor(() => {
        expect(screen.getByTestId('meetings-grid')).toBeInTheDocument();
      });

      const meetingDays = screen.getAllByTestId(/^meeting-day-/);
      expect(meetingDays).toHaveLength(21);
    });

    test('displays progress tracking correctly', async () => {
      const mockMarks: MeetingMark[] = [
        { meetingNumber: 1, scheduledDate: new Date('2026-04-20'), groupId: 'grp_001' },
        { meetingNumber: 2, scheduledDate: new Date('2026-04-21'), groupId: 'grp_001' },
      ];

      mockFetchMeetingMarks.mockImplementationOnce(async () => mockMarks);

      render(
        <MeetingDaysGridScreen
          project={mockProjects[0]}
          fetchMeetingMarks={mockFetchMeetingMarks}
          markMeetingDay={mockMarkMeetingDay}
          unmarkMeetingDay={mockUnmarkMeetingDay}
        />,
      );

      await waitFor(() => {
        expect(screen.getByTestId('progress-text')).toHaveTextContent('2 / 21');
      });
    });

    test('opens dialog when meeting day is clicked', async () => {
      const user = userEvent.setup();

      render(
        <MeetingDaysGridScreen
          project={mockProjects[0]}
          fetchMeetingMarks={mockFetchMeetingMarks}
          markMeetingDay={mockMarkMeetingDay}
          unmarkMeetingDay={mockUnmarkMeetingDay}
        />,
      );

      await waitFor(() => {
        expect(screen.getByTestId('meetings-grid')).toBeInTheDocument();
      });

      const meetingDay1 = screen.getByTestId('meeting-day-1');
      await user.click(meetingDay1);

      expect(screen.getByTestId('meeting-dialog')).toBeInTheDocument();
      expect(screen.getByRole('heading', { name: /meeting day 1/i })).toBeInTheDocument();
    });

    test('marks a meeting when mark button is clicked', async () => {
      const user = userEvent.setup();

      render(
        <MeetingDaysGridScreen
          project={mockProjects[0]}
          fetchMeetingMarks={mockFetchMeetingMarks}
          markMeetingDay={mockMarkMeetingDay}
          unmarkMeetingDay={mockUnmarkMeetingDay}
        />,
      );

      await waitFor(() => {
        expect(screen.getByTestId('meetings-grid')).toBeInTheDocument();
      });

      const meetingDay1 = screen.getByTestId('meeting-day-1');
      await user.click(meetingDay1);

      const markButton = screen.getByTestId('mark-button');
      await user.click(markButton);

      expect(mockMarkMeetingDay).toHaveBeenCalledWith(
        'grp_001',
        1,
        expect.any(Date),
      );
    });

    test('unmarks a meeting when unmark button is clicked', async () => {
      const user = userEvent.setup();

      const mockMarks: MeetingMark[] = [
        { meetingNumber: 1, scheduledDate: new Date('2026-04-20'), groupId: 'grp_001' },
      ];

      mockFetchMeetingMarks.mockImplementationOnce(async () => mockMarks);

      render(
        <MeetingDaysGridScreen
          project={mockProjects[0]}
          fetchMeetingMarks={mockFetchMeetingMarks}
          markMeetingDay={mockMarkMeetingDay}
          unmarkMeetingDay={mockUnmarkMeetingDay}
        />,
      );

      await waitFor(() => {
        expect(screen.getByTestId('meetings-grid')).toBeInTheDocument();
      });

      const meetingDay1 = screen.getByTestId('meeting-day-1');
      await user.click(meetingDay1);

      const unmarkButton = screen.getByTestId('unmark-button');
      await user.click(unmarkButton);

      expect(mockUnmarkMeetingDay).toHaveBeenCalledWith('grp_001', 1);
    });

    test('displays marked date for marked meetings', async () => {
      const mockMarks: MeetingMark[] = [
        { meetingNumber: 5, scheduledDate: new Date('2026-05-01'), groupId: 'grp_001' },
      ];

      mockFetchMeetingMarks.mockImplementationOnce(async () => mockMarks);

      render(
        <MeetingDaysGridScreen
          project={mockProjects[0]}
          fetchMeetingMarks={mockFetchMeetingMarks}
          markMeetingDay={mockMarkMeetingDay}
          unmarkMeetingDay={mockUnmarkMeetingDay}
        />,
      );

      await waitFor(() => {
        expect(screen.getByTestId('meeting-date-5')).toBeInTheDocument();
      });

      expect(screen.getByTestId('meeting-date-5')).toHaveTextContent('May 1');
    });

    test('closes dialog when close button is clicked', async () => {
      const user = userEvent.setup();

      render(
        <MeetingDaysGridScreen
          project={mockProjects[0]}
          fetchMeetingMarks={mockFetchMeetingMarks}
          markMeetingDay={mockMarkMeetingDay}
          unmarkMeetingDay={mockUnmarkMeetingDay}
        />,
      );

      await waitFor(() => {
        expect(screen.getByTestId('meetings-grid')).toBeInTheDocument();
      });

      const meetingDay1 = screen.getByTestId('meeting-day-1');
      await user.click(meetingDay1);

      expect(screen.getByTestId('meeting-dialog')).toBeInTheDocument();

      const closeButton = screen.getByTestId('close-dialog');
      await user.click(closeButton);

      expect(screen.queryByTestId('meeting-dialog')).not.toBeInTheDocument();
    });
  });
});
