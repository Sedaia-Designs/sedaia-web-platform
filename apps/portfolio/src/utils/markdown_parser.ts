/**
 * Adapted from ymfpfp's original JavaScript Markdown parser:
 * https://github.com/ymfpfp/markdown-parser/tree/main
 *
 * Ported to TypeScript and modified for the Sedaia Designs portfolio.
 */

type AttributeValue = string | boolean;
type Attributes = Record<string, AttributeValue>;

export interface MarkdownToken {
  type: string;
  content: MarkdownTokenContent;
  attributes?: Attributes;
}

export type MarkdownTokenContent = string | -1 | MarkdownToken[];

const specialCharacters = ['*', '`', '[', '~', '^'];

const splitBlock = (
  source: string,
  inner = false,
): MarkdownToken[] | MarkdownToken => {
  let block = source;
  const fragments: MarkdownToken[] = [];

  const takeNormal = (): string => {
    let index = 0;

    while (
      index < block.length &&
      !specialCharacters.includes(block.charAt(index))
    ) {
      index += 1;
    }

    const normalText = block.slice(0, index);
    block = block.slice(index);
    return normalText;
  };

  const sliceUpTo = (
    phrase: string,
    ignoreMarkup = false,
  ): MarkdownToken[] | string => {
    block = block.slice(phrase.length);
    const closingIndex = block.indexOf(phrase);
    const content = closingIndex === -1 ? block : block.slice(0, closingIndex);
    block =
      closingIndex === -1 ? '' : block.slice(closingIndex + phrase.length);

    return ignoreMarkup ? content : asTokenArray(splitBlock(content, true));
  };

  if (!block.length) return [];

  if (/^[-*] /.test(block) && !/^- \[[X ]\] /.test(block) && !inner) {
    return {
      type: 'li',
      content: asTokenArray(splitBlock(block.slice(2), true)),
    };
  }

  const orderedListMatch = block.match(/^\d+\.\s*/);
  if (orderedListMatch && !inner) {
    return {
      type: 'li',
      content: asTokenArray(
        splitBlock(block.slice(orderedListMatch[0].length), true),
      ),
    };
  }

  const taskListMatch = block.match(/^- \[([X ])\] /);
  if (taskListMatch && !inner) {
    return {
      type: 'ti',
      content: asTokenArray(
        splitBlock(block.slice(taskListMatch[0].length), true),
      ),
      attributes: { checked: taskListMatch[1] === 'X' },
    };
  }

  while (block.length) {
    const currentCharacter = block.charAt(0);

    if (currentCharacter === '*') {
      if (block.startsWith('***')) {
        fragments.push({ type: 'boldItalic', content: sliceUpTo('***') });
      } else if (block.startsWith('**')) {
        fragments.push({ type: 'b', content: sliceUpTo('**') });
      } else {
        fragments.push({ type: 'i', content: sliceUpTo('*') });
      }
    } else if (currentCharacter === '`') {
      fragments.push({ type: 'code', content: sliceUpTo('`', true) });
    } else if (currentCharacter === '~') {
      fragments.push(
        block.startsWith('~~')
          ? { type: 's', content: sliceUpTo('~~') }
          : { type: 'sub', content: sliceUpTo('~') },
      );
    } else if (currentCharacter === '^') {
      fragments.push({ type: 'sup', content: sliceUpTo('^') });
    } else if (currentCharacter === '[') {
      const fragment: MarkdownToken = {
        type: 'a',
        content: sliceUpTo(']'),
      };

      if (block.startsWith('(')) {
        fragment.attributes = {
          href: sliceUpTo(')', true) as string,
        };
      }

      fragments.push(fragment);
    } else {
      fragments.push({ type: 'normal', content: takeNormal() });
    }
  }

  return fragments;
};

const asTokenArray = (
  tokens: MarkdownToken[] | MarkdownToken,
): MarkdownToken[] => (Array.isArray(tokens) ? tokens : [tokens]);

