export default function CollageButton(props: { onClick: () => void; b: boolean }) {
  return <button
    aria-controls="portfolio-content"
    class="blur-toggle"
    onClick={props.onClick}
    type="button"
  >
    {props.b ? 'Reveal Collage' : 'Hide Collage'}
  </button>
}