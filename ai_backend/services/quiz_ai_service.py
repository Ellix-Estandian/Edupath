from services.search_service import search_chunks
from services.llm_service import ask


def generate_quiz(
    course_id: str,
    topic: str,
    num_questions: int = 5,
    cognitive_level: str = "Balanced",
    material_id: str | None = None,
    learning_objective: str | None = None,
):
    chunks = search_chunks(topic, course_id)

    if material_id:
        selected_chunks = [chunk for chunk in chunks if chunk.get("material_id") == material_id]
        if selected_chunks:
            chunks = selected_chunks

    if not chunks:
        return "[]"

    context = "\n\n".join(
        chunk["chunk_text"]
        for chunk in chunks
    )

    prompt = f"""
You are EduPath AI.

Using ONLY the learning materials below, generate exactly {num_questions} multiple-choice questions.

Cognitive-level target: {cognitive_level}
- LOS (Lower-Order Skills): use recall, comprehension, and direct application.
- HOS (Higher-Order Skills): use realistic scenarios that require analysis, evaluation, or problem solving. Do not ask students merely to recall a fact.
- Balanced: create an even mix of LOS and HOS questions (as close as possible when the total is odd).
- Add a "cognitive_level" field to every question containing either "LOS" or "HOS", and ensure it matches the target above.

Learning objective: {learning_objective or 'Assess the selected topic.'}

Return ONLY valid JSON.

The JSON format must be:

[
  {{
    "question": "...",
    "choices": {{
      "A": "...",
      "B": "...",
      "C": "...",
      "D": "..."
    }},
    "answer": "A",
    "cognitive_level": "LOS"
  }}
]

Rules:
- Do NOT write explanations.
- Do NOT use markdown.
- Do NOT wrap in ```json.
- Return ONLY JSON.
- Generate exactly {num_questions} questions.

Context:
----------------
{context}
----------------
"""
    return ask(prompt)
