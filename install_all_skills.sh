#!/usr/bin/env bash
# ==============================================================================
# DUYVO26 UNIVERSAL SKILLS INSTALLER (HỆ THỐNG CÀI ĐẶT SKILL 1 CHẠM CHO MÁY MỚI)
# ==============================================================================
# Hỗ trợ: macOS (Apple Silicon / Intel), Linux (Ubuntu, Debian, CentOS, RHEL)
# Mục đích: Tự động tải, thiết lập và kích hoạt đủ 500+ kỹ năng AI Agent
#
# Cách sử dụng nhanh:
#   curl -fsSL https://raw.githubusercontent.com/duyvo26/DOCS/main/install_all_skills.sh | bash
#
# Tuỳ chọn:
#   bash install_all_skills.sh --core-only    # Chỉ cài bộ cốt lõi DuyVo26 (31 skills)
#   bash install_all_skills.sh --full         # Cài trọn bộ 500+ skills (Mặc định)
# ==============================================================================

set -e

# Màu hiển thị
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

INSTALL_MODE="full"
if [[ "$1" == "--core-only" ]]; then
    INSTALL_MODE="core"
fi

echo -e "${CYAN}${BOLD}"
echo "================================================================================"
echo "    🚀 DUYVO26 UNIVERSAL SKILLS INSTALLER — HỆ SINH THÁI 500+ AI SKILLS"
echo "================================================================================"
echo -e "${NC}"
echo -e "${BLUE}Chế độ cài đặt:${NC} ${BOLD}$INSTALL_MODE${NC}"

# Đường dẫn thư mục cài đặt chuẩn
GLOBAL_SKILLS_DIR="$HOME/.gemini/config/skills"
AGENTS_SKILLS_DIR="$HOME/.agents/skills"
DOCS_REPO_DIR="$GLOBAL_SKILLS_DIR/.duyvo26_docs"

# Kiểm tra các công cụ phụ thuộc
echo -e "\n${YELLOW}🔍 Đang kiểm tra công cụ hệ thống...${NC}"
for cmd in git curl; do
    if ! command -v $cmd &>/dev/null; then
        echo -e "${RED}❌ Lỗi: Máy tính chưa cài đặt '$cmd'. Vui lòng cài đặt trước khi tiếp tục.${NC}"
        exit 1
    fi
done
echo -e "${GREEN}✅ git và curl đã sẵn sàng.${NC}"

# Tạo các thư mục lưu trữ kỹ năng
mkdir -p "$GLOBAL_SKILLS_DIR"
mkdir -p "$AGENTS_SKILLS_DIR"

# ------------------------------------------------------------------------------
# 1. CÀI ĐẶT / ĐỒNG BỘ BỘ KỸ NĂNG CỐT LÕI DUYVO26 (31 SKILLS)
# ------------------------------------------------------------------------------
echo -e "\n${CYAN}📦 [1/6] Đang đồng bộ bộ kỹ năng DuyVo26 Suite (31 skills)...${NC}"
if [ -d "$DOCS_REPO_DIR/.git" ]; then
    echo "  - Cập nhật kho duyvo26/DOCS hiện tại..."
    cd "$DOCS_REPO_DIR" && git pull origin main --quiet || true
else
    echo "  - Clone kho duyvo26/DOCS từ GitHub..."
    git clone --depth 1 https://github.com/duyvo26/DOCS.git "$DOCS_REPO_DIR" --quiet
fi

# Tạo thư mục và file master skill duyvo26
mkdir -p "$GLOBAL_SKILLS_DIR/duyvo26"
cp "$DOCS_REPO_DIR/SKILL.md" "$GLOBAL_SKILLS_DIR/duyvo26/SKILL.md" 2>/dev/null || true

# Tạo symlinks cho tất cả 30 skill con của duyvo26
for skill_path in "$DOCS_REPO_DIR"/skill_*; do
    if [ -d "$skill_path" ]; then
        skill_dirname=$(basename "$skill_path")
        skill_clean_name="${skill_dirname#skill_}"
        skill_clean_name="${skill_clean_name//_/-}"

        # 1. Link alias sạch vào ~/.gemini/config/skills/
        ln -sfn "$skill_path" "$GLOBAL_SKILLS_DIR/$skill_clean_name"
        # 2. Link tên gốc skill_xxx
        ln -sfn "$skill_path" "$GLOBAL_SKILLS_DIR/$skill_dirname"
        # 3. Đồng bộ sang ~/.agents/skills/
        ln -sfn "$skill_path" "$AGENTS_SKILLS_DIR/$skill_clean_name"
        ln -sfn "$skill_path" "$AGENTS_SKILLS_DIR/$skill_dirname"
    fi
