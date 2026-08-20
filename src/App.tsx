import { createEffect, createSignal, onCleanup } from 'solid-js';
import './app.scss';
import BackgroundArticle from './components/sections/background-article';
import SoftwareProjectsArticle from './components/sections/software-projects-article';
import RenderProjectsArticle from './components/sections/render-projects-article';
import TechStacksArticle from './components/sections/tech-stacks-article';
import Header from "./components/sections/header";
import Navigation from "./components/sections/navigation";
import CollageButton from "./components/collage-button";
import SiteDevWarning from "./components/sections/side-dev-warning";
import GetInTouch from "~/components/sections/get-in-touch";

// The app root: the central content component — the document shell lives in
// src/Document.tsx.
export default function App() {
  const [blur, setBlur] = createSignal(true);
  const [collageLoaded, setCollageLoaded] = createSignal(false);
  let main: HTMLElement | undefined;

  createEffect(() => main, (element) => {
    if (!element || !('IntersectionObserver' in window)) {
      setCollageLoaded(true);
      return;
    }

    const observer = new IntersectionObserver(([entry]) => {
      if (!entry?.isIntersecting) return;

      setCollageLoaded(true);
      observer.disconnect();
    });

    observer.observe(element);
    onCleanup(() => observer.disconnect());
  });

  return (
    <main
      ref={main}
      class={{'blur-backdrop': blur(), 'collage-loaded': collageLoaded()}}
    >
      <CollageButton onClick={() => setBlur((isBlurred) => !isBlurred)} b={blur()}/>

      <div class="container" id="portfolio-content" inert={!blur()}>
        <SiteDevWarning/>
        <Navigation/>
        <Header/>
        <BackgroundArticle/>
        <TechStacksArticle/>
        <SoftwareProjectsArticle/>
        <RenderProjectsArticle/>
        {/* TODO: Add my Technical credentials regarding my hands on trade work */}
        <GetInTouch/>
      </div>
    </main>
  );
}
