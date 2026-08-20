import { Show } from "solid-js";
import { JSX } from "@solidjs/web";

interface IconBundleProps extends JSX.SvgSVGAttributes<SVGSVGElement> {
  name: string;
  class?: string;
}

export default function IconBundle({ name, class: className, ...others }: IconBundleProps) {
  const icons: Record<string, string> = {
    "discord": "bi-logos-discord",
    "github": "bi-logos-github",
    "youtube": "bi-logos-youtube",
    "deviantart": "bi-logos-deviantart",
    "codeberg": "logos-codeberg",
    "gumroad": "logos-gumroad",
    "git": "bi-logos-git",
    "instagram": "bi-logos-instagram",
    "pinterest": "bi-logos-pinterest",
    "reddit": "bi-logos-reddit",
    "twitch": "bi-logos-twitch",
    "twitter": "bi-logos-twitter",
    "patreon": "bi-logos-patreon",
    "envelope": "bi-envelope",
    "globe": "bi-globe",
    "arrow-down": "arrow-down",
    "hamburger": "hamburger",
    "image-management": "image-management",
    "rig-renaming": "rig-renaming",
    "skin-downloader": "skin-downloader",
    "quick-access": "quick-access",
    "blender-bw": "logo-blender-bw",
    "python-bw": "logo-python-bw",
    "bi-external-link": "external-link",
  };

  const iconName = () => icons[name];

  return (
    <Show when={iconName()}>
      {(resolvedIconName) => (
        <div class={"icon"}>
          <svg
            viewBox="0 0 24 24"
            fill="currentColor"
            class={className}
            {...others}
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
