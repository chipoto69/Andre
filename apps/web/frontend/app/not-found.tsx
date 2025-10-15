import Link from 'next/link';
import { Button } from '@/components/ui';

export default function NotFound() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-background-primary">
      <div className="text-center">
        <h1 className="text-display-lg font-bold text-text-primary">404</h1>
        <p className="mt-md text-title-md text-text-secondary">Page Not Found</p>
        <p className="mt-sm text-body-md text-text-tertiary">
          The page you&apos;re looking for doesn&apos;t exist.
        </p>
        <Link href="/" className="mt-xl inline-block">
          <Button variant="primary" size="large">
            Go Home
          </Button>
        </Link>
      </div>
    </div>
  );
}
