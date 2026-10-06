-- md-links.lua — 渲染时把站内 .md 链接改写为 .html
-- md 源保持 .md 书写习惯（对作者友好、源码可达），渲染产物指向 html 页面。
-- 只处理站内链接：外链（http/https/mailto/tel）与锚点原样；非 .md 资源不动。
-- 注意：Lua 模式不支持对捕获组加量词，故用子串/find 写法而非 (…)? 捕获。
local function is_internal(t)
  if t:match("^https?://") then return false end
  if t:match("^mailto:") or t:match("^tel:") then return false end
  return true
end

local function md2html(t)
  if not is_internal(t) then return nil end
  local hash = t:find("#", 1, true)
  local target = hash and t:sub(1, hash - 1) or t
  local frag = hash and t:sub(hash) or ""
  if target:sub(-3) ~= ".md" then return nil end
  return target:sub(1, -4) .. ".html" .. frag
end

function Link(el)
  local nt = md2html(el.target)
  if nt then el.target = nt end
  return el
end
