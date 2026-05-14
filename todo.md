# Sniffnet website — outstanding improvements

Follow-up items from the 2026-05-14 audit pass. The "Bugs / inconsistencies / dead code" tier was already completed in that session (see "Already done" section at the bottom). What remains is everything that needed deeper investigation or out-of-scope work.

Each item is self-contained: context, where to look, concrete steps, success criteria. Pick any one; they're independent unless noted.

---

## 1. Accessibility — full WCAG pass

**Why it matters.** Surface-level a11y was already fixed (alt text on the downloads badge, `title` on the Whimsical iframe). What's left is the deeper stuff: contrast in every state, keyboard nav, ARIA on interactive widgets, focus visibility, screen-reader flow.

**Where to look.**
- `_includes/nav.html` — the dropdown menu (`role="button"`, `aria-haspopup`, `aria-expanded`). Beautiful-jekyll defaults are minimal; verify keyboard works (Tab/Enter/Esc) and screen readers announce the dropdown state.
- `assets/css/sniffnet.css` — every `:hover` rule should have a matching `:focus` or `:focus-visible`. Search for `:hover` and check coverage.
- `_includes/search.html` + the search overlay logic in `assets/js/sniffnet.js` — modal a11y (focus trap, Esc to close already exists, but no focus return on close).
- All anchor links with only icons (e.g. social icons in footer, GitHub icons) — most have `title=` attrs which become accessible names, but a few `<a><img alt=""></a>` patterns rely on the title. Run an audit tool to find which fail.
- The home-banner cyan announcement and the anniversary `<details>` element — verify keyboard interaction.

**Concrete steps.**
1. Install axe-core or run Lighthouse a11y on a local `bundle exec jekyll serve`. Target score: 95+.
2. Document failing rules in this file as sub-items, then fix.
3. Test keyboard-only navigation on every page: Tab through, can you reach everything? Can you Escape modals?
4. Check contrast ratios on:
   - `.home-banner-date` (italic `#888888` on the cyan/amber banner bgs)
   - `.news-card-meta` (italic `#888888` on dark card bg)
   - All `#888888` text in general — that's borderline AAA on dark bg.

**Success criteria.** Lighthouse a11y ≥95, axe-core reports zero violations, keyboard-only nav works for every interactive element, focus indicators visible everywhere.

---

## 2. Image optimisation — compress PNG screenshots, consider WebP

**Why it matters.** The gallery and post cover images are 1280×800 PNGs straight from screenshots — typically 200–500 KB each. They compress 50–70% with proper PNG optimisation (oxipng, pngquant) and a further 30–50% if served as WebP/AVIF.

**Where to look.**
- `assets/img/post/*/cover.*` — 25+ post covers, all unoptimised.
- `assets/img/*.png` — `initial_page.png`, `overview_page.png`, `thumbnail.png`, `inspect_page.png`, `connection_details.png`, `settings_notifications.png`, `notifications_page.png`, `yeti_night.png`, `a11y_day.png`, `deep_cosmos.png`, `merch.png`, `me.png`, `preview.png`.

**Concrete steps.**
1. Get baseline: `du -sh assets/img/` (currently ~?). Run `find assets/img -name "*.png" -exec ls -lh {} \; | awk '{print $5, $9}' | sort -h` to find the biggest offenders.
2. Run `oxipng -o 4 --strip safe assets/img/**/*.png` for lossless. Should shave 10–30% with zero quality loss.
3. For lossy optional pass: `pngquant --quality=80-95 --skip-if-larger --output {} {} ::: assets/img/**/*.png`.
4. WebP variants: `for f in assets/img/**/*.png; do cwebp -q 85 "$f" -o "${f%.png}.webp"; done`. Then use `<picture>` element in templates:
   ```html
   <picture>
     <source srcset="image.webp" type="image/webp">
     <img src="image.png" alt="...">
   </picture>
   ```
   But this requires template changes in `gallery.html`, `news/index.html`, and probably a Liquid helper. Bigger refactor — assess whether it's worth it.
5. Commit a "compress images" change separately so the diff is reviewable.

**Success criteria.** Total `assets/img/` size drops ≥30%. Visual diff on the gallery page is imperceptible.

---

## 3. SEO depth — sitemap, structured data, robots

**Why it matters.** Surface OG/Twitter tags are good (done in audit). What's missing is the discoverability infrastructure that helps search engines understand and index the site properly.

**Where to look.**
- `_config.yml:104-105` — `jekyll-sitemap` plugin is enabled, so `sitemap.xml` is auto-generated. Verify by hitting `/sitemap.xml` after `jekyll serve` — it should list all pages and posts. Check that the news posts have proper `<lastmod>` and `<priority>`.
- No `robots.txt` exists. Add one at the repo root.
- No JSON-LD structured data. Posts could use schema.org `Article` / `BlogPosting`; home page could use `SoftwareApplication` or `WebSite`.

**Concrete steps.**
1. Create `/robots.txt`:
   ```
   User-agent: *
   Allow: /
   Sitemap: https://sniffnet.net/sitemap.xml
   ```
