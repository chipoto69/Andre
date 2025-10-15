'use client';

import { AntiTodoEntry } from '@/lib/api-client';
import { Card } from '@/components/ui';
import { formatTime } from '@/lib/utils';

interface WinTimelineProps {
  entries: AntiTodoEntry[];
}

export function WinTimeline({ entries }: WinTimelineProps) {
  // Sort entries by completion time (newest first)
  const sortedEntries = [...entries].sort(
    (a, b) =>
      new Date(b.completedAt).getTime() - new Date(a.completedAt).getTime()
  );

  return (
    <div className="space-y-md">
      {sortedEntries.map((entry, index) => (
        <div key={entry.id} className="relative">
          {/* Timeline connector */}
          {index < sortedEntries.length - 1 && (
            <div className="absolute left-4 top-12 h-full w-0.5 bg-background-tertiary" />
          )}

          <div className="flex gap-md">
            {/* Timeline dot */}
            <div className="relative z-10 mt-xs flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full bg-status-success">
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                <path
                  d="M13 4L6 11L3 8"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  className="text-brand-black"
                />
              </svg>
            </div>

            {/* Content */}
            <Card padding="medium" className="flex-1">
              <div className="flex items-start justify-between gap-md">
                <div className="flex-1">
                  <h4 className="text-body-md font-medium text-text-primary">
                    {entry.title}
                  </h4>
                  <p className="mt-xs text-label-sm text-text-tertiary">
                    {formatTime(entry.completedAt)}
                  </p>
                </div>
                <div className="text-xl">✅</div>
              </div>
            </Card>
          </div>
        </div>
      ))}
    </div>
  );
}
