/// <reference types="react" />
/// <reference types="react-dom" />

import { cleanup, fireEvent, render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import { useMemo, useState } from 'react';

const mockToastSuccess = jest.fn();
const mockNavigate = jest.fn();

jest.mock('react-hot-toast', () => ({
  toast: {
    success: (message: string) => mockToastSuccess(message),
  },
}), { virtual: true });

jest.mock('react-router-dom', () => ({
  useNavigate: () => mockNavigate,
}), { virtual: true });

type Project = {
  id: string;
  title: string;
};

type GradeSubmissionPayload = {
  technicalFeasibility: number;
  innovationResearch: number;
  projectScopeExecution: number;
  finalMark: number;
  feedbackNotes: string;
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

function ProjectGradingPage({
  project,
  submitProjectGrade,
}: {
  project: Project;
  submitProjectGrade: (payload: GradeSubmissionPayload) => Promise<void>;
}) {
  const { toast } = require('react-hot-toast') as {
    toast: {
      success: (message: string) => void;
    };
  };
  const { useNavigate } = require('react-router-dom') as {
    useNavigate: () => (to: string | number) => void;
  };
  const navigate = useNavigate();

  const [scores, setScores] = useState<ScoreState>({
    technicalFeasibility: 0,
    innovationResearch: 0,
    projectScopeExecution: 0,
  });
  const [feedbackNotes, setFeedbackNotes] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const finalMark = useMemo(() => computeFinalMark(scores), [scores]);

  const radius = 40;
  const circumference = 2 * Math.PI * radius;
  const progress = finalMark / 100;
  const strokeDashoffset = circumference * (1 - progress);

  const isSubmitEnabled =
    scores.technicalFeasibility > 0 &&
    scores.innovationResearch > 0 &&
    scores.projectScopeExecution > 0 &&
    feedbackNotes.trim().length > 0 &&
    !isSubmitting;

  const handleSubmit = async () => {
    setIsSubmitting(true);

    try {
      await submitProjectGrade({
        technicalFeasibility: scores.technicalFeasibility,
        innovationResearch: scores.innovationResearch,
        projectScopeExecution: scores.projectScopeExecution,
        finalMark,
        feedbackNotes,
      });

      toast.success('Final grade submitted successfully');
      navigate('/evaluations');
    } finally {
      setIsSubmitting(false);
    }
  };

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

      <label htmlFor="feedback-notes">Feedback Notes</label>
      <textarea
        id="feedback-notes"
        aria-label="Feedback Notes"
        placeholder="Provide detailed qualitative feedback..."
        value={feedbackNotes}
        onChange={(event) => setFeedbackNotes(event.target.value)}
      />
      <p data-testid="feedback-notes-preview">{feedbackNotes}</p>

      <button
        type="button"
        onClick={() => {
          void handleSubmit();
        }}
        disabled={!isSubmitEnabled}
      >
        Submit Final Grade
      </button>

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
  let mockSubmitProjectGrade: jest.MockedFunction<
    (payload: GradeSubmissionPayload) => Promise<void>
  >;

  beforeEach(() => {
    mockSubmitProjectGrade = jest.fn(async () => {});
    mockToastSuccess.mockReset();
    mockNavigate.mockReset();
  });

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
        submitProjectGrade={mockSubmitProjectGrade}
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

  test('Verify feedback notes input updates textarea value and internal state', () => {
    render(
      <ProjectGradingPage
        project={{
          id: 'project-1',
          title: 'Mock Project for Grading',
        }}
        submitProjectGrade={mockSubmitProjectGrade}
      />,
    );

    const feedbackTextarea = screen.getByPlaceholderText(
      'Provide detailed qualitative feedback...',
    ) as HTMLTextAreaElement;

    const feedbackInput =
      'The group demonstrated a strong understanding of ML concepts,\nthough the UI needs refinement.';

    fireEvent.change(feedbackTextarea, { target: { value: feedbackInput } });

    expect(feedbackTextarea.value).toBe(feedbackInput);
    const normalizedFeedback = feedbackInput.replace(/\n/g, ' ');
    expect(screen.getByTestId('feedback-notes-preview')).toHaveTextContent(
      normalizedFeedback,
    );
  });

  test('TC_GRAD_PAGE_007: Verify Submit Final Grade button is disabled initially', () => {
    render(
      <ProjectGradingPage
        project={{
          id: 'project-1',
          title: 'Mock Project for Grading',
        }}
        submitProjectGrade={mockSubmitProjectGrade}
      />,
    );

    const submitButton = screen.getByRole('button', {
      name: /submit final grade/i,
    });

    expect(submitButton).toBeDisabled();
  });

  test('TC_GRAD_PAGE_008: Verify submission payload includes scores, final mark, and feedback', async () => {
    render(
      <ProjectGradingPage
        project={{
          id: 'project-1',
          title: 'Mock Project for Grading',
        }}
        submitProjectGrade={mockSubmitProjectGrade}
      />,
    );

    const technicalSlider = screen.getByLabelText('Technical Feasibility') as HTMLInputElement;
    const innovationSlider = screen.getByLabelText('Innovation & Research') as HTMLInputElement;
    const scopeSlider = screen.getByLabelText('Project Scope & Execution') as HTMLInputElement;
    const feedbackTextarea = screen.getByLabelText('Feedback Notes') as HTMLTextAreaElement;
    const submitButton = screen.getByRole('button', {
      name: /submit final grade/i,
    });

    fireEvent.change(technicalSlider, { target: { value: '70' } });
    fireEvent.change(innovationSlider, { target: { value: '80' } });
    fireEvent.change(scopeSlider, { target: { value: '90' } });
    fireEvent.change(feedbackTextarea, {
      target: { value: 'Strong backend, needs UI polish.' },
    });

    expect(submitButton).toBeEnabled();

    fireEvent.click(submitButton);

    await screen.findByText('80');

    await waitFor(() => {
      expect(mockSubmitProjectGrade).toHaveBeenCalledTimes(1);
    });

    expect(mockSubmitProjectGrade).toHaveBeenCalledWith({
      technicalFeasibility: 70,
      innovationResearch: 80,
      projectScopeExecution: 90,
      finalMark: 80,
      feedbackNotes: 'Strong backend, needs UI polish.',
    });
  });

  test('Verify post-submission success toast and redirect to evaluations list', async () => {
    mockSubmitProjectGrade.mockResolvedValueOnce(undefined);

    render(
      <ProjectGradingPage
        project={{
          id: 'project-1',
          title: 'Mock Project for Grading',
        }}
        submitProjectGrade={mockSubmitProjectGrade}
      />,
    );

    const technicalSlider = screen.getByLabelText('Technical Feasibility') as HTMLInputElement;
    const innovationSlider = screen.getByLabelText('Innovation & Research') as HTMLInputElement;
    const scopeSlider = screen.getByLabelText('Project Scope & Execution') as HTMLInputElement;
    const feedbackTextarea = screen.getByLabelText('Feedback Notes') as HTMLTextAreaElement;
    const submitButton = screen.getByRole('button', {
      name: /submit final grade/i,
    });

    fireEvent.change(technicalSlider, { target: { value: '70' } });
    fireEvent.change(innovationSlider, { target: { value: '80' } });
    fireEvent.change(scopeSlider, { target: { value: '90' } });
    fireEvent.change(feedbackTextarea, {
      target: { value: 'Strong backend, needs UI polish.' },
    });

    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(mockToastSuccess).toHaveBeenCalledWith('Final grade submitted successfully');
    });

    await waitFor(() => {
      expect(mockNavigate).toHaveBeenCalledWith('/evaluations');
    });
  });
});