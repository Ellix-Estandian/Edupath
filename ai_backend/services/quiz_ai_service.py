from services.search_service import search_chunks
from services.llm_service import ask


def generate_quiz(course_id: str, topic: str, num_questions: int = 5):
    chunks = search_chunks(topic, course_id)

    if not chunks:
        return "[]"

    context = "\n\n".join(
        chunk["chunk_text"]
        for chunk in chunks
    )

    prompt = f"""
You are EduPath AI.

Using ONLY the learning materials below, generate exactly {num_questions} multiple-choice questions.

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
    "answer": "A"
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