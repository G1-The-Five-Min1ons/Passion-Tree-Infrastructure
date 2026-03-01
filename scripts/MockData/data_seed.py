"""
Passion Tree - Mock Data Seeder
================================
ส่ง mock data ไปที่ Backend API เพื่อเพิ่มข้อมูลลง Database

Usage:
    python mock_data_seed.py                        # ใช้ default localhost:5000
    python mock_data_seed.py --base-url http://localhost:8080
    python mock_data_seed.py --skip-verify           # ข้าม email verification

หมายเหตุ:
    - Backend ต้องรันอยู่ก่อน
    - ถ้า backend ต้อง verify email ให้ใช้ --skip-verify (จะ login ด้วย credential ที่สร้างไว้)
"""

import requests
import json
import time
import sys
import argparse

# ─────────────────────────────── CONFIG ───────────────────────────────

DEFAULT_BASE_URL = "http://localhost:5000"
API_PREFIX = "/api/v1"
DEFAULT_PASSWORD = "Test@12345678"

# ─── Existing user (already registered in DB) ───
EXISTING_USER = {
    "user_id": "8049de4b-ec43-40f8-b429-6fa5dcfd4351",
    "username": "farlos3",
    "password": "Tae53006?",
    "role": "teacher",  # assumed role for creating paths
}

# ─────────────────────────── COLORS (ANSI) ────────────────────────────

class C:
    GREEN = "\033[92m"
    RED = "\033[91m"
    YELLOW = "\033[93m"
    CYAN = "\033[96m"
    BOLD = "\033[1m"
    END = "\033[0m"

def ok(msg):   print(f"  {C.GREEN}✓{C.END} {msg}")
def fail(msg): print(f"  {C.RED}✗{C.END} {msg}")
def info(msg): print(f"  {C.CYAN}→{C.END} {msg}")
def head(msg): print(f"\n{C.BOLD}{C.YELLOW}{'='*60}\n  {msg}\n{'='*60}{C.END}")

# ─────────────────────────── MOCK DATA ────────────────────────────────

TEACHERS = [
    {
        "username": "teacher_somchai",
        "email": "somchai.mock@passiontree.dev",
        "password": DEFAULT_PASSWORD,
        "first_name": "สมชาย",
        "last_name": "ใจดี",
        "role": "teacher",
        "bio": "อาจารย์สอนวิทยาศาสตร์ มีประสบการณ์กว่า 10 ปี",
        "location": "Bangkok, Thailand",
    },
    {
        "username": "teacher_maria",
        "email": "maria.mock@passiontree.dev",
        "password": DEFAULT_PASSWORD,
        "first_name": "Maria",
        "last_name": "Johnson",
        "role": "teacher",
        "bio": "Computer Science instructor specializing in web development",
        "location": "Chiang Mai, Thailand",
    },
]

STUDENTS = [
    {
        "username": "student_ploy",
        "email": "ploy.mock@passiontree.dev",
        "password": DEFAULT_PASSWORD,
        "first_name": "พลอย",
        "last_name": "สว่างใจ",
        "role": "student",
    },
    {
        "username": "student_tong",
        "email": "tong.mock@passiontree.dev",
        "password": DEFAULT_PASSWORD,
        "first_name": "ต้อง",
        "last_name": "รักเรียน",
        "role": "student",
    },
    {
        "username": "student_alex",
        "email": "alex.mock@passiontree.dev",
        "password": DEFAULT_PASSWORD,
        "first_name": "Alex",
        "last_name": "Chen",
        "role": "student",
    },
    {
        "username": "student_nina",
        "email": "nina.mock@passiontree.dev",
        "password": DEFAULT_PASSWORD,
        "first_name": "Nina",
        "last_name": "Nakamura",
        "role": "student",
    },
]

