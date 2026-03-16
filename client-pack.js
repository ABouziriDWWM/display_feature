(() => {
  const DEFAULT_CAPABILITIES_PATH = "./capabilities/";
  const DEFAULT_STATUS_SOURCE = "./capabilities/behat_status.json";
  const DB_NAME = "client-pack";
  const DB_VERSION = 1;
  const KV_STORE = "kv";
  const SAVED_DIR_KEY = "capabilitiesDir";

  const escapeHtml = (value) =>
    String(value)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#039;");

  const escapeRegex = (value) => String(value).replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

  const toSlug = (value) =>
    String(value)
      .toLowerCase()
      .trim()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/(^-|-$)/g, "");

  const splitTags = (line) =>
    line
      .trim()
      .split(/\s+/g)
      .filter((t) => t.startsWith("@"));

  const normalizeNewlines = (text) => String(text).replaceAll("\r\n", "\n");

  const applyQuery = (value) => String(value ?? "").trim().toLowerCase();

  const statusLabel = (status) => {
    const s = applyQuery(status);
    if (!s) return "unknown";
    return s;
  };

  const statusClass = (status) => {
    const s = statusLabel(status);
    if (s === "passed" || s === "pass") return "ok";
    if (s === "failed" || s === "fail") return "bad";
    if (s === "skipped") return "warn";
    return "other";
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

  const statusKey = ({ featureTitle, scenarioTitle }) =>
    `${applyQuery(featureTitle)}||${applyQuery(scenarioTitle)}`;

  const highlightHtml = (text, query) => {
    const safe = escapeHtml(text);
    if (!query) return safe;
    const parts = query.split(/\s+/g).filter(Boolean);
    if (parts.length === 0) return safe;
    const pattern = parts.map(escapeRegex).join("|");
    const re = new RegExp(`(${pattern})`, "ig");
    return safe.replace(re, "<mark>$1</mark>");
  };

  function renderGherkinLineHtml(line, query) {
    const trimmed = line.trimStart();

    const quoteHighlight = (text) => {
      const parts = String(text).split(/(".*?")/g);
      return parts
        .map((p) => {
          if (p.startsWith('"') && p.endsWith('"') && p.length >= 2) {
            return `<span class="gstr">${highlightHtml(p, query)}</span>`;
          }
          return highlightHtml(p, query);
        })
        .join("");
    };

    const keywordMatch = /^(Given|When|Then|And|But|Soit|Quand|Alors|Et|Mais|\*)\b/i.exec(trimmed);
    if (keywordMatch) {
      const kw = keywordMatch[0];
      const rest = trimmed.slice(kw.length);
      const leadingSpaces = line.slice(0, line.length - trimmed.length);
      return `${escapeHtml(leadingSpaces)}<span class="gkw">${highlightHtml(kw, query)}</span>${quoteHighlight(rest)}`;
    }

    if (trimmed.startsWith("|")) {
      const leadingSpaces = line.slice(0, line.length - trimmed.length);
      const cells = trimmed
        .split("|")
        .map((c) => c)
        .filter((c) => c.length > 0);
      const rendered =
        `<span class="gpipe">|</span>` +
        cells
          .map((c) => `<span class="gcell">${quoteHighlight(c)}</span><span class="gpipe">|</span>`)
          .join("");
      return `${escapeHtml(leadingSpaces)}${rendered}`;
    }

    return quoteHighlight(line);
  }

  function renderGherkinBlockHtml(text, query) {
    const lines = normalizeNewlines(text).split("\n");
    return lines.map((l) => renderGherkinLineHtml(l, query)).join("\n");
  }

  const setAllDetailsOpen = (open) => {
    for (const el of document.querySelectorAll("details.feature, details.scenario")) el.open = open;
  };

  function parseFeatureText({ capability, file, text }) {
    const lines = normalizeNewlines(text).split("\n");
    let featureName = "";
    let description = [];
    let pendingTags = [];
    let scenarios = [];
    let currentScenario = null;
    let afterFeatureHeader = false;

    const flushScenario = () => {
      if (!currentScenario) return;
      const normalizedSteps = currentScenario.steps
        .map((s) => s.replaceAll("\t", "  ").replace(/\s+$/g, ""))
        .filter((s) => s.length > 0);
      scenarios.push({ ...currentScenario, steps: normalizedSteps });
      currentScenario = null;
    };

    for (const rawLine of lines) {
      const line = rawLine.replace(/\s+$/g, "");
      const trimmed = line.trim();

      if (!trimmed) {
        if (afterFeatureHeader && !currentScenario && description.length > 0 && description.at(-1) !== "") {
          description.push("");
        }
        if (currentScenario) currentScenario.steps.push("");
        continue;
      }

      if (trimmed.startsWith("@")) {
        pendingTags = [...pendingTags, ...splitTags(trimmed)];
        continue;
      }

      const featureMatch = /^Feature:\s*(.*)$/i.exec(trimmed);
      if (featureMatch) {
        featureName = featureMatch[1].trim();
        afterFeatureHeader = true;
        continue;
      }

      const scenarioMatch = /^(Scenario Outline|Scenario|Background):\s*(.*)$/i.exec(trimmed);
      if (scenarioMatch) {
        flushScenario();
        currentScenario = {
          keyword: scenarioMatch[1],
          name: scenarioMatch[2].trim(),
          tags: pendingTags,
          steps: [],
        };
        pendingTags = [];
        continue;
      }

      if (currentScenario) {
        const display = line.startsWith("    ") ? line.slice(4) : line.trimStart();
        currentScenario.steps.push(display);
        continue;
      }

      if (afterFeatureHeader) {
        description.push(line.trimStart());
      }
    }

    flushScenario();

    return {
      capability,
      file,
      featureName,
      description: description.join("\n").trim(),
      scenarios,
    };
  }

  const buildIndex = (features) =>
    features.map((f) => {
      const scenarioText = f.scenarios
        .map((s) => [s.keyword, s.name, ...(s.tags ?? []), ...(s.steps ?? [])].join("\n"))
        .join("\n\n");
      const index = [f.capability, f.file, f.featureName, f.description, scenarioText]
        .filter(Boolean)
        .join("\n")
        .toLowerCase();
      return { ...f, _index: index };
    });

  async function fetchText(url) {
    const res = await fetch(url, { cache: "no-store" });
    if (!res.ok) throw new Error(`HTTP ${res.status} (${url})`);
    return await res.text();
  }

  async function tryFetchJson(url) {
    const res = await fetch(url, { cache: "no-store" });
    if (!res.ok) return null;
    try {
      return await res.json();
    } catch {
      return null;
    }
  }

  async function safeTryFetchJson(url) {
    try {
      return await tryFetchJson(url);
    } catch {
      return null;
    }
  }

  function buildStatusContext(statusData) {
    const map = new Map();
    const scenarios = Array.isArray(statusData?.scenarios) ? statusData.scenarios : [];
    for (const s of scenarios) {
      const featureTitle = s?.feature?.title ?? "";
      const scenarioTitle = s?.title ?? "";
      map.set(statusKey({ featureTitle, scenarioTitle }), statusLabel(s?.status));
    }
    return { data: statusData ?? null, map };
  }

  function renderDashboard({ statusContext, featureCount, scenarioCount, statusCounts }) {
    const data = statusContext?.data ?? null;

    const runMetaEl = document.getElementById("dashboardRunMeta");
    const updatedMetaEl = document.getElementById("dashboardUpdatedMeta");
    const kpiScenariosEl = document.getElementById("dashboardKpiScenarios");
    const kpiFeaturesEl = document.getElementById("dashboardKpiFeatures");
    const kpiStateEl = document.getElementById("dashboardKpiState");
    const kpiDurationEl = document.getElementById("dashboardKpiDuration");
    const barPassedEl = document.getElementById("dashboardBarPassed");
    const barFailedEl = document.getElementById("dashboardBarFailed");
    const barSkippedEl = document.getElementById("dashboardBarSkipped");
    const barOtherEl = document.getElementById("dashboardBarOther");
    const barLegendEl = document.getElementById("dashboardBarLegend");
    const overviewEl = document.getElementById("dashboardOverview");

    if (kpiScenariosEl) kpiScenariosEl.textContent = String(scenarioCount);
    if (kpiFeaturesEl) kpiFeaturesEl.textContent = String(featureCount);

    const startedAt = parseIso(data?.startedAt);
    const updatedAt = parseIso(data?.updatedAt);
    const durationMs = startedAt && updatedAt ? updatedAt.getTime() - startedAt.getTime() : null;

    if (kpiStateEl) kpiStateEl.textContent = data?.state ? String(data.state) : "—";
    if (kpiDurationEl) kpiDurationEl.textContent = formatDuration(durationMs);

    if (runMetaEl) {
      const bits = [];
      if (data?.suite) bits.push(`suite: ${data.suite}`);
      if (data?.runId) bits.push(`runId: ${data.runId}`);
      runMetaEl.textContent = bits.join(" · ");
    }

    if (updatedMetaEl) {
      const bits = [];
      if (startedAt) bits.push(`start: ${formatDateTime(startedAt)}`);
      if (updatedAt) bits.push(`end: ${formatDateTime(updatedAt)}`);
      updatedMetaEl.textContent = bits.join(" · ");
    }

    const passed = statusCounts.passed;
    const failed = statusCounts.failed;
    const skipped = statusCounts.skipped;
    const other = statusCounts.other;
    const total = scenarioCount;

    const pct = (v) => (total <= 0 ? 0 : (v / total) * 100);

    if (barPassedEl) barPassedEl.style.width = `${pct(passed)}%`;
    if (barFailedEl) barFailedEl.style.width = `${pct(failed)}%`;
    if (barSkippedEl) barSkippedEl.style.width = `${pct(skipped)}%`;
    if (barOtherEl) barOtherEl.style.width = `${pct(other)}%`;

    if (barLegendEl) {
      const parts = [`${passed} passed`, `${failed} failed`, `${skipped} skipped`, `${other} other`];
      barLegendEl.textContent = parts.join(" · ");
    }

    if (overviewEl) {
      if (!data) {
        overviewEl.textContent = `Source: ${DEFAULT_STATUS_SOURCE} (non disponible)`;
      } else if (failed > 0) {
        overviewEl.textContent = `${failed} échec${failed === 1 ? "" : "s"} détecté${failed === 1 ? "" : "s"}.`;
      } else {
        overviewEl.textContent = scenarioCount > 0 ? "No failure detected." : "No scenario.";
      }
    }
  }

  function parseDirectoryListingAnchors(htmlText, baseUrl) {
    const doc = new DOMParser().parseFromString(htmlText, "text/html");
    const anchors = [...doc.querySelectorAll("a[href]")].map((a) => a.getAttribute("href")).filter(Boolean);
    const urls = [];
    for (const href of anchors) {
      if (href === "../" || href === "./") continue;
      if (href.startsWith("?")) continue;
      if (href.startsWith("#")) continue;
      try {
        urls.push(new URL(href, baseUrl).toString());
      } catch {
        continue;
      }
    }
    return urls;
  }

  async function listDirectoryEntries(dirUrl) {
    const html = await fetchText(dirUrl);
    const links = parseDirectoryListingAnchors(html, dirUrl);
    const entries = new Set();

    for (const link of links) {
      if (!link.startsWith(dirUrl)) continue;
      const rel = decodeURIComponent(link.slice(dirUrl.length));
      if (!rel || rel === "/" || rel.startsWith("/")) continue;
      const clean = rel.split("?")[0].split("#")[0];
      const first = clean.split("/")[0];
      if (!first) continue;
      entries.add(first + (clean.endsWith("/") ? "/" : ""));
    }

    return [...entries].sort((a, b) => a.localeCompare(b));
  }

  function openDb() {
    return new Promise((resolve, reject) => {
      const req = indexedDB.open(DB_NAME, DB_VERSION);
      req.onerror = () => reject(req.error);
      req.onupgradeneeded = () => {
        const db = req.result;
        if (!db.objectStoreNames.contains(KV_STORE)) db.createObjectStore(KV_STORE, { keyPath: "key" });
      };
      req.onsuccess = () => resolve(req.result);
    });
  }

  async function kvGet(key) {
    const db = await openDb();
    try {
      return await new Promise((resolve, reject) => {
        const tx = db.transaction(KV_STORE, "readonly");
        const store = tx.objectStore(KV_STORE);
        const req = store.get(key);
        req.onerror = () => reject(req.error);
        req.onsuccess = () => resolve(req.result ? req.result.value : null);
      });
    } finally {
      db.close();
    }
  }

  async function kvSet(key, value) {
    const db = await openDb();
    try {
      await new Promise((resolve, reject) => {
        const tx = db.transaction(KV_STORE, "readwrite");
        tx.onabort = () => reject(tx.error);
        tx.onerror = () => reject(tx.error);
        tx.oncomplete = () => resolve();
        const store = tx.objectStore(KV_STORE);
        store.put({ key, value });
      });
    } finally {
      db.close();
    }
  }

  async function getSavedDirHandle() {
    if (!("indexedDB" in window)) return null;
    try {
      return await kvGet(SAVED_DIR_KEY);
    } catch {
      return null;
    }
  }

  async function saveDirHandle(handle) {
    if (!("indexedDB" in window)) return;
    await kvSet(SAVED_DIR_KEY, handle);
  }

  async function ensureHandlePermission(handle) {
    if (!handle) return false;
    if (!("queryPermission" in handle) || !("requestPermission" in handle)) return true;
    const opts = { mode: "read" };
    const current = await handle.queryPermission(opts);
    if (current === "granted") return true;
    const requested = await handle.requestPermission(opts);
    return requested === "granted";
  }

  async function collectFeatureFilesFromHandle(handle, baseParts = []) {
    const files = [];
    for await (const [name, entry] of handle.entries()) {
      if (entry.kind === "directory") {
        files.push(...(await collectFeatureFilesFromHandle(entry, [...baseParts, name])));
        continue;
      }
      if (entry.kind === "file" && name.toLowerCase().endsWith(".feature")) {
        const file = await entry.getFile();
        const relative = [...baseParts, name].join("/");
        files.push({ filePath: `capabilities/${relative}`, capability: baseParts[0] || "unknown", file });
      }
    }
    return files.sort((a, b) => a.filePath.localeCompare(b.filePath));
  }

  async function loadFeaturesFromDirectoryPicker({ setSourceText }) {
    if (!("showDirectoryPicker" in window)) return null;
    const handle = await window.showDirectoryPicker({ id: "capabilities", mode: "read" });
    const ok = await ensureHandlePermission(handle);
    if (!ok) throw new Error("Permission refusée pour lire le dossier sélectionné.");
    await saveDirHandle(handle);
    const featureFiles = await collectFeatureFilesFromHandle(handle);
    const features = [];
    for (const item of featureFiles) {
      const text = await item.file.text();
      features.push(parseFeatureText({ capability: item.capability, file: item.filePath, text }));
    }
    setSourceText?.("Source: dossier local (capabilities/)");
    return buildIndex(features);
  }

  async function loadFeaturesFromSavedHandle({ setSourceText }) {
    if (!("indexedDB" in window)) return null;
    const handle = await getSavedDirHandle();
    if (!handle) return null;
    const ok = await ensureHandlePermission(handle);
    if (!ok) return null;
    const featureFiles = await collectFeatureFilesFromHandle(handle);
    const features = [];
    for (const item of featureFiles) {
      const text = await item.file.text();
      features.push(parseFeatureText({ capability: item.capability, file: item.filePath, text }));
    }
    setSourceText?.("Source: dossier local (capabilities/)");
    return buildIndex(features);
  }

  async function loadFeaturesFromFileList(fileList, { setSourceText }) {
    const files = [...fileList].filter((f) => String(f.name).toLowerCase().endsWith(".feature"));
    if (files.length === 0) throw new Error("No .feature file found in the selected directory.");
    const features = [];
    for (const file of files) {
      const relative = String(file.webkitRelativePath || file.name).replace(/^\/+/, "");
      const normalized = relative.replaceAll("\\", "/");
      const parts = normalized.split("/").filter(Boolean);
      const capability = parts.length > 1 ? parts[0] : "misc";
      const filePath = parts.length > 1 ? `capabilities/${normalized}` : `capabilities/${capability}/${parts[0] || file.name}`;
      const text = await file.text();
      features.push(parseFeatureText({ capability, file: filePath, text }));
    }
    setSourceText?.("Source: dossier local (capabilities/)");
    return buildIndex(features);
  }

  function render({ features, query, activeCapabilities, statusContext, sourceLabel, statusFilter }) {
    const content = document.getElementById("content");
    const summary = document.getElementById("summary");
    const statusMap = statusContext?.map ?? new Map();

    const normalizedFilter = statusFilter ? statusLabel(statusFilter) : "";
    const matchesStatusFilter = (normalizedStatus) => {
      if (!normalizedFilter) return true;
      if (normalizedFilter === "other") return !["passed", "failed", "skipped"].includes(normalizedStatus);
      return normalizedStatus === normalizedFilter;
    };

    const filtered = features.filter((f) => {
      if (activeCapabilities.size > 0 && !activeCapabilities.has(f.capability)) return false;
      if (!query) return true;
      return f._index.includes(query);
    });

    const totals = { passed: 0, failed: 0, skipped: 0, other: 0 };
    const visibleCounts = { passed: 0, failed: 0, skipped: 0, other: 0 };

    const decorated = filtered.map((f) => {
      const featureTitle = f.featureName || "";
      const decoratedScenarios = f.scenarios.map((s) => {
        const raw =
          statusMap.get(statusKey({ featureTitle, scenarioTitle: s.name || "" })) ??
          statusMap.get(statusKey({ featureTitle, scenarioTitle: s.name || "" }).replace(/\s+/g, " ")) ??
          null;
        const normalized = statusLabel(raw ?? "unknown");
        if (normalized === "passed") totals.passed += 1;
        else if (normalized === "failed") totals.failed += 1;
        else if (normalized === "skipped") totals.skipped += 1;
        else totals.other += 1;
        return { ...s, _statusRaw: raw, _status: normalized };
      });

      const shownScenarios = decoratedScenarios.filter((s) => matchesStatusFilter(s._status));
      return { ...f, _scenariosAll: decoratedScenarios, _scenariosShown: shownScenarios };
    });

    const visibleFeatures = normalizedFilter
      ? decorated.filter((f) => (f._scenariosShown ?? []).length > 0)
      : decorated;

    const featureCount = visibleFeatures.length;
    const scenarioCount = visibleFeatures.reduce((sum, f) => sum + (f._scenariosShown?.length ?? 0), 0);

    for (const f of visibleFeatures) {
      for (const s of f._scenariosShown ?? []) {
        const normalized = s._status;
        if (normalized === "passed") visibleCounts.passed += 1;
        else if (normalized === "failed") visibleCounts.failed += 1;
        else if (normalized === "skipped") visibleCounts.skipped += 1;
        else visibleCounts.other += 1;
      }
    }

    const prefix = String(sourceLabel ?? "").trim();
    const prefixHtml = prefix ? `${escapeHtml(prefix)} · ` : "";
    summary.innerHTML = `
      <span>${prefixHtml}${featureCount} feature${featureCount === 1 ? "" : "s"}, ${scenarioCount} scénario${
      scenarioCount === 1 ? "" : "s"
    }</span>
      <span class="summary-badges" aria-label="Statuts">
        <button class="summary-badge ok badge-filter" type="button" data-status="passed" data-active="${
          normalizedFilter === "passed" ? "true" : "false"
        }" aria-pressed="${normalizedFilter === "passed" ? "true" : "false"}">${totals.passed} passed</button>
        <button class="summary-badge bad badge-filter" type="button" data-status="failed" data-active="${
          normalizedFilter === "failed" ? "true" : "false"
        }" aria-pressed="${normalizedFilter === "failed" ? "true" : "false"}">${totals.failed} failed</button>
        <button class="summary-badge warn badge-filter" type="button" data-status="skipped" data-active="${
          normalizedFilter === "skipped" ? "true" : "false"
        }" aria-pressed="${normalizedFilter === "skipped" ? "true" : "false"}">${totals.skipped} skipped</button>
        <button class="summary-badge other badge-filter" type="button" data-status="other" data-active="${
          normalizedFilter === "other" ? "true" : "false"
        }" aria-pressed="${normalizedFilter === "other" ? "true" : "false"}">${totals.other} other</button>
      </span>
    `;

    renderDashboard({
      statusContext,
      featureCount,
      scenarioCount,
      statusCounts: visibleCounts,
    });

    if (visibleFeatures.length === 0) {
      content.innerHTML = `<div class="empty">No result. Try a different search or clear the filters.</div>`;
      return;
    }

    const capabilityGroups = new Map();
    for (const f of visibleFeatures) {
      if (!capabilityGroups.has(f.capability)) capabilityGroups.set(f.capability, []);
      capabilityGroups.get(f.capability).push(f);
    }

    const orderedCapabilities = [...capabilityGroups.keys()].sort((a, b) => a.localeCompare(b));
    const html = orderedCapabilities
      .map((cap) => {
        const items = capabilityGroups.get(cap) ?? [];
        const capScenarioCount = items.reduce((sum, f) => sum + (f._scenariosShown?.length ?? 0), 0);
        const capId = `cap-${toSlug(cap)}`;
        const featuresHtml = items
          .sort((a, b) => (a.featureName || a.file).localeCompare(b.featureName || b.file))
          .map((f) => {
            const featureId = `${capId}-${toSlug(f.featureName || f.file)}`;
            const featureDesc = f.description
              ? `<div class="feature-desc">${highlightHtml(f.description, query)}</div>`
              : "";
            const scenariosHtml = (f._scenariosShown ?? [])
              .map((s, idx) => {
                const tags = s.tags ?? [];
                const hasWip = tags.some((t) => t.toLowerCase() === "@wip");
                const tagsHtml = tags
                  .map(
                    (t) =>
                      `<span class="pill${t.toLowerCase() === "@wip" ? " warn" : ""}">${highlightHtml(
                        t,
                        query
                      )}</span>`
                  )
                  .join("");
                const stepsText = (s.steps ?? []).join("\n").trimEnd();
                const stepCount = (s.steps ?? []).filter((line) => line.trim().length > 0).length;
                const scenarioId = `${featureId}-s${idx + 1}-${toSlug(s.name || String(idx + 1))}`;
                const statusBadge = s._statusRaw
                  ? `<span class="badge ${statusClass(s._status)}">${escapeHtml(s._status)}</span>`
                  : "";
                return `
                  <details class="scenario" id="${escapeHtml(scenarioId)}">
                    <summary>
                      <div class="scenario-name">
                        <span class="keyword">${escapeHtml(s.keyword)}</span>
                        <span class="title">${highlightHtml(s.name, query)}</span>
                        ${tagsHtml}
                      </div>
                      <div class="scenario-meta">
                        ${statusBadge}
                        <span class="pill">${stepCount} step${stepCount === 1 ? "" : "s"}</span>
                        ${hasWip ? `<span class="pill warn">WIP</span>` : ""}
                      </div>
                    </summary>
                    <pre class="steps" tabindex="0" role="region" aria-label="Étapes du scénario">${renderGherkinBlockHtml(
                      stepsText,
                      query
                    )}</pre>
                  </details>
                `;
              })
              .join("");

            return `
              <details class="feature" open id="${escapeHtml(featureId)}">
                <summary>
                  <div class="feature-title">
                    <h2>${highlightHtml(f.featureName || "(feature sans titre)", query)}</h2>
                    <span class="feature-path">${highlightHtml(f.file, query)}</span>
                  </div>
                </summary>
                ${featureDesc}
                <div class="scenario-list">${scenariosHtml}</div>
              </details>
            `;
          })
          .join("");

        return `
          <section class="capability" id="${escapeHtml(capId)}">
            <div class="capability-header">
              <h3 class="capability-title">${highlightHtml(cap, query)}</h3>
              <div class="capability-meta">${items.length} feature${items.length === 1 ? "" : "s"} · ${capScenarioCount} scénario${
          capScenarioCount === 1 ? "" : "s"
        }</div>
            </div>
            <div class="features">${featuresHtml}</div>
          </section>
        `;
      })
      .join("");

    content.innerHTML = html;
  }

  function renderChips({ allCapabilities, counts, activeCapabilities }) {
    const chipsEl = document.getElementById("capabilityChips");
    if (!chipsEl) return;
    chipsEl.innerHTML = allCapabilities
      .map((cap) => {
        const count = counts.get(cap) ?? 0;
        const active = activeCapabilities.has(cap);
        return `<button type="button" class="chip" data-cap="${escapeHtml(cap)}" data-active="${
          active ? "true" : "false"
        }" aria-pressed="${active ? "true" : "false"}"><span>${escapeHtml(cap)}</span><span class="count">${count}</span></button>`;
      })
      .join("");
  }

  function setLoading(text) {
    const content = document.getElementById("content");
    const summary = document.getElementById("summary");
    summary.textContent = "";
    content.innerHTML = `<div class="empty">${escapeHtml(text)}</div>`;
  }

  function setError(err) {
    const content = document.getElementById("content");
    const summary = document.getElementById("summary");
    summary.textContent = "";
    const message = err instanceof Error ? err.message : String(err);
    const protocolHint =
      window.location.protocol === "file:"
        ? `Astuce: vous avez ouvert la page en "file://". Dans ce mode, le navigateur bloque l’accès aux fichiers du disque via fetch(). Utilisez le bouton "Choisir capabilities/" ou ouvrez la page via un serveur HTTP.`
        : `Astuce: si votre serveur ne permet pas le listing de répertoires, ajoutez capabilities/manifest.json (format: {"files": ["capabilities/.../*.feature"]}).`;
    content.innerHTML = `<div class="empty">${escapeHtml(`Erreur: ${message}`)}<br /><br />${escapeHtml(
      protocolHint
    )}</div>`;
  }

  async function discoverFeatureFiles({ capabilitiesPath }) {
    const base = new URL(capabilitiesPath, window.location.href).toString();

    const manifest = await tryFetchJson(new URL("manifest.json", base).toString());
    if (manifest && Array.isArray(manifest.files)) {
      return manifest.files
        .map((f) => String(f))
        .filter((f) => f.startsWith("capabilities/") && f.endsWith(".feature"))
        .sort((a, b) => a.localeCompare(b));
    }

    const capabilityEntries = (await listDirectoryEntries(base)).filter((e) => e.endsWith("/") && !e.startsWith("."));
    if (capabilityEntries.length === 0) {
      throw new Error(
        `Impossible de lister ${capabilitiesPath}. Assurez-vous que votre serveur autorise le listing de répertoires (autoindex) ou fournissez capabilities/manifest.json.`
      );
    }

    const files = [];
    for (const entry of capabilityEntries) {
      const capName = entry.replace(/\/$/, "");
      const capUrl = new URL(entry, base).toString();
      const capEntries = await listDirectoryEntries(capUrl);
      const featureFiles = capEntries.filter((e) => e.toLowerCase().endsWith(".feature") && !e.includes("/"));
      for (const ff of featureFiles) files.push(`capabilities/${capName}/${ff}`);
    }

    return files.sort((a, b) => a.localeCompare(b));
  }

  async function loadFeatures() {
    const url = new URL(window.location.href);
    const capabilitiesPath = url.searchParams.get("capabilities") ?? DEFAULT_CAPABILITIES_PATH;

    const featureFiles = await discoverFeatureFiles({ capabilitiesPath });

    const features = [];
    for (const file of featureFiles) {
      const capability = file.split("/")[1] || "unknown";
      const text = await fetchText(new URL(file, window.location.href).toString());
      features.push(parseFeatureText({ capability, file, text }));
    }

    return buildIndex(features);
  }

  async function main() {
    const searchEl = document.getElementById("search");
    const clearEl = document.getElementById("clear");
    const expandAllEl = document.getElementById("expandAll");
    const collapseAllEl = document.getElementById("collapseAll");
    const pickDirEl = document.getElementById("pickDir");
    const pickDirInputEl = document.getElementById("pickDirInput");
    const pickFilesEl = document.getElementById("pickFiles");
    const pickFilesInputEl = document.getElementById("pickFilesInput");

    let sourceLabel = "";
    const setSourceText = (text) => {
      sourceLabel = String(text ?? "").trim();
    };

    const statusData = await safeTryFetchJson(new URL(DEFAULT_STATUS_SOURCE, window.location.href).toString());
    const statusContext = buildStatusContext(statusData);

    if (pickDirEl) {
      pickDirEl.addEventListener("click", async () => {
        try {
          if ("showDirectoryPicker" in window) {
            setLoading("Chargement depuis le dossier sélectionné…");
            const indexed = await loadFeaturesFromDirectoryPicker({ setSourceText });
            if (!indexed) throw new Error("Sélection de dossier indisponible dans ce navigateur.");
            startUi({
              indexed,
              searchEl,
              clearEl,
              expandAllEl,
              collapseAllEl,
              getSourceLabel: () => sourceLabel,
              statusContext,
            });
            return;
          }
          if (pickDirInputEl) {
            pickDirInputEl.value = "";
            pickDirInputEl.click();
            return;
          }
          throw new Error("Sélection de dossier indisponible dans ce navigateur.");
        } catch (err) {
          setError(err);
          return;
        }
      });
    }

    if (pickDirInputEl) {
      pickDirInputEl.addEventListener("change", async () => {
        if (!pickDirInputEl.files || pickDirInputEl.files.length === 0) return;
        setLoading("Chargement depuis le dossier sélectionné…");
        try {
          const indexed = await loadFeaturesFromFileList(pickDirInputEl.files, { setSourceText });
          startUi({
            indexed,
            searchEl,
            clearEl,
            expandAllEl,
            collapseAllEl,
            getSourceLabel: () => sourceLabel,
            statusContext,
          });
        } catch (err) {
          setError(err);
        }
      });
    }

    if (pickFilesEl) {
      pickFilesEl.addEventListener("click", () => {
        if (!pickFilesInputEl) {
          setError("Sélection de fichiers indisponible dans ce navigateur.");
          return;
        }
        pickFilesInputEl.value = "";
        pickFilesInputEl.click();
      });
    }

    if (pickFilesInputEl) {
      pickFilesInputEl.addEventListener("change", async () => {
        if (!pickFilesInputEl.files || pickFilesInputEl.files.length === 0) return;
        setLoading("Chargement des fichiers .feature…");
        try {
          const indexed = await loadFeaturesFromFileList(pickFilesInputEl.files, { setSourceText });
          startUi({
            indexed,
            searchEl,
            clearEl,
            expandAllEl,
            collapseAllEl,
            getSourceLabel: () => sourceLabel,
            statusContext,
          });
        } catch (err) {
          setError(err);
        }
      });
    }

    setLoading("Chargement des features…");

    let indexed;
    try {
      if (window.location.protocol === "file:") {
        indexed = await loadFeaturesFromSavedHandle({ setSourceText });
        if (!indexed) throw new Error("Aucune source disponible en mode file://.");
      } else {
        try {
          indexed = await loadFeatures();
          setSourceText("Source: serveur (capabilities/)");
        } catch {
          indexed = await loadFeaturesFromSavedHandle({ setSourceText });
          if (!indexed) throw new Error("Impossible de charger les features depuis le serveur.");
        }
      }
    } catch (err) {
      setError(err);
      return;
    }

    startUi({
      indexed,
      searchEl,
      clearEl,
      expandAllEl,
      collapseAllEl,
      getSourceLabel: () => sourceLabel,
      statusContext,
    });
  }

  function startUi({ indexed, searchEl, clearEl, expandAllEl, collapseAllEl, getSourceLabel, statusContext }) {
    const allCapabilities = [...new Set(indexed.map((f) => f.capability))].sort((a, b) => a.localeCompare(b));
    const counts = new Map();
    for (const cap of allCapabilities) counts.set(cap, indexed.filter((f) => f.capability === cap).length);

    const activeCapabilities = new Set();
    let statusFilter = "";

    const normalizeFilter = (value) => {
      const normalized = statusLabel(value);
      if (["passed", "failed", "skipped", "other"].includes(normalized)) return normalized;
      return "other";
    };

    const rerender = () => {
      const query = applyQuery(searchEl ? searchEl.value : "");
      renderChips({ allCapabilities, counts, activeCapabilities });
      render({
        features: indexed,
        query,
        activeCapabilities,
        statusContext,
        sourceLabel: getSourceLabel?.(),
        statusFilter,
      });

      for (const btn of document.querySelectorAll(".chip[data-cap]")) {
        btn.addEventListener("click", () => {
          const cap = btn.getAttribute("data-cap");
          if (!cap) return;
          if (activeCapabilities.has(cap)) activeCapabilities.delete(cap);
          else activeCapabilities.add(cap);
          rerender();
        });
      }
    };

    if (searchEl) searchEl.addEventListener("input", rerender);
    if (clearEl && searchEl) {
      clearEl.addEventListener("click", () => {
        searchEl.value = "";
        activeCapabilities.clear();
        statusFilter = "";
        rerender();
      });
    }
    if (expandAllEl) expandAllEl.addEventListener("click", () => setAllDetailsOpen(true));
    if (collapseAllEl) collapseAllEl.addEventListener("click", () => setAllDetailsOpen(false));

    const mainEl = document.getElementById("mainContent");
    if (mainEl) {
      mainEl.addEventListener("click", (event) => {
        const target = event.target;
        if (!(target instanceof Element)) return;
        const btn = target.closest(".badge-filter[data-status]");
        if (!btn) return;
        const next = normalizeFilter(btn.getAttribute("data-status"));
        statusFilter = statusFilter === next ? "" : next;
        rerender();
      });
    }

    rerender();
  }

  window.addEventListener("error", (event) => setError(event.error || event.message));
  window.addEventListener("unhandledrejection", (event) => setError(event.reason));
  main();
})();
