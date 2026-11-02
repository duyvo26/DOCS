import yaml
import subprocess
from pathlib import Path

# Configuration
SKILLS_REPO_URL = "https://github.com/vibeforge1111/vibeship-spawner-skills.git"
SKILLS_DIR = Path("vibeship-skills")
AGENT_SKILLS_DIR = Path("skills")

SKILL_TEMPLATE_STR = """---
name: {skill_id}
description: {description}Use when "{triggers_and_tags}" mentioned. 
---

# {skill_name}

## Identity

{identity}

## Reference System Usage

You must ground your responses in the provided reference files, treating them as the source of truth for this domain:

* **For Creation:** Always consult **`references/patterns.md`**. This file dictates *how* things should be built. Ignore generic approaches if a specific pattern exists here.
* **For Diagnosis:** Always consult **`references/sharp_edges.md`**. This file lists the critical failures and "why" they happen. Use it to explain risks to the user.
* **For Review:** Always consult **`references/validations.md`**. This contains the strict rules and constraints. Use it to validate user inputs objectively.

**Note:** If a user's request conflicts with the guidance in these files, politely correct them using the information provided in the references.
"""

def setup_skills_repo():
    """Clones the Vibeship skills repo if it doesn't exist."""
    if not SKILLS_DIR.exists():
        print("First time setup: Cloning Vibeship skills repository...")
        subprocess.run(["git", "clone", SKILLS_REPO_URL, str(SKILLS_DIR)], check=True)
        print("Repository cloned.")

def load_yaml_safe(path):
    with open(path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f.read())
        
def generate_skill_markdown(skill_data):
    """Generates the content for SKILL.md."""
    
    skill_id = skill_data.get("id", skill_data.get("skill_id", ""))
    skill_name = skill_id.replace("-", " ").title()
    description = skill_data['description'].replace("\n", " ")
    triggers_str = ", ".join(skill_data.get('triggers', []))
    tags_str = ", ".join(skill_data.get('tags', []))
    triggers_and_tags = triggers_str + ", " + tags_str

    if "identity" in skill_data:
        new_line = "\n"
        if isinstance(skill_data["identity"], str):
            identity = skill_data['identity']
        elif isinstance(skill_data["identity"], dict):
            identity = "\n".join(
                f"\n**{k.replace('_', ' ').title()}**: {(new_line + '- ' + (new_line+'- ').join(map(str, v))) if isinstance(v, list) else (new_line + v) if str(v).strip().startswith('-') else v}"
                for k, v in skill_data["identity"].items()
            )
        else:
            print("Not string or dict identity field!")
    else:
        identity = ""

    if "expertise" in skill_data:
        identity += "\n\n### Expertise\n\n" + "\n\n".join([f"- {k.replace('_', ' ').title()}: \n{new_line.join('  - ' + e for e in v)}" for k, v in skill_data['expertise'].items()])

    if "principles" in skill_data:
        identity += "\n\n### Principles\n\n" + "\n".join([f"- {e}" for e in skill_data['principles']])

    md = SKILL_TEMPLATE_STR.format(
        skill_id=skill_id,
        skill_name=skill_name,
        description=description,
        identity=identity,
        triggers_and_tags=triggers_and_tags,
    )

    return md

def create_patterns_markdown(skill_data):
    md = f"# {skill_data['name']}\n\n"
    if 'patterns' in skill_data:
        md += "## Patterns\n\n" + yaml_to_md(skill_data['patterns'])

    if 'anti_patterns' in skill_data:
        md += "\n\n## Anti-Patterns\n\n" + yaml_to_md(skill_data['anti_patterns'])
    
    return md

def create_validations_markdown(validation_data, skill_name):
    md = f"# {skill_name.replace('-', ' ').title()} - Validations"
    if 'validations' in validation_data:
        for validation in validation_data['validations']:
            if isinstance(validation, dict):
                if 'name' in validation:
                    validation_name = validation.pop('name')
                else:
                    validation_name = validation['id'].replace('-', ' ').title()
                md += f"\n\n## {validation_name}\n\n" + yaml_to_md(validation)
            elif isinstance(validation, str):
                md += f"\n\n## {validation.replace('_', ' ').title()}\n\n" + yaml_to_md(validation_data['validations'][validation])
            else:
                raise ValueError(f"Invalid validation: {validation}")
    
    return md

