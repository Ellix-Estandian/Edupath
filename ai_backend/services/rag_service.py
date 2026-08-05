import os
import tempfile
import requests

from services.supabase_service import supabase
from services.pdf_service import extract_text
from services.chunk_service import chunk_text
from services.embedding_service import create_embedding
from services.search_service import search_chunks
from services.llm_service import ask


def index_pdf(material_id: str, pdf_path: str):
    signed = supabase.storage.from_("learning-materials").create_signed_url(
        pdf_path,
        3600,
    )

    download_url = signed["signedURL"]

    response = requests.get(download_url)
    response.raise_for_status()

    with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as tmp:
        tmp.write(response.content)
        temp_path = tmp.name

    try:
        text = extract_text(temp_path)
        chunks = chunk_text(text)

        for chunk in chunks:
            embedding = create_embedding(chunk)

            supabase.table("document_chunks").insert({
                "material_id": material_id,
                "chunk_text": chunk,
                "embedding": embedding,
            }).execute()

        return len(chunks)

    finally:
        os.remove(temp_path)


def ask_rag(question: str, course_id: str):
    chunks = search_chunks(question, course_id)

    print("Chunks found:", len(chunks))

    if chunks:
        print(chunks[0]["chunk_text"][:200])

    if not chunks:
        return "I cannot find the answer in the uploaded learning materials."

    context = "\n\n".join(
        chunk["chunk_text"] for chunk in chunks
    )

    prompt = f"""
You are EduPath AI.

Answer ONLY using the learning materials below.

If the answer is not found, reply:
I cannot find the answer in the uploaded learning materials.

Context:
{context}

Question:
{question}

Answer:
"""

    return ask(prompt)