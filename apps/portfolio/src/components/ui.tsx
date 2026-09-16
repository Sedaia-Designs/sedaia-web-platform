interface SwitchProps {
  type?: 'flat';
  id: string;
  checked?: boolean;
  onChange?: () => void;
}

export default function Switch(props: SwitchProps) {
  // Styling and code taken from https://codepen.io/mallendeo/pen/QWKrEL
  const type = () => props.type ?? 'flat';
  const inputId = () => `button-${props.id}`;

  return (
    <div class={type()}>
      <input
        aria-label="Show renders"
        checked={props.checked ?? false}
        class={['tgl', `tgl-${type()}`]}
        id={inputId()}
        onChange={() => props.onChange?.()}
        type="checkbox"
      />
      <label class="tgl-btn" for={inputId()} />
    </div>
  );
}
