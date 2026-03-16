const json = (statusCode, body, extraHeaders = {}) => ({
  statusCode,
  headers: {
    "content-type": "application/json; charset=utf-8",
    ...extraHeaders,
  },
  body: JSON.stringify(body),
});

const text = (statusCode, body, extraHeaders = {}) => ({
  statusCode,
  headers: {
    "content-type": "text/plain; charset=utf-8",
    ...extraHeaders,
  },
  body: String(body ?? ""),
});

const requiredEnv = (name) => {
  const value = process.env[name];
  if (!value || String(value).trim().length === 0) throw new Error(`Missing env var: ${name}`);
  return String(value).trim();
};

const safeJsonParse = (raw) => {
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
};

const normalizePath = (p) => String(p ?? "").replaceAll("\\", "/").replace(/^\/+/, "");

const isAllowedPath = (p) => {
  if (!p.startsWith("capabilities/")) return false;
  if (p.includes("..")) return false;
  if (p.endsWith(".feature")) return true;
  if (p === "capabilities/manifest.json") return true;
  if (p === "capabilities/behat_status.json") return true;
  return false;
};

const ghFetch = async ({ token, url, method = "GET", body }) => {
  const headers = {
    authorization: `Bearer ${token}`,
    accept: "application/vnd.github+json",
    "user-agent": "client-pack-netlify-function",
  };
  const hasBody = body !== undefined;
  if (hasBody) headers["content-type"] = "application/json";
  const res = await fetch(url, { method, headers, body: hasBody ? JSON.stringify(body) : undefined });
  const textBody = await res.text();
  if (!res.ok) {
    throw new Error(`GitHub API ${res.status} ${res.statusText}: ${textBody.slice(0, 2000)}`);
  }
  return textBody ? safeJsonParse(textBody) : null;
};

exports.handler = async (event) => {
  try {
    if (event.httpMethod !== "POST") return text(405, "Method not allowed");

    const publishKey = String(event.headers?.["x-publish-key"] ?? event.headers?.["X-Publish-Key"] ?? "").trim();
    const expectedKey = requiredEnv("PUBLISH_KEY");
    if (!publishKey || publishKey !== expectedKey) return text(401, "Unauthorized");

    const rawBody = String(event.body ?? "");
    if (rawBody.length > 6_000_000) return text(413, "Payload too large");
    const payload = safeJsonParse(rawBody);
    if (!payload || !Array.isArray(payload.files)) return text(400, "Invalid JSON payload");

    const token = requiredEnv("GITHUB_TOKEN");
    const owner = requiredEnv("GITHUB_OWNER");
    const repo = requiredEnv("GITHUB_REPO");
    const branch = String(process.env.GITHUB_BRANCH ?? "main").trim() || "main";

    const incomingFiles = payload.files
      .map((f) => ({
        path: normalizePath(f?.path),
        content: String(f?.content ?? ""),
      }))
      .filter((f) => f.path.length > 0);

    const fileMap = new Map();
    for (const f of incomingFiles) {
      if (!isAllowedPath(f.path)) return text(400, `Unsupported path: ${f.path}`);
      if (f.path === "capabilities/behat_status.json") continue;
      fileMap.set(f.path, f.content);
    }

    const featurePaths = [...fileMap.keys()].filter((p) => p.endsWith(".feature")).sort((a, b) => a.localeCompare(b));
    if (featurePaths.length === 0) return text(400, "No .feature files received");

    const manifestJson = JSON.stringify({ files: featurePaths }, null, 2) + "\n";
    fileMap.set("capabilities/manifest.json", manifestJson);

    const apiBase = `https://api.github.com/repos/${encodeURIComponent(owner)}/${encodeURIComponent(repo)}`;

    const ref = await ghFetch({
      token,
      url: `${apiBase}/git/ref/heads/${encodeURIComponent(branch)}`,
    });
    const parentSha = ref?.object?.sha;
    if (!parentSha) throw new Error("Unable to resolve branch head");

    const parentCommit = await ghFetch({
      token,
      url: `${apiBase}/git/commits/${encodeURIComponent(parentSha)}`,
    });
    const baseTreeSha = parentCommit?.tree?.sha;
    if (!baseTreeSha) throw new Error("Unable to resolve base tree");

    const baseTree = await ghFetch({
      token,
      url: `${apiBase}/git/trees/${encodeURIComponent(baseTreeSha)}?recursive=1`,
    });

    const existingCapabilityPaths = new Set(
      (Array.isArray(baseTree?.tree) ? baseTree.tree : [])
        .filter((e) => e && e.type === "blob" && typeof e.path === "string")
        .map((e) => e.path)
        .filter((p) => p.startsWith("capabilities/") && (p.endsWith(".feature") || p === "capabilities/manifest.json"))
    );

    const nextPaths = new Set(fileMap.keys());
    const deletions = [...existingCapabilityPaths].filter((p) => !nextPaths.has(p));

    const treeEntries = [
      ...[...fileMap.entries()].map(([path, content]) => ({
        path,
        mode: "100644",
        type: "blob",
        content,
      })),
      ...deletions.map((path) => ({
        path,
        mode: "100644",
        type: "blob",
        sha: null,
      })),
    ];

    const newTree = await ghFetch({
      token,
      url: `${apiBase}/git/trees`,
      method: "POST",
      body: { base_tree: baseTreeSha, tree: treeEntries },
    });
    const newTreeSha = newTree?.sha;
    if (!newTreeSha) throw new Error("Unable to create git tree");

    const nowIso = new Date().toISOString();
    const commit = await ghFetch({
      token,
      url: `${apiBase}/git/commits`,
      method: "POST",
      body: {
        message: `Update capabilities from web (${nowIso})`,
        tree: newTreeSha,
        parents: [parentSha],
      },
    });
    const commitSha = commit?.sha;
    if (!commitSha) throw new Error("Unable to create commit");

    await ghFetch({
      token,
      url: `${apiBase}/git/refs/heads/${encodeURIComponent(branch)}`,
      method: "PATCH",
      body: { sha: commitSha, force: false },
    });

    return json(200, {
      ok: true,
      commitSha,
      commitUrl: commit?.html_url ?? `https://github.com/${owner}/${repo}/commit/${commitSha}`,
      updatedFiles: fileMap.size,
      deletedFiles: deletions.length,
    });
  } catch (err) {
    return json(500, { ok: false, error: err instanceof Error ? err.message : String(err) });
  }
};