2. Add Article JSON-LD to `_layouts/post.html` (inside `<head>` or just before `</article>`):
   ```liquid
   <script type="application/ld+json">
   {
     "@context": "https://schema.org",
     "@type": "BlogPosting",
     "headline": "{{ page.title | strip_html | xml_escape }}",
     "image": "{{ page.thumbnail-img | absolute_url }}",
     "datePublished": "{{ page.date | date_to_xmlschema }}",
     "author": { "@type": "Person", "name": "{{ site.author }}" },
     "publisher": { "@type": "Organization", "name": "Sniffnet" }
   }
   </script>
   ```
3. Add `SoftwareApplication` JSON-LD to `_layouts/home.md` — Sniffnet is the product the homepage describes.
4. Verify with Google's Rich Results Test (https://search.google.com/test/rich-results).

**Success criteria.** `sitemap.xml` lists every page/post. `robots.txt` exists and references the sitemap. Posts pass Google's Rich Results Test as `Article`.

---

## 4. JS bundle — assess jQuery / Bootstrap dependency

**Why it matters.** The site loads jQuery 3.5.1 slim, Bootstrap 4.4.1 JS, and Popper.js — all to support a few interactions (navbar collapse, dropdown menu, scroll-based navbar shrink, search overlay). For a static site that's a lot of weight.

**Where to look.**
- `_layouts/base.html:11-16` — the three external JS dependencies.
- `assets/js/sniffnet.js` — the actual site logic (after the audit cleanup, ~70 lines).

**What sniffnet.js uses jQuery for.**
- `$(window).scroll(...)` — vanilla `window.addEventListener('scroll', ...)` replacement is trivial.
- `$('#main-navbar').on('show.bs.collapse', ...)` — this IS the Bootstrap event. Replacement requires either keeping Bootstrap's collapse JS or rewriting the mobile menu toggle in vanilla JS.
- `$('.navbar').css(...)` / `addClass` / `removeClass` — `element.classList.add/remove` is the vanilla replacement.

**Concrete steps.**
1. Rewrite `assets/js/sniffnet.js` in vanilla JS (~100 lines, no jQuery). This is straightforward; the file is small.
2. The harder question: can you drop Bootstrap entirely? The site uses:
   - Bootstrap grid (`container-md`, `row`, `col-xl-8`, etc.) — used heavily, would need CSS replacement (Grid/Flexbox).
   - `.navbar` / `.navbar-toggler` / `.collapse` — needs custom implementation.
   - `.pagination` / `.page-link` — used by the back-to-home button and post navigation. Easy to replicate.
   - `.list-inline` / `.list-inline-item` — used in footer.
3. Realistic path: replace jQuery (easy win), keep Bootstrap CSS for the grid + nav for now, drop Bootstrap JS (you only need collapse).

**Success criteria.** First-paint JS payload drops by ≥80 KB (jQuery slim is ~24 KB minified, Bootstrap JS ~50 KB, Popper ~20 KB). Site behaves identically.

---

## 5. Self-host third-party assets

**Why it matters.** The site currently depends on multiple external CDNs. Any one going down breaks the site. Tracker concerns aside, this is a reliability issue.

**Where to look (`_layouts/base.html`).**
- `https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css`
- `https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js`
- `https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.12.1/css/all.min.css`
- `https://fonts.googleapis.com/css?family=Lora:400,700`
- `https://fonts.googleapis.com/css?family=Open+Sans:300,400,800`
- `https://code.jquery.com/jquery-3.5.1.slim.min.js`
- `https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js`

**Concrete steps.**
1. Download each asset, drop into `assets/vendor/`. Add `assets/vendor/` to git.
2. Update `_layouts/base.html` to reference local paths.
3. Remove SRI hashes (they were for CDN integrity verification).
4. For Font Awesome 5: it's ~70 KB of icons; consider switching to a subset generator (e.g. only `fa-tag`, `fa-arrow-left`, `fa-arrow-right`, `fa-home`, `fa-search`, `fa-bullhorn`, `fa-calendar-day` — that's 7 icons of the hundreds shipped). Could use `fontawesome-subsetter` or hand-pick SVGs.
5. For Google Fonts: download the woff2 files (3 weights of Open Sans, 2 of Lora — already trimmed in audit), self-host with `@font-face`. Saves the cookie-laden Google Fonts request.

**Success criteria.** Zero external network requests on page load (except the GitHub stars/downloads badges, which are dynamic). Site renders correctly offline.

---

## 6. Mobile viewport check

**Why it matters.** Responsive CSS rules exist throughout `sniffnet.css` (lots of `@media (max-width: ...)` blocks), but the audit didn't actually load the site on real mobile viewports to confirm everything renders correctly.

