import type { JSX } from '@solidjs/web';
import { Href } from '~/components/routing/Href.tsx';
import {
  type MarkdownToken,
  type MarkdownTokenContent,
  parseMarkdown,
} from '~/utils/markdown_parser.ts';

const attribute = (token: MarkdownToken, name: string): string | undefined => {
  const value = token.attributes?.[name];
  return typeof value === 'string' ? value : undefined;
};

const renderContent = (content: MarkdownTokenContent): JSX.Element => {
  if (content === -1) return undefined;
  if (typeof content === 'string') return content;
  return content.map(renderToken);
};

const renderToken = (token: MarkdownToken): JSX.Element => {
  const content = () => renderContent(token.content);

  switch (token.type) {
    case 'normal':
      return content();
    case 'a':
      return <Href href={attribute(token, 'href')}>{content()}</Href>;
    case 'b':
      return <b>{content()}</b>;
    case 'i':
      return <i>{content()}</i>;
    case 'boldItalic':
      return (
        <b>
          <i>{content()}</i>
        </b>
      );
    case 'code':
      return <code>{content()}</code>;
    case 'codeBlock':
      return (
        <pre class={[`language-${attribute(token, 'lang') ?? 'auto'}`, 'hljs']}>
          {content()}
        </pre>
      );
    case 's':
      return <s>{content()}</s>;
    case 'sub':
      return <sub>{content()}</sub>;
    case 'sup':
      return <sup>{content()}</sup>;
    case 'blockquote':
      return <blockquote>{content()}</blockquote>;
    case 'ul':
      return <ul>{content()}</ul>;
    case 'ol':
      return <ol>{content()}</ol>;
    case 'li':
      return <li>{content()}</li>;
    case 'tl':
      return (
        <ul class="tasklist" role="list">
          {content()}
        </ul>
      );
    case 'ti':
      return (
        <li>
          <input
            disabled
            type="checkbox"
            checked={token.attributes?.checked === true}
          />
          <span>{content()}</span>
        </li>
      );
    case 'hr':
      return <hr />;
    case 'img':
      return (
        <img src={attribute(token, 'src')} alt={attribute(token, 'alt')} />
      );
    case 'h1':
      return <h1 id={attribute(token, 'id')}>{content()}</h1>;
    case 'h2':
      return <h2 id={attribute(token, 'id')}>{content()}</h2>;
    case 'h3':
      return <h3 id={attribute(token, 'id')}>{content()}</h3>;
    case 'h4':
      return <h4 id={attribute(token, 'id')}>{content()}</h4>;
    case 'h5':
      return <h5 id={attribute(token, 'id')}>{content()}</h5>;
    case 'h6':
      return <h6 id={attribute(token, 'id')}>{content()}</h6>;
    default:
      return <p>{content()}</p>;
  }
};

export default function Markdown(props: { content: string }) {
  return <div>{parseMarkdown(props.content).map(renderToken)}</div>;
}
