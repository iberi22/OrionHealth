export const ui = {
  es: {
    nav: {
      home: 'Inicio',
      app: 'App',
      docs: 'Docs',
      kb: 'Base de conocimiento',
      github: 'GitHub',
    },
    footer: {
      description: 'Asistente de salud privado potenciado por IA local. Tus datos nunca salen de tu dispositivo.',
      links: 'Enlaces',
      legal: 'Legal',
      vision: 'Visión',
      mission: 'Misión',
      features: 'Características',
      blog: 'Blog',
      support: 'Soporte',
      githubRepo: 'Repositorio GitHub',
      contribute: 'Contribuir',
      license: 'Licencia (AGPL-3.0)',
      copyright: '© 2025 OrionHealth. Plataforma de Salud de Código Abierto.',
      builtWith: 'Construido con',
      forPrivacy: 'por la Privacidad',
    }
  },
  en: {
    nav: {
      home: 'Home',
      app: 'App',
      docs: 'Docs',
      kb: 'Knowledge Base',
      github: 'GitHub',
    },
    footer: {
      description: 'Privacy-first health assistant powered by local AI. Your data never leaves your device.',
      links: 'Links',
      legal: 'Legal',
      vision: 'Vision',
      mission: 'Mission',
      features: 'Features',
      blog: 'Blog',
      support: 'Support',
      githubRepo: 'GitHub Repo',
      contribute: 'Contribute',
      license: 'License (AGPL-3.0)',
      copyright: '© 2025 OrionHealth. Open Source Health Platform.',
      builtWith: 'Built with',
      forPrivacy: 'for Privacy',
    }
  }
} as const;

export type SupportedLanguage = keyof typeof ui;
type Dict = typeof ui.es;
type NestedKeyOf<ObjectType extends object> = {
  [Key in keyof ObjectType & (string | number)]: ObjectType[Key] extends object
    ? `${Key}.${NestedKeyOf<ObjectType[Key]>}`
    : `${Key}`;
}[keyof ObjectType & (string | number)];

export function t(lang: string | undefined, path: NestedKeyOf<Dict>): string {
  const dictionary = ui[(lang as SupportedLanguage)] || ui.es;
  const keys = path.split('.');
  let current: any = dictionary;
  for (const key of keys) {
    if (current[key] === undefined) return path;
    current = current[key];
  }
  return current as string;
}
