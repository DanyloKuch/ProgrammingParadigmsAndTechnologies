"""Generate Word reports for tasks 2, 3, 4 (Haskell + Prolog).

Usage:
    python gen_reports.py            # generate all reports
    python gen_reports.py task3      # generate only task3 (both languages)
"""
import sys
from docx import Document
from docx.shared import Pt, Cm
from docx.enum.text import WD_ALIGN_PARAGRAPH


REPO = "https://github.com/DanyloKuch/ProgrammingParadigmsAndTechnologies"
BRANCH = "branch-task1a"


# --------------------------- docx helpers ---------------------------

def add_centered(doc, text, *, bold=False, size=14):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = p.add_run(text)
    r.bold = bold
    r.font.size = Pt(size)
    r.font.name = "Times New Roman"
    return p


def add_body(doc, text, *, bold=False, size=12, align=WD_ALIGN_PARAGRAPH.JUSTIFY):
    p = doc.add_paragraph()
    p.alignment = align
    r = p.add_run(text)
    r.bold = bold
    r.font.size = Pt(size)
    r.font.name = "Times New Roman"
    return p


def add_code_block(doc, code):
    for line in code.splitlines() or [""]:
        p = doc.add_paragraph()
        p.paragraph_format.space_after = Pt(0)
        p.paragraph_format.space_before = Pt(0)
        r = p.add_run(line if line else " ")
        r.font.size = Pt(9)
        r.font.name = "Consolas"


def add_section_heading(doc, text):
    add_body(doc, text, bold=True, size=13, align=WD_ALIGN_PARAGRAPH.LEFT)


def build_report(*, language, task_num, source_file, code, out_path,
                 problem_text, sections, tests, branch=BRANCH):
    """Generic report builder.

    sections:  list of (heading, [paragraphs]) extra sections inserted
               between the problem statement and the code listing
               (e.g. "Алгоритм" or "Граматика").
    tests:     list of dicts with keys
               title, purpose, input, expected, explanation.
    """
    doc = Document()
    for sec in doc.sections:
        sec.top_margin = Cm(2)
        sec.bottom_margin = Cm(2)
        sec.left_margin = Cm(2.5)
        sec.right_margin = Cm(1.5)

    # --- title page ---
    add_centered(doc, "ЗВІТ", bold=True, size=20)
    add_centered(doc, f"ЗАДАЧА {task_num} ({language}), Варіант 16",
                 bold=True, size=16)
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

    # --- problem statement ---
    add_body(doc, "Умова:", bold=True, size=13, align=WD_ALIGN_PARAGRAPH.LEFT)
    add_body(doc, f"Задача {task_num}:", bold=True, size=12,
             align=WD_ALIGN_PARAGRAPH.LEFT)
    add_body(doc, problem_text)

    # --- optional extra sections (algorithm, grammar, etc.) ---
    section_index = 1
    for heading, paragraphs in sections:
        add_section_heading(doc, f"{section_index}. {heading}")
        for para in paragraphs:
            if isinstance(para, tuple):
                kind, text = para
                if kind == "code":
                    add_code_block(doc, text)
                else:
                    add_body(doc, text, align=WD_ALIGN_PARAGRAPH.LEFT)
            else:
                add_body(doc, para, align=WD_ALIGN_PARAGRAPH.LEFT)
        section_index += 1

    # --- code listing ---
    add_section_heading(doc, f"{section_index}. Код програми")
    add_body(doc, f"Файл: {source_file}", align=WD_ALIGN_PARAGRAPH.LEFT)
    add_code_block(doc, code)
    section_index += 1

    # --- tests ---
    add_section_heading(doc, f"{section_index}. Тестування")
    for t in tests:
        add_body(doc, t["title"], bold=True, align=WD_ALIGN_PARAGRAPH.LEFT)
        add_body(doc, f"Мета тесту: {t['purpose']}",
                 align=WD_ALIGN_PARAGRAPH.LEFT)
        add_body(doc, f"Вхідні дані: {t['input']}",
                 align=WD_ALIGN_PARAGRAPH.LEFT)
        add_body(doc, f"Очікуваний результат: {t['expected']}",
                 align=WD_ALIGN_PARAGRAPH.LEFT)
        add_body(doc, f"Пояснення: {t['explanation']}",
                 align=WD_ALIGN_PARAGRAPH.LEFT)
    section_index += 1

    # --- appendix ---
    add_section_heading(doc, "Додатки")
    add_body(doc, "Посилання на репозиторій GitHub з кодом програми:",
             align=WD_ALIGN_PARAGRAPH.LEFT)
    add_body(doc, f"{REPO}/tree/{branch}",
             align=WD_ALIGN_PARAGRAPH.LEFT)

    doc.save(out_path)
    print(f"Saved: {out_path}")


