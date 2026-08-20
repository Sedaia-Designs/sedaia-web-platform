export default function SoftwareProjectsArticle() {
  return (
    <article id="software-projects">
      <h2>Technical Achievements</h2>
      <p>
        A collection of technical achievements in software engineering, custom tooling, and workflow automation designed to solve real-world pipeline challenges and provide practical utility to designers and developers.
      </p>
      <div class="project-container">
        <h3>Blender Development for Pycharm</h3>
        <div class="router left">
          <div class="project-link"><a href="https://www.sedaia-designs.org/projects/blender-development">Project Page</a></div>
          <div class="project-link"><a href="https://gitlab.com/sedaia-designs/blender_pycharm">Source</a></div>
          <div class="project-link"><a href="https://docs.blender-development.sakura-sedaia.tech/">Documentation</a></div>
        </div>
        <p><strong>Blender Development</strong> is a plugin originally developed for PyCharm. The original idea is based on the <a href="https://github.com/JacquesLucke/blender_vscode">Blender Development</a> extension by Jacques Lucke for Visual Studio Code, of which my plugin's core Python runtime is forked from. The plugin is developed in Kotlin, and is heavily integrated into the Intellij Platform SDK, granting it more advanced and integrated features including:</p>
        <ul><li>Managed Blender Installs</li><li>Access to Pycharm's advanced debugging tools</li><li>Python Intellisense Stub installations</li></ul>
        <p>The plugin is currently at version 1.0.0 Beta 3, with the main development being focused on refinement and security in preparation for a full 1.0.0 release.</p>
      </div>
      <div class="project-container">
        <h3 id={"heading-advanced-character-rig"}>Advanced Character Rig</h3>
        <div class="router left">
          <div class="project-link"><a href="https://www.sedaia-designs.org/projects/sakura-character-rig">Project Page</a></div>
          <div class="project-link"><a href="https://gitlab.com/sedaia-designs/advanced-character-rig">Source</a></div>
          <div class="project-link"><a href="https://docs.sakura-sedaia.com">Documentation</a></div>
        </div>
        <p><strong>Sakura Advanced Character Rig (SACR)</strong> is a Blender rig and toolkit for creating Minecraft-style character renders. The project brings its independently released components together in one repository, including:</p>
        <ul><li>Character rig releases, source assets, and supporting files</li><li>Sakura Rig Utilities for rig and skin management workflows</li><li>Reusable Blender scripts for specialized, one-off tasks</li></ul>
        <p>The rig is actively maintained across Blender versions, while Sakura Rig Utilities is in early development as the future home for discovering, downloading, and importing SACR rigs directly in Blender.</p>
      </div>
    </article>
  );
}
