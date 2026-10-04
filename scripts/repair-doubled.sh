#!/data/data/com.termux/files/usr/bin/bash
# hope2333 repair-doubled.sh — pacman 叠影病灶静默检测 + 自动修复（离线，不依赖网络）
#
# 由 hope2333-mirrorlist 包携带（安装于 $PREFIX/lib/hope2333/repair-doubled.sh），
# 经 .INSTALL post_install/post_upgrade 在包更新时静默调用；
# 也可手动直接运行（bash repair-doubled.sh）。
# 修复语义与 opencode-termux packing/init-pacmanV00fix20.sh 的 [17]-[19] 对齐；
# 本脚本修复失败时保留现场并指向 fix20 手动脚本。
#
# 检测判据（用户订正 2026-10-04）：
#   递归检出 <RootDir>/data/data/com.termux/files/usr 子树存在且非空
#   （子树内存在实体文件才算病灶，空壳不算），且满足以下其一：
#   a) RootDir 仍为非 "/" 活动态（绝对路径包会继续装入叠影）；
#   b) 存在「正确路径缺文件」的受影响包（pacman -Qk 不过，真正装坏）。
#   仅剩冗余副本（RootDir 已回落且各包 -Qk 全过）= 健康，静默跳过。
# 自动修复流程：
#   RootDir 注释回落 / → 反查受影响包重装归位（--overwrite）→ 复检叠影 → 打印摘要。
# 任何一步失败：红字报错 + 保留现场 + 指向 fix20 手动脚本，不静默吞错。

P="${PREFIX:-/data/data/com.termux/files/usr}"
PACMAN_CONF="$P/etc/pacman.conf"
DB_LCK="$P/var/lib/pacman/db.lck"
LOG="$HOME/hope2333-repair.log"
FIX20_URL="https://github.com/Hope2333/opencode-termux/releases/download/EarlyEmergencyRelease0/init-pacmanV00fix20.sh"
RED=$'\033[31m'; GREEN=$'\033[32m'; NC=$'\033[0m'

# 输出：stdout + 尽力写入控制 tty（延迟模式下 stdout 已落日志）
say() {
    printf '%s\n' "$*"
    { [ -c /dev/tty ] && [ -w /dev/tty ]; } 2>/dev/null && \
        { printf '%s\n' "$*" >/dev/tty; } 2>/dev/null
    return 0
}
fail() {
    say "${RED}  !! $*${NC}"
    say "${RED}  !! 自动修复中止（现场已保留，未删除任何文件）。手动修复:${NC}"
    say "${RED}     bash <(curl -sL ${FIX20_URL})${NC}"
    exit 1
}

# ── 叠影顶层（与 fix20 shadow_tops 同语义）──────────────────────────────
# 顶层 = <RootDir>/data；判病须子树 data/com.termux/files/usr 内有实体文件。
shadow_tops() {
    local c root_data
    root_data=$(cd "$P/.." 2>/dev/null && pwd)/data
    for c in "$root_data" "$P/data"; do
        if [ -d "$c/data/com.termux/files/usr" ] && \
           [ -n "$(find "$c/data/com.termux/files/usr" -type f -print -quit 2>/dev/null)" ]; then
            printf '%s\n' "$c"
        fi
    done
}

rootdir_active() {
    local rd rdv
    rd=$(grep -E '^[[:space:]]*RootDir[[:space:]]*=' "$PACMAN_CONF" 2>/dev/null | head -n1)
    [ -n "$rd" ] || return 1
    rdv=$(printf '%s' "${rd#*=}" | tr -d '[:space:]')
    [ -n "$rdv" ] && [ "$rdv" != "/" ]
}

# 反查受影响包：叠影文件三键形（双叠直录 / 剥 RootDir 补 / / 剥 RootDir 相对）
# 与 pacman -Ql 求交（同 fix20 [17]）
affected_pkgs() {
    local tops="$1" rel_list eff_root
    rel_list=$(mktemp) || return 1
    for t in $tops; do
        eff_root="${t%/data}"
        find "$t" -type f 2>/dev/null | while IFS= read -r f; do
            printf '%s\n' "$f"
            strip="${f#"$eff_root"}"
            printf '/%s\n%s\n' "$strip" "$strip"
        done | sort -u > "$rel_list"
    done
    pacman -Ql 2>/dev/null | awk '{ pkg=$1; $1=""; sub(/^ /,""); print $0 "\t" pkg }' \
        | sort | join -t "$(printf '\t')" - "$rel_list" 2>/dev/null \
        | cut -f2 | sort -u
    rm -f "$rel_list"
}

# 病灶中真正装坏的包：正确路径缺文件（-Qk 不过）
broken_pkgs() { # $1 = affected list
    local broken="" p
    for p in $1; do
        pacman -Qk "$p" >/dev/null 2>&1 || broken="$broken $p"
    done
    printf '%s' "$broken"
}

