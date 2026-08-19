


interface SwitchProps {
  type?: "flat";
  id: string;
  checked?: boolean;
  onChange?: () => void;
}

export default function Switch({ type = "flat", id, checked = false, onChange }: SwitchProps) {
  const inputId = `button-${id}`;

  return (
    <div class={type}>
      <input
        aria-label="Show renders"
        checked={checked}
        class={`tgl tgl-${type}`}
        id={inputId}
        onChange={onChange}
        type="checkbox"
      />
      <label class="tgl-btn" for={inputId}></label>
    </div>
  )
}