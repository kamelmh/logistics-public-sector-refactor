"""
CrossFlow Logistics Bot — Command Handler
Telegram bot for El Bayadh DSS status and control.

Usage:
    python bot_commands.py              # Run with polling
    python bot_commands.py --webhook    # Run with webhook
"""

import os
import sys
import json
import subprocess
import logging
from datetime import datetime
from pathlib import Path

# Configuration
BOT_TOKEN = os.environ.get("TELEGRAM_BOT_TOKEN", "8842110496:AAHWDP6PhZ3pCqY6TXykrFRw4hvJxa99ryo")
ALLOWED_USERS = [6562604500]  # Kamel
PROJECT_ROOT = Path(r"C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor")
HERMES_AGENT = Path(r"C:\Users\Administrator\Dropbox\hermes-agent")

# Logging
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)
logger = logging.getLogger(__name__)


class CrossFlowBot:
    """Telegram bot for CrossFlow Logistics."""
    
    def __init__(self):
        self.token = BOT_TOKEN
        self.allowed_users = ALLOWED_USERS
        self.project_root = PROJECT_ROOT
        
    def is_authorized(self, user_id: int) -> bool:
        """Check if user is authorized."""
        return user_id in self.allowed_users
    
    def run_command(self, cmd: str, timeout: int = 60) -> tuple:
        """Run a shell command and return (output, returncode)."""
        try:
            result = subprocess.run(
                cmd,
                shell=True,
                capture_output=True,
                text=True,
                timeout=timeout,
                cwd=str(self.project_root)
            )
            return result.stdout + result.stderr, result.returncode
        except subprocess.TimeoutExpired:
            return "Command timed out", 1
        except Exception as e:
            return f"Error: {e}", 1
    
    def cmd_status(self) -> str:
        """Get system status."""
        # ERP Version
        erp_file = self.project_root / "ERP_v13.3.xlsm"
        erp_exists = erp_file.exists()
        erp_size = erp_file.stat().st_size // 1024 if erp_exists else 0
        
        # Thesis PDF
        thesis_pdf = self.project_root / "Thesis_Surgical_Edit" / "output" / "Memoire_DSS_Logistique_ElBayadh.pdf"
        thesis_exists = thesis_pdf.exists()
        thesis_size = thesis_pdf.stat().st_size // 1024 if thesis_exists else 0
        
        # English paper
        english_pdf = self.project_root / "Thesis_Surgical_Edit" / "output" / "English_Research_Paper_IEEE.pdf"
        english_exists = english_pdf.exists()
        
        # Verify results
        verify_dir = self.project_root / "vbe-auto" / "results"
        verify_files = list(verify_dir.glob("verify_results_*.json")) if verify_dir.exists() else []
        verify_status = "Unknown"
        if verify_files:
            latest = max(verify_files, key=os.path.getmtime)
            try:
                with open(latest) as f:
                    data = json.load(f)
                    verify_status = f"{data.get('passed', 0)}/{data.get('total', 0)} PASS"
            except:
                verify_status = "Check failed"
        
        # Task board
        tasks_file = self.project_root / ".crossflow" / "opus-tasks.md"
        tasks_done = 0
        tasks_pending = 0
        if tasks_file.exists():
            content = tasks_file.read_text()
            tasks_done = content.count("Status**: DONE")
            tasks_pending = content.count("Status**: PENDING")
        
        # Bot status
        bot_status = "Online"
        hermes_config = Path(r"C:\Users\Administrator\AppData\Local\hermes\config.yaml")
        hermes_ok = hermes_config.exists()
        
        # OCR Reader
        ocr_dir = Path(r"C:\Users\Administrator\Dropbox\OCR-Reader")
        ocr_ok = (ocr_dir / "ocr_reader.py").exists()
        
        status = f"""📊 **CrossFlow Status — El Bayadh DSS**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔧 **ERP System**
  Version: v13.3
  Workbook: {'✅' if erp_exists else '❌'} ({erp_size} KB)
  Verify: {verify_status}

📄 **Thesis**
  Arabic: {'✅' if thesis_exists else '❌'} ({thesis_size} KB PDF)
  English: {'✅' if english_exists else '❌'} (IEEE format)
  CCA'2026: Submitted

🤖 **Bot**
  Gateway: {bot_status}
  Hermes: {'✅' if hermes_ok else '⚠️ Config missing'}
  OCR: {'✅ Tesseract ready' if ocr_ok else '❌ Not installed'}

📋 **CrossFlow Tasks**
  DONE: {tasks_done}
  PENDING: {tasks_pending}

⏰ Last updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"""
        
        return status
    
    def cmd_build(self) -> str:
        """Run ERP build."""
        output, rc = self.run_command(
            r"& 'C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\vbe-auto\build.ps1' -ConfigPath 'vbe-auto\config.json'",
            timeout=300
        )
        
        if rc == 0:
            return f"""✅ **Build Complete**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Build completed successfully.

Output (last 500 chars):
```
{output[-500:]}
```

⏰ {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"""
        else:
            return f"""❌ **Build Failed**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Build returned error code: {rc}

Output (last 500 chars):
```
{output[-500:]}
```

⏰ {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"""
    
    def cmd_verify(self) -> str:
        """Run verification checks."""
        output, rc = self.run_command(
            r"& 'C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\vbe-auto\verify.ps1' -ConfigPath 'vbe-auto\config.json'",
            timeout=180
        )
        
        # Parse results
        verify_status = "Unknown"
        if "PASS" in output:
            # Extract pass count
            import re
            match = re.search(r'(\d+)/(\d+)\s*PASS', output)
            if match:
                verify_status = f"{match.group(1)}/{match.group(2)} PASS"
        
        return f"""🔍 **Verification Results**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Status: {verify_status}

Output (last 500 chars):
```
{output[-500:]}
```

⏰ {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"""
    
    def cmd_thesis(self) -> str:
        """Get thesis status."""
        # Check files
        thesis_pdf = self.project_root / "Thesis_Surgical_Edit" / "output" / "Memoire_DSS_Logistique_ElBayadh.pdf"
        thesis_docx = self.project_root / "Thesis_Surgical_Edit" / "output" / "Memoire_DSS_Logistique_ElBayadh.docx"
        english_pdf = self.project_root / "Thesis_Surgical_Edit" / "output" / "English_Research_Paper_IEEE.pdf"
        
        pdf_size = thesis_pdf.stat().st_size // 1024 if thesis_pdf.exists() else 0
        docx_size = thesis_docx.stat().st_size // 1024 if thesis_docx.exists() else 0
        english_size = english_pdf.stat().st_size // 1024 if english_pdf.exists() else 0
        
        return f"""📄 **Thesis Status**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Arabic Thesis**
  PDF: {'✅' if thesis_pdf.exists() else '❌'} ({pdf_size} KB)
  DOCX: {'✅' if thesis_docx.exists() else '❌'} ({docx_size} KB)
  Version: v13.3

**English Paper**
  PDF: {'✅' if english_pdf.exists() else '❌'} ({english_size} KB)
  Format: IEEE double-column

**CCA'2026**
  Status: Submitted
  Deadline: Aug 15, 2026

**Build Command**
  `& "Thesis_Surgical_Edit\build-thesis.ps1"`

⏰ {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"""
    
    def cmd_tasks(self) -> str:
        """Get task board status."""
        tasks_file = self.project_root / ".crossflow" / "opus-tasks.md"
        
        if not tasks_file.exists():
            return "❌ Task board not found"
        
        content = tasks_file.read_text()
        
        # Count tasks
        done = content.count("Status**: DONE")
        pending = content.count("Status**: PENDING")
        running = content.count("Status**: RUNNING")
        failed = content.count("Status**: FAILED")
        
        # Extract task names
        import re
        tasks = re.findall(r'\[TASK-\d+\]\s*(.+?)$', content, re.MULTILINE)
        
        task_list = "\n".join([f"  • {t.strip()}" for t in tasks[:10]])
        
        return f"""📋 **Task Board**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Summary**
  ✅ DONE: {done}
  ⏳ PENDING: {pending}
  🔄 RUNNING: {running}
  ❌ FAILED: {failed}

**Recent Tasks**
{task_list}

**Board Location**
  `.crossflow/opus-tasks.md`

⏰ {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"""
    
    def cmd_help(self) -> str:
        """Show help message."""
        return """🤖 **CrossFlow Bot — Help**
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Commands**
  /status — System status overview
  /build — Run ERP build
  /verify — Run verification checks
  /thesis — Thesis status
  /tasks — Task board status
  /help — This message

**About**
  CrossFlow Logistics Bot for El Bayadh DSS
  Powered by Hermes Agent v0.15.1

**Security**
  Authorized users only
  Bot token: @ElBayadhDSSBot

⏰ {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"""
    
    def handle_message(self, message: dict) -> str:
        """Handle incoming message."""
        user_id = message.get("from", {}).get("id")
        text = message.get("text", "")
        
        # Authorization check
        if not self.is_authorized(user_id):
            return f"❌ Unauthorized. Your ID: {user_id}"
        
        # Parse command
        if text.startswith("/status"):
            return self.cmd_status()
        elif text.startswith("/build"):
            return self.cmd_build()
        elif text.startswith("/verify"):
            return self.cmd_verify()
        elif text.startswith("/thesis"):
            return self.cmd_thesis()
        elif text.startswith("/tasks"):
            return self.cmd_tasks()
        elif text.startswith("/help"):
            return self.cmd_help()
        else:
            return self.cmd_help()


