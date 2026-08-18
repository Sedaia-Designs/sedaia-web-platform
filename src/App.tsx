import { createSignal } from 'solid-js';
import './app.scss';

// The app root: the central content component — the document shell lives in
// src/Document.tsx.
export default function App() {
  const [blur, setBlur] = createSignal(true);
  return (
    <main class={{ 'blur-backdrop': blur() }}>
      <button
        aria-controls="portfolio-content"
        class="blur-toggle"
        onClick={() => setBlur((isBlurred) => !isBlurred)}
        type="button"
      >
        {blur() ? 'Reveal Collage' : 'Blur Collage'}
      </button>

      <div
        class="container"
        id="portfolio-content"
        inert={!blur()}
      >
        <aside class="site-moved">
          <h2>There's been a shakeup!</h2>
          <p>
            This new portfolio is taking over the domain. The previous Sedaia
            Designs website has moved to{' '}
            <a href="https://sedaia-designs.org">sedaia-designs.org</a>.
          </p>
        </aside>
        
        <nav class={"router right"}>
          <div class={"nav-item"}><a href={"https://sedaia-designs.org"}>Sedaia Designs</a></div>
          <div class={"nav-item"}><a href={"https://gitlab.com/SakuraSedaia"}>Gitlab</a></div>
        </nav>
        <header>
          <img
            src={"images/iowa_motor_speedway_garage_selfie.avif"}
            alt={"Selfie of my at the IndyCar Race at Iowa Motor Speedway in June 2025"}
            width={"300px"}
            class={"about-image"}
          />
          <h1>Sakura Sedaia</h1>
          <p class={"subtitle"}>Novice Web Engineer and 3D Artist</p>
        </header>
        
        
        <article class={"background"}>
          <h2 id={"my-background"}>My Background</h2>
          <p>I am an experienced multi-disciplinary technician, 3D Voxel artist, and software engineer with a diverse background. I got my
            start in 2017 when I got introduced to the world of HTML development by a senior friend in high school, and
            since then my skills have only grown, and passion for computers, cars, and communications has only
            grown!</p>
          
          <p>My love for computers starts from a young age, when I got my first personal computer in 2014. It would be
            then that I began experimenting with Computer Generated Graphics using <a href={"https://blender.org"}
                                                                                      target={"_blank"}
                                                                                      rel={"noopener noreferrer"}>Blender
              3D</a>, a free and open source 3D Rendering, Video Composition, and Image Processing suite</p>
          
          <h3>My skills</h3>
          <ul class="landing-about__skills">
            <li>
              <strong>3D Rendering & Rigging:</strong> Crafting Minecraft based
              models and rigs using Blender since 2015.
            </li>
            <li>
              <strong>Software Development:</strong> Building reactive web
              applications with SolidJS and developing custom tooling using Python
              and Kotlin.
            </li>
            <li>
              <strong>Hands-on Technical:</strong> Extensive background as an
              automotive and tire technician, currently traveling the country as
              an asset recovery technician.
            </li>
          </ul>
        </article>
        
        <article class={"tech-stacks"}>
          <h2>Technical Expertise</h2>
          <div class={"tech-container"}>
            <div class={"tech-list"}>
              <h3>Web Dev</h3>
              <ul id={"web-frameworks"}>
                <li>
                  <a href={"https://developer.mozilla.org/en-US/docs/Web/"} target={"_blank"} rel={"noopener noreferrer"}>HTML/CSS</a>
                  {" - Document structure and styling."}
                </li>
                <li>
                  <a href={"https://sass-lang.com/"} target={"_blank"} rel={"noopener noreferrer"}>SCSS</a>
                  {" - Advanced styling."}
                </li>
                <li>
                  <a href={"https://www.solidjs.com/"} target={"_blank"} rel={"noopener noreferrer"}>SolidJS</a>
                  {" - Reactive web framework."}
                </li>
                <li>
                  <a href={"https://www.typescriptlang.org/docs/"} target={"_blank"} rel={"noopener noreferrer"}>TypeScript</a>
                  {" - Interactive logic."}
                </li>
              </ul>
            </div>

            <div class={"tech-list"}>
              <h3>Other</h3>
              <ul id={"other-expertise"}>
                <li>
                  <a href={"https://kotlinlang.org/"} target={"_blank"} rel={"noopener noreferrer"}>Kotlin</a>
                  {" - General-purpose JVM and multiplatform application development."}
                </li>
                <li>
                  <a href={"https://ktor.io/"} target={"_blank"} rel={"noopener noreferrer"}>Ktor</a>
                  {" - Backend APIs and server application development."}
                </li>
                <li>
                  <a href={"https://docs.blender.org/api/current/index.html"} target={"_blank"} rel={"noopener noreferrer"}>Blender Python API</a>
                  {" - 3D automation and tool scripting in Python."}
                </li>
                <li>
                  <a href={"https://www.python.org/"} target={"_blank"} rel={"noopener noreferrer"}>Python 3</a>
                  {" - General purpose software development."}
                </li>
              </ul>
            </div>
          </div>
        </article>
        
        <article id={"software-projects"}>
          <h2>Software Projects</h2>
          <p>
            All software projects I've made so far are pet projects designed to help level up my skills while providing a genuine utility to other designers or programmers.
          </p>
          
          <div class={"project-container"}>
            <h3>Blender Development for Pycharm</h3>
            <div class={"router left"}>
              <div class={"project-link"}>
                <a href={"https://www.sedaia-designs.org/projects/blender-development"}>Project Page</a>
              </div>
              <div class={"project-link"}>
                <a href={"https://gitlab.com/sedaia-designs/blender_pycharm"}>Source</a>
              </div>
              <div class={"project-link"}>
                <a href={"https://docs.blender-development.sakura-sedaia.tech/"}>Documentation</a>
              </div>
            </div>
            
            <p>
              Blender Development is a plugin originally developed for PyCharm. The original idea is based on the <a href={"https://github.com/JacquesLucke/blender_vscode"}>Blender Development</a> extension by Jacques Lucke for Visual Studio Code, of which my plugin's core Python runtime is forked from. The plugin is developed in Kotlin, and is heavily integrated into the Intellij Platform SDK, granting it more advanced and integrated features including:
            </p>
            <ul>
              <li>Managed Blender Installs</li>
              <li>Access to Pycharm's advanced debugging tools</li>
              <li>Python Intellisense Stub installations</li>
            </ul>
            <p>The plugin is currently at version 1.0.0 Beta 3, with the main development being focused on refinement and security in preparation for a full 1.0.0 release.</p>
          </div>
          
          
          <div class={"project-container"}>
            <h3>Advanced Character Rig</h3>
            <div class={"router left"}>
              <div class={"project-link"}>
                <a href={"https://www.sedaia-designs.org/projects/sakura-character-rig"}>Project Page</a>
              </div>
              <div class={"project-link"}>
                <a href={"https://gitlab.com/sedaia-designs/advanced-character-rig"}>Source</a>
              </div>
              <div class={"project-link"}>
                <a href={"https://docs.sakura-sedaia.com"}>Documentation</a>
              </div>
            </div>
            
            <p>
              <strong>Sakura Advanced Character Rig (SACR)</strong> is a Blender rig and toolkit for creating Minecraft-style character renders. The project brings its independently released components together in one repository, including:
            </p>
            <ul>
              <li>Character rig releases, source assets, and supporting files</li>
              <li>Sakura Rig Utilities for rig and skin management workflows</li>
              <li>Reusable Blender scripts for specialized, one-off tasks</li>
            </ul>
            <p>
              The rig is actively maintained across Blender versions, while Sakura Rig Utilities is in early development as the future home for discovering, downloading, and importing SACR rigs directly in Blender.
            </p>
          </div>
        </article>
      </div>
    </main>
  );
}
