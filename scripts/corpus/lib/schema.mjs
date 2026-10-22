// Small JSON Schema checker (subset used by corpus/*.schema*.json). Zero dependencies.
const typeOf = (v) => (v === null ? 'null' : Array.isArray(v) ? 'array' : Number.isInteger(v) ? 'integer' : typeof v);
const isType = (v, t) => (t === 'number' ? typeof v === 'number' : t === 'integer' ? Number.isInteger(v) : typeOf(v) === t);
const isDate = (s) => /^\d{4}-\d{2}-\d{2}$/.test(s) && !Number.isNaN(Date.parse(`${s}T00:00:00Z`)) && new Date(`${s}T00:00:00Z`).toISOString().startsWith(s);
const isDateTime = (s) => /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?(Z|[+-]\d{2}:\d{2})$/.test(s) && !Number.isNaN(Date.parse(s));
const isUri = (s) => { try { new URL(s); return true; } catch { return false; } };

export function checkSchema(value, schema, path = '$', errs = [], root = schema) {
  if (schema.$ref) {
    const target = schema.$ref.replace(/^#\//, '').split('/').reduce((n, k) => n?.[k], root);
    if (!target) { errs.push(`${path}: unresolved $ref ${schema.$ref}`); return errs; }
    return checkSchema(value, target, path, errs, root);
  }
  if (schema.oneOf) {
    const ok = schema.oneOf.filter((sub) => checkSchema(value, sub, path, [], root).length === 0).length;
    if (ok !== 1) errs.push(`${path}: must match exactly one of oneOf (matched ${ok})`);
  }
  const err = (m) => errs.push(`${path}: ${m}`);
  if (schema.const !== undefined && JSON.stringify(value) !== JSON.stringify(schema.const)) err(`must equal ${JSON.stringify(schema.const)}`);
  if (schema.type) {
    const types = Array.isArray(schema.type) ? schema.type : [schema.type];
    if (!types.some((t) => isType(value, t))) { err(`expected ${types.join('|')}, got ${typeOf(value)}`); return errs; }
  }
  if (schema.enum && !schema.enum.some((e) => JSON.stringify(e) === JSON.stringify(value))) err(`not in enum [${schema.enum.join(', ')}]`);
  if (typeof value === 'string') {
    if (schema.minLength !== undefined && value.length < schema.minLength) err(`shorter than ${schema.minLength}`);
    if (schema.maxLength !== undefined && value.length > schema.maxLength) err(`longer than ${schema.maxLength}`);
    if (schema.pattern && !new RegExp(schema.pattern).test(value)) err(`does not match ${schema.pattern}`);
    if (schema.format === 'date' && !isDate(value)) err('invalid date');
    if (schema.format === 'date-time' && !isDateTime(value)) err('invalid date-time');
    if (schema.format === 'uri' && !isUri(value)) err('invalid uri');
  }
  if (typeof value === 'number') {
    if (schema.minimum !== undefined && value < schema.minimum) err(`below ${schema.minimum}`);
    if (schema.maximum !== undefined && value > schema.maximum) err(`above ${schema.maximum}`);
    if (schema.exclusiveMinimum !== undefined && value <= schema.exclusiveMinimum) err(`not above ${schema.exclusiveMinimum}`);
  }
  if (Array.isArray(value)) {
    if (schema.minItems !== undefined && value.length < schema.minItems) err(`fewer than ${schema.minItems} items`);
    if (schema.maxItems !== undefined && value.length > schema.maxItems) err(`more than ${schema.maxItems} items`);
  }
  if (Array.isArray(value) && schema.items) value.forEach((v, i) => checkSchema(v, schema.items, `${path}[${i}]`, errs, root));
  if (value && typeof value === 'object' && !Array.isArray(value)) {
    for (const k of schema.required ?? []) if (!(k in value)) errs.push(`${path}: missing required "${k}"`);
    const props = schema.properties ?? {};
    for (const [k, v] of Object.entries(value)) {
      if (schema.propertyNames?.enum && !schema.propertyNames.enum.includes(k)) errs.push(`${path}: property "${k}" not allowed`);
      if (schema.propertyNames?.pattern && !new RegExp(schema.propertyNames.pattern).test(k)) errs.push(`${path}: property "${k}" does not match ${schema.propertyNames.pattern}`);
      if (k in props) checkSchema(v, props[k], `${path}.${k}`, errs, root);
      else if (schema.additionalProperties === false) errs.push(`${path}: unexpected property "${k}"`);
      else if (schema.additionalProperties && typeof schema.additionalProperties === 'object') checkSchema(v, schema.additionalProperties, `${path}.${k}`, errs, root);
    }
  }
  return errs;
}