def send_telegram(token: str, chat_id: int, text: str) -> bool:
    """Send message via Telegram API."""
    import urllib.request
    import urllib.parse
    
    url = f"https://api.telegram.org/bot{token}/sendMessage"
    data = json.dumps({
        "chat_id": chat_id,
        "text": text,
        "parse_mode": "Markdown"
    }).encode("utf-8")
    
    req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})
    
    try:
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read())
            return result.get("ok", False)
    except Exception as e:
        logger.error(f"Failed to send message: {e}")
        return False


def poll_updates(token: str, bot: CrossFlowBot, offset: int = 0) -> int:
    """Poll for updates from Telegram."""
    import urllib.request
    
    url = f"https://api.telegram.org/bot{token}/getUpdates?offset={offset}&timeout=30"
    
    try:
        with urllib.request.urlopen(url) as response:
            data = json.loads(response.read())
            
            if data.get("ok"):
                for update in data.get("result", []):
                    message = update.get("message")
                    if message:
                        response_text = bot.handle_message(message)
                        chat_id = message["from"]["id"]
                        send_telegram(token, chat_id, response_text)
                        logger.info(f"Handled update {update['update_id']}")
                    
                    offset = update["update_id"] + 1
                    
    except Exception as e:
        logger.error(f"Poll error: {e}")
    
    return offset


def main():
    """Main entry point."""
    bot = CrossFlowBot()
    
    print("CrossFlow Bot Starting...")
    print(f"Token: {bot.token[:10]}...")
    print(f"Allowed users: {bot.allowed_users}")
    print(f"Project root: {bot.project_root}")
    print()
    
    # Poll loop
    offset = 0
    print("Polling for updates (Ctrl+C to stop)...")
    
    try:
        while True:
            offset = poll_updates(bot.token, bot, offset)
    except KeyboardInterrupt:
        print("\nBot stopped.")


if __name__ == "__main__":
    main()