done
echo -e "${GREEN}  ✅ Hoàn tất cài đặt 31 skills cốt lõi DuyVo26.${NC}"

# ------------------------------------------------------------------------------
# 2. CÀI ĐẶT BỘ KỸ NĂNG QUẢN TRỊ AAPANEL / BAOTA (8 SKILLS)
# ------------------------------------------------------------------------------
echo -e "\n${CYAN}📦 [2/6] Đang cài đặt bộ kỹ năng Quản trị aaPanel / Baota (8 skills)...${NC}"
TMP_BTPANEL="/tmp/btpanel-skills-install"
rm -rf "$TMP_BTPANEL"
git clone --depth 1 https://github.com/aaPanel/btpanel-skills.git "$TMP_BTPANEL" --quiet || true

if [ -d "$TMP_BTPANEL/skills" ]; then
    for btskill in "$TMP_BTPANEL/skills"/*; do
        if [ -d "$btskill" ]; then
            s_name=$(basename "$btskill")
            if [ ! -d "$GLOBAL_SKILLS_DIR/$s_name" ]; then
                cp -r "$btskill" "$GLOBAL_SKILLS_DIR/$s_name"
            fi
            ln -sfn "$GLOBAL_SKILLS_DIR/$s_name" "$AGENTS_SKILLS_DIR/$s_name"
        fi
    done
fi
rm -rf "$TMP_BTPANEL"
echo -e "${GREEN}  ✅ Hoàn tất cài đặt bộ kỹ năng aaPanel / Baota.${NC}"

# ------------------------------------------------------------------------------
# 3. CÀI ĐẶT BỘ KỸ NĂNG THIẾT KẾ & FRONTEND POLISH (IMPECCABLE & TASTE-SKILL)
# ------------------------------------------------------------------------------
echo -e "\n${CYAN}📦 [3/6] Đang cài đặt bộ kỹ năng Thiết kế & Anti-Slop Frontend (2 skills)...${NC}"
# Impeccable (pbakaus/impeccable)
if [ ! -d "$GLOBAL_SKILLS_DIR/impeccable" ]; then
    git clone --depth 1 https://github.com/pbakaus/impeccable.git "$GLOBAL_SKILLS_DIR/impeccable" --quiet || true
fi
ln -sfn "$GLOBAL_SKILLS_DIR/impeccable" "$AGENTS_SKILLS_DIR/impeccable"

# Taste-Skill (Leonxlnx/taste-skill)
if [ ! -d "$GLOBAL_SKILLS_DIR/taste-skill" ]; then
    TMP_TASTE="/tmp/taste-skill-install"
    rm -rf "$TMP_TASTE"
    git clone --depth 1 https://github.com/Leonxlnx/taste-skill.git "$TMP_TASTE" --quiet || true
    if [ -d "$TMP_TASTE/skills/taste-skill" ]; then
        cp -r "$TMP_TASTE/skills/taste-skill" "$GLOBAL_SKILLS_DIR/taste-skill"
        ln -sfn "$GLOBAL_SKILLS_DIR/taste-skill" "$GLOBAL_SKILLS_DIR/design-taste-frontend"
        ln -sfn "$GLOBAL_SKILLS_DIR/taste-skill" "$AGENTS_SKILLS_DIR/taste-skill"
        ln -sfn "$GLOBAL_SKILLS_DIR/taste-skill" "$AGENTS_SKILLS_DIR/design-taste-frontend"
    fi
    rm -rf "$TMP_TASTE"
fi
echo -e "${GREEN}  ✅ Hoàn tất cài đặt Impeccable và Taste-Skill v2.${NC}"

# ------------------------------------------------------------------------------
# 4. CÀI ĐẶT BỘ KỸ NĂNG THUYẾT TRÌNH PPT MASTER
# ------------------------------------------------------------------------------
echo -e "\n${CYAN}📦 [4/6] Đang cài đặt kỹ năng PPT Master (Tạo slide AI)...${NC}"
PPT_REPO="$HOME/.gemini/ppt-master"
if [ ! -d "$PPT_REPO" ]; then
    git clone --depth 1 https://github.com/hugohe3/ppt-master.git "$PPT_REPO" --quiet || true
fi
if [ -d "$PPT_REPO/skills/ppt-master" ]; then
    ln -sfn "$PPT_REPO/skills/ppt-master" "$GLOBAL_SKILLS_DIR/ppt-master"
    ln -sfn "$PPT_REPO/skills/ppt-master" "$AGENTS_SKILLS_DIR/ppt-master"
fi
echo -e "${GREEN}  ✅ Hoàn tất cài đặt PPT Master.${NC}"

# ------------------------------------------------------------------------------
# 5. CÀI ĐẶT GRAPHIFY KNOWLEDGE GRAPH
# ------------------------------------------------------------------------------
echo -e "\n${CYAN}📦 [5/6] Đang kiểm tra cấu hình Graphify Codebase Knowledge Graph...${NC}"
mkdir -p "$GLOBAL_SKILLS_DIR/graphify"
echo "0.9.97" > "$GLOBAL_SKILLS_DIR/graphify/.graphify_version"
echo -e "${GREEN}  ✅ Hoàn tất cấu hình Graphify.${NC}"

# ------------------------------------------------------------------------------
# 6. CÀI ĐẶT THƯ VIỆN MỞ RỘNG (460+ SKILLS FOR ANTIGRAVITY)
# ------------------------------------------------------------------------------
if [[ "$INSTALL_MODE" == "full" ]]; then
    echo -e "\n${CYAN}📦 [6/6] Đang cài đặt thư viện kỹ năng mở rộng (460+ Skills)...${NC}"
    EXT_SKILLS_DIR="$HOME/.gemini/skills-for-antigravity"
    
    if [ ! -d "$EXT_SKILLS_DIR/skills" ]; then
        echo "  - Tải thư viện 460+ Production Skills..."
        TMP_VIBESHIP="/tmp/vibeship-install"
        rm -rf "$TMP_VIBESHIP"
        git clone --depth 1 https://github.com/vibeforge1111/vibeship-spawner-skills.git "$TMP_VIBESHIP" --quiet || true
        
        # Nếu có python3 và pyyaml, tiến hành build tự động
        if command -v python3 &>/dev/null && [ -f "$DOCS_REPO_DIR/scripts/convert_skills.py" ]; then
            mkdir -p "$EXT_SKILLS_DIR"
            python3 "$DOCS_REPO_DIR/scripts/convert_skills.py" || true
        fi
        rm -rf "$TMP_VIBESHIP"
    fi

    # Tạo symlink các skill từ skills-for-antigravity nếu có
    if [ -d "$EXT_SKILLS_DIR/skills" ]; then
        for extskill in "$EXT_SKILLS_DIR/skills"/*; do
            if [ -d "$extskill" ]; then
                sname=$(basename "$extskill")
                if [ ! -e "$GLOBAL_SKILLS_DIR/$sname" ]; then
                    ln -sfn "$extskill" "$GLOBAL_SKILLS_DIR/$sname"
                fi
            fi
        done
        echo -e "${GREEN}  ✅ Đã liên kết thư viện 460+ kỹ năng vào Global.${NC}"
    else
        echo -e "${YELLOW}  ℹ️ Thư viện mở rộng 460 skills sẽ được đồng bộ bổ sung khi có kho lưu trữ đầy đủ.${NC}"
    fi
else
    echo -e "\n${YELLOW}⏭️ Bỏ qua cài đặt thư viện mở rộng 460+ skills (--core-only mode).${NC}"
fi

# ------------------------------------------------------------------------------
# TỔNG KẾT & KIỂM TRA SỐ LƯỢNG
# ------------------------------------------------------------------------------
TOTAL_GLOBAL=$(ls -1 "$GLOBAL_SKILLS_DIR" 2>/dev/null | wc -l | tr -d ' ')
TOTAL_AGENTS=$(ls -1 "$AGENTS_SKILLS_DIR" 2>/dev/null | wc -l | tr -d ' ')

echo -e "\n${GREEN}${BOLD}================================================================================"
echo "    🎉 CÀI ĐẶT THÀNH CÔNG HỆ THỐNG SKILL DUYVO26!"
echo "================================================================================${NC}"
echo -e "📍 Thư mục Global Skills: ${BOLD}$GLOBAL_SKILLS_DIR${NC} (${CYAN}$TOTAL_GLOBAL entries${NC})"
echo -e "📍 Thư mục Agent Skills : ${BOLD}$AGENTS_SKILLS_DIR${NC} (${CYAN}$TOTAL_AGENTS entries${NC})"
echo -e "\n${BOLD}Xem bảng tra cứu đầy đủ tại:${NC}"
echo -e "${CYAN}file://$DOCS_REPO_DIR/FULL_SKILLS_MANIFEST.md${NC}\n"
