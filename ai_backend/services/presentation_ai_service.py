from services.search_service import search_chunks
from services.llm_service import ask


def generate_slide_content(course_id: str, topic: str):
    chunks = search_chunks(topic, course_id, limit=8)

    if not chunks:
        return None

    context = "\n\n".join(
        chunk["chunk_text"] for chunk in chunks
    )

    prompt = f"""
You are an expert university instructor.

Using ONLY the learning material below, create a PowerPoint presentation.

Rules:
- Generate 6 slides.
- Each slide must have:
  Slide Title:
  Bullet Points:
- Maximum 5 bullet points per slide.
- Keep bullets short.
- Do not invent information.

Learning Material:
{context}

Topic:
{topic}
"""

    return ask(prompt)