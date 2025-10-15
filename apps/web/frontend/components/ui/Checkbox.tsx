'use client';

import { InputHTMLAttributes, forwardRef } from 'react';
import { cn } from '@/lib/utils';

export interface CheckboxProps extends Omit<InputHTMLAttributes<HTMLInputElement>, 'type'> {
  label?: string;
}

const Checkbox = forwardRef<HTMLInputElement, CheckboxProps>(
  ({ className, label, ...props }, ref) => {
    return (
      <label className="inline-flex cursor-pointer items-center gap-xs">
        <input
          type="checkbox"
          className={cn(
            'h-5 w-5 cursor-pointer rounded-small border border-background-tertiary bg-background-secondary text-accent-primary transition-colors focus:ring-2 focus:ring-accent-primary focus:ring-offset-2 focus:ring-offset-background-primary disabled:cursor-not-allowed disabled:opacity-50',
            className
          )}
          ref={ref}
          {...props}
        />
        {label && <span className="text-body-md text-text-primary">{label}</span>}
      </label>
    );
  }
);

Checkbox.displayName = 'Checkbox';

export { Checkbox };
