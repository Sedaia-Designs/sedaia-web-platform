import { For } from 'solid-js';
import RenderCard, { RenderInfoProps } from './parts/render-card';

// TODO: Rewrite this component to retrieve the renders from the API/Database when those are finished.
const renderCards: RenderInfoProps[] = [
  {
    title: 'Forest Hike (2022)',
    caption:
      'A simple render showing my character and a wolf taking a hike through a forest. Created using SACR in Blender.',
    description: (
      <p>
        This render showcases my character and a wolf taking a hike through a
        forest. The scene is lit with natural sunlight and features a variety of
        3D trees, flowers, and tall grass. The environment itself was completely
        modelled from scratch, and is one of my first and only times I modelled
        a natural environment in a Render within Blender. The character rig used
        is an older version of my{' '}
        <a
          href={'https://www.sedaia-designs.org/projects/sakura-character-rig'}
          target={'_blank'}
        >
          Advanced Character Rig
        </a>
        .
      </p>
    ),
    img: '/images/renders/sakura-forest-hike.avif',
  },
  {
    title: 'Hylian Sakura in Rito Village (2026)',
    caption:
      'A depiction of my OC if she were in Zelda, Breath of the Wild as a Hylian woman travelling Hyrule; presently, at Rito Village.',
    description: (
      <div>
        <p>
          This render was meant to serve as a test of my new computer which I
          had just got, and safe to say it performed valiantly for being a
          laptop compared to my old desktop.
        </p>

        <p>
          The environment is{' '}
          <a href="https://www.youtube.com/watch?v=lmdl2Wu7PO0">Grazzy</a>, in
          which he recreates the world of Zelda: Breath of the Wild inside of
          Minecraft, modified to add some custom Geometry and Shading.
        </p>
        <p>
          Every rig in the scene makes use of my{' '}
          <a
            href={
              'https://www.sedaia-designs.org/projects/sakura-character-rig'
            }
            target={'_blank'}
          >
            Advanced Character Rig
          </a>
        </p>
      </div>
    ),
    img: '/images/renders/hylian_sakura_in_rito.avif',
  },
  {
    title: 'Nether Honeymoon (2026)',
    caption: "Depiction of two of my friend's OCs in a romantic setting.",
    description: (
      <div>
        <p>
          A render request from a friend of mine, representing two of his OC's,
          named Nia and Dupe, the two are on a honeymoon in the Nether near
          their home base. The scene is one of my first times using{' '}
          <a href={'https://github.com/BramStoutProductions/MiEx'}>MiEx</a> to
          export a modded Minecraft World, which is how I got the Benches into
          the world.
        </p>

        <p>
          Both characters in the scene were made using my{' '}
          <a
            href={
              'https://www.sedaia-designs.org/projects/sakura-character-rig'
            }
            target={'_blank'}
          >
            Advanced Character Rig
          </a>
          , modified to add their unique traits such as Dupe's horns and Nia's
          Feline assets
        </p>
      </div>
    ),
    img: '/images/renders/nether-honeymoon.avif',
  },
];

export default function RenderProjectsArticle() {
  return (
    <article id="render-projects">
      <h2>3D Render Achievements</h2>
      <p>
        A showcase of creative and technical achievements in 3D voxel art,
        character staging, and visual storytelling created with Blender,
        focusing on advanced lighting, rigging, and atmospheric scene
        composition.
      </p>
      <For each={renderCards}>
        {(renderInfo) => <RenderCard info={renderInfo} />}
      </For>
    </article>
  );
}
