import {Show} from "solid-js";
import {JSX} from "@solidjs/web";

interface IconBundleProps extends JSX.HTMLAttributes<HTMLDivElement> {
  name: string;
}

export default function IconBundle(props: IconBundleProps) {
  const icons: Record<string, string> = {
    "discord": "logos-discord",
    "gitlab": "logos-gitlab",
    "youtube": "logos-youtube"
  }

  const iconName = () => icons[props.name];
  
  return (
    <Show when={iconName()}>
      {(resolvedIconName) => (
        <div class={"icon"}>
          <svg
            viewBox="0 0 24 24"
            fill="currentColor"
          >
            <use
              href={`/images/vectors/${resolvedIconName()}.svg#${resolvedIconName()}`}
            />
          </svg>
        </div>
      )}
    </Show>
  );

}
