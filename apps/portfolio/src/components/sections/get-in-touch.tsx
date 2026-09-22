import { ContactResponse } from '~/lib/types';
import { For, Loading } from 'solid-js';
import { Href } from '~/components/routing/Href.tsx';
import IconBundle from "~/components/media/icon-bundle.tsx";

export function Contact(props: { content: ContactResponse[] }) {
  return (
    <article class={'get-in-touch'}>
      <h2>Contact</h2>
      <p>
        Like what you see and want to work with me? Feel free to shoot me an
        email, or a message on Discord or Telegram!
      </p>
      <div class="actions">
        <Loading fallback={<span>Loading...</span>}>
          <For each={props.content}>
            {(item) => <Href href={item.href} class={"button"}>{item.label} <IconBundle name={item.icon ?? ""} /></Href>}
          </For>
        </Loading>
      </div>
    </article>
  );
}
