'use client';

import { SelectHTMLAttributes, forwardRef } from 'react';
import { cn } from '@/lib/utils';

export interface SelectProps extends SelectHTMLAttributes<HTMLSelectElement> {
  label?: string;
  error?: string;
  options: Array<{ value: string; label: string }>;
}

const Select = forwardRef<HTMLSelectElement, SelectProps>(
  ({ className, label, error, options, ...props }, ref) => {
    return (
      <div className="w-full space-y-xs">
        {label && (
          <label className="block text-label-md text-text-secondary">{label}</label>
        )}
        <select
          className={cn(
            'w-full rounded-medium border bg-background-secondary px-md py-sm text-body-md text-text-primary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-primary disabled:cursor-not-allowed disabled:opacity-50',
            error
              ? 'border-status-error focus-visible:ring-status-error'
              : 'border-background-tertiary',
            className
          )}
          ref={ref}
          {...props}
        >
          {options.map((option) => (
            <option key={option.value} value={option.value}>
              {option.label}
            </option>
          ))}
        </select>
        {error && <p className="text-label-sm text-status-error">{error}</p>}
      </div>
    );
  }
);

Select.displayName = 'Select';

export { Select };
