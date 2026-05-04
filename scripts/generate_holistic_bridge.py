import json
import os

def generate_bridge(file_path):
    if not os.path.exists(file_path):
        return

    with open(file_path, 'r', encoding='utf-8') as f:
        content = json.load(f)
    
    data_list = content.get("data", [])
    
    updated = 0
    categories_updated = 0
    
    for item in data_list:
        code = item["code"]
        
        # 1. Assign Categories based on ICD-10 sections
        if not item.get("category"):
            if code.startswith("A") or code.startswith("B"):
                item["category"] = "Infectious"
            elif code.startswith("C") or code.startswith("D"):
                item["category"] = "Oncology/Blood"
            elif code.startswith("E"):
                item["category"] = "Endocrine/Metabolic"
            elif code.startswith("F"):
                item["category"] = "Mental"
            elif code.startswith("G"):
                item["category"] = "Neurology"
            elif code.startswith("H"):
                item["category"] = "Sensory (Eyes/Ears)"
            elif code.startswith("I"):
                item["category"] = "Cardiovascular"
            elif code.startswith("J"):
                item["category"] = "Respiratory"
            elif code.startswith("K"):
                item["category"] = "Digestive"
            elif code.startswith("L"):
                item["category"] = "Dermatology"
            elif code.startswith("M"):
                item["category"] = "Musculoskeletal"
            elif code.startswith("N"):
                item["category"] = "Genitourinary"
            elif code.startswith("Q"):
                item["category"] = "Congenital"
            elif code.startswith("R"):
                item["category"] = "Symptoms/Findings"
            elif code.startswith("S") or code.startswith("T"):
                item["category"] = "Injury/Trauma"
            elif code.startswith("Z"):
                item["category"] = "Social/Factors"
            categories_updated += 1

        # 2. Holistic Bridge (Physical -> Mental)
        cat = item["category"]
        if cat == "Mental":
            if not item.get("physicalHealthImpact"):
                item["physicalHealthImpact"] = "Manifestación física: Alteraciones en el eje HPA, cambios en el cortisol, trastornos del sueño y riesgo de enfermedades psicosomáticas."
                updated += 1
        elif cat in ["Cardiovascular", "Oncology/Blood", "Endocrine/Metabolic"]:
            if not item.get("mentalHealthImpact"):
                item["mentalHealthImpact"] = f"Impacto mental: Riesgo elevado de ansiedad crónica y depresión reactiva debido a la carga de enfermedad crónica en {cat.lower()}."
                updated += 1
        elif cat == "Neurology":
            if not item.get("mentalHealthImpact"):
                item["mentalHealthImpact"] = "Impacto mental: Cambios neurocognitivos, fatiga mental y riesgo de labilidad emocional."
                updated += 1
        else:
            if not item.get("mentalHealthImpact") and cat:
                item["mentalHealthImpact"] = "Impacto mental: Estrés por enfermedad aguda y potencial ansiedad reactiva."
                updated += 1
    
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(content, f, indent=2, ensure_ascii=False)
    
    print(f"Updated {categories_updated} categories and {updated} holistic bridges in {file_path}")

if __name__ == "__main__":
    generate_bridge("medical-standards/icd10.json")
