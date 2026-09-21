import { NoHydration } from '@solidjs/web';
import IconBundle from '~/components/media/icon-bundle';
import { ContactResponse } from '~/lib/types';
import { For } from 'solid-js';

export function GetInTouch() {
  return (
    <NoHydration>
      <article class={'get-in-touch'}>
        <h2>Get in touch</h2>
        <p>
          Like what you see and want to work with me? Feel free to shoot me an
          email or message me on Discord!
        </p>
        <div class={'actions'}>
          <a href="mailto:email@sakura-sedaia.com" class={'button'}>
            <IconBundle name={'envelope'} /> Email
          </a>
          <a
            href={'https://discord.com/users/705154478382252053'}
            rel={'noreferrer noopener'}
            target={'_blank'}
            class={'button'}
          >
            <IconBundle name={'discord'} /> Discord
          </a>
          <a
            href={'https://t.me/SakuraSedaia'}
            rel={'noreferrer noopener'}
            target={'_blank'}
            class={'button'}
          >
            <IconBundle name={'telegram'} /> Telegram
          </a>
        </div>
      </article>
    </NoHydration>
  );
}

export function Contact(props: { content: ContactResponse[] }) {
  return (
    <article class={'get-in-touch'}>
      <h2>Contact</h2>
      <p>
        Like what you see and want to work with me? Feel free to shoot me an
        email, or a message on Discord or Telegram!
      </p>
      <div class="actions">
        <For each={props.content}>
          {(item) => <a href={item.href}>{item.label}</a>}
        </For>
      </div>
    </article>
  );
}