# --------------------------- task 2 content ---------------------------

TASK2_PROBLEM = (
    "Розбити заданий список на кілька підсписків, записуючи, за можливості, "
    "у перший і останній по 1¹ елементів, потім у другий і передостанній "
    "по 2² елементів, і т.д. Розміри підсписків: 1, 1, 4, 4, 27, 27, … "
    "(беремо з початку і кінця по черзі)."
)

TASK2_TESTS = [
    {
        "title": "Тест 1. Базовий випадок",
        "purpose": "Перевірити основну логіку симетричного розбиття списку.",
        "input": "[1..10]",
        "expected": "[[1],[2,3,4,5],[6,7,8,9],[10]]",
        "explanation": "1 з початку, 1 з кінця, 4 з початку, 4 з кінця.",
    },
    {
        "title": "Тест 2. Список із двох елементів",
        "purpose": "Перевірити граничний випадок.",
        "input": "[7,9]",
        "expected": "[[7,9]]",
        "explanation": "Len=2 < 2×1 — весь список залишаємо одним підсписком.",
    },
    {
        "title": "Тест 3. Великий список [1..60]",
        "purpose": "Перевірити розбиття, коли наступний чанк перевищує залишок.",
        "input": "[1..60]",
        "expected": "[[1],[2,3,4,5],[6,7,8,9],[10..59],[60]]",
        "explanation": "Після 1,1,4,4 залишається 50 елементів; k=27, 50 < 54 — кладемо все разом.",
    },
    {
        "title": "Тест 4. Порожній список",
        "purpose": "Перевірити стійкість при порожньому введенні.",
        "input": "[]",
        "expected": "[]",
        "explanation": "Базовий випадок — повертаємо порожній список.",
    },
    {
        "title": "Тест 5. Список із одного елемента",
        "purpose": "Перевірити обробку списку, меншого за мінімальний чанк.",
        "input": "[99]",
        "expected": "[[99]]",
        "explanation": "Len=1 < 2 — весь список кладеться в єдиний підсписок.",
    },
]

TASK2_SECTIONS = []


# --------------------------- task 3 content ---------------------------

TASK3_PROBLEM = (
    "Для заданих слів v і w виявити, чи допускає скінчений автомат хоча б "
    "одне слово, що може бути подане у вигляді xvxw для деякого слова x. "
    "При ствердній відповіді навести приклад відповідного слова xvxw."
)

TASK3_ALGORITHM = [
    "Розглядаємо скінчений детермінований автомат M = (Q, Σ, δ, q₀, F). "
    "Хочемо знайти такі x ∈ Σ*, q₁, q₂, q₃ ∈ Q, що:",
    "  q₁ = δ*(q₀, x),    q₂ = δ*(q₁, v),    q₃ = δ*(q₂, x),    δ*(q₃, w) ∈ F.",
    "Зауважимо: для фіксованого q₁ значення q₂ обчислюється однозначно. "
    "Залишається знайти x такий, що паралельне читання його з двох "
    "початкових станів (q₀ і q₂) приводить у пару (q₁, q₃), де "
    "δ*(q₃, w) ∈ F. Це задача про досяжність у добутку автомата самого "
    "на себе.",
    "Алгоритм:",
    "  1) Для кожного кандидата q₁ ∈ Q обчислюємо q₂ = δ*(q₁, v).",
    "  2) Робимо BFS у просторі пар (s₁, s₂) станів автомата, починаючи "
    "з (q₀, q₂); на кожному символі a ∈ Σ переходимо одночасно з обох "
    "координат: (s₁, s₂) → (δ(s₁, a), δ(s₂, a)).",
    "  3) Якщо досяжна пара (s₁, s₂) задовольняє s₁ = q₁ і δ*(s₂, w) ∈ F — "
    "знайдено x (шлях у BFS).",
    "  4) Якщо для жодного q₁ такий x не знайдено — відповіді не існує.",
    "Складність: O(|Q|³ · |Σ|) (для кожного з |Q| кандидатів — BFS по "
    "|Q|² парах із розгалуженням |Σ|). Простір пар обмежений |Q|², тому "
    "BFS гарантовано завершується. Якщо x існує, BFS повертає найкоротший.",
]

TASK3_DFAS = [
    "У програмі використано три тестові DFA над алфавітом {a, b}:",
    "  M1 — приймає слова, що містять підрядок «aa» "
    "(стани 0, 1, 2; 2 — приймальний).",
    "  M2 — приймає слова парної довжини (стани 0, 1; 0 — приймальний).",
    "  M3 — приймає слова, що закінчуються на «ab» "
    "(стани 0, 1, 2; 2 — приймальний).",
]

