'use client';

import { HTMLAttributes, forwardRef } from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const badgeVariants = cva(
  'inline-flex items-center rounded-small px-xs py-xxs text-label-sm font-medium',
  {
    variants: {
      variant: {
        default: 'bg-background-tertiary text-text-secondary',
        primary: 'bg-accent-primary text-brand-black',
        success: 'bg-status-success text-brand-black',
        warning: 'bg-status-warning text-brand-black',
        error: 'bg-status-error text-text-primary',
        outline: 'border border-background-tertiary text-text-secondary',
      },
    },
    defaultVariants: {
      variant: 'default',
    },
  }
);

export interface BadgeProps
  extends HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof badgeVariants> {}

const Badge = forwardRef<HTMLDivElement, BadgeProps>(
  ({ className, variant, ...props }, ref) => {
    return (
      <div ref={ref} className={cn(badgeVariants({ variant, className }))} {...props} />
    );
  }
);

Badge.displayName = 'Badge';

export { Badge, badgeVariants };
