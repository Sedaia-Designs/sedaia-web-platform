import { Href } from '~/components/routing/Href.tsx';

export default function TechStacksArticle() {
  return (
    <article id="tech-stacks">
      <h2>Technical Expertise</h2>
      <div class="tech-container">
        <div class="tech-list">
          <h3>Web Dev</h3>
          <ul id="web-frameworks">
            <li>
              <Href href="https://developer.mozilla.org/en-US/docs/Web/">
                HTML/CSS
              </Href>
              {' - Document structure and styling.'}
            </li>
            <li>
              <Href href="https://sass-lang.com/">SCSS</Href>
              {' - Advanced styling.'}
            </li>
            <li>
              <Href href="https://www.solidjs.com/">SolidJS</Href>
              {' - Reactive web framework.'}
            </li>
            <li>
              <Href href="https://www.typescriptlang.org/docs/">
                TypeScript
              </Href>
              {' - Interactive logic.'}
            </li>
          </ul>
        </div>
        <div class="tech-list">
          <h3>Other</h3>
          <ul id="other-expertise">
            <li>
              <Href href="https://kotlinlang.org/">Kotlin</Href>
              {
                ' - General-purpose JVM and multiplatform application development.'
              }
            </li>
            <li>
              <Href href="https://ktor.io/">Ktor</Href>
              {' - Backend APIs and server application development.'}
            </li>
            <li>
              <Href href="https://docs.blender.org/api/current/index.html">
                Blender Python API
              </Href>
              {' - 3D automation and tool scripting in Python.'}
            </li>
            <li>
              <Href href="https://www.python.org/">Python 3</Href>
              {' - General purpose software development.'}
            </li>
          </ul>
        </div>
      </div>
    </article>
  );
}