TASK3_TESTS = [
    {
        "title": "Тест 1. M1, v='a', w='b'",
        "purpose": "Базовий випадок: для автомата, що приймає слова з 'aa'.",
        "input": "M1, v='a', w='b'",
        "expected": "Знайдено x; xvxw містить підрядок 'aa' (наприклад, x='a' → 'aaab').",
        "explanation": "Будь-яке x що утворює 'aa' у xvxw підходить; BFS повертає одне з найкоротших.",
    },
    {
        "title": "Тест 2. M1, v='b', w='b'",
        "purpose": "Випадок, коли x має ввести 'aa' до v.",
        "input": "M1, v='b', w='b'",
        "expected": "x = 'aa' → xvxw = 'aabaab' (містить 'aa').",
        "explanation": "Без 'aa' слово не приймається; x='aa' дає 'aabaab', де 'aa' уже на позиціях 1–2.",
    },
    {
        "title": "Тест 3. M1, v='', w=''",
        "purpose": "Випадок порожніх v і w: шукаємо xx, що приймається.",
        "input": "M1, v='', w=''",
        "expected": "x = 'a' → xvxw = 'aa' (мінімальне слово з 'aa').",
        "explanation": "BFS знаходить найкоротший x, що утворює потрібний підрядок.",
    },
    {
        "title": "Тест 4. M2 (парна довжина), v='a', w=''",
        "purpose": "Випадок, коли відповіді не існує.",
        "input": "M2, v='a', w=''",
        "expected": "Не існує такого x.",
        "explanation": "|xvxw| = 2|x| + 1 — завжди непарне, тому жодне слово xvxw не приймається M2.",
    },
    {
        "title": "Тест 5. M3 (закінчується на 'ab'), v='a', w='b'",
        "purpose": "Перевірити роботу з автоматом «закінчується на ab».",
        "input": "M3, v='a', w='b'",
        "expected": "Знайдено x (наприклад, x='' → xvxw='ab').",
        "explanation": "x='' дає 'ab', яке закінчується на 'ab' — приймається.",
    },
]

TASK3_SECTIONS = [
    ("Алгоритм", TASK3_ALGORITHM),
    ("Тестові автомати", TASK3_DFAS),
]


# --------------------------- task 4 content ---------------------------

TASK4_PROBLEM = (
    "Реалізація синтаксичного аналізатора для заданої граматики "
    "Кореняка-Хопкрофта (у граматиці Кореняка-Хопкрофта для кожного з "
    "нетерміналів правила мають починатися з різних термінальних "
    "символів)."
)

TASK4_GRAMMAR_DESC = [
    "Граматика Кореняка-Хопкрофта — це КВ-граматика, у якій кожне "
    "правило має вигляд A → a α, де a — термінал, причому для кожного "
    "нетермінала A всі його правила починаються з різних терміналів. "
    "Завдяки цій властивості перший символ залишку вхідного рядка "
    "однозначно визначає, яке правило треба застосувати — це робить "
    "клас граматик LL(1) і дозволяє реалізувати простий аналізатор "
    "методом рекурсивного спуску без back-tracking-у.",
    "У програмі використано таку приклад-граматику з аксіомою E:",
    ("code",
     "E → ( T )  |  n\n"
     "T → + E    |  - E"),
    "Перевірка інваріанту К-Х: правила E починаються з '(' та 'n' "
    "(різні), правила T — з '+' та '-' (різні).",
]

TASK4_ALGORITHM = [
    "Для кожного нетермінала визначаємо функцію parse_NT(input):",
    "  1) Якщо input порожній — помилка «end of input».",
    "  2) Беремо перший символ c рядка input.",
    "  3) Шукаємо правило A → c α (за інваріантом К-Х — рівно одне таке).",
    "  4) Якщо правила немає — помилка «no rule for A starting with c».",
    "  5) Інакше «з'їдаємо» c і рекурсивно розбираємо хвіст α: "
    "термінали порівнюємо посимвольно, нетермінали — рекурсивно.",
    "  6) Повертаємо вузол дерева розбору з міткою A і списком "
    "дочірніх піддерев.",
    "Для повного розбору вимагаємо, щоб після parse_S весь input був "
    "спожитий (інакше — помилка «extra input»).",
    "Складність: O(|input|), оскільки кожен символ вхідного рядка "
    "розглядається константну кількість разів.",
]

