import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          black: '#000000',
          cyan: '#00FFFF',
          white: '#FFFFFF',
          'dark-gray': '#1A1A1A',
          'light-gray': '#F5F5F5',
          'bright-green': '#00FF00',
          'electric-blue': '#0066FF',
        },
        background: {
          primary: '#000000',
          secondary: '#1A1A1A',
          tertiary: '#2A2A2A',
        },
        text: {
          primary: '#FFFFFF',
          secondary: '#CCCCCC',
          tertiary: '#999999',
        },
        accent: {
          primary: '#00FFFF',
          secondary: '#0066FF',
        },
        status: {
          success: '#00FF00',
          warning: '#FFA500',
          error: '#FF3B30',
          info: '#00FFFF',
        },
        list: {
          todo: '#00FFFF',
          watch: '#FFD60A',
          later: '#BF5AF2',
          antiTodo: '#00FF00',
        },
      },
      spacing: {
        xxs: '4px',
        xs: '8px',
        sm: '12px',
        md: '16px',
        lg: '24px',
        xl: '32px',
        xxl: '48px',
        xxxl: '64px',
        xxxxl: '96px',
      },
      fontSize: {
        'display-xl': ['48px', { lineHeight: '1.2', fontWeight: '600' }],
        'display-lg': ['40px', { lineHeight: '1.2', fontWeight: '600' }],
        'display-md': ['34px', { lineHeight: '1.2', fontWeight: '600' }],
        'display-sm': ['28px', { lineHeight: '1.3', fontWeight: '600' }],
        'title-lg': ['24px', { lineHeight: '1.3', fontWeight: '700' }],
        'title-md': ['20px', { lineHeight: '1.4', fontWeight: '600' }],
        'title-sm': ['18px', { lineHeight: '1.4', fontWeight: '600' }],
        'body-lg': ['17px', { lineHeight: '1.5', fontWeight: '400' }],
        'body-md': ['15px', { lineHeight: '1.5', fontWeight: '400' }],
        'body-sm': ['13px', { lineHeight: '1.5', fontWeight: '400' }],
        'label-lg': ['14px', { lineHeight: '1.4', fontWeight: '500' }],
        'label-md': ['12px', { lineHeight: '1.4', fontWeight: '500' }],
        'label-sm': ['11px', { lineHeight: '1.4', fontWeight: '500' }],
      },
      borderRadius: {
        small: '4px',
        medium: '8px',
        large: '12px',
        xl: '16px',
        pill: '999px',
      },
    },
  },
  plugins: [],
};

export default config;
