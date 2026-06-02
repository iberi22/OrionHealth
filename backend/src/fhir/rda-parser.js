/**
 * RDA Parser for IHCE Colombia
 * Maps FHIR Composition/Bundle to a simplified Digital Health Summary
 */
class RdaParser {
  static parse(fhirBundle) {
    if (!fhirBundle || fhirBundle.resourceType !== 'Bundle') {
      // It might be a single Composition resource
      if (fhirBundle && fhirBundle.resourceType === 'Composition') {
        return this._parseComposition(fhirBundle);
      }
      return null;
    }

    const composition = fhirBundle.entry?.find(e => e.resource?.resourceType === 'Composition')?.resource;
    if (!composition) return null;

    return this._parseComposition(composition, fhirBundle);
  }

  static _parseComposition(composition, bundle = null) {
    const summary = {
      id: composition.id,
      date: composition.date,
      title: composition.title,
      status: composition.status,
      patient: this._resolveReference(composition.subject, bundle),
      author: this._resolveReference(composition.author?.[0], bundle),
      sections: []
    };

    if (composition.section) {
      summary.sections = composition.section.map(section => ({
        title: section.title,
        code: section.code?.coding?.[0]?.code,
        text: section.text?.div,
        entries: section.entry?.map(ref => this._resolveReference(ref, bundle)) || []
      }));
    }

    return summary;
  }

  static _resolveReference(reference, bundle) {
    if (!reference || !reference.reference) return reference;
    if (!bundle) return reference;

    const fullUrl = reference.reference;
    const resourceId = fullUrl.split('/').pop();

    const entry = bundle.entry?.find(e => {
      const res = e.resource;
      return e.fullUrl === fullUrl || (res && res.resourceType + '/' + res.id === fullUrl) || (res && res.id === resourceId);
    });

    return entry ? entry.resource : reference;
  }
}

module.exports = { RdaParser };
