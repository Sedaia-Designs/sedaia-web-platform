export default function TechStacksArticle() {
  return (
    <article id="tech-stacks">
      <h2>Technical Expertise</h2>
      <div class="tech-container">
        <div class="tech-list">
          <h3>Web Dev</h3>
          <ul id="web-frameworks">
            <li><a href="https://developer.mozilla.org/en-US/docs/Web/" target="_blank" rel="noopener noreferrer">HTML/CSS</a>{' - Document structure and styling.'}</li>
            <li><a href="https://sass-lang.com/" target="_blank" rel="noopener noreferrer">SCSS</a>{' - Advanced styling.'}</li>
            <li><a href="https://www.solidjs.com/" target="_blank" rel="noopener noreferrer">SolidJS</a>{' - Reactive web framework.'}</li>
            <li><a href="https://www.typescriptlang.org/docs/" target="_blank" rel="noopener noreferrer">TypeScript</a>{' - Interactive logic.'}</li>
          </ul>
        </div>
        <div class="tech-list">
          <h3>Other</h3>
          <ul id="other-expertise">
            <li><a href="https://kotlinlang.org/" target="_blank" rel="noopener noreferrer">Kotlin</a>{' - General-purpose JVM and multiplatform application development.'}</li>
            <li><a href="https://ktor.io/" target="_blank" rel="noopener noreferrer">Ktor</a>{' - Backend APIs and server application development.'}</li>
            <li><a href="https://docs.blender.org/api/current/index.html" target="_blank" rel="noopener noreferrer">Blender Python API</a>{' - 3D automation and tool scripting in Python.'}</li>
            <li><a href="https://www.python.org/" target="_blank" rel="noopener noreferrer">Python 3</a>{' - General purpose software development.'}</li>
          </ul>
        </div>
      </div>
    </article>
  );
}
