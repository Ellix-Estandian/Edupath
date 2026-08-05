from services.supabase_service import supabase


def save_quiz(course_id: str, title: str, questions: list):
    # Create quiz
    quiz = (
        supabase.table("quizzes")
        .insert({
            "course_id": course_id,
            "title": title,
        })
        .execute()
    )

    quiz_id = quiz.data[0]["id"]

    # Save questions
    for q in questions:
        supabase.table("quiz_questions").insert({
            "quiz_id": quiz_id,
            "question": q["question"],
            "option_a": q["choices"]["A"],
            "option_b": q["choices"]["B"],
            "option_c": q["choices"]["C"],
            "option_d": q["choices"]["D"],
            "correct_answer": q["answer"],
        }).execute()

    return quiz_id