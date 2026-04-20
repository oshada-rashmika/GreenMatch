/// <reference types="react" />
/// <reference types="react-dom" />

import { useEffect, useState } from 'react';
import { render, screen, waitFor, within, fireEvent } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

type ModuleLeaderModule = {
  moduleName: string;
  moduleCode: string;
  academicYear: string;
  batch: string;
};

type ModuleLeaderProfile = {
  id: string;
  fullName: string;
  staffId: string;
  email: string;
  ledModules: ModuleLeaderModule[];
};

type ModuleLeaderProfileProps = {
  fetchProfile: () => Promise<ModuleLeaderProfile>;
  updateProfile: (data: {
    fullName: string;
    staffId: string;
  }) => Promise<{ success: boolean; message: string }>;
  onLogout: () => Promise<void>;
};

function ModuleLeaderProfileComponent({
  fetchProfile,
  updateProfile,
  onLogout,
}: ModuleLeaderProfileProps) {
  const [profile, setProfile] = useState<ModuleLeaderProfile | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [isPersonalInfoExpanded, setIsPersonalInfoExpanded] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [fullName, setFullName] = useState('');
  const [staffId, setStaffId] = useState('');

  useEffect(() => {
    let isMounted = true;

    const loadProfile = async () => {
      try {
        const data = await fetchProfile();
        if (isMounted) {
          setProfile(data);
          setFullName(data.fullName);
          setStaffId(data.staffId);
          setError(null);
        }
      } catch (err) {
        if (isMounted) {
          setError(err instanceof Error ? err.message : 'Failed to load profile');
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
  }, [fetchProfile]);

  const handleSaveChanges = async () => {
    setIsSaving(true);
    try {
      const result = await updateProfile({
        fullName: fullName.trim(),
        staffId: staffId.trim(),
      });

      if (result.success) {
        setProfile((prev) =>
          prev ? { ...prev, fullName, staffId } : null,
        );
        setIsPersonalInfoExpanded(false);
      }
    } finally {
      setIsSaving(false);
    }
  };

  const handleLogout = async () => {
    await onLogout();
  };

  if (isLoading) {
    return (
      <div data-testid="profile-loading" role="status" aria-label="Loading profile">
        Loading profile...
      </div>
    );
  }

  if (error) {
    return (
      <div data-testid="profile-error" role="alert">
        Error: {error}
      </div>
    );
  }

  if (!profile) {
    return (
      <div data-testid="profile-not-found">
        Authentication required
      </div>
    );
  }

  return (
    <div data-testid="module-leader-profile" className="profile-container">
      <header data-testid="profile-header" className="profile-header">
        <button data-testid="back-button" className="back-button" aria-label="Go back">
          ←
        </button>
        <h1>Module Leader Profile</h1>
      </header>

      <main className="profile-content">
        <div data-testid="profile-avatar" className="profile-avatar">
          👨‍🎓
        </div>

        <h2 data-testid="profile-name">{profile.fullName}</h2>

        <div data-testid="staff-id-badge" className="staff-id-badge">
          Staff ID: {profile.staffId}
        </div>

        {/* Managed Modules Card */}
        <section data-testid="managed-modules-card" className="card">
          <div className="card-header">
            <h3>MANAGED MODULES</h3>
            <span data-testid="modules-count" className="badge">
              {profile.ledModules.length} Modules
            </span>
          </div>

          {profile.ledModules.length === 0 ? (
            <p data-testid="no-modules-message">No modules currently managed.</p>
          ) : (
            <div data-testid="modules-list" className="modules-list">
              {profile.ledModules.map((module, index) => (
                <div key={index} data-testid={`module-${index}`} className="module-item">
                  <h4>{module.moduleName}</h4>
                  <p className="module-details">
                    {module.moduleCode} • {module.academicYear} • {module.batch}
                  </p>
                </div>
              ))}
            </div>
          )}
        </section>

        {/* Personal Information Section */}
        <section data-testid="personal-info-section" className="personal-info-section">
          <button
            data-testid="personal-info-toggle"
            className="section-toggle"
            onClick={() => setIsPersonalInfoExpanded(!isPersonalInfoExpanded)}
            aria-expanded={isPersonalInfoExpanded}
          >
            <span>Personal Information</span>
            <span>{isPersonalInfoExpanded ? '▲' : '▼'}</span>
          </button>

          {isPersonalInfoExpanded && (
            <div data-testid="personal-info-form" className="card">
              <div className="form-group">
                <label htmlFor="fullname-input">FULL NAME</label>
                <input
                  id="fullname-input"
                  data-testid="fullname-input"
                  type="text"
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  className="form-input"
                />
              </div>

              <div className="form-group">
                <label htmlFor="staffid-input">STAFF ID</label>
                <input
                  id="staffid-input"
                  data-testid="staffid-input"
                  type="text"
                  value={staffId}
                  onChange={(e) => setStaffId(e.target.value)}
                  className="form-input"
                />
              </div>

              <div className="form-group">
                <label>EMAIL ADDRESS</label>
                <p data-testid="email-readonly" className="readonly-field">
                  {profile.email}
                </p>
              </div>

              <button
                data-testid="save-changes-button"
                className="btn-primary"
                onClick={handleSaveChanges}
                disabled={isSaving}
              >
                {isSaving ? 'Saving...' : 'Save Changes'}
              </button>
            </div>
          )}
        </section>

        {/* Logout Button */}
        <button
          data-testid="logout-button"
          className="btn-logout"
          onClick={handleLogout}
        >
          Log Out
        </button>
      </main>
    </div>
  );
}

describe('ModuleLeaderProfile - Verify profile display and edit functionality', () => {
  const mockProfile: ModuleLeaderProfile = {
    id: 'leader_1',
    fullName: 'Dr. Perera',
    staffId: 'STAFF001',
    email: 'perera@nsbm.edu',
    ledModules: [
      {
        moduleName: 'Software Development Tools',
        moduleCode: 'PUSL2020',
        academicYear: '2026/2027',
        batch: 'Batch 24',
      },
      {
        moduleName: 'Enterprise Applications',
        moduleCode: 'PUSL3022',
        academicYear: '2026/2027',
        batch: 'Batch 23',
      },
    ],
  };

  let mockFetchProfile: jest.MockedFunction<() => Promise<ModuleLeaderProfile>>;
  let mockUpdateProfile: jest.MockedFunction<
    (data: { fullName: string; staffId: string }) => Promise<{ success: boolean; message: string }>
  >;
  let mockOnLogout: jest.MockedFunction<() => Promise<void>>;

  beforeEach(() => {
    mockFetchProfile = jest.fn(async () => mockProfile);
    mockUpdateProfile = jest.fn(async () => ({
      success: true,
      message: 'Profile updated successfully',
    }));
    mockOnLogout = jest.fn(async () => {});
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  test('renders profile header and displays user information', async () => {
    render(
      <ModuleLeaderProfileComponent
        fetchProfile={mockFetchProfile}
        updateProfile={mockUpdateProfile}
        onLogout={mockOnLogout}
      />,
    );

    expect(screen.getByTestId('profile-loading')).toBeInTheDocument();

    await waitFor(() => {
      expect(screen.queryByTestId('profile-loading')).not.toBeInTheDocument();
    });

    expect(screen.getByRole('heading', { name: /module leader profile/i })).toBeInTheDocument();
    expect(screen.getByTestId('profile-name')).toHaveTextContent('Dr. Perera');
    expect(screen.getByTestId('staff-id-badge')).toHaveTextContent('Staff ID: STAFF001');
  });

  test('loads profile data on mount and displays modules', async () => {
    render(
      <ModuleLeaderProfileComponent
        fetchProfile={mockFetchProfile}
        updateProfile={mockUpdateProfile}
        onLogout={mockOnLogout}
      />,
    );

    await waitFor(() => {
      expect(mockFetchProfile).toHaveBeenCalledTimes(1);
    });

    await waitFor(() => {
      expect(screen.getByTestId('modules-list')).toBeInTheDocument();
    });

    expect(screen.getByTestId('modules-count')).toHaveTextContent('2 Modules');
    expect(screen.getByTestId('module-0')).toHaveTextContent('Software Development Tools');
    expect(screen.getByTestId('module-1')).toHaveTextContent('Enterprise Applications');
  });

  test('displays module details correctly', async () => {
    render(
      <ModuleLeaderProfileComponent
        fetchProfile={mockFetchProfile}
        updateProfile={mockUpdateProfile}
        onLogout={mockOnLogout}
      />,
    );

    await waitFor(() => {
      expect(screen.getByTestId('modules-list')).toBeInTheDocument();
    });

    const module0 = screen.getByTestId('module-0');
    expect(within(module0).getByText(/PUSL2020/)).toBeInTheDocument();
    expect(within(module0).getByText(/2026\/2027/)).toBeInTheDocument();
    expect(within(module0).getByText(/Batch 24/)).toBeInTheDocument();
  });

  test('expands and collapses personal information section', async () => {
    const user = userEvent.setup();

    render(
      <ModuleLeaderProfileComponent
        fetchProfile={mockFetchProfile}
        updateProfile={mockUpdateProfile}
        onLogout={mockOnLogout}
      />,
    );

    await waitFor(() => {
      expect(screen.queryByTestId('profile-loading')).not.toBeInTheDocument();
    });

    const toggleButton = screen.getByTestId('personal-info-toggle');
    expect(screen.queryByTestId('personal-info-form')).not.toBeInTheDocument();

    await user.click(toggleButton);

    expect(screen.getByTestId('personal-info-form')).toBeInTheDocument();
    expect(toggleButton).toHaveAttribute('aria-expanded', 'true');

    await user.click(toggleButton);

    expect(screen.queryByTestId('personal-info-form')).not.toBeInTheDocument();
    expect(toggleButton).toHaveAttribute('aria-expanded', 'false');
  });

  test('populates form fields with current profile data', async () => {
    const user = userEvent.setup();

    render(
      <ModuleLeaderProfileComponent
        fetchProfile={mockFetchProfile}
        updateProfile={mockUpdateProfile}
        onLogout={mockOnLogout}
      />,
    );

    await waitFor(() => {
      expect(screen.queryByTestId('profile-loading')).not.toBeInTheDocument();
    });

    await user.click(screen.getByTestId('personal-info-toggle'));

    const fullNameInput = screen.getByTestId('fullname-input') as HTMLInputElement;
    const staffIdInput = screen.getByTestId('staffid-input') as HTMLInputElement;

    expect(fullNameInput.value).toBe('Dr. Perera');
    expect(staffIdInput.value).toBe('STAFF001');
    expect(screen.getByTestId('email-readonly')).toHaveTextContent('perera@nsbm.edu');
  });

  test('allows editing full name and staff id', async () => {
    const user = userEvent.setup();

    render(
      <ModuleLeaderProfileComponent
        fetchProfile={mockFetchProfile}
        updateProfile={mockUpdateProfile}
        onLogout={mockOnLogout}
      />,
    );

    await waitFor(() => {
      expect(screen.queryByTestId('profile-loading')).not.toBeInTheDocument();
    });

    await user.click(screen.getByTestId('personal-info-toggle'));

    const fullNameInput = screen.getByTestId('fullname-input');
    const staffIdInput = screen.getByTestId('staffid-input');

    await user.clear(fullNameInput);
    await user.type(fullNameInput, 'Prof. Silva');

    await user.clear(staffIdInput);
    await user.type(staffIdInput, 'STAFF002');

    expect((fullNameInput as HTMLInputElement).value).toBe('Prof. Silva');
    expect((staffIdInput as HTMLInputElement).value).toBe('STAFF002');
  });

  test('saves changes when Save Changes button is clicked', async () => {
    const user = userEvent.setup();

    render(
      <ModuleLeaderProfileComponent
        fetchProfile={mockFetchProfile}
        updateProfile={mockUpdateProfile}
        onLogout={mockOnLogout}
      />,
    );

    await waitFor(() => {
      expect(screen.queryByTestId('profile-loading')).not.toBeInTheDocument();
    });

    await user.click(screen.getByTestId('personal-info-toggle'));

    const fullNameInput = screen.getByTestId('fullname-input');
    await user.clear(fullNameInput);
    await user.type(fullNameInput, 'Prof. Silva');

    const saveButton = screen.getByTestId('save-changes-button');
    await user.click(saveButton);

    await waitFor(() => {
      expect(mockUpdateProfile).toHaveBeenCalledWith({
        fullName: 'Prof. Silva',
        staffId: 'STAFF001',
      });
    });
  });

  test('closes personal info form after successful save', async () => {
    const user = userEvent.setup();

    render(
      <ModuleLeaderProfileComponent
        fetchProfile={mockFetchProfile}
        updateProfile={mockUpdateProfile}
        onLogout={mockOnLogout}
      />,
    );

    await waitFor(() => {
      expect(screen.queryByTestId('profile-loading')).not.toBeInTheDocument();
    });

    await user.click(screen.getByTestId('personal-info-toggle'));
    expect(screen.getByTestId('personal-info-form')).toBeInTheDocument();

    const saveButton = screen.getByTestId('save-changes-button');
    await user.click(saveButton);

    await waitFor(() => {
      expect(screen.queryByTestId('personal-info-form')).not.toBeInTheDocument();
    });
  });

  test('updates profile name after successful save', async () => {
    const user = userEvent.setup();

    render(
      <ModuleLeaderProfileComponent
        fetchProfile={mockFetchProfile}
        updateProfile={mockUpdateProfile}
        onLogout={mockOnLogout}
      />,
    );

    await waitFor(() => {
      expect(screen.getByTestId('profile-name')).toHaveTextContent('Dr. Perera');
    });

    await user.click(screen.getByTestId('personal-info-toggle'));

    const fullNameInput = screen.getByTestId('fullname-input');
    await user.clear(fullNameInput);
    await user.type(fullNameInput, 'Prof. Silva');

    await user.click(screen.getByTestId('save-changes-button'));

    await waitFor(() => {
      expect(screen.getByTestId('profile-name')).toHaveTextContent('Prof. Silva');
    });
  });

  test('calls logout function when Log Out button is clicked', async () => {
    const user = userEvent.setup();

    render(
      <ModuleLeaderProfileComponent
        fetchProfile={mockFetchProfile}
        updateProfile={mockUpdateProfile}
        onLogout={mockOnLogout}
      />,
    );

    await waitFor(() => {
      expect(screen.queryByTestId('profile-loading')).not.toBeInTheDocument();
    });

    const logoutButton = screen.getByTestId('logout-button');
    await user.click(logoutButton);

    await waitFor(() => {
      expect(mockOnLogout).toHaveBeenCalledTimes(1);
    });
  });

  test('displays empty state when module leader has no modules', async () => {
    const emptyProfile: ModuleLeaderProfile = {
      ...mockProfile,
      ledModules: [],
    };

    mockFetchProfile.mockImplementation(async () => emptyProfile);

    render(
      <ModuleLeaderProfileComponent
        fetchProfile={mockFetchProfile}
        updateProfile={mockUpdateProfile}
        onLogout={mockOnLogout}
      />,
    );

    await waitFor(() => {
      expect(screen.getByTestId('no-modules-message')).toBeInTheDocument();
    });

    expect(screen.getByTestId('modules-count')).toHaveTextContent('0 Modules');
    expect(screen.queryByTestId('modules-list')).not.toBeInTheDocument();
  });

  test('displays error when profile fetch fails', async () => {
    mockFetchProfile.mockRejectedValueOnce(new Error('Network error'));

    render(
      <ModuleLeaderProfileComponent
        fetchProfile={mockFetchProfile}
        updateProfile={mockUpdateProfile}
        onLogout={mockOnLogout}
      />,
    );

    await waitFor(() => {
      expect(screen.getByTestId('profile-error')).toBeInTheDocument();
    });

    expect(screen.getByTestId('profile-error')).toHaveTextContent('Error: Network error');
  });

  test('disables save button while saving', async () => {
    const user = userEvent.setup();

    mockUpdateProfile.mockImplementationOnce(async () => {
      await new Promise((resolve) => setTimeout(resolve, 100));
      return { success: true, message: 'Saved' };
    });

    render(
      <ModuleLeaderProfileComponent
        fetchProfile={mockFetchProfile}
        updateProfile={mockUpdateProfile}
        onLogout={mockOnLogout}
      />,
    );

    await waitFor(() => {
      expect(screen.queryByTestId('profile-loading')).not.toBeInTheDocument();
    });

    await user.click(screen.getByTestId('personal-info-toggle'));
    const saveButton = screen.getByTestId('save-changes-button');

    await user.click(saveButton);

    expect(saveButton).toBeDisabled();

    await waitFor(
      () => {
        expect(saveButton).not.toBeDisabled();
      },
      { timeout: 2000 },
    );
  });
});
