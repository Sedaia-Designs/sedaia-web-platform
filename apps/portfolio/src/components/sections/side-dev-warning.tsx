import { Href } from '~/components/routing/Href.tsx';

export default function SiteDevWarning() {
  return (
    <aside class="site-moved">
      <h2>There's been a shakeup!</h2>
      <p>
        This new portfolio is taking over the domain. The previous Sedaia
        Designs website has moved to{' '}
        <Href href="https://sedaia-designs.org" target={'_self'}>
          sedaia-designs.org
        </Href>
        .
      </p>
    </aside>
  );
}
