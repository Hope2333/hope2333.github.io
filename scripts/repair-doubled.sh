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
#   RootDir 注释回落 / → 审计式归位（见下）→ 复检 → 打印摘要。
# 任何一步失败：红字报错 + 保留现场 + 指向 fix20 手动脚本，不静默吞错。
#
# 归位为何是「审计式」而不是整集重装（oscar 实测修订，2026-10-04）：
#   受影响集合含 glibc / bash / openssh / python / zsh / git —— 在 3.18 机上
#   这些正是承载 ssh 通道的自身包，`pacman -S <整集>` 会把承载通道一起砸掉。
#   故先逐条审计（叠影副本 vs db mtree），再按结论动作：
#     STALE=0 → 只做 rename 归位（零包管理事务、零网络）
#     STALE≠0 → 仅该 STALE 包才单包 pacman -S --overwrite 重装
#   审计判据两类条目都要比（缺一即判 STALE）：
#     正则文件 → 比 sha256digest；软链 → 比 db 记录的 link 目标
#     （db mtree 里软链无 sha256digest，只按摘要过滤会静默丢掉全部软链 ——
#      oscar 首轮就漏了 980 个：htop copyright / git libexec / libmd man）

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

# 审计：把受影响包的每个 db 条目分成
#   OK         正确路径已有实体
#   RESTORABLE 正确路径缺失 + 叠影副本在 + 内容/链接目标与 db 相符 → 纯 rename 可还原
#   STALE      叠影副本在但与 db 不符（或条目缺判据）→ rename 会落错内容，须重装
#   ABSENT     正确路径与叠影皆无
# 末行打印 "AUDIT <ok> <restorable> <stale> <absent> <link>"。
audit_shadow() { # $1=受影响包(空格分隔)  $2=叠影顶层(空格分隔)  $3=工作目录
    local pkgs="$1" tops="$2" wd="$3"
    local dbdir="$P/var/lib/pacman/local"
    local TAB p d t eff
    TAB=$(printf '\t')
    mkdir -p "$wd" || return 1
    : >"$wd/db.tab"; : >"$wd/shadow.sorted"

    for p in $pkgs; do
        d=$(ls -d "$dbdir/$p-"* 2>/dev/null | head -1)
        [ -n "$d" ] || continue
        gzip -dc "$d/mtree" 2>/dev/null | LC_ALL=C awk -v pkg="$p" -v pfx="$P/" '
            # mtree 把空格/反斜杠写成八进制转义（\040 / \134），原样比较永远落空
            function unesc(s,  out,i,c,n,o) {
                out = ""; n = length(s); i = 1
                while (i <= n) {
                    c = substr(s, i, 1)
                    if (c == "\\" && i < n) {
                        c = substr(s, ++i, 1)
                        if (c ~ /^[0-7]$/) {
                            o = c
                            while (length(o) < 3 && substr(s, i+1, 1) ~ /^[0-7]$/) o = o substr(s, ++i, 1)
                            out = out sprintf("%c", o + 0)
                        } else out = out c
                    } else out = out c
                    i++
                }
                return out
            }
            /^#/ { next }
            /^\.\// {
                path = unesc(substr($1, 3))
                if (index("/" path, pfx) != 1) next
                typ = ""; sum = ""; lnk = ""
                for (i = 2; i <= NF; i++) {
                    if      ($i ~ /^type=/)          { typ = substr($i, 6) }
                    else if ($i ~ /^sha256digest=/) { sum = substr($i, 14) }
                    else if ($i ~ /^link=/)         { lnk = unesc(substr($i, 6)) }
                }
                if (typ == "dir") next
                if (typ == "link") {
                    kind = "L"; expect = lnk
                } else if (sum != "") {
                    kind = "F"; expect = sum
                } else {
                    kind = "U"; expect = ""     # 无摘要且无 link 目标 = 无判据
                }
                printf "/%s\t%s\t%s\t%s\n", path, kind, expect, pkg
            }'
    done >"$wd/db.tab"

    find "$P" \( -type f -o -type l \) -print 2>/dev/null | LC_ALL=C sort >"$wd/exist.sorted"

    # 叠影清单，按它对应的 db 路径建键（叠影路径 = <原 RootDir> + db 路径）
    for t in $tops; do
        eff="${t%/data}"
        find "$t" \( -type f -printf "%p\tf\t\t%p\n" -o -type l -printf "%p\tl\t%l\t%p\n" \) 2>/dev/null \
            | awk -F"$TAB" -v OFS="$TAB" -v eff="$eff" '{ $1 = substr($1, length(eff) + 1); print }' \
            | LC_ALL=C sort -t"$TAB" -k1,1 >>"$wd/shadow.sorted"
    done

    LC_ALL=C sort -t"$TAB" -k1,1 "$wd/db.tab" >"$wd/db.sorted"
    join -t"$TAB" -1 1 -2 1 -v1 -o 1.1,1.2,1.3,1.4 \
        "$wd/db.sorted" "$wd/exist.sorted" >"$wd/missing.sorted" 2>/dev/null || true
    join -t"$TAB" -1 1 -2 1 -o 1.1,1.2,1.3,1.4,2.2,2.3,2.4 \
        "$wd/missing.sorted" "$wd/shadow.sorted" >"$wd/paired.tab" 2>/dev/null || true

    # 正则候选批量取 sha256（一次 xargs 批量，而非每文件一次进程）
    awk -F"$TAB" '$2 == "F" && $5 == "f" { print $7 }' "$wd/paired.tab" \
        | LC_ALL=C sort -u >"$wd/dig-args"
    : >"$wd/dig.tab"
    if [ -s "$wd/dig-args" ]; then
        tr '\n' '\0' <"$wd/dig-args" \
            | xargs -0 -r -n 200 sha256sum 2>/dev/null \
            | awk '{ if (substr($0,1,1) == "\\") next
                     printf "%s\t%s\n", substr($0, 67), substr($0, 1, 64) }' >>"$wd/dig.tab"
    fi

    LC_ALL=C awk -F"$TAB" -v OFS="$TAB" '
        NR == FNR { if (NF >= 2) dig[$1] = $2; next }
        {
            absp = $1; kind = $2; expect = $3; pkg = $4; st = $5; lnk = $6; full = $7
            if (st == "") { print "ABSENT", pkg, absp, ""; next }
            if (kind == "L") {
                if (expect != "" && st == "l" && lnk == expect) print "RESTORABLE", pkg, absp, expect
                else print "STALE", pkg, absp, expect
                next
            }
            if (kind == "F") {
                if (st == "f" && expect != "" && dig[full] == expect) print "RESTORABLE", pkg, absp, ""
                else print "STALE", pkg, absp, expect
                next
            }
            print "STALE", pkg, absp, ""     # 无判据条目：缺一即判 STALE
        }' "$wd/dig.tab" "$wd/paired.tab" >"$wd/classified.tab"

    local ndb nmiss
    ndb=$(wc -l <"$wd/db.tab"); nmiss=$(wc -l <"$wd/missing.sorted")
    printf 'AUDIT %d %d %d %d %d\n' \
        "$((ndb - nmiss))" \
        "$(grep -c '^RESTORABLE' "$wd/classified.tab" || true)" \
        "$(grep -c '^STALE' "$wd/classified.tab" || true)" \
        "$(grep -c '^ABSENT' "$wd/classified.tab" || true)" \
        "$(awk -F"$TAB" '$1=="RESTORABLE" && $4!=""' "$wd/classified.tab" | wc -l)"
}

