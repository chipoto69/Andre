'use client';

import { useState, useEffect } from 'react';
import { DailyFocusCard, ListItem } from '@/lib/api-client';
import { Card, Tag, TextArea, Button } from '@/components/ui';
import { formatDate } from '@/lib/utils';

interface FocusCardProps {
  card: DailyFocusCard;
  onUpdate: (updates: Partial<DailyFocusCard>) => void;
}

const energyColors = {
  low: 'bg-status-warning/20 text-status-warning',
  medium: 'bg-accent-secondary/20 text-accent-secondary',
  high: 'bg-status-success/20 text-status-success',
};

export function FocusCard({ card, onUpdate }: FocusCardProps) {
  const [isEditingReflection, setIsEditingReflection] = useState(false);
  const [reflection, setReflection] = useState(card.reflection || '');

  // Sync reflection state when card prop changes
  useEffect(() => {
    setReflection(card.reflection || '');
  }, [card.reflection]);

  const handleSaveReflection = () => {
    onUpdate({ reflection });
    setIsEditingReflection(false);
  };

  const handleToggleItemStatus = (item: ListItem) => {
    const updatedItems = card.items.map((i) =>
      i.id === item.id
        ? {
            ...i,
            status:
              i.status === 'completed'
                ? ('planned' as const)
                : ('completed' as const),
            completedAt:
              i.status === 'completed' ? null : new Date().toISOString(),
          }
        : i
    );
    onUpdate({ items: updatedItems });
  };

  const completedCount = card.items.filter((i) => i.status === 'completed').length;
  const totalCount = card.items.length;

  return (
    <div className="space-y-lg">
      {/* Card Header */}
      <Card padding="large" variant="elevated">
        <div className="space-y-md">
          {/* Theme & Energy */}
          <div className="flex items-start justify-between">
            <div className="flex-1">
              <h2 className="text-title-md font-semibold text-text-primary">
                {card.meta.theme || 'Focus Card'}
              </h2>
              <p className="mt-xs text-body-sm text-text-tertiary">
                {formatDate(card.date)}
              </p>
            </div>
            <div className="flex gap-xs">
              <div
                className={`rounded-pill px-sm py-xxs text-label-sm font-medium ${
                  energyColors[card.meta.energyBudget]
                }`}
              >
                {card.meta.energyBudget} energy
              </div>
            </div>
          </div>

          {/* Success Metric */}
          {card.meta.successMetric && (
            <div className="rounded-medium bg-background-tertiary p-md">
              <p className="text-label-sm font-medium text-text-secondary">
                Success Metric
              </p>
              <p className="mt-xs text-body-md text-text-primary">
                {card.meta.successMetric}
              </p>
            </div>
          )}

          {/* Progress Bar */}
          <div className="space-y-xs">
            <div className="flex justify-between text-label-sm">
              <span className="text-text-secondary">Progress</span>
              <span className="font-medium text-text-primary">
                {completedCount} / {totalCount}
              </span>
            </div>
            <div className="h-2 w-full overflow-hidden rounded-pill bg-background-tertiary">
              <div
                className="h-full bg-accent-primary transition-all duration-300"
                style={{
                  width: `${totalCount > 0 ? (completedCount / totalCount) * 100 : 0}%`,
                }}
              />
            </div>
          </div>
        </div>
      </Card>

      {/* Focus Items */}
      <div className="space-y-md">
        <h3 className="text-title-sm font-semibold text-text-primary">
          Today&apos;s Focus ({totalCount})
        </h3>

        {card.items.map((item, index) => (
          <Card
            key={item.id}
            padding="medium"
            hover
            onClick={() => handleToggleItemStatus(item)}
            className="cursor-pointer"
          >
            <div className="flex items-start gap-md">
              {/* Checkbox */}
              <button
                className="mt-xs"
                onClick={(e) => {
                  e.stopPropagation();
                  handleToggleItemStatus(item);
                }}
              >
                <div
                  className={`h-6 w-6 rounded-small border-2 transition-colors ${
                    item.status === 'completed'
                      ? 'border-status-success bg-status-success'
                      : 'border-text-tertiary hover:border-text-secondary'
                  }`}
                >
                  {item.status === 'completed' && (
                    <svg
                      width="20"
                      height="20"
                      viewBox="0 0 20 20"
                      fill="none"
                      className="text-brand-black"
                    >
                      <path
                        d="M16 6L8 14L4 10"
                        stroke="currentColor"
                        strokeWidth="2"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      />
                    </svg>
                  )}
                </div>
              </button>

              {/* Content */}
              <div className="flex-1">
                <div className="flex items-start justify-between gap-md">
                  <div className="flex items-center gap-xs">
                    <span className="text-label-lg font-medium text-text-tertiary">
                      {index + 1}.
                    </span>
                    <h4
                      className={`text-body-md font-medium ${
                        item.status === 'completed'
                          ? 'text-text-tertiary line-through'
                          : 'text-text-primary'
                      }`}
                    >
                      {item.title}
                    </h4>
                  </div>
                  <Tag
                    variant={
                      item.listType === 'todo'
                        ? 'todo'
                        : item.listType === 'watch'
                          ? 'watch'
                          : 'later'
                    }
                  >
                    {item.listType}
                  </Tag>
                </div>

                {item.notes && (
                  <p className="mt-xs text-body-sm text-text-secondary">
                    {item.notes}
                  </p>
                )}
              </div>
            </div>
          </Card>
        ))}
      </div>

      {/* Reflection Section */}
      <Card padding="large">
        <div className="space-y-md">
          <div className="flex items-center justify-between">
            <h3 className="text-title-sm font-semibold text-text-primary">
              End of Day Reflection
            </h3>
            {!isEditingReflection && (
              <Button
                variant="ghost"
                size="small"
                onClick={() => setIsEditingReflection(true)}
              >
                {card.reflection ? 'Edit' : 'Add Reflection'}
              </Button>
            )}
          </div>

          {isEditingReflection ? (
            <div className="space-y-md">
              <TextArea
                value={reflection}
                onChange={(e) => setReflection(e.target.value)}
                placeholder="How did today go? What worked well? What could be improved?"
                rows={4}
                autoFocus
              />
              <div className="flex justify-end gap-md">
                <Button
                  variant="ghost"
                  size="small"
                  onClick={() => {
                    setReflection(card.reflection || '');
                    setIsEditingReflection(false);
                  }}
                >
                  Cancel
                </Button>
                <Button
                  variant="primary"
                  size="small"
                  onClick={handleSaveReflection}
                >
                  Save Reflection
                </Button>
              </div>
            </div>
          ) : card.reflection ? (
            <p className="text-body-md text-text-primary">{card.reflection}</p>
          ) : (
            <p className="text-body-sm text-text-tertiary">
              Add a reflection at the end of the day to track your progress and
              learnings.
            </p>
          )}
        </div>
      </Card>
    </div>
  );
}
