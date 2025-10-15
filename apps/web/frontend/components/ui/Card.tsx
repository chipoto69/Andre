'use client';

import { HTMLAttributes, forwardRef } from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const cardVariants = cva('rounded-large transition-all', {
  variants: {
    variant: {
      default: 'bg-background-secondary border border-background-tertiary',
      glass:
        'bg-background-secondary/60 backdrop-blur-md border border-background-tertiary/40',
      accent: 'bg-accent-primary/10 border border-accent-primary/30',
      elevated: 'bg-background-secondary shadow-lg',
    },
    padding: {
      none: '',
      small: 'p-md',
      medium: 'p-lg',
      large: 'p-xl',
    },
    hover: {
      true: 'hover:bg-background-tertiary cursor-pointer',
    },
  },
  defaultVariants: {
    variant: 'default',
    padding: 'medium',
  },
});

export interface CardProps
  extends HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof cardVariants> {}

const Card = forwardRef<HTMLDivElement, CardProps>(
  ({ className, variant, padding, hover, ...props }, ref) => {
    return (
      <div
        ref={ref}
        className={cn(cardVariants({ variant, padding, hover, className }))}
        {...props}
      />
    );
  }
);

Card.displayName = 'Card';

export { Card, cardVariants };
