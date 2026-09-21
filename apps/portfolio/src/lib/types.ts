export type ContactIconType =
  | 'discord'
  | 'github'
  | 'youtube'
  | 'deviantart'
  | 'codeberg'
  | 'gumroad'
  | 'instagram'
  | 'pinterest'
  | 'reddit'
  | 'twitch'
  | 'twitter'
  | 'patreon'
  | 'telegram'
  | 'pixiv'
  | 'envelope'
  | 'globe';

export type ContactType = 'email' | 'discord_user' | 'telegram';

export type ContactResponse = {
  type: ContactType;
  label: string;
  icon?: ContactIconType;
  value: string;
  href: string;
};

export type ProgrammingResponse = {
  title: string;
  description: string;
  projectPage: string;
  sourceCode: string;
  documentation?: string | null;
};

export type PortfolioContent = {
  programming: ProgrammingResponse[];
  contact: ContactResponse[];
};
