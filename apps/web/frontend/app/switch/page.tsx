'use client';

import { useQuery } from '@tanstack/react-query';
import { apiClient } from '@/lib/api-client';
import { SuggestionCard } from '@/components/suggestions/SuggestionCard';
import { LoadingIndicator, Button } from '@/components/ui';

export default function SwitchPage() {
  const {
    data: suggestions,
    isLoading,
    error,
    refetch,
  } = useQuery({
    queryKey: ['suggestions'],
    queryFn: () => apiClient.getSuggestions(5),
  });

  return (
    <div className="min-h-screen bg-background-primary">
      {/* Header */}
      <header className="border-b border-background-tertiary bg-background-secondary">
        <div className="mx-auto max-w-4xl px-md py-lg">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-title-lg font-semibold text-text-primary">
                <span className="text-accent-primary">Structured Procrastination</span>
              </h1>
              <p className="mt-xs text-body-sm text-text-tertiary">
                Quick wins when focus is low
              </p>
            </div>

            <Button onClick={() => refetch()} variant="secondary" size="small">
              🔄 Refresh
            </Button>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="mx-auto max-w-4xl px-md py-xl">
        {isLoading && (
          <div className="flex items-center justify-center py-xxxl">
            <LoadingIndicator size="large" message="Loading suggestions..." />
          </div>
        )}

        {error && (
          <div className="text-center">
            <p className="text-body-md text-status-error">
              Failed to load suggestions
            </p>
            <p className="mt-sm text-body-sm text-text-tertiary">
              Please try again or contact support if the problem persists.
            </p>
            <Button onClick={() => refetch()} variant="primary" className="mt-lg">
              Try Again
            </Button>
          </div>
        )}

        {!isLoading && !error && suggestions && suggestions.length === 0 && (
          <div className="flex flex-col items-center justify-center py-xxxl text-center">
            <div className="mb-lg text-6xl">💡</div>
            <h2 className="text-title-md text-text-primary">
              No Suggestions Available
            </h2>
            <p className="mt-sm max-w-md text-body-md text-text-secondary">
              Add more items to your Watch and Later lists to get suggestions.
            </p>
          </div>
        )}

        {suggestions && suggestions.length > 0 && (
          <div className="space-y-md">
            <p className="text-body-md text-text-secondary">
              When you need a break from your main focus, these quick wins can keep
              your momentum going.
            </p>

            <div className="grid gap-md md:grid-cols-2">
              {suggestions.map((suggestion) => (
                <SuggestionCard key={suggestion.id} suggestion={suggestion} />
              ))}
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
