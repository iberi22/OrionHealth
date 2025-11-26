/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        // Cyber-Minimalism Palette (BestOf OpenSource)
        background: '#121212',
        surface: {
          DEFAULT: '#1E1E1E',
          dark: '#0A0A0A',
          light: '#2A2A2A'
        },
        bone: {
          DEFAULT: '#F5F5DC',
          dark: '#E8E8C0'
        },
        accent: {
          DEFAULT: '#10B981', // Emerald-500
          light: '#34D399',
          dark: '#059669'
        },
        error: '#F87171',
        // Medical Theme Accents
        primary: {
          DEFAULT: '#10B981',
          dark: '#059669',
          light: '#34D399'
        },
        secondary: {
          DEFAULT: '#06B6D4', // Cyan
          dark: '#0891B2',
          light: '#22D3EE'
        }
      },
      fontFamily: {
        mono: ['Fira Code', 'monospace']
      },
      screens: {
        'xs': '375px',
        'sm': '640px',
        'md': '768px',
        'lg': '1024px',
        'xl': '1280px',
        '2xl': '1536px',
      },
      animation: {
        'fade-in-up': 'fadeInUp 0.6s cubic-bezier(0.19, 1, 0.22, 1) forwards',
        'border-beam': 'borderBeam 3s linear infinite',
        'slide-down': 'slideDown 0.8s cubic-bezier(0.19, 1, 0.22, 1) forwards',
        'blob': 'blob 7s infinite',
        'pulse-slow': 'pulse 4s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'float': 'float 6s ease-in-out infinite'
      },
      keyframes: {
        fadeInUp: {
          '0%': {
            opacity: '0',
            transform: 'translateY(20px)',
            filter: 'blur(10px)'
          },
          '100%': {
            opacity: '1',
            transform: 'translateY(0)',
            filter: 'blur(0)'
          }
        },
        borderBeam: {
          '0%': { transform: 'rotate(0deg)' },
          '100%': { transform: 'rotate(360deg)' }
        },
        slideDown: {
          '0%': { transform: 'translateY(-100%)' },
          '100%': { transform: 'translateY(0)' }
        },
        blob: {
          '0%, 100%': { transform: 'translate(0, 0) scale(1)' },
          '33%': { transform: 'translate(30px, -50px) scale(1.1)' },
          '66%': { transform: 'translate(-20px, 20px) scale(0.9)' }
        },
        float: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-20px)' }
        }
      }
    }
  },
  plugins: [],
}
