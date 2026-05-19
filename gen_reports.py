"""Generate Word reports for tasks 2, 3, 4 (Haskell + Prolog).

Usage:
    python gen_reports.py                  # generate all reports
    python gen_reports.py task3-pl         # only one
    python gen_reports.py task3-hs task3-pl
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


def build_report(*, language, task_num, variant, source_file, code, out_path,
                 problem_text, sections, tests, branch=BRANCH):
    """Generic report builder.

    sections:  list of (heading, [paragraphs]) extra sections inserted
               between the problem statement and the code listing.
               A paragraph may be a string or a tuple ("code", text).
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
    add_centered(doc, f"ЗАДАЧА {task_num} ({language}), Варіант {variant}",
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

    # --- extra sections ---
    idx = 1
    for heading, paragraphs in sections:
        add_section_heading(doc, f"{idx}. {heading}")
        for para in paragraphs:
            if isinstance(para, tuple):
                kind, text = para
                if kind == "code":
                    add_code_block(doc, text)
                else:
                    add_body(doc, text, align=WD_ALIGN_PARAGRAPH.LEFT)
            else:
                add_body(doc, para, align=WD_ALIGN_PARAGRAPH.LEFT)
        idx += 1

    # --- code listing ---
    add_section_heading(doc, f"{idx}. Код програми")
    add_body(doc, f"Файл: {source_file}", align=WD_ALIGN_PARAGRAPH.LEFT)
    add_code_block(doc, code)
    idx += 1

    # --- tests ---
    add_section_heading(doc, f"{idx}. Тестування")
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
    idx += 1

    # --- appendix ---
    add_section_heading(doc, "Додатки")
    add_body(doc, "Посилання на репозиторій GitHub з кодом програми:",
             align=WD_ALIGN_PARAGRAPH.LEFT)
    add_body(doc, f"{REPO}/tree/{branch}", align=WD_ALIGN_PARAGRAPH.LEFT)

    doc.save(out_path)
    print(f"Saved: {out_path}")


# =========================== TASK 2 (both langs, variant 16) =====================

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


# =========================== TASK 3 (Haskell, variant 16) =======================

TASK3_HS_PROBLEM = (
    "Для заданих слів v і w виявити, чи допускає скінчений автомат хоча б "
    "одне слово, що може бути подане у вигляді xvxw для деякого слова x. "
    "При ствердній відповіді навести приклад відповідного слова xvxw."
)

TASK3_HS_ALGORITHM = [
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
    "|Q|² парах із розгалуженням |Σ|).",
]

TASK3_HS_DFAS = [
    "У програмі використано три тестові DFA над алфавітом {a, b}:",
    "  M1 — приймає слова, що містять підрядок «aa».",
    "  M2 — приймає слова парної довжини.",
    "  M3 — приймає слова, що закінчуються на «ab».",
]

TASK3_HS_TESTS = [
    {
        "title": "Тест 1. M1, v='a', w='b'",
        "purpose": "Базовий випадок для автомата, що приймає слова з 'aa'.",
        "input": "M1, v='a', w='b'",
        "expected": "Знайдено x; xvxw містить підрядок 'aa'.",
        "explanation": "BFS повертає одне з найкоротших підходящих x.",
    },
    {
        "title": "Тест 2. M1, v='b', w='b'",
        "purpose": "Випадок, коли x має ввести 'aa' до v.",
        "input": "M1, v='b', w='b'",
        "expected": "x = 'aa' → xvxw = 'aabaab'.",
        "explanation": "x='aa' дає 'aabaab', де 'aa' уже на позиціях 1–2.",
    },
    {
        "title": "Тест 3. M1, v='', w=''",
        "purpose": "Випадок порожніх v і w: шукаємо xx, що приймається.",
        "input": "M1, v='', w=''",
        "expected": "Найкоротше xx, що містить 'aa'.",
        "explanation": "BFS знаходить найкоротший x.",
    },
    {
        "title": "Тест 4. M2, v='a', w=''",
        "purpose": "Випадок, коли відповіді не існує.",
        "input": "M2, v='a', w=''",
        "expected": "Не існує такого x.",
        "explanation": "|xvxw| = 2|x|+1 завжди непарне — жодне слово xvxw не приймається M2.",
    },
    {
        "title": "Тест 5. M3, v='a', w='b'",
        "purpose": "Перевірити роботу з автоматом «закінчується на ab».",
        "input": "M3, v='a', w='b'",
        "expected": "Знайдено x (наприклад, x='' → xvxw='ab').",
        "explanation": "x='' дає 'ab', яке закінчується на 'ab' — приймається.",
    },
]


# =========================== TASK 3 (Prolog, variant 3) =========================

TASK3_PL_PROBLEM = (
    "Для заданого натурального k виявити всі слова довжини, що не "
    "перевищує k, які допускаються автоматом. Вивести їх у "
    "лексикографічному порядку."
)

TASK3_PL_ALGORITHM = [
    "Нехай задано скінчений детермінований автомат M = (Q, Σ, δ, q₀, F) і "
    "натуральне число k. Потрібно знайти множину всіх слів w ∈ Σ* таких, "
    "що |w| ≤ k і w приймається M, та вивести їх у певному порядку.",
    "Порядок виводу — shortlex: спочатку коротші слова, серед слів однакової "
    "довжини — лексикографічно за порядком символів алфавіту Σ.",
    "Алгоритм:",
    "  1) Для n = 0, 1, …, k:",
    "    1.1) перебираємо всі слова довжини n над алфавітом Σ у "
    "лексикографічному порядку (через рекурсивну генерацію префіксів);",
    "    1.2) для кожного слова w симулюємо роботу автомата δ*(q₀, w) і "
    "перевіряємо, чи δ*(q₀, w) ∈ F;",
    "    1.3) приймальні слова збираємо в результат у тому ж порядку.",
    "Складність: загальна кількість слів довжини ≤ k над алфавітом розміру "
    "|Σ| дорівнює (|Σ|^(k+1) − 1)/(|Σ| − 1) (геометрична прогресія); "
    "кожне слово симулюється за O(|w|), тому повна оцінка — "
    "O(k · |Σ|^k).",
    "Зауваження: лексикографічний порядок забезпечується природним "
    "порядком backtracking-у Prolog у предикаті word_of_length/3 — у "
    "ньому member(C, Sigma) перебирає символи у порядку, заданому "
    "списком Sigma.",
]

TASK3_PL_DFAS = [
    "У програмі використано три тестові DFA над алфавітом {a, b}:",
    "  M1 — приймає слова, що містять підрядок «aa» (стани 0, 1, 2; "
    "2 — приймальний).",
    "  M2 — приймає слова парної довжини (стани 0, 1; 0 — приймальний; "
    "порожнє слово приймається).",
    "  M3 — приймає слова, що закінчуються на «ab» (стани 0, 1, 2; "
    "2 — приймальний).",
]

TASK3_PL_TESTS = [
    {
        "title": "Тест 1. M1, k = 0",
        "purpose": "Перевірити обробку k = 0 (тільки порожнє слово).",
        "input": "DFA M1, k = 0",
        "expected": "Жодного слова (0 accepted word(s)).",
        "explanation": "Порожнє слово відповідає кінцевому стану q₀ = 0, який не є приймальним для M1.",
    },
    {
        "title": "Тест 2. M1, k = 2",
        "purpose": "Базовий випадок: найкоротше прийняте слово.",
        "input": "DFA M1, k = 2",
        "expected": "{ aa } — 1 слово.",
        "explanation": "Усі коротші слова не містять підрядка «aa», тому не приймаються; «aa» — найкоротше.",
    },
    {
        "title": "Тест 3. M1, k = 4",
        "purpose": "Перевірити порядок shortlex на нетривіальному прикладі.",
        "input": "DFA M1, k = 4",
        "expected": "12 слів: aa, aaa, aab, baa, aaaa, aaab, aaba, aabb, abaa, baaa, baab, bbaa.",
        "explanation": "Усі слова довжини 2, 3, 4 над {a,b}, що містять підрядок «aa», у shortlex-порядку.",
    },
    {
        "title": "Тест 4. M2, k = 4",
        "purpose": "Перевірити випадок з порожнім словом у відповіді.",
        "input": "DFA M2, k = 4",
        "expected": "21 слово: <eps>, потім всі слова довжини 2 і 4.",
        "explanation": "M2 приймає рівно слова парної довжини; кількість — 1 + 2² + 2⁴ = 21.",
    },
    {
        "title": "Тест 5. M3, k = 3",
        "purpose": "Перевірити автомат із одним приймальним станом.",
        "input": "DFA M3, k = 3",
        "expected": "{ ab, aab, bab } — 3 слова.",
        "explanation": "Усі слова довжини ≤ 3 над {a,b}, що закінчуються на «ab».",
    },
]


# =========================== TASK 4 (Haskell, variant 16) =======================

TASK4_HS_PROBLEM = (
    "Реалізація синтаксичного аналізатора для заданої граматики "
    "Кореняка-Хопкрофта (у граматиці Кореняка-Хопкрофта для кожного з "
    "нетерміналів правила мають починатися з різних термінальних "
    "символів)."
)

TASK4_HS_GRAMMAR = [
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

TASK4_HS_ALGORITHM = [
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
    "Складність: O(|input|).",
]

TASK4_HS_TESTS = [
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
        "explanation": "Жодне правило E не виводить порожнє слово.",
    },
]


# =========================== TASK 4 (Prolog, variant 3) =========================

TASK4_PL_PROBLEM = (
    "Виявити ліво-рекурсивні нетермінали та виконати усунення лівої "
    "рекурсії (пряму та непряму)."
)

TASK4_PL_DEFINITIONS = [
    "Нехай задано КВ-граматику G = (N, Σ, P, S), де N — множина "
    "нетерміналів, Σ — алфавіт терміналів, P — правила, S — аксіома.",
    "Нетермінал A ∈ N називається пряма ліво-рекурсивним, якщо існує "
    "правило A → A γ ∈ P.",
    "Нетермінал A ∈ N називається ліво-рекурсивним (загалом — прямо чи "
    "непрямо), якщо існує послідовність ⇒ виведень, при якій "
    "A ⇒+ A γ для деякої правої частини γ.",
    "Виявлення проводиться через ліво-залежний граф: вершини — "
    "нетермінали, дуга A → B існує, якщо є правило A → B γ. A є "
    "ліво-рекурсивним ⟺ через A проходить цикл у цьому графі. "
    "Пошук — DFS зі списком відвіданих вершин.",
]

TASK4_PL_ALGORITHM = [
    "Використано алгоритм Ахо-Сеті-Ульмана. Фіксуємо порядок "
    "нетерміналів A₁, A₂, …, Aₙ. Для i = 1, …, n:",
    "  1) Для j = 1, …, i − 1: знайти всі правила вигляду "
    "Aᵢ → Aⱼ γ і замінити кожне з них на множину правил Aᵢ → δ γ, "
    "по одному для кожного правила Aⱼ → δ. Після цього жодне правило "
    "Aᵢ більше не починається з Aⱼ для j < i.",
    "  2) Усунути пряму ліву рекурсію в Aᵢ за стандартним перетворенням:",
    ("code",
     "Aᵢ  → Aᵢ α₁ | ... | Aᵢ αₘ | β₁ | ... | βₚ\n"
     "    ⇓\n"
     "Aᵢ  → β₁ Aᵢ' | ... | βₚ Aᵢ'\n"
     "Aᵢ' → α₁ Aᵢ' | ... | αₘ Aᵢ' | ε"),
    "  де Aᵢ' — свіже ім'я нетермінала (у реалізації — A_p).",
    "Після завершення алгоритму граматика не містить ані прямих, ані "
    "непрямих лівих рекурсій. Доведення: на кроці i = k всі правила Aₖ "
    "починаються або з термінала, або з нетермінала Aⱼ з j ≥ k+1 (бо "
    "пряма рекурсія Aₖ → Aₖ α усунута, а правила Aₖ → Aⱼ γ з j < k "
    "вже замінені). Отже у ліво-залежному графі немає циклів.",
    "Зауваження: для коректності алгоритму граматика не повинна "
    "містити ε-правил у початковому стані (інакше потрібен попередній "
    "крок їх усунення). У реалізації прийнято це припущення.",
]

TASK4_PL_GRAMMARS = [
    "У програмі визначено три тестові граматики:",
    ("code",
     "G1 (тільки пряма ліва рекурсія):\n"
     "  E → E + T | T\n"
     "  T → T * F | F\n"
     "  F → ( E ) | id\n"
     "\n"
     "G2 (непряма ліва рекурсія через два нетермінали):\n"
     "  A → B a | c\n"
     "  B → A b | d\n"
     "\n"
     "G3 (без лівої рекурсії):\n"
     "  S → a S | b"),
]

TASK4_PL_TESTS = [
    {
        "title": "Тест 1. G1 — пряма ліва рекурсія",
        "purpose": "Перевірити виявлення прямої лівої рекурсії та її усунення.",
        "input": "Граматика G1.",
        "expected": (
            "Виявлено: E, T (пряма). Після усунення: "
            "E → T E_p; E_p → + T E_p | ε; "
            "T → F T_p; T_p → * F T_p | ε; F → ( E ) | id."
        ),
        "explanation": "Стандартне перетворення для двох пар правил із прямою рекурсією; F залишається без змін.",
    },
    {
        "title": "Тест 2. G2 — непряма ліва рекурсія",
        "purpose": "Перевірити виявлення непрямої лівої рекурсії та підстановку.",
        "input": "Граматика G2.",
        "expected": (
            "Виявлено: A, B (непряма). Після алгоритму Ахо-Сеті-Ульмана: "
            "A → B a | c; B → d B_p | c b B_p; B_p → a b B_p | ε."
        ),
        "explanation": "При обробці B (i=2) правило B → A b замінюється на B → B a b | c b; далі пряма рекурсія B → B a b усувається стандартним чином.",
    },
    {
        "title": "Тест 3. G3 — без лівої рекурсії",
        "purpose": "Перевірити, що алгоритм нічого не міняє у вже коректній граматиці.",
        "input": "Граматика G3.",
        "expected": "Виявлено: жодних. Граматика без змін.",
        "explanation": "Жодне правило не починається з нетермінала, тому усувати нічого.",
    },
    {
        "title": "Тест 4. Контрольна перевірка результату",
        "purpose": "Підтвердити, що після усунення в G1 та G2 жоден нетермінал не є ліво-рекурсивним.",
        "input": "Граматики після перетворення.",
        "expected": "Verification: left-recursive in result: [] для всіх трьох граматик.",
        "explanation": "Після алгоритму ліво-залежний граф у новій граматиці є ациклічним — перевірено явно функцією left_recursive у програмі.",
    },
]


# --------------------------- driver ---------------------------

REPORTS = {
    "task2-hs": {
        "task_num": 2, "variant": 16, "language": "Haskell", "file": "task2.hs",
        "problem": TASK2_PROBLEM, "sections": [], "tests": TASK2_TESTS,
    },
    "task2-pl": {
        "task_num": 2, "variant": 16, "language": "Prolog", "file": "task2.pl",
        "problem": TASK2_PROBLEM, "sections": [], "tests": TASK2_TESTS,
    },
    "task3-hs": {
        "task_num": 3, "variant": 16, "language": "Haskell", "file": "task3.hs",
        "problem": TASK3_HS_PROBLEM,
        "sections": [
            ("Алгоритм", TASK3_HS_ALGORITHM),
            ("Тестові автомати", TASK3_HS_DFAS),
        ],
        "tests": TASK3_HS_TESTS,
    },
    "task3-pl": {
        "task_num": 3, "variant": 3, "language": "Prolog", "file": "task3.pl",
        "problem": TASK3_PL_PROBLEM,
        "sections": [
            ("Алгоритм", TASK3_PL_ALGORITHM),
            ("Тестові автомати", TASK3_PL_DFAS),
        ],
        "tests": TASK3_PL_TESTS,
    },
    "task4-hs": {
        "task_num": 4, "variant": 16, "language": "Haskell", "file": "task4.hs",
        "problem": TASK4_HS_PROBLEM,
        "sections": [
            ("Граматика", TASK4_HS_GRAMMAR),
            ("Алгоритм", TASK4_HS_ALGORITHM),
        ],
        "tests": TASK4_HS_TESTS,
    },
    "task4-pl": {
        "task_num": 4, "variant": 3, "language": "Prolog", "file": "task4.pl",
        "problem": TASK4_PL_PROBLEM,
        "sections": [
            ("Означення", TASK4_PL_DEFINITIONS),
            ("Алгоритм", TASK4_PL_ALGORITHM),
            ("Тестові граматики", TASK4_PL_GRAMMARS),
        ],
        "tests": TASK4_PL_TESTS,
    },
}


def gen_report(key):
    cfg = REPORTS[key]
    with open(cfg["file"], "r", encoding="utf-8") as f:
        code = f.read()
    out = f"{cfg['language']}_{cfg['task_num']}_Звіт_Кучерук_ТТП31.docx"
    build_report(
        language=cfg["language"],
        task_num=cfg["task_num"],
        variant=cfg["variant"],
        source_file=cfg["file"],
        code=code,
        out_path=out,
        problem_text=cfg["problem"],
        sections=cfg["sections"],
        tests=cfg["tests"],
    )


def main():
    if len(sys.argv) > 1:
        keys = sys.argv[1:]
        for k in keys:
            if k not in REPORTS:
                print(f"Unknown report key: {k}. Known: {list(REPORTS)}")
                sys.exit(1)
    else:
        keys = list(REPORTS)
    for k in keys:
        gen_report(k)


if __name__ == "__main__":
    main()