**Concrete steps.**
1. `bundle exec jekyll serve`, open in browser, use DevTools device emulator.
2. Test at 320 px, 375 px, 414 px, 768 px breakpoints.
3. Pages to check: home, news listing (news cards stack at <600 px — confirm), individual post, gallery, download, sponsor, 404.
4. Things to watch:
   - News-card grid collapse at <600 px (CSS rule exists).
   - Navbar burger menu functions correctly.
   - Anniversary banner `<details>` expand on tap.
   - Gallery images don't overflow horizontally.
   - Footer doesn't break layout.
   - Tag pills wrap correctly when many tags.
5. Document any visual breakage as sub-items.

**Success criteria.** No horizontal scroll on any page at 320 px. All interactive elements tappable (≥44×44 px hit area). Text readable without zoom.

---

## 7. Bootstrap 4 → 5 migration (low priority)

**Why it matters.** Bootstrap 4.4.1 is end-of-life; Bootstrap 5.x dropped jQuery dependency and uses CSS custom properties. Not urgent — 4.x still works — but eventually:

**What changes between 4 → 5.**
- `data-toggle` → `data-bs-toggle` (and same for `target`, `dismiss`, etc.).
- `.ml-auto` → `.ms-auto` (margin-start instead of left).
- `.no-gutters` → `.g-0`.
- Some color names changed.
- Bootstrap 5 drops jQuery (good — pairs with item 4).

**Where to look.**
- All `data-toggle`, `data-target` attributes in `_includes/header.html`, `_includes/nav.html`, `_layouts/post.html`.
- All `.ml-auto` / `.mr-auto` instances.
- `_layouts/base.html` — version bump in the CDN URLs.

**Concrete steps.** Out of scope for a single session; do it after item 4 (kill jQuery first).

---

## 8. Content review

**Why it matters.** Audit was code-focused, not content-focused. Posts (25 of them) and the prose on `index.html`, `download.html`, `sponsor.html`, `gallery.html` haven't been read for:
- Typos / grammar.
- Dead external links (some posts link to GitHub PRs/issues or external articles that may have rotted).
- Outdated info (version numbers, feature lists).

**Concrete steps.**
1. Run a link checker: `bundle exec htmlproofer ./_site --disable-external false`. (htmlproofer is a Ruby gem; add to Gemfile.)
2. Read each post chronologically; flag anything that references "coming soon" features that have now shipped.
3. Run a spellcheck on every `.md` and `.html` file. `aspell` or `cspell`.

---

## Already done in the 2026-05-14 session

For reference so the next session doesn't redo work:

1. ✅ Duplicate IDs (`myQuote`, `myShadow`, `pinkBG`) → classes site-wide, CSS updated.
2. ✅ `rel="noopener"` added to every `target="_blank"` (32 files including all posts).
3. ✅ Favicon switched from GitHub raw URL to local `/favicon.ico`.
4. ✅ Dead `feed_show_tags` test removed from `news/index.html`.
5. ✅ Whimsical iframe given `title="Sniffnet visual roadmap"`.
6. ✅ JS comment typo — block deleted entirely (was inside the big-image feature).
7. ✅ Gallery images given explicit `width="1280" height="800"` + responsive style — prevents CLS.
8. ✅ Downloads badge given `alt="Total downloads"`.
9. ✅ Old feed CSS cluster removed (~120 lines: `.posts-list`, `.post-preview*`, `.post-meta`).
10. ✅ `_includes/readtime.html` deleted, conditional removed from `_includes/header.html`.
11. ✅ `_layouts/default.html` deleted (no page referenced it).
12. ✅ Notification-box CSS removed (`.box-note/.box-warning/.box-error/.box-success`).
13. ✅ Big-image header feature completely removed: ~130 lines of CSS + ~65 lines of JS.
14. ✅ `cover-img` feature completely removed (head.html, header.html, news/index.html).
15. ✅ Beautiful-jekyll dead Liquid branches removed: `page.full-width`, `page.before-content`, `page.after-content`, `page.head-extra`, `page.ext-css`, `page.css`, `page.nav-short`, `site.navbar-extra`, `site.title-img`, `page.show-avatar`.
16. ✅ Google Fonts trimmed: Open Sans 10 → 3 weights, Lora 4 → 2 weights.
17. ✅ `_config.yml`: unused `footer-text-col` removed.
18. ✅ Unreferenced asset files deleted: `assets/img/public-sponsor.png`, `open-source.png`, `reddit.svg`. Commented `<!-- reddit ... -->` line removed from `_includes/my-socials.html`.
19. ✅ `_includes/footer.html` — `class="list-inline"` → `class="list-inline-item"` on the middle `<li>`.
20. ✅ Post front-matter dedup: `share-img` removed from all 25 posts (was always identical to `thumbnail-img`); OG image still resolves identically via fallback chain.

**Intentionally not changed:**
- `sponsor.html` pink `<hr>` inline override — matches the page's pink theme.
- `align="center"` attribute (HTML4 obsolete) — used site-wide as a convention; the user has explicitly chosen to keep it.
- `title-img` commented-out line in `_config.yml` — instructive comment for users.

**Build status at end of session.** `bundle exec jekyll build --quiet` clean (only the ruby logger deprecation warning, unrelated to the site).