TASK4_TESTS = [
    {
        "title": "Тест 1. Найпростіше слово",
        "purpose": "Базове застосування правила E → n.",
        "input": "'n'",
        "expected": "ACCEPTED. Дерево: E[n].",
        "explanation": "Перший символ 'n' відповідає правилу E → n; інших символів немає.",
    },
    {
        "title": "Тест 2. Дужки і додавання",
        "purpose": "Перевірити правила E → ( T ) і T → + E.",
        "input": "'(+n)'",
        "expected": "ACCEPTED. Дерево: E[ ( , T[+, E[n]], ) ].",
        "explanation": "'(' активує E → ( T ); '+' активує T → + E; 'n' — E → n; ')' замикає правило.",
    },
    {
        "title": "Тест 3. Вкладеність",
        "purpose": "Перевірити рекурсію (3 рівні вкладення).",
        "input": "'(-(+n))'",
        "expected": "ACCEPTED. Глибина дерева 5.",
        "explanation": "Кожне '(' додає рівень E і T; парсер коректно повертається на верхні рівні.",
    },
    {
        "title": "Тест 4. Глибша вкладеність",
        "purpose": "Перевірити стабільність на довшому рекурсивному вході.",
        "input": "'(+(-(+n)))'",
        "expected": "ACCEPTED.",
        "explanation": "Рекурсивний спуск працює коректно для довільної глибини вкладень.",
    },
    {
        "title": "Тест 5. Невірний початок",
        "purpose": "Перевірити обробку помилки на верхньому рівні.",
        "input": "'+n'",
        "expected": "PARSE ERROR: no rule for E starting with '+'.",
        "explanation": "E починається тільки з '(' або 'n'; '+' є FIRST для T, а не для E.",
    },
    {
        "title": "Тест 6. Невірний символ після '('",
        "purpose": "Перевірити помилку всередині правила.",
        "input": "'(n)'",
        "expected": "PARSE ERROR: no rule for T starting with 'n'.",
        "explanation": "Після '(' за правилом E → ( T ) очікується T, що починається з '+' або '-'.",
    },
    {
        "title": "Тест 7. Залишковий вхід",
        "purpose": "Перевірити обов'язкове повне споживання вхідного рядка.",
        "input": "'n+'",
        "expected": "PARSE ERROR: extra input after parse.",
        "explanation": "Аксіома E розбирає 'n', але після цього лишається '+', що не належить жодному виводу.",
    },
    {
        "title": "Тест 8. Порожній вхід",
        "purpose": "Перевірити обробку порожнього рядка.",
        "input": "''",
        "expected": "PARSE ERROR: unexpected end of input.",
        "explanation": "Жодне правило E не виводить порожнє слово (у К-Х граматиці немає ε-правил для нетерміналів).",
    },
]

TASK4_SECTIONS = [
    ("Граматика", TASK4_GRAMMAR_DESC),
    ("Алгоритм", TASK4_ALGORITHM),
]


# --------------------------- driver ---------------------------

REPORTS = {
    "task2": {
        "problem": TASK2_PROBLEM,
        "sections": TASK2_SECTIONS,
        "tests": TASK2_TESTS,
        "task_num": 2,
        "files": {
            "Haskell": "task2.hs",
            "Prolog":  "task2.pl",
        },
    },
    "task3": {
        "problem": TASK3_PROBLEM,
        "sections": TASK3_SECTIONS,
        "tests": TASK3_TESTS,
        "task_num": 3,
        "files": {
            "Haskell": "task3.hs",
            "Prolog":  "task3.pl",
        },
    },
    "task4": {
        "problem": TASK4_PROBLEM,
        "sections": TASK4_SECTIONS,
        "tests": TASK4_TESTS,
        "task_num": 4,
        "files": {
            "Haskell": "task4.hs",
            "Prolog":  "task4.pl",
        },
    },
}


def gen_task(name):
    cfg = REPORTS[name]
    for lang, src in cfg["files"].items():
        with open(src, "r", encoding="utf-8") as f:
            code = f.read()
        out = f"{lang}_{cfg['task_num']}_Звіт_Кучерук_ТТП31.docx"
        build_report(
            language=lang,
            task_num=cfg["task_num"],
            source_file=src,
            code=code,
            out_path=out,
            problem_text=cfg["problem"],
            sections=cfg["sections"],
            tests=cfg["tests"],
        )


def main():
    if len(sys.argv) > 1:
        for name in sys.argv[1:]:
            if name not in REPORTS:
                print(f"Unknown task: {name}. Known: {list(REPORTS)}")
                sys.exit(1)
            gen_task(name)
    else:
        for name in REPORTS:
            gen_task(name)


if __name__ == "__main__":
    main()
