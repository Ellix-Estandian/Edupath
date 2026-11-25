from docx import Document
from docx.shared import Pt


def export_exam_to_docx(exam: str, output_file: str, title_text: str = "EduPath AI Generated Examination"):
    document = Document()

    title = document.add_heading(
        title_text,
        level=1,
    )

    title.style.font.size = Pt(20)

    for line in exam.split("\n"):
        document.add_paragraph(line)

    document.save(output_file)
