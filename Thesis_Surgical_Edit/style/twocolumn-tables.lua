-- Fix tables for two-column LaTeX output (pandoc 3.x API)
function Table(tbl)
  local caption_text = ''
  if tbl.caption and tbl.caption.long and #tbl.caption.long > 0 then
    local parts = {}
    for _, block in ipairs(tbl.caption.long) do
      if block.content then
        for _, inline in ipairs(block.content) do
          if inline.text then table.insert(parts, inline.text) end
        end
      end
    end
    if #parts > 0 then caption_text = '\\caption{' .. table.concat(parts) .. '}' end
  end

  local cols = ''
  for _, align in ipairs(tbl.column_alignment) do
    if align == 'AlignLeft' then cols = cols .. 'l'
    elseif align == 'AlignRight' then cols = cols .. 'r'
    elseif align == 'AlignCenter' then cols = cols .. 'c'
    else cols = cols .. 'l'
    end
  end

  local all_rows = {}
  -- Header
  if tbl.header and #tbl.header > 0 then
    local cells = {}
    for _, cell in ipairs(tbl.header) do
      local text = ''
      if cell.content then
        for _, block in ipairs(cell.content) do
          if block.content then
            for _, inline in ipairs(block.content) do
              if inline.text then text = text .. inline.text end
            end
          end
        end
      end
      table.insert(cells, '\\textbf{' .. text .. '}')
    end
    table.insert(all_rows, '    ' .. table.concat(cells, ' & ') .. ' \\\\')
  end

  -- Body rows
  for _, row in ipairs(tbl.rows) do
    local cells = {}
    for _, cell in ipairs(row) do
      local text = ''
      if cell.content then
        for _, block in ipairs(cell.content) do
          if block.content then
            for _, inline in ipairs(block.content) do
              if inline.text then text = text .. inline.text end
            end
          end
        end
      end
      table.insert(cells, text)
    end
    table.insert(all_rows, '    ' .. table.concat(cells, ' & ') .. ' \\\\')
  end

  local latex = '\\begin{table*}[t]\n\\centering\n'
  if caption_text ~= '' then latex = latex .. caption_text .. '\n' end
  latex = latex .. '\\begin{tabular}{|' .. cols .. '|}\n\\hline\n'
  latex = latex .. table.concat(all_rows, '\n') .. '\n'
  latex = latex .. '\\hline\n\\end{tabular}\n\\end{table*}'

  return pandoc.RawBlock('latex', latex)
end
