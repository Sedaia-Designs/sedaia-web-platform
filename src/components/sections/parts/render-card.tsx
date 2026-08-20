import type { JSX } from "@solidjs/web";
import { createSignal, Show } from "solid-js";
import ImageModal from "~/components/media/image-modal";

export interface RenderInfoProps {
  title: string;
  caption: string;
  description?: JSX.Element | string;
  img: string;
}

export interface RenderCardProps {
  info?: RenderInfoProps;
  title?: string;
  caption?: string;
  description?: JSX.Element | string;
  img?: string;
}

export default function RenderCard(props: RenderCardProps) {
  const [modalOpen, setModalOpen] = createSignal(false);
  const data = () => props.info ?? props;

  return (
    <div class="project-container">
      <h3>{data().title}</h3>
      <div class="router left">
        <div class="project-link">
          <a href="https://www.sedaia-designs.org">Art Portfolio</a>
        </div>
        <div class="project-link">
          <a href="https://gitlab.com/sedaia-designs/advanced-character-rig">SACR Project</a>
        </div>
      </div>
      <figure class="render-card">
        <Show
          when={data().img && data().img !== "{none}"}
          fallback={
            <div class="render-placeholder" role="img" aria-label="3D render preview placeholder">
              <span>Render Preview Placeholder</span>
            </div>
          }
        >
          <img
            src={data().img}
            alt={data().title}
            onClick={() => setModalOpen(!modalOpen())}
          />
          <ImageModal
            show={modalOpen()}
            onClose={() => setModalOpen(false)}
            title={data().title}
            description={data().description}
            src={data().img}
          />
        </Show>

        <figcaption>
          {data().caption}
        </figcaption>
      </figure>
    </div>
  );
}