# 反查受影响包：叠影文件三键形（双叠直录 / 剥 RootDir 补 / / 剥 RootDir 相对）
# 与 pacman -Ql 求交（同 fix20 [17]）
affected_pkgs() {
    local tops="$1" rel_list eff_root rel_raw
    rel_list=$(mktemp) || return 1
    # 先收集再统一排序去重：多叠影顶层时逐轮 `sort -u >` 会互相覆盖，
    # 只剩最后一个 top 的清单（漏检另一 top 的受影响包）
    rel_raw="$rel_list.raw"
    : >"$rel_raw"
    for t in $tops; do
        eff_root="${t%/data}"
        find "$t" -type f 2>/dev/null | while IFS= read -r f; do
            printf '%s\n' "$f"
            strip="${f#"$eff_root"}"
            printf '/%s\n%s\n' "$strip" "$strip"
        done >>"$rel_raw"
    done
    sort -u "$rel_raw" >"$rel_list"
    rm -f "$rel_raw"
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

repair() { # $1 = tops, $2 = affected list
    local tops="$1" affected="$2" before after
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
    # 步骤 2：审计式归位 —— STALE=0 只 rename，STALE≠0 才单包重装
    say "  [2/3] 审计（叠影副本 vs db mtree 逐条比对）..."
    local wd line a_ok a_rest a_stale a_absent a_link
    wd=$(mktemp -d) || fail "无法创建审计工作目录"
    line=$(audit_shadow "$affected" "$tops" "$wd" || true)
    case "$line" in
        AUDIT\ *) ;;
        *) rm -rf "$wd"; fail "审计未产出统计（db mtree 不可读？）" ;;
    esac
    set -- $line
    a_ok=$2; a_rest=$3; a_stale=$4; a_absent=$5; a_link=$6
    say "      OK=$a_ok RESTORABLE=$a_rest STALE=$a_stale ABSENT=$a_absent（RESTORABLE 中软链 $a_link）"
    local need_reinstall rel_failed rel_conflict p
    need_reinstall=$(awk -F"$(printf '\t')" '$1=="STALE" || $1=="ABSENT" {print $2}' \
        "$wd/classified.tab" 2>/dev/null | sort -u)
    rel_failed=""; rel_conflict=""
    if [ "${a_rest:-0}" -gt 0 ] 2>/dev/null; then
        say "      STALE=0 的部分：只做 rename 归位（零包管理事务、零网络）"
        while IFS="$(printf '\t')" read -r cls pkg absp link; do
            [ "$cls" = "RESTORABLE" ] || continue
            [ -n "$absp" ] || continue
            mkdir -p "$(dirname "$absp")" 2>/dev/null || true
            if [ -n "$link" ]; then
                # 软链：db 记录了 link 目标（无摘要），按目标重建
                ln -sfn "$link" "$absp" 2>/dev/null || rel_failed="$rel_failed $pkg"
            else
                # 目标已存在同名文件时以 db 记录路径为准，被占条目降级为单包重装
                if [ -e "$absp" ] || [ -L "$absp" ]; then
                    rel_conflict="$rel_conflict $pkg"
                    continue
                fi
                local shadow="" t cand
                for t in $tops; do
                    cand="${t%/data}/${absp#/}"
                    if [ -f "$cand" ]; then shadow="$cand"; break; fi
                done
                [ -n "$shadow" ] || { rel_failed="$rel_failed $pkg"; continue; }
                mv -f "$shadow" "$absp" 2>/dev/null || rel_failed="$rel_failed $pkg"
            fi
        done <"$wd/classified.tab"
    fi
    [ -n "$rel_failed" ] && fail "rename 归位失败:$(printf '%s' "$rel_failed" | tr ' ' '\n' | sed '/^$/d;s/^/ /' | tr -d '\n')"
    # 冲突项与 STALE/ABSENT 一并按单包重装处理（绝不整集重装）
    need_reinstall=$(printf '%s\n%s\n' "$need_reinstall" "$rel_conflict" | tr ' ' '\n' | sed '/^$/d' | sort -u)
    if [ -z "$need_reinstall" ]; then
        say "      无 STALE/ABSENT/冲突包：全程零包管理事务、零网络"
    else
        say "      需重装的包（STALE/ABSENT/冲突，逐包单包重装）:$(printf '%s' "$need_reinstall" | tr '\n' ' ')"
        for p in $need_reinstall; do
            # shellcheck disable=SC2086
            pacman -S --noconfirm --overwrite '*' "$p" >>"$LOG" 2>&1 \
                || { rm -rf "$wd"; fail "单包重装失败：$p（详见 $LOG）"; }
        done
    fi
    rm -rf "$wd"
    # 步骤 3：复检（叠影不得因归位而增长 + 各包 -Qk 通过）
    before=$(find $tops -type f 2>/dev/null | wc -l)
    say "  [3/3] 归位复检..."
    local qfail=""
    for p in $affected; do
        pacman -Qk "$p" >/dev/null 2>&1 || qfail="$qfail $p"
    done
    [ -n "$qfail" ] \
        && fail "归位复检失败（正确路径下仍有文件缺失）:$(printf '%s' "$qfail" | tr ' ' '\n' | sed '/^$/d;s/^/ /' | tr -d '\n')"
    after=$(find $tops -type f 2>/dev/null | wc -l)
    [ "$after" -le "$before" ] \
        || fail "归位仍向叠影写入（+$((after - before)) 文件）——源内尚无绝对约定重打包，请等待 repack 版后重试"
    say "${GREEN}✓ [3/3] 归位并复检通过${NC}"
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
    repair "$tops" "$affected"
}

main "$@"