def create_sharp_edges_markdown(sharp_edges_data, skill_name):
    md = f"# {skill_name.replace('-', ' ').title()} - Sharp Edges"
    if 'sharp_edges' in sharp_edges_data:
        for sharp_edge in sharp_edges_data['sharp_edges']:
            if isinstance(sharp_edge, dict):
                if 'title' in sharp_edge:
                    sharp_edge_name = sharp_edge.pop('title')
                else:
                    sharp_edge_name = sharp_edge['id'].replace('-', ' ').title()
                md += f"\n\n## {sharp_edge_name}\n\n" + yaml_to_md(sharp_edge)
    
    return md

def yaml_to_md(yaml_obj, level=0):
    result = ""
    new_line = "\n"
    if yaml_obj is None:
        result = ""
    if isinstance(yaml_obj, str):
        if "\n" in yaml_obj:
            result += "  "*level + yaml_obj.replace('\n', '\n'+'  '*level).strip('\n')
        else:
            result += yaml_obj
    if isinstance(yaml_obj, list):
        result += "\n".join([f"{'  '*level}{new_line+'---'+new_line if len(yaml_obj) > 0 and isinstance(yaml_obj[0], dict) else '- '}{yaml_to_md(e, level + 1)}" for e in yaml_obj])
    if isinstance(yaml_obj, dict):
        result += "\n".join([f"{'  '*level}{'#'*(level+3)} **{str(k).replace('_', ' ').title()}**\n{yaml_to_md(v, level + 1)}" for k, v in yaml_obj.items()])
    return result

def convert_skill(category, skill_name):
    """Converts a Vibeship skill to Antigravity SKILL.md"""
    source_dir = SKILLS_DIR / category / skill_name
    target_dir = AGENT_SKILLS_DIR / skill_name
    reference_dir = target_dir / "references"
    
    if not source_dir.exists():
        print(f"Error: Skill not found at {source_dir}")
        return

    print(f"Converting {category}/{skill_name}...")
    
    skill_yaml = load_yaml_safe(source_dir / "skill.yaml")
    validations_yaml = load_yaml_safe(source_dir / "validations.yaml")
    sharp_edges_yaml = load_yaml_safe(source_dir / "sharp-edges.yaml")

    skill_md_content = generate_skill_markdown(skill_yaml)

    target_dir.mkdir(parents=True, exist_ok=True)
    reference_dir.mkdir(parents=True, exist_ok=True)

    (target_dir / "SKILL.md").write_text(skill_md_content, encoding="utf-8")

    patterns_md_content = create_patterns_markdown(skill_yaml)
    if patterns_md_content.strip() != "":
        (reference_dir / "patterns.md").write_text(patterns_md_content, encoding="utf-8")
        print(f"Success: Skill spawned at {target_dir / 'SKILL.md'} and {reference_dir / 'patterns.md'}")
    else:
        print(f"Success: Skill spawned at {target_dir / 'SKILL.md'}")

    validations_md_content = create_validations_markdown(validations_yaml, skill_name)
    (reference_dir / "validations.md").write_text(validations_md_content, encoding="utf-8")
    
    sharp_edges_md_content = create_sharp_edges_markdown(sharp_edges_yaml, skill_name)
    (reference_dir / "sharp_edges.md").write_text(sharp_edges_md_content, encoding="utf-8")

def main():
    errors = {}
    for category in SKILLS_DIR.iterdir():
        if category.is_dir() and not category.name.startswith("."):
            for skill in category.iterdir():
                if skill.is_dir() and (skill / "skill.yaml").exists():
                    if category.name == "ai-tools" and skill.name == "marketing":
                        print(f"Skipping {category.name}/{skill.name}")
                        continue
                    if category.name == "ai-tools" and skill.name == "analytics":
                        print(f"Skipping {category.name}/{skill.name}")
                        continue
                    try:
                        convert_skill(category.name, skill.name)
                    except Exception as e:
                        errors[f"{category.name}/{skill.name}"] = e
    
    print("\nErrors:")
    for skill, error in errors.items():
        try:
            print(f"- {skill}: {str(error)}")
        except UnicodeEncodeError:
            print(f"- {skill}: {str(error).encode('ascii', 'replace').decode('ascii')}")
    
    with open("errors.md", "w") as f:
        for skill, error in errors.items():
            f.write(f"\n**{skill}:**\n- {error}\n")
        
if __name__ == "__main__":
    main()
