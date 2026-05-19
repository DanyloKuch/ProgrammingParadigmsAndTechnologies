"""Generate Word reports for Task 2 (Haskell + Prolog) from a common template."""
from docx import Document
from docx.shared import Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH

PROBLEM = (
    "Розбити заданий список на кілька підсписків, записуючи, за можливості, "
    "у перший і останній по 1¹ елементів, потім у другий і передостанній "
    "по 2² елементів, і т.д. Розміри підсписків: 1, 1, 4, 4, 27, 27, … "
    "(беремо з початку і кінця по черзі)."
)

TESTS = [
    {
        "title": "Тест 1. Базовий випадок",
        "purpose": "Перевірити основну логіку симетричного розбиття списку.",
        "input": "[1..10]",
        "expected": "[[1],[2,3,4,5],[6,7,8,9],[10]]",
        "explanation": "1 з початку, 1 з кінця, 4 з початку, 4 з кінця.",
    },
    {
        "title": "Тест 2. Список із двох елементів",
        "purpose": "Перевірити граничний випадок, коли список менший за 2×k.",
        "input": "[7,9]",
        "expected": "[[7,9]]",
        "explanation": "Len=2 < 2×1=2 хибне, але вже на наступному кроці залишок не ділиться — весь список одним підсписком.",
    },
    {
        "title": "Тест 3. Великий список [1..60]",
        "purpose": "Перевірити розбиття, коли наступний чанк перевищує залишок.",
        "input": "[1..60]",
        "expected": "[[1],[2,3,4,5],[6,7,8,9],[10..59],[60]] — після 1,1,4,4 решта єдиним блоком",
        "explanation": "Після 1,1,4,4 залишається 50 елементів; k=27, 50 < 54 — кладемо все разом.",
    },
    {
        "title": "Тест 4. Порожній список",
        "purpose": "Перевірити стійкість при порожньому введенні.",
        "input": "[]",
        "expected": "[]",
        "explanation": "Базовий випадок — повертаємо порожній список одразу.",
    },
    {
        "title": "Тест 5. Список із одного елемента",
        "purpose": "Перевірити обробку списку, меншого за мінімальний чанк.",
        "input": "[99]",
        "expected": "[[99]]",
        "explanation": "Len=1 < 2×1=2 — весь список кладеться в єдиний підсписок.",
    },
]

REPO = "https://github.com/DanyloKuch/ProgrammingParadigmsAndTechnologies"


def add_centered(doc, text, *, bold=False, size=14):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run(text)
    run.bold = bold
    run.font.size = Pt(size)
    run.font.name = "Times New Roman"
    return p


def add_body(doc, text, *, bold=False, size=12, align=WD_ALIGN_PARAGRAPH.JUSTIFY):
    p = doc.add_paragraph()
    p.alignment = align
    run = p.add_run(text)
    run.bold = bold
    run.font.size = Pt(size)
    run.font.name = "Times New Roman"
    return p


def add_code_block(doc, code):
    for line in code.splitlines() or [""]:
        p = doc.add_paragraph()
        p.paragraph_format.space_after = Pt(0)
        p.paragraph_format.space_before = Pt(0)
        run = p.add_run(line if line else " ")
        run.font.size = Pt(9)
        run.font.name = "Consolas"


def build_report(language: str, source_file: str, branch: str, code: str, out_path: str):
    doc = Document()

    for section in doc.sections:
        section.top_margin = Cm(2)
        section.bottom_margin = Cm(2)
        section.left_margin = Cm(2.5)
        section.right_margin = Cm(1.5)

    add_centered(doc, "ЗВІТ", bold=True, size=20)
    add_centered(doc, f"ЗАДАЧА 2 ({language}), Варіант 16", bold=True, size=16)
    add_centered(doc, "Парадигми та технології програмування", size=14)

    for _ in range(2):
        doc.add_paragraph()

    add_centered(doc, "Виконав", size=12)
    add_centered(doc, "Студент 3 курсу", size=12)
    add_centered(doc, "Групи ТТП-31", size=12)
    add_centered(doc, "Факультету комп'ютерних наук та кібернетики", size=12)
    add_centered(doc, "Кучерук Данило", bold=True, size=12)

    for _ in range(2):
        doc.add_paragraph()

    add_centered(doc, "Київ – 2025", size=12)

    doc.add_page_break()

    add_body(doc, "Умова:", bold=True, size=13, align=WD_ALIGN_PARAGRAPH.LEFT)
    add_body(doc, "Задача 2:", bold=True, size=12, align=WD_ALIGN_PARAGRAPH.LEFT)
    add_body(doc, PROBLEM)

    add_body(doc, "1. Код програми", bold=True, size=13, align=WD_ALIGN_PARAGRAPH.LEFT)
    add_body(doc, f"Файл: {source_file}", align=WD_ALIGN_PARAGRAPH.LEFT)
    add_code_block(doc, code)

    add_body(doc, "2. Тестування", bold=True, size=13, align=WD_ALIGN_PARAGRAPH.LEFT)
    for t in TESTS:
        add_body(doc, t["title"], bold=True, align=WD_ALIGN_PARAGRAPH.LEFT)
        add_body(doc, f"Мета тесту: {t['purpose']}", align=WD_ALIGN_PARAGRAPH.LEFT)
        add_body(doc, f"Вхідні дані: {t['input']}", align=WD_ALIGN_PARAGRAPH.LEFT)
        add_body(doc, f"Очікуваний результат: {t['expected']}", align=WD_ALIGN_PARAGRAPH.LEFT)
        add_body(doc, f"Пояснення: {t['explanation']}", align=WD_ALIGN_PARAGRAPH.LEFT)

    add_body(doc, "Додатки", bold=True, size=13, align=WD_ALIGN_PARAGRAPH.LEFT)
    add_body(doc, "Посилання на репозиторій GitHub з кодом програми:", align=WD_ALIGN_PARAGRAPH.LEFT)
    add_body(doc, f"{REPO}/tree/{branch}", align=WD_ALIGN_PARAGRAPH.LEFT)

    doc.save(out_path)
    print(f"Saved: {out_path}")


def main():
    with open("task2.hs", "r", encoding="utf-8") as f:
        hs_code = f.read()
    with open("task2.pl", "r", encoding="utf-8") as f:
        pl_code = f.read()

    build_report(
        language="Haskell",
        source_file="task2.hs",
        branch="branch-task2",
        code=hs_code,
        out_path="Haskell_2_Звіт_Кучерук_ТТП31.docx",
    )

    build_report(
        language="Prolog",
        source_file="task2.pl",
        branch="branch-task2-pl",
        code=pl_code,
        out_path="Prolog_2_Звіт_Кучерук_ТТП31.docx",
    )


if __name__ == "__main__":
    main()
