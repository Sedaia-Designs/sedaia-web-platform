import Switch from "./ui";

export default function CollageButton(props: { onClick: () => void; b: boolean }) {
  return (
    <div class={"collage-button"}>
      <div>Show Renders</div>

      <Switch checked={!props.b} id="collage-toggle" onChange={props.onClick} />
    </div>
  )
}