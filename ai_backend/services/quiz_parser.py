import re


def parse_quiz(text: str):
    questions = []

    pattern = r"Question\s+\d+:\s*(.*?)\nA\.\s*(.*?)\nB\.\s*(.*?)\nC\.\s*(.*?)\nD\.\s*(.*?)\nAnswer:\s*([ABCD])"

    matches = re.findall(pattern, text, re.DOTALL)

    for match in matches:
        question, a, b, c, d, answer = match

        questions.append({
            "question": question.strip(),
            "choices": {
                "A": a.strip(),
                "B": b.strip(),
                "C": c.strip(),
                "D": d.strip(),
            },
            "answer": answer.strip(),
        })

    return questions