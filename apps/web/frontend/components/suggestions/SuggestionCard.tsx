'use client';

import { Suggestion } from '@/lib/api-client';
import { Card, Tag } from '@/components/ui';

interface SuggestionCardProps {
  suggestion: Suggestion;
}

const sourceColors = {
  later: 'bg-list-later/20 text-list-later',
  watch: 'bg-list-watch/20 text-list-watch',
  momentum: 'bg-status-success/20 text-status-success',
};

const sourceLabels = {
  later: 'From Later List',
  watch: 'From Watch List',
  momentum: 'Building Momentum',
};

export function SuggestionCard({ suggestion }: SuggestionCardProps) {
  const scorePercentage = Math.round(suggestion.score * 100);

  return (
    <Card padding="large" hover className="cursor-pointer">
      <div className="space-y-md">
        {/* Header with Score */}
        <div className="flex items-start justify-between gap-md">
          <div className="flex-1">
            <h3 className="text-body-lg font-semibold text-text-primary">
              {suggestion.title}
            </h3>
          </div>

          {/* Score Circle */}
          <div className="relative flex h-12 w-12 items-center justify-center">
            <svg className="absolute h-12 w-12 -rotate-90 transform">
              <circle
                cx="24"
                cy="24"
                r="20"
                stroke="currentColor"
                strokeWidth="3"
                fill="none"
                className="text-background-tertiary"
              />
              <circle
                cx="24"
                cy="24"
                r="20"
                stroke="currentColor"
                strokeWidth="3"
                fill="none"
                strokeDasharray={`${2 * Math.PI * 20}`}
                strokeDashoffset={`${2 * Math.PI * 20 * (1 - suggestion.score)}`}
                className="text-accent-primary transition-all duration-300"
                strokeLinecap="round"
              />
            </svg>
            <span className="relative text-label-md font-semibold text-text-primary">
              {scorePercentage}
            </span>
          </div>
        </div>

        {/* Description */}
        <p className="text-body-sm text-text-secondary">{suggestion.description}</p>

        {/* Tags */}
        <div className="flex flex-wrap gap-xs">
          <div
            className={`rounded-pill px-sm py-xxs text-label-sm font-medium ${
              sourceColors[suggestion.source]
            }`}
          >
            {sourceLabels[suggestion.source]}
          </div>
          <Tag
            variant={
              suggestion.listType === 'todo'
                ? 'todo'
                : suggestion.listType === 'watch'
                  ? 'watch'
                  : suggestion.listType === 'later'
                    ? 'later'
                    : 'default'
            }
          >
            {suggestion.listType}
          </Tag>
        </div>
      </div>
    </Card>
  );
}