LEARNING_PATHS = [
    {
        "title": "Biology 101 - พื้นฐานชีววิทยา",
        "objective": "เข้าใจความสัมพันธ์พื้นฐานของสิ่งมีชีวิตและระบบนิเวศ",
        "description": "มุ่งเน้นให้ผู้เรียนเข้าใจความสัมพันธ์ของสิ่งมีชีวิต โครงสร้าง และหน้าที่ของเซลล์ ระบบนิเวศ และการจำแนกสิ่งมีชีวิต",
        "cover_img_url": "https://images.unsplash.com/photo-1530026405186-ed1f139313f8?w=800",
        "publish_status": "published",
        "nodes": [
            {
                "title": "เซลล์และโครงสร้าง",
                "description": "ศึกษาโครงสร้างของเซลล์ ส่วนประกอบหลักและหน้าที่ของออร์แกเนลล์ต่างๆ",
                "sequence": "1",
                "materials": [
                    {"type": "video", "url": "https://www.youtube.com/watch?v=example1"},
                    {"type": "pdf", "url": "https://example.com/cell-structure.pdf"},
                ],
                "questions": [
                    {
                        "question_text": "ออร์แกเนลล์ใดทำหน้าที่ผลิตพลังงานให้เซลล์?",
                        "type": "multiple",
                        "choices": [
                            {"choice_text": "ไรโบโซม", "is_correct": False, "reasoning": "ไรโบโซมทำหน้าที่สังเคราะห์โปรตีน"},
                            {"choice_text": "ไมโทคอนเดรีย", "is_correct": True, "reasoning": "ไมโทคอนเดรียเป็นโรงงานผลิตพลังงาน ATP ของเซลล์"},
                            {"choice_text": "นิวเคลียส", "is_correct": False, "reasoning": "นิวเคลียสเป็นศูนย์ควบคุมของเซลล์"},
                            {"choice_text": "กอลจิบอดี", "is_correct": False, "reasoning": "กอลจิบอดีทำหน้าที่บรรจุและส่งออกสาร"},
                        ],
                    },
                ],
            },
            {
                "title": "ระบบนิเวศ",
                "description": "เรียนรู้เกี่ยวกับระบบนิเวศ ห่วงโซ่อาหาร และความสัมพันธ์ระหว่างสิ่งมีชีวิต",
                "sequence": "2",
                "materials": [
                    {"type": "video", "url": "https://www.youtube.com/watch?v=example2"},
                ],
                "questions": [
                    {
                        "question_text": "ความสัมพันธ์แบบ +/+ หมายถึงข้อใด?",
                        "type": "multiple",
                        "choices": [
                            {"choice_text": "ปรสิต", "is_correct": False, "reasoning": "ปรสิตเป็นแบบ +/- ฝ่ายหนึ่งได้ประโยชน์อีกฝ่ายเสียประโยชน์"},
                            {"choice_text": "ภาวะอิงอาศัย", "is_correct": False, "reasoning": "ภาวะอิงอาศัยเป็นแบบ +/0"},
                            {"choice_text": "ภาวะพึ่งพากัน", "is_correct": True, "reasoning": "ภาวะพึ่งพากันทั้งสองฝ่ายได้ประโยชน์"},
                            {"choice_text": "การล่าเหยื่อ", "is_correct": False, "reasoning": "การล่าเหยื่อเป็นแบบ +/-"},
                        ],
                    },
                ],
            },
            {
                "title": "การจำแนกสิ่งมีชีวิต",
                "description": "ศึกษาระบบการจำแนกสิ่งมีชีวิตตามลำดับขั้นอนุกรมวิธาน",
                "sequence": "3",
                "materials": [
                    {"type": "image", "url": "https://example.com/taxonomy-chart.png"},
                ],
                "questions": [],
            },
            {
                "title": "พันธุศาสตร์เบื้องต้น",
                "description": "เรียนรู้กฎของเมนเดลและการถ่ายทอดลักษณะทางพันธุกรรม",
                "sequence": "4",
                "materials": [],
                "questions": [
                    {
                        "question_text": "กฎของเมนเดลข้อใดกล่าวถึงการแยกตัวของยีน?",
                        "type": "multiple",
                        "choices": [
                            {"choice_text": "Law of Segregation", "is_correct": True, "reasoning": "กฎแห่งการแยกตัว กล่าวว่ายีนจะแยกออกจากกันเมื่อสร้างเซลล์สืบพันธุ์"},
                            {"choice_text": "Law of Independent Assortment", "is_correct": False, "reasoning": "กฎแห่งการรวมกลุ่มอย่างอิสระ"},
                            {"choice_text": "Law of Dominance", "is_correct": False, "reasoning": "กฎแห่งลักษณะเด่น"},
                        ],
                    },
                ],
            },
        ],
    },
    {
        "title": "Web Development Fundamentals",
        "objective": "Build modern web applications from scratch",
        "description": "Learn HTML, CSS, JavaScript, and React.js to build responsive and interactive web applications",
        "cover_img_url": "https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=800",
        "publish_status": "published",
        "nodes": [
            {
                "title": "HTML & CSS Basics",
                "description": "Learn the building blocks of web pages - HTML for structure, CSS for styling",
                "sequence": "1",
                "materials": [
                    {"type": "video", "url": "https://www.youtube.com/watch?v=html-basics"},
                    {"type": "link", "url": "https://developer.mozilla.org/en-US/docs/Web/HTML"},
                ],
                "questions": [
                    {
                        "question_text": "Which HTML tag is used for the largest heading?",
                        "type": "multiple",
                        "choices": [
                            {"choice_text": "<h6>", "is_correct": False, "reasoning": "h6 is the smallest heading"},
                            {"choice_text": "<h1>", "is_correct": True, "reasoning": "h1 is the largest heading tag"},
                            {"choice_text": "<header>", "is_correct": False, "reasoning": "header is a semantic container element"},
                            {"choice_text": "<title>", "is_correct": False, "reasoning": "title sets the page title in the browser tab"},
                        ],
                    },
                ],
            },
            {
                "title": "JavaScript Essentials",
                "description": "Master the basics of JavaScript - variables, functions, DOM manipulation",
                "sequence": "2",
                "materials": [
                    {"type": "video", "url": "https://www.youtube.com/watch?v=js-essentials"},
                ],
                "questions": [
                    {
                        "question_text": "What keyword declares a block-scoped variable in JavaScript?",
                        "type": "multiple",
                        "choices": [
                            {"choice_text": "var", "is_correct": False, "reasoning": "var is function-scoped, not block-scoped"},
                            {"choice_text": "let", "is_correct": True, "reasoning": "let declares a block-scoped variable"},
                            {"choice_text": "const", "is_correct": False, "reasoning": "const declares a block-scoped constant"},
                            {"choice_text": "define", "is_correct": False, "reasoning": "define is not a JS keyword"},
                        ],
                    },
                ],
            },
            {
                "title": "React.js Fundamentals",
                "description": "Learn component-based architecture with React.js",
                "sequence": "3",
                "materials": [
                    {"type": "link", "url": "https://react.dev/learn"},
                ],
                "questions": [],
            },
        ],
    },
    {
        "title": "Chemistry - เคมีพื้นฐาน",
        "objective": "เข้าใจปฏิกิริยาเคมีและโครงสร้างของสสาร",
        "description": "มุ่งเน้นให้ผู้เรียนเข้าใจองค์ประกอบและปฏิกิริยาต่างๆทางเคมีในชีวิตประจำวัน รวมถึงโครงสร้างอะตอมและตารางธาตุ",
        "cover_img_url": "https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=800",
        "publish_status": "published",
        "nodes": [
            {
                "title": "โครงสร้างอะตอม",
                "description": "ศึกษาส่วนประกอบของอะตอม: โปรตอน นิวตรอน อิเล็กตรอน และแบบจำลองอะตอม",
                "sequence": "1",
                "materials": [
                    {"type": "video", "url": "https://www.youtube.com/watch?v=atom-structure"},
                ],
                "questions": [
                    {
                        "question_text": "อนุภาคใดมีประจุบวก?",
                        "type": "multiple",
                        "choices": [
                            {"choice_text": "โปรตอน", "is_correct": True, "reasoning": "โปรตอนมีประจุบวก +1"},
                            {"choice_text": "นิวตรอน", "is_correct": False, "reasoning": "นิวตรอนเป็นกลาง ไม่มีประจุ"},
                            {"choice_text": "อิเล็กตรอน", "is_correct": False, "reasoning": "อิเล็กตรอนมีประจุลบ -1"},
                        ],
                    },
                ],
            },
            {
                "title": "ตารางธาตุ",
                "description": "เรียนรู้การจัดเรียงธาตุในตารางธาตุและสมบัติเป็นคาบ",
                "sequence": "2",
                "materials": [],
                "questions": [],
            },
            {
                "title": "พันธะเคมี",
                "description": "ศึกษาพันธะไอออนิก พันธะโคเวเลนต์ และพันธะโลหะ",
                "sequence": "3",
                "materials": [
                    {"type": "pdf", "url": "https://example.com/chemical-bonds.pdf"},
                ],
                "questions": [
                    {
                        "question_text": "พันธะชนิดใดเกิดจากการใช้อิเล็กตรอนร่วมกัน?",
                        "type": "multiple",
                        "choices": [
                            {"choice_text": "พันธะไอออนิก", "is_correct": False, "reasoning": "พันธะไอออนิกเกิดจากการให้-รับอิเล็กตรอน"},
                            {"choice_text": "พันธะโคเวเลนต์", "is_correct": True, "reasoning": "พันธะโคเวเลนต์เกิดจากการใช้อิเล็กตรอนร่วมกัน"},
                            {"choice_text": "พันธะโลหะ", "is_correct": False, "reasoning": "พันธะโลหะเกิดจากการเคลื่อนที่ของอิเล็กตรอนอิสระ"},
                        ],
                    },
                ],
            },
        ],
    },
    {
        "title": "Cybersecurity Basics",
        "objective": "ป้องกันและรับมือภัยคุกคามในโลกไซเบอร์",
        "description": "เน้นให้ผู้เรียนเข้าใจหลักการรักษาความปลอดภัยไซเบอร์ ภัยคุกคาม Malware, Phishing และวิธีป้องกัน",
        "cover_img_url": "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=800",
        "publish_status": "published",
        "nodes": [
            {
                "title": "Introduction to Cybersecurity",
                "description": "Overview of cybersecurity concepts, CIA Triad, and threat landscape",
                "sequence": "1",
                "materials": [
                    {"type": "video", "url": "https://www.youtube.com/watch?v=cyber-intro"},
                ],
                "questions": [
                    {
                        "question_text": "CIA Triad ประกอบด้วยอะไรบ้าง?",
                        "type": "multiple",
                        "choices": [
                            {"choice_text": "Confidentiality, Integrity, Availability", "is_correct": True, "reasoning": "CIA Triad คือหลักการ 3 ประการ: การรักษาความลับ ความถูกต้อง และความพร้อมใช้งาน"},
                            {"choice_text": "Control, Identity, Access", "is_correct": False, "reasoning": "ไม่ใช่องค์ประกอบของ CIA Triad"},
                            {"choice_text": "Cryptography, Internet, Authentication", "is_correct": False, "reasoning": "ไม่ใช่องค์ประกอบของ CIA Triad"},
                        ],
                    },
                ],
            },
            {
                "title": "Malware Analysis",
                "description": "Understanding different types of malware: viruses, worms, trojans, ransomware",
                "sequence": "2",
                "materials": [],
                "questions": [],
            },
            {
                "title": "Network Security",
                "description": "Firewalls, IDS/IPS, VPN, and secure network architecture",
                "sequence": "3",
                "materials": [
                    {"type": "pdf", "url": "https://example.com/network-security.pdf"},
                ],
                "questions": [],
            },
        ],
    },
    {
        "title": "Python for Data Science",
        "objective": "ใช้ภาษา Python ในการวิเคราะห์และจัดการข้อมูล",
        "description": "เรียนรู้การใช้ Pandas, NumPy, Matplotlib สำหรับวิเคราะห์ข้อมูลเชิงลึกและสร้าง visualization",
        "cover_img_url": "https://images.unsplash.com/photo-1526379095098-d400fd0bf935?w=800",
        "publish_status": "draft",
        "nodes": [
            {
                "title": "Python Basics for Data Science",
                "description": "Variables, data types, lists, dictionaries, and control flow in Python",
                "sequence": "1",
                "materials": [
                    {"type": "video", "url": "https://www.youtube.com/watch?v=python-ds"},
                ],
                "questions": [],
            },
            {
                "title": "Pandas & NumPy",
                "description": "Data manipulation and numerical computing with Pandas and NumPy",
                "sequence": "2",
                "materials": [],
                "questions": [],
            },
        ],
    },
]

