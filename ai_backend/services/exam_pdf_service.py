from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import SimpleDocTemplate, Paragraph


def export_exam_to_pdf(exam: str, output_file: str):
    doc = SimpleDocTemplate(output_file)
    styles = getSampleStyleSheet()

    elements = []

    elements.append(
        Paragraph("<b>EduPath AI Generated Examination</b>", styles["Title"])
    )

    for line in exam.split("\n"):
        elements.append(Paragraph(line.replace(" ", "&nbsp;"), styles["BodyText"]))

    doc.build(elements)