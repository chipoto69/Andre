'use client';

import { HTMLAttributes } from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const loadingVariants = cva('', {
  variants: {
    variant: {
      pulse: 'animate-pulse',
      spin: 'animate-spin',
    },
    size: {
      small: 'h-4 w-4',
      medium: 'h-6 w-6',
      large: 'h-8 w-8',
      xlarge: 'h-12 w-12',
    },
  },
  defaultVariants: {
    variant: 'spin',
    size: 'medium',
  },
});

export interface LoadingIndicatorProps
  extends HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof loadingVariants> {
  message?: string;
}

export function LoadingIndicator({
  variant,
  size,
  message,
  className,
  ...props
}: LoadingIndicatorProps) {
  if (variant === 'pulse') {
    return (
      <div className="flex flex-col items-center gap-md" {...props}>
        <div className={cn(loadingVariants({ variant, size, className }))}>
          <div className="h-full w-full rounded-full bg-accent-primary" />
        </div>
        {message && <p className="text-body-sm text-text-secondary">{message}</p>}
      </div>
    );
  }

  return (
    <div className="flex flex-col items-center gap-md" {...props}>
      <svg
        className={cn(loadingVariants({ variant, size, className }))}
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
      >
        <circle
          className="opacity-25"
          cx="12"
          cy="12"
          r="10"
          stroke="currentColor"
          strokeWidth="4"
        />
        <path
          className="opacity-75"
          fill="currentColor"
          d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
        />
      </svg>
      {message && <p className="text-body-sm text-text-secondary">{message}</p>}
    </div>
  );
}
