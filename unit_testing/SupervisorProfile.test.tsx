/// <reference types="react" />
/// <reference types="react-dom" />

import { cleanup, fireEvent, render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

const mockNavigate = jest.fn();

jest.mock('react-router-dom', () => ({
  useNavigate: () => mockNavigate,
}), { virtual: true });

type SupervisorProfileData = {
  name: string;
  staffId: string;
  specializations: string;
  avatarUrl?: string;
};

function SupervisorProfilePage({
  profile,
}: {
  profile?: SupervisorProfileData;
}) {
  const { useNavigate } = require('react-router-dom') as {
    useNavigate: () => (to: string | number) => void;
  };

  const navigate = useNavigate();

  return (
    <section aria-label="supervisor-profile-page" className="bg-slate-900 text-slate-100">
      <nav
        aria-label="supervisor-profile-top-nav"
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '16px',
          borderBottom: '1px solid #1f2937',
        }}
      >
        <button
          type="button"
          data-testid="profile-back-button"
          aria-label="Go back"
          onClick={() => navigate(-1)}
        >
          <span aria-hidden="true">chevron-left</span>
        </button>

        <h1 style={{ margin: 0 }}>Supervisor Profile</h1>

        <button
          type="button"
          data-testid="profile-settings-button"
          aria-label="Settings"
        >
          <span aria-hidden="true">gear</span>
        </button>
      </nav>

      {profile ? (
        <section aria-label="supervisor-identity-section" style={{ padding: '16px' }}>
          {profile.avatarUrl ? (
            <img src={profile.avatarUrl} alt="Supervisor avatar" />
          ) : (
            <div data-testid="profile-avatar-fallback" aria-label="Profile avatar fallback">
              avatar-fallback
            </div>
          )}
          <h2>{profile.name}</h2>
          <p>Staff ID: {profile.staffId}</p>
          <p>Specializations: {profile.specializations}</p>
        </section>
      ) : null}
    </section>
  );
}

describe('SupervisorProfile - Verify the top navigation bar renders the back button and settings gear icon', () => {
  beforeEach(() => {
    mockNavigate.mockReset();
  });

  afterEach(() => {
    cleanup();
    jest.clearAllMocks();
    jest.resetAllMocks();
  });

  test('Verify the top navigation bar renders the back button and settings gear icon.', () => {
    render(<SupervisorProfilePage />);

    const backButton = screen.getByLabelText(/go back/i);
    const settingsButton = screen.getByLabelText(/settings/i);

    expect(backButton).toBeInTheDocument();
    expect(settingsButton).toBeInTheDocument();
  });

  test('Verify clicking the back button triggers navigation', () => {
    render(<SupervisorProfilePage />);

    const backButton = screen.getByTestId('profile-back-button');

    fireEvent.click(backButton);

    expect(mockNavigate).toHaveBeenCalledTimes(1);
    expect(mockNavigate).toHaveBeenCalledWith(-1);
  });

  test('Verify supervisor identity section renders avatar and profile details', () => {
    const mockProfile: SupervisorProfileData = {
      name: 'Anton Jayakody_',
      staffId: 'SUP-999',
      specializations: 'Cybersecurity, Web Development',
    };

    render(<SupervisorProfilePage profile={mockProfile} />);

    const avatarElement = screen.getByTestId('profile-avatar-fallback');

    expect(avatarElement).toBeInTheDocument();
    expect(screen.getByText('Anton Jayakody_')).toBeInTheDocument();
    expect(screen.getByText('Staff ID: SUP-999')).toBeInTheDocument();
    expect(
      screen.getByText('Specializations: Cybersecurity, Web Development'),
    ).toBeInTheDocument();
  });
});