import type { JSX } from '@solidjs/web';
import { omit } from 'solid-js';

export type HrefProps = JSX.AnchorHTMLAttributes<HTMLAnchorElement> & {
  /** Override whether the destination should use external-link defaults. */
  external?: boolean;
};

const externalUrlPattern = /^(?:https?:)?\/\//i;

export function Href(props: HrefProps) {
  const anchorProps = omit(
    props,
    'external',
    'href',
    'target',
    'rel',
    'class',
    'children',
  );
  const isExternal = () =>
    props.external ??
    externalUrlPattern.test(typeof props.href === 'string' ? props.href : '');
  const target = () => props.target ?? (isExternal() ? '_blank' : undefined);
  const rel = () =>
    props.rel ?? (target() === '_blank' ? 'noopener noreferrer' : undefined);
  const className = () => (props.class ? `${props.class} link` : 'link');

  return (
    <a
      {...anchorProps}
      href={props.href}
      target={target()}
      rel={rel()}
      class={className()}
    >
      {props.children}
    </a>
  );
}
