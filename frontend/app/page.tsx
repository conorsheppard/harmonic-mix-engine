import styles from "./page.module.css";
import KeyFinder from "./components/KeyFinder/KeyFinder";

export default function Home() {
  return (
    <div className={styles.page}>
      <main className={styles.main}>
        <div className={styles.intro}>
          <h1>Harmonic Mix Engine</h1>
          <p>
            Find compatible keys for harmonic mixing. Select a musical key to
            discover which keys sound great together.
          </p>
        </div>
        <KeyFinder />
      </main>
    </div>
  );
}
