import Link from 'next/link';

export default function Home() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center p-md">
      <main className="flex flex-col items-center gap-lg text-center">
        <h1 className="text-display-lg font-semibold">
          <span className="text-accent-primary">Andre</span>
        </h1>
        <p className="text-title-md text-text-secondary max-w-md">
          Three-List Productivity System
        </p>
        <p className="text-body-lg text-text-tertiary max-w-lg">
          Master focus. Build momentum. Track wins.
        </p>
        <div className="mt-xl flex gap-md">
          <Link
            href="/focus"
            className="rounded-medium bg-accent-primary px-lg py-sm text-body-md font-medium text-brand-black transition-colors hover:bg-accent-primary/90"
          >
            Get Started
          </Link>
          <Link
            href="/lists"
            className="rounded-medium bg-background-secondary px-lg py-sm text-body-md font-medium text-text-primary transition-colors hover:bg-background-tertiary"
          >
            View Lists
          </Link>
        </div>
      </main>
    </div>
  );
}
