# Changelog

## [Unreleased]

### Changed

- **UI Framework**: Migrated from Tailwind CSS CDN to local installation using `@astrojs/tailwind`.
- **Configuration**: Moved Tailwind configuration from `BaseLayout.astro` to `tailwind.config.mjs`.
- **Performance**: Removed external script blocking and improved load times by bundling CSS.
- **Styles**: Ensured consistent application of the "Cyber-Minimalism" theme and Fira Code font.

### Fixed

- Fixed issue where UI styles were not loading due to CDN dependency.
