from fastapi import FastAPI  # type: ignore[import-not-found]
from services.llm_service import load_model
from services.llm_service import ask
from services.pdf_service import extract_text
from services.chunk_service import chunk_text
from services.embedding_service import create_embedding
from services.search_service import search_chunks
from services.rag_service import ask_rag
from services.rag_service import index_pdf
from pydantic import BaseModel
from services.presentation_service import create_presentation
from fastapi.responses import FileResponse
from services.presentation_ai_service import generate_slide_content
from services.slide_parser import parse_slides

app = FastAPI(title="EduPath AI Backend")


@app.on_event("startup")
def startup():
    load_model("models/Llama-3.2-3B-Instruct-Q4_K_M.gguf")
    print("✅ Llama model loaded.")


@app.get("/")
def root():
    return {
        "message": "EduPath AI Backend is running"
    }


@app.get("/health")
def health():
    return {
        "status": "ok"
    }

@app.get("/ask")
def ask_ai(question: str):
    answer = ask(question)

    return {
        "question": question,
        "answer": answer,
    }

@app.get("/test-chunks")
def test_chunks():

    text = extract_text("uploads/oop.pdf")

    chunks = chunk_text(text)

    return {
        "total_characters": len(text),
        "total_chunks": len(chunks),
        "first_chunk": chunks[0],
        "last_chunk": chunks[-1]
    }

@app.get("/test-embedding")
def test_embedding():

    vector = create_embedding(
        "Object-Oriented Programming"
    )

    return {
        "dimensions": len(vector),
        "preview": vector[:10]
    }

@app.get("/index-test")
def index_test():

    count = index_pdf(
        material_id="621b2271-389f-4e5f-831b-3686fe5dd67c",
        pdf_path="uploads/oop.pdf"
    )

    return {
        "chunks_saved": count
    }

@app.get("/search")
def search(question: str, course_id: str):
    return search_chunks(question, course_id)

@app.get("/rag")
def rag(question: str, course_id: str):
    return {
        "answer": ask_rag(question, course_id)
    }

class IndexRequest(BaseModel):
    material_id: str
    pdf_path: str


@app.post("/index-material")
def index_material(request: IndexRequest):
    count = index_pdf(
        material_id=request.material_id,
        pdf_path=request.pdf_path,
    )

    return {
        "success": True,
        "chunks_saved": count,
    }

@app.get("/presentation-test")
def presentation_test():
    file = create_presentation("Object-Oriented Programming")

    return FileResponse(
        file,
        media_type="application/vnd.openxmlformats-officedocument.presentationml.presentation",
        filename="presentation.pptx",
    )

@app.get("/presentation-content")
def presentation_content(course_id: str, topic: str):
    return {
        "slides": generate_slide_content(course_id, topic)
    }

@app.get("/generate-presentation")
def generate_presentation(course_id: str, topic: str):

    ai_text = generate_slide_content(
        course_id,
        topic,
    )

    slides = parse_slides(ai_text)

    output = "generated_presentation.pptx"

    create_presentation(
        slides,
        output,
    )

    return FileResponse(
        output,
        media_type="application/vnd.openxmlformats-officedocument.presentationml.presentation",
        filename="presentation.pptx",
    )