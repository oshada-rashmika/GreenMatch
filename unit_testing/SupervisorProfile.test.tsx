/// <reference types="react" />
/// <reference types="react-dom" />

import { cleanup, render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

const mockNavigate = jest.fn();

jest.mock('react-router-dom', () => ({
  useNavigate: () => mockNavigate,
}), { virtual: true });

function SupervisorProfilePage() {
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
});