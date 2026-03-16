(() => {
  const DEFAULT_SOURCE = "./capabilities/behat_status.json";

  const escapeHtml = (value) =>
    String(value ?? "")
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#039;");

  const normalize = (value) => String(value ?? "").trim().toLowerCase();

  const byString = (a, b) => String(a).localeCompare(String(b), "fr", { sensitivity: "base" });

  const basenameFromPath = (value) => {
    const raw = String(value ?? "").trim();
    if (!raw) return "";
    const parts = raw.split(/[\\/]/g).filter(Boolean);
    return parts.at(-1) ?? raw;
  };

  const parseIso = (value) => {
    const date = new Date(String(value ?? ""));
    if (Number.isNaN(date.getTime())) return null;
    return date;
  };

  const formatDateTime = (date) => {
    try {
      return new Intl.DateTimeFormat("fr-FR", {
        year: "numeric",
        month: "2-digit",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
      }).format(date);
    } catch {
      return date.toISOString();
    }
  };

  const formatDuration = (ms) => {
    if (!Number.isFinite(ms) || ms < 0) return "—";
    const totalSeconds = Math.round(ms / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    if (minutes <= 0) return `${seconds}s`;
    return `${minutes}m ${String(seconds).padStart(2, "0")}s`;
  };

  const statusClass = (status) => {
    const s = normalize(status);
    if (s === "passed" || s === "pass") return "ok";
    if (s === "failed" || s === "fail") return "bad";
    if (s === "skipped") return "warn";
    return "other";
  };

  const statusLabel = (status) => {
    const s = normalize(status);
    if (!s) return "unknown";
    return s;
  };

  const getEls = () => ({
    search: document.getElementById("search"),
    clear: document.getElementById("clear"),
    statusChips: document.getElementById("statusChips"),
    sourceMeta: document.getElementById("sourceMeta"),
    runMeta: document.getElementById("runMeta"),
    updatedMeta: document.getElementById("updatedMeta"),
    kpiScenarios: document.getElementById("kpiScenarios"),
    kpiFeatures: document.getElementById("kpiFeatures"),
    kpiState: document.getElementById("kpiState"),
    kpiDuration: document.getElementById("kpiDuration"),
    barPassed: document.getElementById("barPassed"),
    barFailed: document.getElementById("barFailed"),
    barSkipped: document.getElementById("barSkipped"),
    barOther: document.getElementById("barOther"),
    barLegend: document.getElementById("barLegend"),
    overview: document.getElementById("overview"),
    featureList: document.getElementById("featureList"),
  });

  async function fetchJson(url) {
    const res = await fetch(url, { cache: "no-store" });
    if (!res.ok) throw new Error(`HTTP ${res.status} (${url})`);
    return await res.json();
  }

  function buildDataIndex(data) {
    const scenarios = Array.isArray(data?.scenarios) ? data.scenarios : [];
    const features = new Map();

    for (const s of scenarios) {
      const featureTitle = s?.feature?.title ?? "Feature";
      const featureFile = s?.feature?.file ?? "";
      const key = String(featureTitle);
      if (!features.has(key)) {
        features.set(key, {
          title: featureTitle,
          file: featureFile,
          scenarios: [],
          counts: new Map(),
        });
      }
      const group = features.get(key);
      const status = statusLabel(s?.status);
      group.scenarios.push({
        title: s?.title ?? "",
        line: s?.line ?? null,
        status,
      });
      group.counts.set(status, (group.counts.get(status) ?? 0) + 1);
    }

    const featureList = [...features.values()].map((f) => {
      const total = f.scenarios.length;
      const counts = f.counts;
      const failed = counts.get("failed") ?? 0;
      const passed = counts.get("passed") ?? 0;
      const skipped = counts.get("skipped") ?? 0;
      const other = total - failed - passed - skipped;
      const idx = normalize([f.title, ...f.scenarios.map((s) => `${s.status} ${s.title}`)].join("\n"));
      return { ...f, total, failed, passed, skipped, other, _index: idx };
    });

    featureList.sort((a, b) => {
      if (b.failed !== a.failed) return b.failed - a.failed;
      if (b.other !== a.other) return b.other - a.other;
      if (b.skipped !== a.skipped) return b.skipped - a.skipped;
      return byString(a.title, b.title);
    });

    return { scenarios, featureList };
  }

  function countStatuses(scenarios) {
    const counts = new Map();
    for (const s of scenarios) {
      const status = statusLabel(s?.status);
      counts.set(status, (counts.get(status) ?? 0) + 1);
    }
    return counts;
  }

  function renderStatusChips({ statusCounts, activeStatuses, onToggle }) {
    const chips = document.getElementById("statusChips");
    const sorted = [...statusCounts.entries()]
      .sort((a, b) => {
        if (b[1] !== a[1]) return b[1] - a[1];
        return byString(a[0], b[0]);
      })
      .map(([status, count]) => ({ status, count }));

    chips.innerHTML = sorted
      .map(({ status, count }) => {
        const active = activeStatuses.has(status);
        return `<button class="chip" type="button" data-status="${escapeHtml(status)}" data-active="${
          active ? "true" : "false"
        }"><span>${escapeHtml(status)}</span><span class="count">${count}</span></button>`;
      })
      .join("");

    for (const btn of chips.querySelectorAll("button.chip[data-status]")) {
      btn.addEventListener("click", () => {
        const status = btn.getAttribute("data-status") ?? "";
        onToggle(status);
      });
    }
  }

  function statusBarSegments({ total, passed, failed, skipped, other }) {
    const pct = (v) => (total <= 0 ? 0 : (v / total) * 100);
    return {
      passedPct: pct(passed),
      failedPct: pct(failed),
      skippedPct: pct(skipped),
      otherPct: pct(other),
    };
  }

  function renderTop({ data, index, statusCounts }) {
    const els = getEls();

    els.sourceMeta.textContent = `Source: ${DEFAULT_SOURCE}`;

    const startedAt = parseIso(data?.startedAt);
    const updatedAt = parseIso(data?.updatedAt);
    const durationMs = startedAt && updatedAt ? updatedAt.getTime() - startedAt.getTime() : null;

    const runBits = [];
    if (data?.suite) runBits.push(`suite: ${data.suite}`);
    if (data?.runId) runBits.push(`runId: ${data.runId}`);
    els.runMeta.textContent = runBits.join(" · ");

    const updatedBits = [];
    if (startedAt) updatedBits.push(`début: ${formatDateTime(startedAt)}`);
    if (updatedAt) updatedBits.push(`fin: ${formatDateTime(updatedAt)}`);
    els.updatedMeta.textContent = updatedBits.join(" · ");

    els.kpiScenarios.textContent = String(index.scenarios.length);
    els.kpiFeatures.textContent = String(index.featureList.length);
    els.kpiState.textContent = String(data?.state ?? "—");
    els.kpiDuration.textContent = formatDuration(durationMs);

    const passed = statusCounts.get("passed") ?? 0;
    const failed = statusCounts.get("failed") ?? 0;
    const skipped = statusCounts.get("skipped") ?? 0;
    const total = index.scenarios.length;
    const other = total - passed - failed - skipped;

    const { passedPct, failedPct, skippedPct, otherPct } = statusBarSegments({
      total,
      passed,
      failed,
      skipped,
      other,
    });

    els.barPassed.style.width = `${passedPct}%`;
    els.barFailed.style.width = `${failedPct}%`;
    els.barSkipped.style.width = `${skippedPct}%`;
    els.barOther.style.width = `${otherPct}%`;

    const legendParts = [
      `${passed} passed`,
      `${failed} failed`,
      `${skipped} skipped`,
      other > 0 ? `${other} autres` : null,
    ].filter(Boolean);
    els.barLegend.textContent = legendParts.join(" · ");

    const overviewParts = [];
    if (failed > 0) overviewParts.push(`${failed} échec${failed === 1 ? "" : "s"} détecté${failed === 1 ? "" : "s"}.`);
    if (failed === 0 && total > 0) overviewParts.push(`Aucun échec détecté.`);
    if (skipped > 0) overviewParts.push(`${skipped} scénario${skipped === 1 ? "" : "s"} skipped.`);
    if (other > 0) overviewParts.push(`${other} scénario${other === 1 ? "" : "s"} avec un statut différent.`);
    els.overview.textContent = overviewParts.join(" ");
  }

  function renderFeatures({ featureList, query, activeStatuses }) {
    const els = getEls();
    const q = normalize(query);

    const filtered = featureList.filter((f) => {
      if (activeStatuses.size > 0) {
        const hasAny = f.scenarios.some((s) => activeStatuses.has(s.status));
        if (!hasAny) return false;
      }
      if (!q) return true;
      return f._index.includes(q);
    });

    if (filtered.length === 0) {
      els.featureList.innerHTML = `<div class="empty">Aucun résultat. Essayez une autre recherche ou ajustez les filtres.</div>`;
      return;
    }

    const html = filtered
      .map((f) => {
        const title = f.title || "Feature";
        const file = basenameFromPath(f.file || "");

        const scenarios = f.scenarios
          .filter((s) => (activeStatuses.size > 0 ? activeStatuses.has(s.status) : true))
          .filter((s) => (q ? normalize(`${s.status} ${s.title}`).includes(q) || normalize(title).includes(q) : true))
          .map((s) => {
            const badge = statusClass(s.status);
            const label = escapeHtml(statusLabel(s.status));
            const line = Number.isFinite(Number(s.line)) ? ` <span class="meta">L${escapeHtml(Number(s.line))}</span>` : "";
            return `<div class="scenario"><div class="name">${escapeHtml(s.title)}${line}</div><span class="badge ${badge}">${label}</span></div>`;
          })
          .join("");

        const showCounts = [];
        if (f.failed > 0) showCounts.push(`${f.failed} failed`);
        if (f.passed > 0) showCounts.push(`${f.passed} passed`);
        if (f.skipped > 0) showCounts.push(`${f.skipped} skipped`);
        if (f.other > 0) showCounts.push(`${f.other} autres`);
        if (showCounts.length === 0) showCounts.push(`${f.total} scénario${f.total === 1 ? "" : "s"}`);

        return `<details class="feature">
          <summary>
            <div class="feature-head">
              <h2 class="name">${escapeHtml(title)}</h2>
              <div class="counts">${escapeHtml(showCounts.join(" · "))}</div>
            </div>
            ${file ? `<div class="feature-sub">${escapeHtml(file)}</div>` : ""}
          </summary>
          <div class="scenario-list">${scenarios || `<div class="empty">Aucun scénario à afficher.</div>`}</div>
        </details>`;
      })
      .join("");

    els.featureList.innerHTML = html;
  }

  async function main() {
    const els = getEls();
    let data;
    try {
      data = await fetchJson(DEFAULT_SOURCE);
    } catch (err) {
      els.featureList.innerHTML = `<div class="empty">Impossible de charger ${escapeHtml(
        DEFAULT_SOURCE
      )}. Lancez la page via un serveur HTTP et vérifiez le chemin.</div>`;
      els.overview.textContent = String(err?.message ?? err ?? "");
      return;
    }

    const index = buildDataIndex(data);
    const statusCounts = countStatuses(index.scenarios);

    const state = {
      query: "",
      activeStatuses: new Set(),
    };

    const rerender = () => {
      renderTop({ data, index, statusCounts });
      renderStatusChips({
        statusCounts,
        activeStatuses: state.activeStatuses,
        onToggle: (status) => {
          if (!status) return;
          if (state.activeStatuses.has(status)) state.activeStatuses.delete(status);
          else state.activeStatuses.add(status);
          rerender();
        },
      });
      renderFeatures({ featureList: index.featureList, query: state.query, activeStatuses: state.activeStatuses });
    };

    els.search.addEventListener("input", () => {
      state.query = els.search.value ?? "";
      rerender();
    });

    els.clear.addEventListener("click", () => {
      state.query = "";
      state.activeStatuses.clear();
      els.search.value = "";
      rerender();
      els.search.focus();
    });

    rerender();
  }

  main();
})();
