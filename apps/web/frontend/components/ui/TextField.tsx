'use client';

import { InputHTMLAttributes, forwardRef } from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const inputVariants = cva(
  'w-full rounded-medium border bg-background-secondary px-md py-sm text-body-md text-text-primary placeholder:text-text-tertiary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-primary disabled:cursor-not-allowed disabled:opacity-50',
  {
    variants: {
      variant: {
        default: 'border-background-tertiary',
        error: 'border-status-error focus-visible:ring-status-error',
        success: 'border-status-success focus-visible:ring-status-success',
      },
    },
    defaultVariants: {
      variant: 'default',
    },
  }
);

export interface TextFieldProps
  extends InputHTMLAttributes<HTMLInputElement>,
    VariantProps<typeof inputVariants> {
  label?: string;
  error?: string;
  helperText?: string;
  icon?: React.ReactNode;
}

const TextField = forwardRef<HTMLInputElement, TextFieldProps>(
  ({ className, variant, label, error, helperText, icon, ...props }, ref) => {
    return (
      <div className="w-full space-y-xs">
        {label && (
          <label className="block text-label-md text-text-secondary">
            {label}
          </label>
        )}
        <div className="relative">
          {icon && (
            <div className="absolute left-md top-1/2 -translate-y-1/2 text-text-tertiary">
              {icon}
            </div>
          )}
          <input
            className={cn(
              inputVariants({
                variant: error ? 'error' : variant,
              }),
              icon && 'pl-10',
              className
            )}
            ref={ref}
            {...props}
          />
        </div>
        {error && <p className="text-label-sm text-status-error">{error}</p>}
        {helperText && !error && (
          <p className="text-label-sm text-text-tertiary">{helperText}</p>
        )}
      </div>
    );
  }
);

TextField.displayName = 'TextField';

export { TextField, inputVariants };
