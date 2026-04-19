/// <reference types="react" />
/// <reference types="react-dom" />

import { cleanup, fireEvent, render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { useMemo, useState } from 'react';

type Project = {
  id: string;
  title: string;
};

type ScoreState = {
  technicalFeasibility: number;
  innovationResearch: number;
  projectScopeExecution: number;
};

const GRADING_WEIGHTS = {
  technicalFeasibility: 0.4,
  innovationResearch: 0.2,
  projectScopeExecution: 0.4,
} as const;

function computeFinalMark(scores: ScoreState): number {
  const weightedTotal =
    scores.technicalFeasibility * GRADING_WEIGHTS.technicalFeasibility +
    scores.innovationResearch * GRADING_WEIGHTS.innovationResearch +
    scores.projectScopeExecution * GRADING_WEIGHTS.projectScopeExecution;

  return Math.round(weightedTotal);
}

function ProjectGradingPage({ project }: { project: Project }) {
  const [scores, setScores] = useState<ScoreState>({
    technicalFeasibility: 0,
    innovationResearch: 0,
    projectScopeExecution: 0,
  });

  const finalMark = useMemo(() => computeFinalMark(scores), [scores]);

  const radius = 40;
  const circumference = 2 * Math.PI * radius;
  const progress = finalMark / 100;
  const strokeDashoffset = circumference * (1 - progress);

  return (
    <section aria-label="project-grading-page">
      <h1>Project Grading</h1>
      <p>{project.title}</p>

      <label htmlFor="technical-feasibility">Technical Feasibility</label>
      <input
        id="technical-feasibility"
        aria-label="Technical Feasibility"
        type="range"
        min={0}
        max={100}
        value={scores.technicalFeasibility}
        onChange={(event) =>
          setScores((prev) => ({
            ...prev,
            technicalFeasibility: Number(event.target.value),
          }))
        }
      />

      <label htmlFor="innovation-research">Innovation &amp; Research</label>
      <input
        id="innovation-research"
        aria-label="Innovation & Research"
        type="range"
        min={0}
        max={100}
        value={scores.innovationResearch}
        onChange={(event) =>
          setScores((prev) => ({
            ...prev,
            innovationResearch: Number(event.target.value),
          }))
        }
      />

      <label htmlFor="project-scope-execution">Project Scope &amp; Execution</label>
      <input
        id="project-scope-execution"
        aria-label="Project Scope & Execution"
        type="range"
        min={0}
        max={100}
        value={scores.projectScopeExecution}
        onChange={(event) =>
          setScores((prev) => ({
            ...prev,
            projectScopeExecution: Number(event.target.value),
          }))
        }
      />

      <div aria-label="final-mark-gauge-wrapper" data-testid="final-mark-gauge">
        <p>FINAL MARK</p>
        <svg width="120" height="120" viewBox="0 0 120 120" role="img" aria-label="Final Mark Gauge">
          <circle
            cx="60"
            cy="60"
            r={radius}
            fill="none"
            stroke="#334155"
            strokeWidth="10"
          />
          <circle
            data-testid="final-mark-progress-ring"
            cx="60"
            cy="60"
            r={radius}
            fill="none"
            stroke="#22c55e"
            strokeWidth="10"
            strokeDasharray={circumference}
            strokeDashoffset={strokeDashoffset}
            transform="rotate(-90 60 60)"
          />
        </svg>
        <p data-testid="final-mark-value" style={{ fontSize: '32px', fontWeight: 700 }}>
          {finalMark}
        </p>
      </div>
    </section>
  );
}

describe('ProjectGrading - Final Mark calculation logic', () => {
  afterEach(() => {
    cleanup();
    jest.clearAllMocks();
    jest.resetAllMocks();
  });

  test('Verify Final Mark gauge updates to 80 for slider values 60, 80, and 100', () => {
    render(
      <ProjectGradingPage
        project={{
          id: 'project-1',
          title: 'Mock Project for Grading',
        }}
      />,
    );

    const technicalSlider = screen.getByLabelText('Technical Feasibility') as HTMLInputElement;
    const innovationSlider = screen.getByLabelText('Innovation & Research') as HTMLInputElement;
    const scopeSlider = screen.getByLabelText('Project Scope & Execution') as HTMLInputElement;

    const progressRing = screen.getByTestId('final-mark-progress-ring');
    const initialDashOffset = Number(progressRing.getAttribute('stroke-dashoffset'));

    fireEvent.change(technicalSlider, { target: { value: '60' } });
    fireEvent.change(innovationSlider, { target: { value: '80' } });
    fireEvent.change(scopeSlider, { target: { value: '100' } });

    expect(technicalSlider.value).toBe('60');
    expect(innovationSlider.value).toBe('80');
    expect(scopeSlider.value).toBe('100');

    expect(screen.getByText('FINAL MARK')).toBeInTheDocument();
    expect(screen.getByTestId('final-mark-value')).toHaveTextContent('80');

    const circumference = 2 * Math.PI * 40;
    const expectedDashOffset = circumference * (1 - 0.8);
    const updatedDashOffset = Number(progressRing.getAttribute('stroke-dashoffset'));

    expect(updatedDashOffset).toBeLessThan(initialDashOffset);
    expect(updatedDashOffset).toBeCloseTo(expectedDashOffset, 4);
  });
});