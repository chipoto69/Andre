'use client';

import { useEffect, useState } from 'react';
import { cn } from '@/lib/utils';

export interface ToastProps {
  id: string;
  message: string;
  variant?: 'default' | 'success' | 'error' | 'warning';
  duration?: number;
  onClose: (id: string) => void;
}

export function Toast({
  id,
  message,
  variant = 'default',
  duration = 5000,
  onClose,
}: ToastProps) {
  const [isLeaving, setIsLeaving] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => {
      setIsLeaving(true);
      setTimeout(() => onClose(id), 300);
    }, duration);

    return () => clearTimeout(timer);
  }, [id, duration, onClose]);

  const variantStyles = {
    default: 'bg-background-secondary border-background-tertiary',
    success: 'bg-status-success/20 border-status-success',
    error: 'bg-status-error/20 border-status-error',
    warning: 'bg-status-warning/20 border-status-warning',
  };

  const iconColors = {
    default: 'text-text-primary',
    success: 'text-status-success',
    error: 'text-status-error',
    warning: 'text-status-warning',
  };

  return (
    <div
      className={cn(
        'mb-md flex items-start gap-md rounded-medium border p-md shadow-lg transition-all duration-300',
        variantStyles[variant],
        isLeaving ? 'translate-x-full opacity-0' : 'translate-x-0 opacity-100'
      )}
      role="alert"
    >
      {/* Icon */}
      <div className={cn('mt-xxs', iconColors[variant])}>
        {variant === 'success' && (
          <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
            <path
              d="M16.667 5L7.5 14.167 3.333 10"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </svg>
        )}
        {variant === 'error' && (
          <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
            <path
              d="M10 6v4m0 4h.01M10 18a8 8 0 100-16 8 8 0 000 16z"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
            />
          </svg>
        )}
        {variant === 'warning' && (
          <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
            <path
              d="M10 6v4m0 4h.01M18 10a8 8 0 11-16 0 8 8 0 0116 0z"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
            />
          </svg>
        )}
        {variant === 'default' && (
          <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
            <path
              d="M10 9v2m0 4h.01M10 18a8 8 0 100-16 8 8 0 000 16z"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
            />
          </svg>
        )}
      </div>

      {/* Message */}
      <p className="flex-1 text-body-md text-text-primary">{message}</p>

      {/* Close button */}
      <button
        onClick={() => {
          setIsLeaving(true);
          setTimeout(() => onClose(id), 300);
        }}
        className="text-text-tertiary transition-colors hover:text-text-primary"
        aria-label="Close notification"
      >
        <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
          <path
            d="M12 4L4 12M4 4l8 8"
            stroke="currentColor"
            strokeWidth="1.5"
            strokeLinecap="round"
          />
        </svg>
      </button>
    </div>
  );
}

export interface ToastContainerProps {
  toasts: ToastProps[];
}

export function ToastContainer({ toasts }: ToastContainerProps) {
  return (
    <div className="pointer-events-none fixed bottom-0 right-0 z-50 p-md">
      <div className="pointer-events-auto w-80">
        {toasts.map((toast) => (
          <Toast key={toast.id} {...toast} />
        ))}
      </div>
    </div>
  );
}
