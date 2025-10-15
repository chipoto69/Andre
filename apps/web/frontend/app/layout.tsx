import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';
import { Providers } from './providers';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'Andre - Three-List Productivity',
  description: 'Master focus. Build momentum. Track wins.',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body className={`${inter.className} bg-background-primary text-text-primary antialiased`}>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
