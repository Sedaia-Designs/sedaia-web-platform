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
      </div>
    </main>
  );
}
