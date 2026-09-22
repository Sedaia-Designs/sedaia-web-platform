import { Href } from '~/components/routing/Href.tsx';

export default function Navigation() {
  return (
    <div id={'navigation'}>
      <Href href={'https://www.sakura-sedaia.com'} class={'navigation-logo'}>
        Portfolio
      </Href>
      <nav class="router right">
        <div class="nav-item">
          <Href href="https://www.sedaia-designs.org">Sedaia Designs</Href>
        </div>
        <div class="nav-item">
          <Href href="https://gitlab.com/SakuraSedaia">Gitlab</Href>
        </div>
      </nav>
    </div>
  );
}
