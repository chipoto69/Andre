'use client';

import { TextareaHTMLAttributes, forwardRef } from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const textareaVariants = cva(
  'w-full rounded-medium border bg-background-secondary px-md py-sm text-body-md text-text-primary placeholder:text-text-tertiary focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent-primary disabled:cursor-not-allowed disabled:opacity-50 resize-y min-h-[100px]',
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

export interface TextAreaProps
  extends TextareaHTMLAttributes<HTMLTextAreaElement>,
    VariantProps<typeof textareaVariants> {
  label?: string;
  error?: string;
  helperText?: string;
}

const TextArea = forwardRef<HTMLTextAreaElement, TextAreaProps>(
  ({ className, variant, label, error, helperText, ...props }, ref) => {
    return (
      <div className="w-full space-y-xs">
        {label && (
          <label className="block text-label-md text-text-secondary">
            {label}
          </label>
        )}
        <textarea
          className={cn(
            textareaVariants({
              variant: error ? 'error' : variant,
            }),
            className
          )}
          ref={ref}
          {...props}
        />
        {error && <p className="text-label-sm text-status-error">{error}</p>}
        {helperText && !error && (
          <p className="text-label-sm text-text-tertiary">{helperText}</p>
        )}
      </div>
    );
  }
);

TextArea.displayName = 'TextArea';

export { TextArea, textareaVariants };
