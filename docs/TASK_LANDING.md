# TASK: Fix Landing Page & Build Data Visualization System

## Current State
The GitHub Pages site at https://iberi22.github.io/OrionHealth uses Astro + Tailwind CSS. 
The landing page styles are broken (Tailwind CSS base styles not applying correctly - `applyBaseStyles: false` causes missing utility classes).

## Issues to Fix

### 1. Tailwind CSS Not Loading Properly
- `astro.config.mjs` has `applyBaseStyles: false` which means Tailwind's base/normalize styles are missing
- The CSS relies on `style is:global` fallbacks in BaseLayout.astro which are incomplete
- Fix: Enable base styles or create a proper CSS import chain

### 2. Landing Page Styling
- Hero section may have missing responsive styles
- Trust badge, feature cards, and glass effects may not render correctly
- Verify all component styles apply

### 3. Data Visualization System (MOST IMPORTANT)
Create a completely OWN data visualization system for the OrionHealth project data.
This is NOT a generic charting library - it must be ORIGINAL, custom-built:

#### What to visualize:
- **Architecture Diagram**: Clean Architecture layers of OrionHealth (domain, application, infrastructure, presentation)
- **Features Map**: All 25 features with their status and layers
- **Medical Standards**: ICD-10 (278), LOINC (145), RxNorm (118), SNOMED CT (87) in interactive cards
- **Data Flow**: How data flows locally (Isar DB -> BLoC -> UI -> no cloud)
- **GitHub Stats**: Pull from GitHub API to show stars, open issues, contributors
- **Test Coverage**: Real-time badges showing test status (494 unit, 35 golden, 31 E2E, 159 PNG refs)
- **CI Status**: Show GitHub Actions build status

#### Design Principles:
1. **Original**: NO chart.js, NO recharts, NO D3 - write own SVG/Canvas visualization components
2. **Cyber-Minimalist**: Dark theme, emerald accent (#10B981), monospace font (Fira Code), glassmorphism
3. **Interactive**: Hover to explore, responsive, animations on scroll
4. **Human-focused**: Designed for humans to browse, not machines - readable, beautiful, informative
5. **Containerized**: Each visualization is a self-contained Astro component in `docs/src/components/`

#### Architecture Visualizations to Build:
1. `ArchitectureFlow.astro` - Interactive clean architecture layers diagram (SVG-based)
2. `FeatureGrid.astro` - 25 features displayed as a radial/dendrogram map with status
3. `MedicalStandardsViz.astro` - 4 medical standards in an interactive treasure/scatter chart
4. `DataPrivacyFlow.astro` - Flow diagram showing local-only data path
5. `TestCoverageDashboard.astro` - Custom donut/bar charts for test stats
6. `GitHubLiveStatus.astro` - Dashboard showing real-time GitHub stats
7. `TimelineViz.astro` - Development timeline/milestones visualization

### 4. New Landing Section
Add new section "Project Dashboard" between mission and screenshots that integrates:
- Architecture visualization
- Feature map
- Medical standards viz
- Test coverage stats
- GitHub status

### Files to modify/create:
- `docs/astro.config.mjs` - Fix tailwind config
- `docs/src/layouts/BaseLayout.astro` - Fix base CSS
- `docs/src/pages/index.astro` - Add dashboard section
- `docs/src/components/` - Each new visualization component
- `docs/src/pages/dashboard.astro` - Full dedicated dashboard page
- `docs/src/data/` - Static data files for project stats

## Init script if running headless
# cd docs && npm run build && npm run preview
