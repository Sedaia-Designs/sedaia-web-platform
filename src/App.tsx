import { createSignal } from 'solid-js';
import './app.scss';
import BackgroundArticle from './components/background-article';
import SoftwareProjectsArticle from './components/software-projects-article';
import TechStacksArticle from './components/tech-stacks-article';
import Header from "./components/header";
import Navigation from "./components/navigation";
import CollageButton from "./components/collage-button";
import SiteDevWarning from "./components/side-dev-warning";

// The app root: the central content component — the document shell lives in
// src/Document.tsx.
export default function App() {
  const [blur, setBlur] = createSignal(true);

  return (
    <main class={{'blur-backdrop': blur()}}>
      <CollageButton onClick={() => setBlur((isBlurred) => !isBlurred)} b={blur()}/>

      <div class="container" id="portfolio-content" inert={!blur()}>
        <SiteDevWarning/>
        
        <Navigation/>
        
        <Header/>
        
        <BackgroundArticle/>
        <TechStacksArticle/>
        <SoftwareProjectsArticle/>
        {/* TODO: Add a section showing off my latest renders in detail, hardcode this section initially, as it will be LazyLoaded from the CDN when the CDN is initialized and setup */}
        
        {/* TODO: Add my Technical credentials regarding my hands on trade work */}
      </div>
    </main>
  );
}
