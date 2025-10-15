'use client';

import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { apiClient } from '@/lib/api-client';
import { WinTimeline } from '@/components/wins/WinTimeline';
import { AddWinModal } from '@/components/wins/AddWinModal';
import { LoadingIndicator, Button, Card } from '@/components/ui';
import { getTodayDate, formatDate } from '@/lib/utils';

export default function WinsPage() {
  const [isAddWinOpen, setIsAddWinOpen] = useState(false);
  const selectedDate = getTodayDate();

  // Fetch today's wins
  const {
    data: entries,
    isLoading,
    error,
  } = useQuery({
    queryKey: ['anti-todo', selectedDate],
    queryFn: () => apiClient.getAntiTodoEntries(selectedDate),
  });

  const winCount = entries?.length || 0;

  return (
    <div className="min-h-screen bg-background-primary">
      {/* Header */}
      <header className="border-b border-background-tertiary bg-background-secondary">
        <div className="mx-auto max-w-4xl px-md py-lg">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-title-lg font-semibold text-text-primary">
                <span className="text-status-success">Today&apos;s Wins</span>
              </h1>
              <p className="mt-xs text-body-sm text-text-tertiary">
                {formatDate(selectedDate)} • {winCount}{' '}
                {winCount === 1 ? 'win' : 'wins'}
              </p>
            </div>

            <Button
              onClick={() => setIsAddWinOpen(true)}
              variant="primary"
              size="medium"
            >
              + Log Win
            </Button>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="mx-auto max-w-4xl px-md py-xl">
        {isLoading && (
          <div className="flex items-center justify-center py-xxxl">
            <LoadingIndicator size="large" message="Loading wins..." />
          </div>
        )}

        {error && (
          <div className="text-center">
            <p className="text-body-md text-status-error">Failed to load wins</p>
            <p className="mt-sm text-body-sm text-text-tertiary">
              Please try again or contact support if the problem persists.
            </p>
          </div>
        )}

        {!isLoading && !error && winCount === 0 && (
          <div className="flex flex-col items-center justify-center py-xxxl text-center">
            <div className="mb-lg text-6xl">🏆</div>
            <h2 className="text-title-md text-text-primary">No Wins Yet Today</h2>
            <p className="mt-sm max-w-md text-body-md text-text-secondary">
              Log your accomplishments throughout the day. Celebrate progress, no
              matter how small!
            </p>
            <Button
              onClick={() => setIsAddWinOpen(true)}
              variant="primary"
              className="mt-xl"
            >
              Log Your First Win
            </Button>
          </div>
        )}

        {!isLoading && !error && entries && winCount > 0 && (
          <div className="space-y-lg">
            {/* Summary Card */}
            <Card padding="large" variant="elevated">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-label-md font-medium text-text-secondary">
                    Total Wins Today
                  </p>
                  <p className="mt-xs text-display-sm font-semibold text-status-success">
                    {winCount}
                  </p>
                </div>
                <div className="text-6xl">🎯</div>
              </div>
            </Card>

            {/* Timeline */}
            <div>
              <h3 className="mb-md text-title-sm font-semibold text-text-primary">
                Timeline
              </h3>
              <WinTimeline entries={entries} />
            </div>
          </div>
        )}
      </main>

      {/* Add Win Modal */}
      <AddWinModal
        isOpen={isAddWinOpen}
        onClose={() => setIsAddWinOpen(false)}
        date={selectedDate}
      />
    </div>
  );
}
