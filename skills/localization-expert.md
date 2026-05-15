# Localization & Internationalization Expert Skill

## Objective
Implement and maintain a robust multi-language system supporting 20+ languages using standard Flutter tools (`intl`, `l10n`).

## Strategy
1. **Infrastructure**: Setup `l10n.yaml` and ARB files in `lib/l10n`.
2. **Key Selection**: Use descriptive, hierarchical keys (e.g., `error_init_title`, `home_vitals_heart_rate`).
3. **Pluralization & Placeholders**: Ensure the system handles complex grammatical cases and dynamic values.
4. **Dynamic Language Switching**: Integrate with state management (Cubit/Bloc) to allow real-time language changes.
5. **Quality Assurance**: Verify RTL (Right-to-Left) support for languages like Arabic and Urdu.

## Target Languages (Top 20)
- English (en), Mandarin (zh), Hindi (hi), Spanish (es), French (fr), Arabic (ar), Bengali (bn), Portuguese (pt), Russian (ru), Urdu (ur), Indonesian (id), German (de), Japanese (ja), Nigerian Pidgin (pcm), Marathi (mr), Telugu (te), Turkish (tr), Tamil (ta), Cantonese (yue), Vietnamese (vi).