ALBUMS = [
    {
        "album_name": "อัลบั้มวิทยาศาสตร์",
        "cover_image_url": "https://images.unsplash.com/photo-1507413245164-6160d8298b31?w=400",
    },
    {
        "album_name": "การเรียนรู้โปรแกรมมิ่ง",
        "cover_image_url": "https://images.unsplash.com/photo-1515879218367-8466d910adef?w=400",
    },
]

# ──────────────────────────── API CLIENT ──────────────────────────────

class PassionTreeAPI:
    def __init__(self, base_url):
        self.base = base_url.rstrip("/") + API_PREFIX
        self.session = requests.Session()
        self.token = None
    
    def _headers(self):
        h = {"Content-Type": "application/json"}
        if self.token:
            h["Authorization"] = f"Bearer {self.token}"
        return h

    def _post(self, path, data=None):
        url = f"{self.base}{path}"
        r = self.session.post(url, json=data, headers=self._headers(), timeout=30)
        return r

    def _get(self, path, params=None):
        url = f"{self.base}{path}"
        r = self.session.get(url, params=params, headers=self._headers(), timeout=30)
        return r

    def _put(self, path, data=None):
        url = f"{self.base}{path}"
        r = self.session.put(url, json=data, headers=self._headers(), timeout=30)
        return r

    def _delete(self, path):
        url = f"{self.base}{path}"
        r = self.session.delete(url, headers=self._headers(), timeout=30)
        return r

    # ── Health ──
    def health(self):
        return self._get("/health")

    # ── Auth ──
    def register(self, user_data):
        return self._post("/auth/register", user_data)

    def login(self, identifier, password):
        r = self._post("/auth/login", {"identifier": identifier, "password": password})
        if r.status_code == 200:
            body = r.json()
            if body.get("data", {}).get("access_token"):
                self.token = body["data"]["access_token"]
        return r

    # ── Auth - Verify Email (OTP) ──
    def verify_email(self, code):
        return self._post("/auth/verify-email", {"code": code})

    # ── Learning Paths ──
    def create_path(self, data):
        return self._post("/learningpaths", data)

    def get_paths(self):
        return self._get("/learningpaths")

    def start_path(self, path_id, user_id):
        return self._post(f"/learningpaths/{path_id}/start", {"user_id": user_id})

    # ── Nodes ──
    def create_node(self, path_id, data):
        return self._post(f"/learningpaths/{path_id}/nodes", data)

    def get_nodes(self, path_id):
        return self._get(f"/learningpaths/{path_id}/nodes")

    # ── Materials ──
    def create_material(self, node_id, data):
        return self._post(f"/learningpaths/nodes/{node_id}/materials", data)

    # ── Questions ──
    def create_question(self, node_id, data):
        return self._post(f"/learningpaths/nodes/{node_id}/questions", data)

    # ── Choices ──
    def create_choice(self, question_id, data):
        return self._post(f"/learningpaths/questions/{question_id}/choices", data)

    # ── Albums ──
    def create_album(self, data):
        return self._post("/albums", data)

    def get_albums(self, user_id):
        return self._get("/albums", params={"user_id": user_id})

    # ── Trees ──
    def create_tree(self, data):
        return self._post("/trees", data)

    def get_trees(self, album_id):
        return self._get("/trees", params={"album_id": album_id})

    # ── Tree Nodes ──
    def create_tree_node(self, data):
        return self._post("/tree-nodes", data)

    # ── Reflections ──
    def create_reflection(self, data):
        return self._post("/reflections", data)


