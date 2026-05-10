"use client";

import { useState } from "react";
import styles from "./KeyFinder.module.css";

const MUSICAL_KEYS = [
  "C", "C#", "D", "D#", "E", "F",
  "F#", "G", "G#", "A", "A#", "B",
].flatMap((note) => [`${note} major`, `${note} minor`]);

export default function KeyFinder() {
  const [selectedKey, setSelectedKey] = useState("");
  const [results, setResults] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSearch() {
    if (!selectedKey) return;

    setLoading(true);
    setError(null);
    setResults([]);

    try {
      const res = await fetch(
        `/api/songs?key=${encodeURIComponent(selectedKey)}`
      );

      if (!res.ok) {
        const msg = await res.text();
        throw new Error(msg || `Request failed (${res.status})`);
      }

      const data: string[] = await res.json();
      setResults(data);
    } catch (err) {
      setError(
        err instanceof Error ? err.message : "An unexpected error occurred"
      );
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className={styles.container}>
      <div className={styles.controls}>
        <select
          className={styles.select}
          value={selectedKey}
          onChange={(e) => setSelectedKey(e.target.value)}
        >
          <option value="" disabled>
            Select a key...
          </option>
          {MUSICAL_KEYS.map((key) => (
            <option key={key} value={key}>
              {key}
            </option>
          ))}
        </select>

        <button
          className={styles.button}
          onClick={handleSearch}
          disabled={!selectedKey || loading}
        >
          {loading ? "Searching..." : "Find Compatible Keys"}
        </button>
      </div>

      {error && <p className={styles.error}>{error}</p>}

      {results.length > 0 && (
        <div className={styles.results}>
          <h2 className={styles.resultsTitle}>Compatible Keys</h2>
          <div className={styles.chips}>
            {results.map((key, i) => (
              <span key={i} className={styles.chip}>
                {key}
              </span>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