repair() { # $1 = tops, $2 = broken list
    local tops="$1" broken="$2" before after
    say "── hope2333 叠影自动修复 $(date '+%F %T') ──"
    # 步骤 1：RootDir 注释回落 /
    if rootdir_active; then
        cp "$PACMAN_CONF" "$PACMAN_CONF.bak.repair" 2>/dev/null
        sed -i -E 's|^([[:space:]]*RootDir[[:space:]]*=)|#\1|' "$PACMAN_CONF" \
            || fail "RootDir 注释失败（$PACMAN_CONF 写保护？）"
        say "${GREEN}✓ [1/3] RootDir 已注释回落默认 /（原配置备份于 $PACMAN_CONF.bak.repair）${NC}"
    else
        say "  [1/3] RootDir 已是回落态（/），跳过注释"
    fi
    # 步骤 2：仅重装「正确路径缺文件」的包
    if [ -z "$broken" ]; then
        say "  [2/3] 受影响包在正确路径下文件齐全（叠影内均为冗余副本），无需重装"
    else
        say "  [2/3] 受影响包（正确路径缺文件，待归位）:$(printf '%s' "$broken" | tr ' ' '\n' | sed '/^$/d;s/^/ /' | tr -d '\n')"
        before=$(find $tops -type f 2>/dev/null | wc -l)
        # shellcheck disable=SC2086
        pacman -S --noconfirm --overwrite '*' $broken >>"$LOG" 2>&1 \
            || fail "重装事务失败（详见 $LOG）"
        after=$(find $tops -type f 2>/dev/null | wc -l)
        [ "$after" -le "$before" ] \
            || fail "重装仍向叠影写入（+$(($after - $before)) 文件）——源内尚无绝对约定重打包，请等待 repack 版后重试"
        local p
        for p in $broken; do
            pacman -Qk "$p" >/dev/null 2>&1 \
                || fail "归位复检失败：$p 在正确路径下仍有文件缺失"
        done
        say "${GREEN}✓ [3/3] 归位并复检通过: $(printf '%s' "$broken" | sed 's/^ //;s/ /, /g')${NC}"
    fi
    say "${GREEN}── 修复完成：RootDir 回落 /，叠影复检通过 ──${NC}"
    say "  残留叠影副本确认无用后可清理: rm -rf $(printf '%s' "$tops" | tr '\n' ' ')"
    say "  完整清理/自检流程: bash <(curl -sL ${FIX20_URL})"
}

main() {
    [ -f "$PACMAN_CONF" ] || exit 0
    tops=$(shadow_tops)
    [ -n "$tops" ] || exit 0   # 无叠影子树：健康，静默
    affected=$(affected_pkgs "$tops")
    broken=$(broken_pkgs "$affected")
    if ! rootdir_active && [ -z "$broken" ]; then
        exit 0   # 仅剩冗余副本（RootDir 已回落且无缺文件包）：健康，静默
    fi
    if [ -z "$affected" ] && rootdir_active; then
        # 叠影文件不匹配任何已装包：历史残留；仅收敛 RootDir 配置
        say "── hope2333 叠影自动修复 $(date '+%F %T') ──"
        rootdir_active && sed -i -E 's|^([[:space:]]*RootDir[[:space:]]*=)|#\1|' "$PACMAN_CONF"
        say "${GREEN}✓ RootDir 已注释回落 /；叠影文件不匹配任何已装包（历史残留），无需重装${NC}"
        say "  清理: rm -rf $(printf '%s' "$tops" | tr '\n' ' ')  或运行 fix20: bash <(curl -sL ${FIX20_URL})"
        exit 0
    fi
    # 在 pacman 事务内（.INSTALL hook 调用）锁被持有：派生延迟进程，
    # 待 pacman 退出释放锁后自动续跑；不在事务内则同步执行。
    if [ -e "$DB_LCK" ] && [ "${1:-}" != "--now" ]; then
        say "${RED}检测到 pacman 叠影病灶——已调度自动修复（pacman 退出后执行），日志: $LOG${NC}"
        ( sleep 3; exec bash "$0" --now >>"$LOG" 2>&1 ) &
        exit 0
    fi
    if [ "${1:-}" = "--now" ]; then
        # 等锁（最多 300s）：保险，正常应已释放
        local i=0
        while [ -e "$DB_LCK" ] && [ "$i" -lt 300 ]; do sleep 2; i=$((i + 2)); done
        [ -e "$DB_LCK" ] && fail "pacman 数据库锁等待超时（$DB_LCK 仍存在）"
    fi
    repair "$tops" "$broken"
}

main "$@"