const processBlock = (source: string, index: number): MarkdownToken => {
  let block = source.trim();
  let type = 'p';
  let attributes: Attributes | undefined;

  if (block === '---') {
    return { type: 'hr', content: -1 };
  }

  if (block.startsWith('#')) {
    const headingMatch = block.match(/^(#+)\s/);
    if (headingMatch) {
      type = `h${headingMatch[1].length}`;
      block = block.slice(headingMatch[0].length).trim();
      const id = block.replace(/[^a-zA-Z0-9 ]/g, '');
      attributes = {
        id: `h-${index}-${id.toLowerCase().replaceAll(' ', '-')}`,
      };
    }
  } else if (block.startsWith('>')) {
    type = 'blockquote';
    block = block.slice(1).trim();
  } else if (/^[-*] /.test(block) && !/^- \[[X ]\] /.test(block)) {
    return {
      type: 'ul',
      content: block
        .split('\n')
        .flatMap((item) => asTokenArray(splitBlock(item))),
    };
  } else if (/^\d+\./.test(block)) {
    return {
      type: 'ol',
      content: block
        .split('\n')
        .flatMap((item) => asTokenArray(splitBlock(item))),
    };
  } else if (/^- \[[X ]\] /.test(block)) {
    return {
      type: 'tl',
      content: block
        .split('\n')
        .flatMap((item) => asTokenArray(splitBlock(item))),
    };
  } else if (block.startsWith('```')) {
    const lines = block.split('\n');
    const language = lines[0].slice(3) || 'auto';
    return {
      type: 'codeBlock',
      content: lines.slice(1, -1).join('\n'),
      attributes: { lang: language },
    };
  } else {
    const imageMatch = block.match(/^!\[(.+)\]\((.+)\)$/);
    if (imageMatch) {
      return {
        type: 'img',
        content: -1,
        attributes: { alt: imageMatch[1], src: imageMatch[2] },
      };
    }
  }

  return {
    type,
    content: asTokenArray(splitBlock(block)),
    ...(attributes && { attributes }),
  };
};

export const parseMarkdown = (markdown: string): MarkdownToken[] => {
  const blocks = markdown.split('\n');
  const fragments: string[] = [];
  let inCodeBlock = false;
  let codeFragments: string[] = [];
  let orderedListFragments: string[] = [];
  let unorderedListFragments: string[] = [];
  let taskListFragments: string[] = [];

  const flush = (list: string[]): void => {
    if (list.length) fragments.push(list.join('\n'));
  };

  for (const block of blocks) {
    const isTaskListItem = /^- \[[X ]\] /.test(block);
    const isUnorderedListItem = /^[-*] /.test(block) && !isTaskListItem;
    const isOrderedListItem = /^\d+\./.test(block);

    if (!isUnorderedListItem && unorderedListFragments.length) {
      flush(unorderedListFragments);
      unorderedListFragments = [];
    }
    if (!isOrderedListItem && orderedListFragments.length) {
      flush(orderedListFragments);
      orderedListFragments = [];
    }
    if (!isTaskListItem && taskListFragments.length) {
      flush(taskListFragments);
      taskListFragments = [];
    }

    if (!block.length && !inCodeBlock) continue;

    if (block.startsWith('```')) {
      codeFragments.push(block);
      if (inCodeBlock) {
        fragments.push(codeFragments.join('\n'));
        codeFragments = [];
      }
      inCodeBlock = !inCodeBlock;
    } else if (inCodeBlock) {
      codeFragments.push(block);
    } else if (isUnorderedListItem) {
      unorderedListFragments.push(block);
    } else if (isOrderedListItem) {
      orderedListFragments.push(block);
    } else if (isTaskListItem) {
      taskListFragments.push(block);
    } else {
      fragments.push(block);
    }
  }

  flush(unorderedListFragments);
  flush(orderedListFragments);
  flush(taskListFragments);
  flush(codeFragments);

  return fragments.map(processBlock);
};
