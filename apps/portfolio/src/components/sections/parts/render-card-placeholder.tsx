import { Show } from 'solid-js';

export interface RenderCardPlaceholderProps {
  title?: string;
  caption?: string;
}

export default function RenderCardPlaceholder(
  props?: RenderCardPlaceholderProps,
) {
  return (
    <figure class="render-card">
      <div
        class="render-placeholder"
        role="img"
        aria-label="3D render preview placeholder"
      >
        <span>Render Preview Placeholder</span>
      </div>

      <figcaption>
        <Show when={props?.title}>
          <strong>{props?.title}: </strong>
        </Show>
        {props?.caption ?? 'This is an image'}
      </figcaption>
    </figure>
  );
}
