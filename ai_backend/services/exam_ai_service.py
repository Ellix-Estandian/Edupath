from services.search_service import search_chunks
from services.llm_service import ask


def generate_exam(
    course_id: str,
    topic: str,
    mcq: int,
    tf: int,
    identification: int,
    essay: int,
    difficulty: str,
):
    chunks = search_chunks(topic, course_id)

    if not chunks:
        return "No learning materials found."

    context = "\n\n".join(
        chunk["chunk_text"]
        for chunk in chunks
    )

    prompt = f"""
You are EduPath AI.

Generate an examination using ONLY the learning materials.

Difficulty:
{difficulty}

Requirements

Part I
{mcq} Multiple Choice Questions
- Four choices each
- Include answer key

Part II
{tf} True or False Questions
- Include answer key

Part III
{identification} Identification Questions
- Include answer key

Part IV
{essay} Essay Questions

Return ONLY the examination.

Context
--------------------
{context}
--------------------
"""

    return ask(prompt)