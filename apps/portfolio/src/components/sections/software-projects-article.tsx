import { ProgrammingResponse } from '~/lib/types.ts';
import { For, Loading } from 'solid-js';
import Markdown from '~/components/parsers/markdown.tsx';
import { Href } from '~/components/routing/Href.tsx';

export default function SoftwareProjectsArticle(props: {
  content: ProgrammingResponse[];
}) {
  function ProjectLink(props: { href?: string; children: Element | string }) {
    return (
      <div class={'project-link'}>
        <Href href={props.href}>{props.children}</Href>
      </div>
    );
  }

  return (
    <article id={'software-projects'}>
      <h2>Software Projects</h2>
      <p>
        A collection of technical achievements in software engineering, custom
        tooling, and workflow automation designed to solve real-world pipeline
        challenges and provide practical utility to designers and developers.
      </p>

      <Loading fallback={<span>Loading...</span>}>
        <For each={props.content}>
          {(project) => (
            <div class={'project-container'}>
              <h3>{project.title}</h3>
              <div class={'router left'}>
                <ProjectLink href={project.projectPage}>
                  Project Page
                </ProjectLink>
                <ProjectLink href={project.sourceCode}>Source</ProjectLink>
                <ProjectLink href={project.documentation}>
                  Documentation
                </ProjectLink>
              </div>

              <Markdown content={project.description} />
            </div>
          )}
        </For>
      </Loading>
    </article>
  );
}
