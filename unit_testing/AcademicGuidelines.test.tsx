/// <reference types="react" />
/// <reference types="react-dom" />

import { useEffect, useState } from 'react';
import { cleanup, render, screen, waitFor, within } from '@testing-library/react';
import '@testing-library/jest-dom';

type Guideline = {
  id: string;
  title: string;
  moduleCode: string;
  publishedDate: string;
};

type AcademicGuidelinesProps = {
  fetchGuidelines: () => Promise<Guideline[]>;
};

function AcademicGuidelinesPage({ fetchGuidelines }: AcademicGuidelinesProps) {
  const [guidelines, setGuidelines] = useState<Guideline[]>([]);

  useEffect(() => {
    let isMounted = true;

    const loadGuidelines = async () => {
      const response = await fetchGuidelines();

      if (isMounted) {
        setGuidelines(response);
      }
    };

    void loadGuidelines();

    return () => {
      isMounted = false;
    };
  }, [fetchGuidelines]);

  return (
    <section
      aria-label="academic-guidelines-page"
      className="dark-theme bg-slate-900 text-slate-100 min-h-screen"
    >
      <header
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '12px',
          padding: '16px',
          borderBottom: '1px solid #1f2937',
        }}
      >
        <button type="button" aria-label="Back" className="icon-button">
          <span aria-hidden="true">←</span>
        </button>
        <h1>Academic Guidelines</h1>
      </header>

      <main style={{ padding: '16px' }}>
        {guidelines.map((guideline) => (
          <article
            key={guideline.id}
            data-testid="guideline-card"
            style={{
              background: '#111827',
              border: '1px solid #374151',
              borderRadius: '12px',
              padding: '16px',
            }}
          >
            <h2>{guideline.title}</h2>
            <div style={{ display: 'flex', gap: '12px', marginBottom: '12px' }}>
              <span className="module-chip bg-slate-700 px-2 py-1 rounded">
                {guideline.moduleCode}
              </span>
              <time>{guideline.publishedDate}</time>
            </div>

            <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
              <button type="button">PDF Report</button>
              <button type="button">Video Demo</button>
              <button type="button">GitHub Repo</button>
            </div>
          </article>
        ))}
      </main>
    </section>
  );
}

describe('AcademicGuidelines - Verify the Academic Guidelines page renders the header and guideline card correctly', () => {
  const mockedGuidelines: Guideline[] = [
    {
      id: 'guide_1',
      title: 'Final Year Project Guidelines',
      moduleCode: 'PUSL2030',
      publishedDate: 'Apr 29, 2026',
    },
  ];

  let mockFetchGuidelines: jest.MockedFunction<() => Promise<Guideline[]>>;

  beforeEach(() => {
    mockFetchGuidelines = jest.fn(async () => mockedGuidelines);
  });

  afterEach(() => {
    cleanup();
    jest.clearAllMocks();
    jest.resetAllMocks();
  });

  test('Verify the Academic Guidelines page renders the header and guideline card correctly', async () => {
    render(<AcademicGuidelinesPage fetchGuidelines={mockFetchGuidelines} />);

    const page = screen.getByLabelText('academic-guidelines-page');
    expect(page).toHaveClass('dark-theme');
    expect(page).toHaveClass('bg-slate-900');

    expect(
      screen.getByRole('heading', { name: /academic guidelines/i }),
    ).toBeInTheDocument();

    const backButton = screen.getByRole('button', { name: /back/i });
    expect(backButton).toBeInTheDocument();
    expect(within(backButton).getByText('←')).toBeInTheDocument();

    await waitFor(() => {
      expect(mockFetchGuidelines).toHaveBeenCalledTimes(1);
    });

    const guidelineCard = await screen.findByTestId('guideline-card');

    expect(
      within(guidelineCard).getByRole('heading', {
        name: 'Final Year Project Guidelines',
      }),
    ).toBeInTheDocument();
    expect(within(guidelineCard).getByText('PUSL2030')).toBeInTheDocument();
    expect(within(guidelineCard).getByText('Apr 29, 2026')).toBeInTheDocument();

    expect(
      within(guidelineCard).getByRole('button', { name: /pdf report/i }),
    ).toBeInTheDocument();
    expect(
      within(guidelineCard).getByRole('button', { name: /video demo/i }),
    ).toBeInTheDocument();
    expect(
      within(guidelineCard).getByRole('button', { name: /github repo/i }),
    ).toBeInTheDocument();
  });
});