'use client';

import { ListItem, ListType } from '@/lib/api-client';
import { Card } from '@/components/ui';
import { ListItemCard } from './ListItemCard';

interface ListColumnProps {
  title: string;
  listType: ListType;
  items: ListItem[];
  onDelete: (id: string) => void;
  onUpdate: (id: string, updates: Partial<ListItem>) => void;
}

const listTypeColors: Record<Exclude<ListType, 'antiTodo'>, string> = {
  todo: 'border-list-todo',
  watch: 'border-list-watch',
  later: 'border-list-later',
};

const listTypeBgColors: Record<Exclude<ListType, 'antiTodo'>, string> = {
  todo: 'bg-list-todo/10',
  watch: 'bg-list-watch/10',
  later: 'bg-list-later/10',
};

export function ListColumn({ title, listType, items, onDelete, onUpdate }: ListColumnProps) {
  if (listType === 'antiTodo') return null;

  const borderColor = listTypeColors[listType];
  const bgColor = listTypeBgColors[listType];

  return (
    <div className="flex flex-col gap-md">
      {/* Column Header */}
      <div className={`rounded-large border-2 ${borderColor} ${bgColor} p-md`}>
        <h2 className="text-title-md font-semibold text-text-primary">{title}</h2>
        <p className="text-label-md text-text-tertiary">{items.length} items</p>
      </div>

      {/* Items List */}
      <div className="space-y-md">
        {items.length === 0 ? (
          <Card padding="large" className="text-center">
            <p className="text-body-sm text-text-tertiary">No items yet</p>
          </Card>
        ) : (
          items.map((item) => (
            <ListItemCard
              key={item.id}
              item={item}
              onDelete={onDelete}
              onUpdate={onUpdate}
            />
          ))
        )}
      </div>

      {/* Add Button */}
      <button
        className={`rounded-medium border-2 border-dashed ${borderColor} p-md text-body-md text-text-tertiary transition-colors hover:${bgColor} hover:text-text-primary`}
      >
        + Add item
      </button>
    </div>
  );
}
