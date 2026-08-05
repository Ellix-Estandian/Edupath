import re


def parse_slides(text: str):
    slides = []

    sections = re.split(r"Slide\s+\d+", text)

    for section in sections:
        section = section.strip()

        if not section:
            continue

        lines = [
            line.strip()
            for line in section.splitlines()
            if line.strip()
        ]

        title = "Untitled"
        bullets = []

        for line in lines:
            lower = line.lower()

            if lower.startswith("title:"):
                title = line.split(":", 1)[1].strip()

            elif (
                line.startswith("-")
                or line.startswith("•")
                or line.startswith("*")
            ):
                bullets.append(
                    line.lstrip("-•* ").strip()
                )

        slides.append({
            "title": title,
            "bullets": bullets,
        })

    return slides