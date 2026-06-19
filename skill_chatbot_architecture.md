# Skill: Kien truc Chatbot & LLM (Chatbot Architecture Skill)

## Muc tieu

Quy dinh tieu chuan hoa module `chatbot/` nham dam bao tinh doc lap, chuyen sau ve logic AI/LLM va de bao tri.

---

## 1. Cau truc Thu muc Chuan

```text
chatbot/
├── services/               # Chua cac luong logic LangGraph
│   ├── rag_chat_service.py
│   └── multi_agent_service.py
└── utils/                  # Cac thanh phan don le
    ├── llm.py              # LLM Factory: Khoi tao OpenAI, Gemini, Grok...
    ├── prompt.py           # Class tap trung quan ly Prompt Templates
    ├── graph_state.py      # Dinh nghia State (TypedDict) cho LangGraph
    ├── {name}_agent.py     # Cac Agent don le
    └── {name}_tool.py      # Cong cu ho tro Agent
```

---

## 2. Quy tac Thiet ke Thanh phan

- **LLM Factory** (`utils/llm.py`): Tat ca thanh phan dung chung mot Class khoi tao LLM.
- **Centralized Prompts** (`utils/prompt.py`): Mot Class duy nhat chua tat ca Prompt. Ten hang so viet HOA.
- **Atomic Agents** (`utils/*_agent.py`): Moi Agent chi lam mot viec (Single Responsibility).
- **LangGraph Workflows** (`services/`): Moi service la mot luong StateGraph hoan chinh.

---

## 3. Luong Hoat dong Tieu chuan

1. Entry Point: Router goi ham trong `chatbot/services/`
2. Khoi tao `StateGraph` voi `GraphState`
3. Thuc thi cac Nodes qua Agent trong `utils/`
4. Kiem tra dieu kien, re nhanh hoac ket thuc
5. Tra ve du lieu JSON sach cho Router

---

## Quy tac bat buoc

1. KHONG de code Ingestion hoac DB Model trong `chatbot/`
2. Moi Agent chi chua mot chuc nang duy nhat
3. Su dung LLM Factory, khong khoi tao LLM rieng le
4. Prompt tap trung trong `prompt.py`, khong rai rac
5. Bat buoc clean_json truoc khi xu ly du lieu tu LLM
6. Retry trong RAG neu khong tim thay tai lieu

---

## File lien quan

- [AI RAG Workflow](./skill_ai_rag_workflow.md)
- [Cau truc Du an Tieu chuan (Skill DuyVo26)](./skill_project_structure.md)
- [Ket noi OpenRouter](./skill_openrouter_integration.md)
- [Tieu chuan Viet Code (Coding Conventions)](./skill_coding_conventions.md)
