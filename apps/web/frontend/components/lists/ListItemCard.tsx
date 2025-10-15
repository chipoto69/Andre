'use client';

import { useState } from 'react';
import { ListItem } from '@/lib/api-client';
import { Card, Checkbox, Tag, Badge } from '@/components/ui';
import { useAppStore } from '@/lib/store';
import { formatDate } from '@/lib/utils';

interface ListItemCardProps {
  item: ListItem;
  onDelete: (id: string) => void;
  onUpdate: (id: string, updates: any) => void;
}

const statusColors = {
  planned: 'default' as const,
  in_progress: 'warning' as const,
  completed: 'success' as const,
  archived: 'outline' as const,
};

export function ListItemCard({ item, onDelete, onUpdate }: ListItemCardProps) {
  const { isPlanningMode, selectedItemsForPlanning, toggleItemSelection } = useAppStore();
  const [isExpanded, setIsExpanded] = useState(false);
  const isSelected = selectedItemsForPlanning.has(item.id);

  const handleToggleStatus = () => {
    const newStatus =
      item.status === 'planned'
        ? 'in_progress'
        : item.status === 'in_progress'
          ? 'completed'
          : 'planned';

    onUpdate(item.id, {
      status: newStatus,
      completedAt: newStatus === 'completed' ? new Date().toISOString() : null,
    });
  };

  const handleSelect = () => {
    if (isPlanningMode) {
      toggleItemSelection(item.id);
    }
  };

  return (
    <Card
      padding="medium"
      hover={isPlanningMode}
      onClick={handleSelect}
      className={`cursor-pointer transition-all ${
        isSelected ? 'ring-2 ring-accent-primary' : ''
      }`}
    >
      <div className="space-y-sm">
        {/* Header */}
        <div className="flex items-start justify-between gap-md">
          <div className="flex flex-1 items-start gap-md">
            {isPlanningMode ? (
              <Checkbox checked={isSelected} onChange={handleSelect} />
            ) : (
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  handleToggleStatus();
                }}
                className="mt-xs"
              >
                <div
                  className={`h-5 w-5 rounded-small border-2 transition-colors ${
                    item.status === 'completed'
                      ? 'border-status-success bg-status-success'
                      : 'border-text-tertiary hover:border-text-secondary'
                  }`}
                >
                  {item.status === 'completed' && (
                    <svg
                      width="16"
                      height="16"
                      viewBox="0 0 16 16"
                      fill="none"
                      className="text-brand-black"
                    >
                      <path
                        d="M13 4L6 11L3 8"
                        stroke="currentColor"
                        strokeWidth="2"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      />
                    </svg>
                  )}
                </div>
              </button>
            )}

            <div className="flex-1">
              <h3
                className={`text-body-md font-medium ${
                  item.status === 'completed'
                    ? 'text-text-tertiary line-through'
                    : 'text-text-primary'
                }`}
              >
                {item.title}
              </h3>
              {item.notes && isExpanded && (
                <p className="mt-xs text-body-sm text-text-secondary">{item.notes}</p>
              )}
            </div>
          </div>

          <Badge variant={statusColors[item.status]}>
            {item.status.replace('_', ' ')}
          </Badge>
        </div>

        {/* Tags */}
        {item.tags.length > 0 && (
          <div className="flex flex-wrap gap-xs">
            {item.tags.map((tag) => (
              <Tag key={tag} variant="default">
                {tag}
              </Tag>
            ))}
          </div>
        )}

        {/* Metadata */}
        <div className="flex items-center justify-between text-label-sm text-text-tertiary">
          <div className="flex gap-md">
            {item.dueAt && (
              <span>
                Due: {formatDate(item.dueAt)}
              </span>
            )}
            {item.completedAt && (
              <span>
                Completed: {formatDate(item.completedAt)}
              </span>
            )}
          </div>

          {!isPlanningMode && (
            <div className="flex gap-xs">
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  setIsExpanded(!isExpanded);
                }}
                className="text-text-tertiary transition-colors hover:text-text-primary"
                aria-label={isExpanded ? 'Collapse' : 'Expand'}
              >
                <svg
                  width="16"
                  height="16"
                  viewBox="0 0 16 16"
                  fill="none"
                  className={`transition-transform ${isExpanded ? 'rotate-180' : ''}`}
                >
                  <path
                    d="M4 6l4 4 4-4"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                </svg>
              </button>
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  if (confirm('Delete this item?')) {
                    onDelete(item.id);
                  }
                }}
                className="text-text-tertiary transition-colors hover:text-status-error"
                aria-label="Delete"
              >
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                  <path
                    d="M12 4L4 12M4 4l8 8"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                  />
                </svg>
              </button>
            </div>
          )}
        </div>
      </div>
    </Card>
  );
}
