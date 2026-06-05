"""CrossFlow FTS5 Search — full-text search across task results and knowledge base."""

import sqlite3
import json
from pathlib import Path

class CrossFlowSearch:
    def __init__(self, crossflow_dir: str):
        self.crossflow_dir = Path(crossflow_dir)
        self.db_path = self.crossflow_dir / "search.db"
        self.conn = None
    
    def initialize(self):
        """Initialize FTS5 database."""
        self.conn = sqlite3.connect(str(self.db_path))
        self.conn.execute("""
            CREATE VIRTUAL TABLE IF NOT EXISTS search_index USING fts5(
                source,
                task_id,
                title,
                content,
                metadata,
                tokenize='porter unicode61'
            )
        """)
    
    def index_content(self):
        """Index all content from results, knowledge, and skills."""
        # Clear existing
        self.conn.execute("DELETE FROM search_index")
        
        # Index opus-results.md
        results_file = self.crossflow_dir / "opus-results.md"
        if results_file.exists():
            content = results_file.read_text(encoding='utf-8')
            blocks = content.split('### [TASK-')
            
            for block in blocks:
                if block.startswith('TASK-'):
                    lines = block.split('\n')
                    if lines:
                        # Extract task ID and title
                        header = lines[0]
                        if '] ' in header:
                            task_id = header.split(']')[0].replace('[', '')
                            title = header.split(']')[1].strip()
                            
                            # Extract output
                            output = ""
                            in_output = False
                            for line in lines:
                                if '**Output**:' in line:
                                    in_output = True
                                    continue
                                if in_output and line.startswith('---'):
                                    break
                                if in_output:
                                    output += line + '\n'
                            
                            self.conn.execute(
                                "INSERT INTO search_index (source, task_id, title, content, metadata) VALUES (?, ?, ?, ?, ?)",
                                ("results", task_id, title, output.strip(), "")
                            )
        
        # Index knowledge-base.json
        kb_file = self.crossflow_dir / "knowledge-base.json"
        if kb_file.exists():
            kb = json.loads(kb_file.read_text(encoding='utf-8'))
            for item in kb:
                self.conn.execute(
                    "INSERT INTO search_index (source, task_id, title, content, metadata) VALUES (?, ?, ?, ?, ?)",
                    ("knowledge", item.get('task_id', ''), item.get('type', ''), item.get('content', ''), json.dumps(item.get('metadata', {})))
                )
        
        # Index skills
        skills_dir = self.crossflow_dir / "skills"
        if skills_dir.exists():
            for skill_file in skills_dir.glob("*.md"):
                content = skill_file.read_text(encoding='utf-8')
                self.conn.execute(
                    "INSERT INTO search_index (source, task_id, title, content, metadata) VALUES (?, ?, ?, ?, ?)",
                    ("skills", skill_file.stem, skill_file.name, content, "")
                )
        
        self.conn.commit()
        print(f"  Indexed content from opus-results.md, knowledge-base.json, skills/")
    
    def search(self, query: str, source: str = "all", limit: int = 10):
        """Search using FTS5."""
        sql = "SELECT source, task_id, title, snippet(search_index, 3, '<b>', '</b>', '...', 32) as snippet, rank FROM search_index WHERE search_index MATCH ?"
        params = [query]
        
        if source != "all":
            sql += " AND source = ?"
            params.append(source)
        
        sql += " ORDER BY rank LIMIT ?"
        params.append(limit)
        
        cursor = self.conn.execute(sql, params)
        results = []
        for row in cursor.fetchall():
            results.append({
                'source': row[0],
                'task_id': row[1],
                'title': row[2],
                'snippet': row[3],
                'rank': row[4]
            })
        
        return results
    
    def close(self):
        if self.conn:
            self.conn.close()

if __name__ == "__main__":
    import sys
    
    crossflow_dir = r"C:\Users\Administrator\Dropbox\Logistics.Public.Sector.Refactor\.crossflow"
    search = CrossFlowSearch(crossflow_dir)
    search.initialize()
    search.index_content()
    
    # Test search
    query = sys.argv[1] if len(sys.argv) > 1 else "EOQ formula"
    results = search.search(query)
    
    print(f"\n  Searching: '{query}'")
    print(f"  Found {len(results)} results:\n")
    
    for r in results:
        print(f"  [{r['source']}] {r['task_id']} - {r['title']}")
        print(f"    {r['snippet']}\n")
    
    search.close()
