'use client';

import { HTMLAttributes, forwardRef } from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const tagVariants = cva(
  'inline-flex items-center gap-xxs rounded-pill px-sm py-xxs text-label-sm transition-colors',
  {
    variants: {
      variant: {
        default: 'bg-background-tertiary text-text-secondary',
        accent: 'bg-accent-primary/20 text-accent-primary',
        success: 'bg-status-success/20 text-status-success',
        warning: 'bg-status-warning/20 text-status-warning',
        error: 'bg-status-error/20 text-status-error',
        todo: 'bg-list-todo/20 text-list-todo',
        watch: 'bg-list-watch/20 text-list-watch',
        later: 'bg-list-later/20 text-list-later',
        antiTodo: 'bg-list-antiTodo/20 text-list-antiTodo',
      },
    },
    defaultVariants: {
      variant: 'default',
    },
  }
);

export interface TagProps
  extends HTMLAttributes<HTMLSpanElement>,
    VariantProps<typeof tagVariants> {
  onRemove?: () => void;
}

const Tag = forwardRef<HTMLSpanElement, TagProps>(
  ({ className, variant, children, onRemove, ...props }, ref) => {
    return (
      <span ref={ref} className={cn(tagVariants({ variant, className }))} {...props}>
        {children}
        {onRemove && (
          <button
            type="button"
            onClick={onRemove}
            className="ml-xs hover:opacity-80 focus:outline-none"
            aria-label="Remove tag"
          >
            <svg width="12" height="12" viewBox="0 0 12 12" fill="none">
              <path
                d="M9 3L3 9M3 3l6 6"
                stroke="currentColor"
                strokeWidth="1.5"
                strokeLinecap="round"
              />
            </svg>
          </button>
        )}
      </span>
    );
  }
);

Tag.displayName = 'Tag';

export { Tag, tagVariants };
