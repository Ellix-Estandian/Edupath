from services.search_service import search_chunks
from services.llm_service import ask


def generate_exam(
    course_id: str,
    topic: str,
    mcq: int,
    tf: int,
    identification: int,
    essay: int,
    parts: list[dict] | None = None,
):
    chunks = search_chunks(topic, course_id)

    selected_material_ids = {
        part.get("material_id") for part in (parts or []) if part.get("material_id")
    }
    if selected_material_ids:
        selected_chunks = [
            chunk for chunk in chunks if chunk.get("material_id") in selected_material_ids
        ]
        if selected_chunks:
            chunks = selected_chunks

    if not chunks:
        return "No learning materials found."

    context = "\n\n".join(
        chunk["chunk_text"]
        for chunk in chunks
    )

    prompt = f"""
You are EduPath AI.

Generate an examination using ONLY the learning materials.

Requirements
{_part_requirements(parts, mcq, tf, identification, essay)}

Return ONLY the examination.

Context
--------------------
{context}
--------------------
"""

    return ask(prompt)


def _part_requirements(parts, mcq, tf, identification, essay):
    """Build explicit per-section instructions with their learning objectives."""
    if not parts:
        parts = [
            {"type": "Multiple Choice", "count": mcq, "learning_objective": ""},
            {"type": "True / False", "count": tf, "learning_objective": ""},
            {"type": "Identification", "count": identification, "learning_objective": ""},
            {"type": "Essay", "count": essay, "learning_objective": ""},
        ]

    instructions = []
    for index, part in enumerate(parts, start=1):
        question_type = part.get("type", "Multiple Choice")
        count = max(0, int(part.get("count", 0)))
        objective = part.get("learning_objective", "").strip() or "Assess the selected topic."
        material_id = part.get("material_id")
        instructions.append(
            f"Part {index}: {count} {question_type} questions\n"
            f"- Learning objective: {objective}\n"
            + (f"- Connected learning material ID: {material_id}. Base this part on that material.\n" if material_id else "")
            + _question_type_instruction(question_type)
        )
    return "\n".join(instructions)


def _question_type_instruction(question_type):
    instructions = {
        "Multiple Choice": "- Use four choices and include an answer key.\n",
        "Matching Type": "- Provide two clearly labeled columns and an answer key.\n",
        "Fill in the Blank": "- Use one unambiguous blank per item and include answers.\n",
        "Enumeration": "- State the number of expected responses and include the expected answers.\n",
        "Problem Solving": "- Include all information needed to solve the problem and show the expected answer or solution.\n",
        "Case Analysis": "- Give a brief realistic case, then ask an analysis question and provide a model answer.\n",
        "Essay": "- Provide a concise scoring guide or key points.\n",
    }
    return instructions.get(question_type, "- Include an answer key where applicable.\n")
