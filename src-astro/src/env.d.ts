/// <reference types="astro/client" />
declare module '@swal/ui' {
  export const Button: any; export const Card: any; export const Badge: any; export const Input: any;
  export const Table: any; export const Tabs: any; export const Skeleton: any; export const Modal: any;
  export const StatusBadge: any; export const LoadingState: any; export const Terminal: any;
  export const CommandPalette: any; export const Toaster: any; export const LogViewer: any;
  export const ConfigEditor: any; export const DashboardLayout: any; export const GlobalTicker: any; export const Landing: any;
}
declare module '@swal/ui/tokens' {}
declare module '@swal/ui/toast' { export const toast: any; }

declare module 'node:fs' {
  export function readFileSync(path: any, encoding?: string): string;
  export function existsSync(path: any): boolean;
}
declare module 'node:path' {
  export function resolve(...paths: string[]): string;
}
declare const process: {
  cwd(): string;
  env: Record<string, string | undefined>;
};