# ──────────────────────────── SEEDER ──────────────────────────────────

class Seeder:
    def __init__(self, base_url, skip_verify=False, full_seed=False):
        self.api = PassionTreeAPI(base_url)
        self.skip_verify = skip_verify
        self.full_seed = full_seed
        self.created_users = {}       # username -> {user_id, token}
        self.created_paths = []       # [{path_id, title, creator}]
        self.created_nodes = {}       # path_id -> [{node_id, title}]
        self.created_albums = []      # [{album_id, user_id}]
        self.created_trees = []       # [{tree_id, album_id}]
        self.created_tree_nodes = []  # [{tree_node_id, tree_id}]
        self.stats = {"success": 0, "fail": 0}

    # ─── Login Existing User (farlos3) ───
    def login_existing_user(self):
        head("Step 1: Login Existing User (farlos3)")
        user = EXISTING_USER
        info(f"Logging in as: {user['username']} (ID: {user['user_id']})")

        r = self.api.login(user["username"], user["password"])
        if r.status_code == 200:
            body = r.json()
            token = body.get("data", {}).get("access_token")
            if token:
                self.api.token = token
                self.created_users[user["username"]] = {
                    "user_id": user["user_id"],
                    "role": user["role"],
                    "token": token,
                }
                ok(f"Logged in as {user['username']}")
            else:
                msg = body.get("message", "")
                if "verification_required" in msg or "code sent" in msg.lower():
                    info(f"OTP required: {msg}")
                    self._handle_otp(user)
                else:
                    fail(f"Login response has no token: {msg}")
        else:
            try:
                detail = r.json()
            except Exception:
                detail = r.text[:200]
            fail(f"Login failed - HTTP {r.status_code}: {detail}")

    def _handle_otp(self, user):
        """Prompt user to enter OTP code from email, then verify"""
        print()
        print(f"  {C.BOLD}{C.YELLOW}┌──────────────────────────────────────────┐{C.END}")
        print(f"  {C.BOLD}{C.YELLOW}│  📧 กรุณากรอกรหัส OTP 6 หลักจากอีเมล   │{C.END}")
        print(f"  {C.BOLD}{C.YELLOW}└──────────────────────────────────────────┘{C.END}")
        print()

        max_attempts = 3
        for attempt in range(1, max_attempts + 1):
            try:
                code = input(f"  {C.CYAN}OTP Code ({attempt}/{max_attempts}): {C.END}").strip()
            except (EOFError, KeyboardInterrupt):
                print()
                fail("Cancelled by user")
                return

            if not code:
                fail("Code cannot be empty")
                continue

            if len(code) != 6 or not code.isdigit():
                fail("Please enter a 6-digit numeric code")
                continue

            info(f"Verifying OTP: {code}")
            r = self.api.verify_email(code)

            if r.status_code == 200:
                body = r.json()
                token = body.get("data", {}).get("access_token")
                if token:
                    self.api.token = token
                    self.created_users[user["username"]] = {
                        "user_id": user["user_id"],
                        "role": user["role"],
                        "token": token,
                    }
                    ok(f"OTP verified! Logged in as {user['username']}")
                    return
                else:
                    fail(f"Verified but no token: {body}")
            else:
                try:
                    detail = r.json()
                except Exception:
                    detail = r.text[:200]
                fail(f"OTP verify failed: {detail}")

        fail(f"Max attempts ({max_attempts}) reached")

    def _track(self, r, entity_name, expected_status=None):
        """Track success/failure of API call"""
        expected = expected_status or [200, 201]
        if not isinstance(expected, list):
            expected = [expected]

        if r.status_code in expected:
            self.stats["success"] += 1
            return True
        else:
            self.stats["fail"] += 1
            try:
                detail = r.json()
            except Exception:
                detail = r.text[:200]
            fail(f"{entity_name} - HTTP {r.status_code}: {detail}")
            return False

    # ─── Step 1: Health Check ───
    def check_health(self):
        head("Step 0: Health Check")
        try:
            r = self.api.health()
            if r.status_code == 200:
                ok(f"Backend is healthy: {r.json()}")
                return True
            else:
                fail(f"Backend unhealthy: {r.status_code}")
                return False
        except requests.ConnectionError:
            fail(f"Cannot connect to backend at {self.api.base}")
            fail("Make sure the backend is running!")
            return False

    # ─── Step 2: Register Users ───
    def register_users(self):
        head("Step 1: Register Users (Teachers + Students)")
        all_users = TEACHERS + STUDENTS

        for user in all_users:
            info(f"Registering {user['role']}: {user['username']}")
            r = self.api.register(user)

            if r.status_code in [200, 201]:
                body = r.json()
                user_id = body.get("data", {}).get("user_id", "unknown")
                self.created_users[user["username"]] = {
                    "user_id": user_id,
                    "role": user["role"],
                    "password": user["password"],
                }
                ok(f"Registered {user['username']} (ID: {user_id})")
            elif r.status_code == 409 or "already exists" in r.text.lower() or "duplicate" in r.text.lower():
                ok(f"{user['username']} already exists, will try to login")
                self.created_users[user["username"]] = {
                    "user_id": None,
                    "role": user["role"],
                    "password": user["password"],
                }
            else:
                self._track(r, f"Register {user['username']}")

    # ─── Step 3: Login Users ───
    def login_users(self):
        head("Step 2: Login Users & Get Tokens")

        for username, data in self.created_users.items():
            info(f"Logging in: {username}")
            r = self.api.login(username, data["password"])

            if r.status_code == 200:
                body = r.json()
                token = body.get("data", {}).get("access_token")
                if token:
                    data["token"] = token
                    ok(f"Logged in {username}")
                else:
                    msg = body.get("message", "")
                    if "verification" in msg.lower():
                        fail(f"{username}: Email verification required - {msg}")
                        if self.skip_verify:
                            info("--skip-verify flag set, continuing without token")
                    else:
                        ok(f"{username}: {msg}")
            else:
                self._track(r, f"Login {username}")

    # ─── Step 4: Create Learning Paths + Nodes ───
    def create_learning_paths(self):
        head("Step 2: Create Learning Paths")

        # Use existing user (farlos3) to create paths
        creator_id = EXISTING_USER["user_id"]
        info(f"Using creator: {EXISTING_USER['username']} (ID: {creator_id})")

        for i, path_data in enumerate(LEARNING_PATHS):

            nodes_data = path_data.pop("nodes", [])

            create_data = {
                "title": path_data["title"],
                "objective": path_data["objective"],
                "description": path_data["description"],
                "cover_img_url": path_data["cover_img_url"],
                "publish_status": path_data["publish_status"],
                "creator_id": creator_id or "",
            }

            info(f"Creating path: {path_data['title']}")
            r = self.api.create_path(create_data)

            if self._track(r, f"Create path '{path_data['title']}'", [200, 201]):
                body = r.json()
                path_id = body.get("data", {}).get("path_id")
                if path_id:
                    ok(f"Created path: {path_data['title']} (ID: {path_id})")
                    self.created_paths.append({
                        "path_id": path_id,
                        "title": path_data["title"],
                        "creator": EXISTING_USER["username"],
                    })

                    # Create nodes for this path
                    self._create_nodes_for_path(path_id, nodes_data)

            # Re-add nodes back
            path_data["nodes"] = nodes_data

    def _create_nodes_for_path(self, path_id, nodes_data):
        """Create nodes with materials and questions for a learning path"""
        self.created_nodes[path_id] = []

        for node_data in nodes_data:
            materials = node_data.get("materials", [])
            questions = node_data.get("questions", [])

            # Build node request with inline materials and questions
            node_req = {
                "title": node_data["title"],
                "description": node_data["description"],
                "path_id": path_id,
                "sequence": node_data["sequence"],
            }

            # Add materials
            if materials:
                node_req["material"] = [
                    {"type": m["type"], "url": m["url"]}
                    for m in materials
                ]

            # Add questions with choices
            if questions:
                node_req["Question"] = []
                for q in questions:
                    q_item = {
                        "question_text": q["question_text"],
                        "type": q["type"],
                    }
                    if q.get("choices"):
                        q_item["choice"] = [
                            {
                                "choice_text": ch["choice_text"],
                                "is_correct": ch["is_correct"],
                                "reasoning": ch.get("reasoning", ""),
                            }
                            for ch in q["choices"]
                        ]
                    node_req["Question"].append(q_item)

            info(f"  Creating node: {node_data['title']}")
            r = self.api.create_node(path_id, node_req)

            if self._track(r, f"Create node '{node_data['title']}'", [200, 201]):
                body = r.json()
                node_id = body.get("data", {}).get("node_id")
                if node_id:
                    ok(f"  Node created: {node_data['title']} (ID: {node_id})")
                    self.created_nodes[path_id].append({
                        "node_id": node_id,
                        "title": node_data["title"],
                    })

    # ─── Step 5: Enroll Students ───
    def enroll_students(self):
        head("Step 4: Enroll Students in Learning Paths")

        students = [(u, d) for u, d in self.created_users.items() if d["role"] == "student" and d.get("token")]
        published_paths = [p for p in self.created_paths]

        if not students:
            fail("No students with tokens found!")
            return

        if not published_paths:
            fail("No learning paths created!")
            return

        for student_username, student_data in students:
            self.api.token = student_data["token"]
            # Enroll each student in 2-3 paths
            paths_to_enroll = published_paths[:3]

            for path in paths_to_enroll:
                info(f"Enrolling {student_username} in '{path['title']}'")
                r = self.api.start_path(path["path_id"], student_data.get("user_id", ""))

                if self._track(r, f"Enroll {student_username}", [200, 201]):
                    ok(f"Enrolled {student_username} in {path['title']}")

    # ─── Step 6: Create Albums & Trees ───
    def create_albums_and_trees(self):
        head("Step 5: Create Albums, Trees, and Tree Nodes")

        students = [(u, d) for u, d in self.created_users.items() if d["role"] == "student" and d.get("token")]

        if not students:
            fail("No students with tokens found!")
            return

        # Use first student
        student_username, student_data = students[0]
        self.api.token = student_data["token"]
        user_id = student_data.get("user_id", "")

        # Create albums
        for album_data in ALBUMS:
            album_req = {
                "user_id": user_id,
                "album_name": album_data["album_name"],
                "cover_image_url": album_data["cover_image_url"],
            }
            info(f"Creating album: {album_data['album_name']}")
            r = self.api.create_album(album_req)

            if self._track(r, f"Create album '{album_data['album_name']}'", [200, 201]):
                body = r.json()
                album_id = body.get("data", {}).get("album_id")
                if not album_id and isinstance(body.get("data"), dict):
                    album_id = body["data"].get("album_id")
                if album_id:
                    ok(f"Created album: {album_data['album_name']} (ID: {album_id})")
                    self.created_albums.append({
                        "album_id": album_id,
                        "user_id": user_id,
                        "album_name": album_data["album_name"],
                    })

        # Create trees (link to albums & learning paths)
        if self.created_albums and self.created_paths:
            for i, album in enumerate(self.created_albums):
                if i < len(self.created_paths):
                    path = self.created_paths[i]
                    tree_req = {
                        "title": f"ต้นไม้ - {path['title']}",
                        "difficulties": "medium",
                        "path_id": path["path_id"],
                        "album_id": album["album_id"],
                    }
                    info(f"Creating tree for path: {path['title']}")
                    r = self.api.create_tree(tree_req)

                    if self._track(r, f"Create tree", [200, 201]):
                        body = r.json()
                        tree_id = body.get("data", {}).get("tree_id")
                        if not tree_id and isinstance(body.get("data"), dict):
                            tree_id = body["data"].get("tree_id")
                        if tree_id:
                            ok(f"Created tree (ID: {tree_id})")
                            self.created_trees.append({
                                "tree_id": tree_id,
                                "album_id": album["album_id"],
                                "path_id": path["path_id"],
                            })

                            # Create tree nodes from learning path nodes
                            self._create_tree_nodes(tree_id, path["path_id"])

    def _create_tree_nodes(self, tree_id, path_id):
        """Create tree nodes from learning path nodes"""
        nodes = self.created_nodes.get(path_id, [])

        for node in nodes:
            tree_node_req = {
                "node_title": node["title"],
                "node_id": node["node_id"],
                "tree_id": tree_id,
            }
            info(f"  Creating tree node: {node['title']}")
            r = self.api.create_tree_node(tree_node_req)

            if self._track(r, f"Create tree node", [200, 201]):
                body = r.json()
                tree_node_id = body.get("data", {}).get("tree_node_id")
                if not tree_node_id and isinstance(body.get("data"), dict):
                    tree_node_id = body["data"].get("tree_node_id")
                if tree_node_id:
                    ok(f"  Created tree node (ID: {tree_node_id})")
                    self.created_tree_nodes.append({
                        "tree_node_id": tree_node_id,
                        "tree_id": tree_id,
                        "node_title": node["title"],
                    })

    # ─── Step 7: Create Reflections ───
    def create_reflections(self):
        head("Step 6: Create Reflections")

        if not self.created_tree_nodes:
            fail("No tree nodes created! Skipping reflections.")
            return

        students = [(u, d) for u, d in self.created_users.items() if d["role"] == "student" and d.get("token")]
        if not students:
            fail("No students with tokens found!")
            return

        student_username, student_data = students[0]
        self.api.token = student_data["token"]

        reflections_data = [
            {
                "learning_reflect": "วันนี้ได้เรียนรู้เรื่องเซลล์และโครงสร้างของมัน เข้าใจหน้าที่ของไมโทคอนเดรียชัดมากขึ้น",
                "mood_reflect": "รู้สึกตื่นเต้นและสนุกกับการเรียน อยากเรียนรู้เพิ่มเติมเกี่ยวกับชีววิทยา",
                "feel_score": 4,
                "progress_score": 3,
                "challenge_score": 2,
            },
            {
                "learning_reflect": "HTML/CSS basics was easier than expected. I feel confident about building simple web pages now.",
                "mood_reflect": "Excited to learn more, but a bit nervous about JavaScript coming up next.",
                "feel_score": 5,
                "progress_score": 4,
                "challenge_score": 1,
            },
            {
                "learning_reflect": "เรื่องพันธะเคมียากนิดหนึ่ง แต่พอทำ quiz แล้วเข้าใจมากขึ้น",
                "mood_reflect": "เหนื่อยนิดหน่อย แต่ภูมิใจที่ทำได้",
                "feel_score": 3,
                "progress_score": 3,
                "challenge_score": 4,
            },
        ]

        for i, tree_node in enumerate(self.created_tree_nodes[:len(reflections_data)]):
            reflection = reflections_data[i].copy()
            reflection["tree_node_id"] = tree_node["tree_node_id"]

            info(f"Creating reflection for node: {tree_node['node_title']}")
            r = self.api.create_reflection(reflection)

            if self._track(r, f"Create reflection", [200, 201]):
                ok(f"Created reflection for '{tree_node['node_title']}'")

    # ─── Run All ───
    def run(self):
        print(f"\n{C.BOLD}{C.CYAN}")
        print("  ╔══════════════════════════════════════════╗")
        print("  ║   🌳 Passion Tree - Mock Data Seeder    ║")
        print("  ╚══════════════════════════════════════════╝")
        print(f"{C.END}")
        info(f"Target: {self.api.base}")

        if not self.check_health():
            return

        # Login with existing user (farlos3)
        self.login_existing_user()

        # Check if we have token
        if not self.api.token:
            head("STOPPED")
            fail("Could not login with existing user!")
            return

        self.create_learning_paths()

        # Optionally register & enroll students, create albums etc.
        if self.full_seed:
            self.register_users()
            self.login_users()
            self.enroll_students()
            self.create_albums_and_trees()
            self.create_reflections()

        # Summary
        head("SUMMARY")
        print(f"  {C.GREEN}✓ Success: {self.stats['success']}{C.END}")
        print(f"  {C.RED}✗ Failed:  {self.stats['fail']}{C.END}")
        print()
        print(f"  Created data:")
        print(f"    Users:          {len(self.created_users)}")
        print(f"    Learning Paths: {len(self.created_paths)}")
        print(f"    Nodes:          {sum(len(v) for v in self.created_nodes.values())}")
        print(f"    Albums:         {len(self.created_albums)}")
        print(f"    Trees:          {len(self.created_trees)}")
        print(f"    Tree Nodes:     {len(self.created_tree_nodes)}")
        print()

        # Save created IDs to file for reference
        self._save_report()

    def _save_report(self):
        """Save created IDs to a JSON file for reference"""
        report = {
            "users": self.created_users,
            "learning_paths": self.created_paths,
            "nodes": {k: v for k, v in self.created_nodes.items()},
            "albums": self.created_albums,
            "trees": self.created_trees,
            "tree_nodes": self.created_tree_nodes,
        }

        # Remove tokens from report
        for user in report["users"].values():
            user.pop("token", None)
            user.pop("password", None)

        report_path = "data_mock.json"
        try:
            with open(report_path, "w", encoding="utf-8") as f:
                json.dump(report, f, indent=2, ensure_ascii=False)
            ok(f"Report saved to: {report_path}")
        except Exception as e:
            fail(f"Could not save report: {e}")


# ──────────────────────────── MAIN ────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="Passion Tree - Mock Data Seeder",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python mock_data_seed.py
  python mock_data_seed.py --base-url http://localhost:8080
  python mock_data_seed.py --skip-verify
        """,
    )
    parser.add_argument(
        "--base-url",
        default=DEFAULT_BASE_URL,
        help=f"Backend base URL (default: {DEFAULT_BASE_URL})",
    )
    parser.add_argument(
        "--skip-verify",
        action="store_true",
        help="Skip email verification requirement",
    )
    parser.add_argument(
        "--full",
        action="store_true",
        help="Full seed: also register students, enroll, create albums/trees/reflections",
    )

    args = parser.parse_args()

    seeder = Seeder(base_url=args.base_url, skip_verify=args.skip_verify, full_seed=args.full)
    seeder.run()


if __name__ == "__main__":
    main()
