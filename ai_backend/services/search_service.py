from services.embedding_service import create_embedding
from services.supabase_service import supabase


def search_chunks(question: str, course_id: str, limit: int = 5):
    print("Question:", question)
    print("Course ID:", course_id)

    embedding = create_embedding(question)

    print("Embedding dimensions:", len(embedding))

    response = supabase.rpc(
        "match_document_chunks",
        {
            "query_embedding": embedding,
            "course_id_param": course_id,
            "match_count": limit,
        },
    ).execute()

    print("Search results:", response.data)

    return response.data
